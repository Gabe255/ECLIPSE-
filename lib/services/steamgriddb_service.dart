import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../data/datasources/sqlite_service.dart';
import '../services/config_service.dart';
import '../services/credential_store.dart';
import '../services/logger_service.dart';
import '../services/screenscraper/rom_hasher.dart';
import '../utils/atomic_file_writer.dart';

/// Optional SteamGridDB artwork provider. Existing media is never overwritten.
class SteamGridDbService {
  static const _credentialKey = 'steamgriddb_api_key';
  static const _apiRoot = 'https://www.steamgriddb.com/api/v2';
  static final _log = LoggerService.instance;
  static http.Client? _clientOverride;

  @visibleForTesting
  static void debugUseHttpClient(http.Client? client) {
    _clientOverride = client;
  }

  static Future<bool> saveApiKey(String key) async {
    final value = key.trim();
    if (value.isEmpty) return false;
    final outcome = await CredentialStore.write(_credentialKey, value);
    return outcome != CredentialWriteOutcome.sessionOnly;
  }

  static Future<bool> hasApiKey() async {
    try {
      final key = await CredentialStore.read(_credentialKey);
      return key != null && key.trim().isNotEmpty;
    } catch (e) {
      _log.e('SteamGridDB: Could not read saved API key', error: e);
      return false;
    }
  }

  static Future<void> clearApiKey() => CredentialStore.delete(_credentialKey);

  /// Scrapes the ROM library, filling absent box art, heroes, logos and icons.
  /// Returns the number of games for which at least one file was saved.
  static Future<int> scrapeLibrary({
    void Function(int done, int total)? onProgress,
  }) async {
    final apiKey = (await CredentialStore.read(_credentialKey))?.trim();
    if (apiKey == null || apiKey.isEmpty) return 0;

    final db = await SqliteService.getDatabase();
    final games = await db.rawQuery('''
      SELECT ur.app_system_id, ur.filename, s.folder_name,
             COALESCE(NULLIF(m.real_name, ''), '') AS game_title
      FROM user_roms ur
      JOIN app_systems s ON s.id = ur.app_system_id
      LEFT JOIN user_screenscraper_metadata m
        ON m.app_system_id = ur.app_system_id
       AND m.filename = ur.filename COLLATE NOCASE
      WHERE s.folder_name IS NOT NULL AND s.folder_name != ''
      ORDER BY s.folder_name, ur.filename
    ''');

    var updated = 0;
    for (var index = 0; index < games.length; index++) {
      final game = games[index];
      try {
        final filename = game['filename']?.toString() ?? '';
        final systemFolder = game['folder_name']?.toString() ?? '';
        final systemId = game['app_system_id']?.toString();
        final metadataTitle = game['game_title']?.toString() ?? '';
        if (filename.isNotEmpty && systemFolder.isNotEmpty) {
          final changed = await _scrapeGame(
            apiKey: apiKey,
            titleCandidates: await _titleCandidates(
              metadataTitle,
              filename,
              systemId,
            ),
            systemFolder: systemFolder,
            filename: filename,
            systemId: systemId,
          );
          if (changed) updated++;
        }
      } catch (e) {
        _log.w('SteamGridDB: Skipped ${game['filename']}: $e');
        final message = e.toString().toLowerCase();
        if (message.contains('rate limit') ||
            message.contains('rejected the api key')) {
          break;
        }
      } finally {
        onProgress?.call(index + 1, games.length);
      }
    }

    _log.i('SteamGridDB: Updated artwork for $updated of ${games.length} games.');
    return updated;
  }

  static Future<List<String>> _titleCandidates(
    String metadataTitle,
    String filename,
    String? systemId,
  ) async {
    final candidates = <String>[];
    final metadata = _cleanTitle(metadataTitle);
    if (metadata.isNotEmpty) candidates.add(metadata);
    final romName = await ScreenscraperRomHasher.getCleanRomName(
      path.basename(filename),
      systemId,
    );
    final fromFilename = _cleanTitle(romName);
    if (fromFilename.isNotEmpty &&
        !candidates.any((value) => _normalizeTitle(value) == _normalizeTitle(fromFilename))) {
      candidates.add(fromFilename);
    }
    return candidates;
  }

  @visibleForTesting
  static String debugCleanTitle(String value) => _cleanTitle(value);

  static String _cleanTitle(String value) => value
      .replaceAll(RegExp(r'[_]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String _normalizeTitle(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static Future<bool> _scrapeGame({
    required String apiKey,
    required List<String> titleCandidates,
    required String systemFolder,
    required String filename,
    required String? systemId,
  }) async {
    final mediaRoot = await ConfigService.getMediaPath();
    final safeSystemFolder = path.basename(systemFolder);
    final cleanRomName = await ScreenscraperRomHasher.getCleanRomName(
      path.basename(filename),
      systemId,
    );
    final safeRomName = path.basenameWithoutExtension(cleanRomName);
    if (safeRomName.isEmpty) return false;

    final targets = <String, String>{
      'grids': path.join(mediaRoot, safeSystemFolder, 'box2d', safeRomName),
      'heroes': path.join(mediaRoot, safeSystemFolder, 'fanarts', safeRomName),
      'logos': path.join(mediaRoot, safeSystemFolder, 'wheels', safeRomName),
      'icons': path.join(mediaRoot, safeSystemFolder, 'icons', safeRomName),
    };

    final missing = <String>[];
    for (final entry in targets.entries) {
      if (!await _hasImage(entry.value)) missing.add(entry.key);
    }
    if (missing.isEmpty || titleCandidates.isEmpty) return false;

    Map<String, dynamic>? matchedGame;
    for (final title in titleCandidates) {
      final search = await _apiGet(
        '/search/autocomplete/${Uri.encodeComponent(title)}',
        apiKey,
      );
      final data = search['data'];
      if (data is! List) continue;
      final normalized = _normalizeTitle(title);
      for (final candidate in data.whereType<Map>()) {
        if (_normalizeTitle(candidate['name']?.toString() ?? '') == normalized) {
          matchedGame = Map<String, dynamic>.from(candidate);
          break;
        }
      }
      if (matchedGame != null) break;
    }
    final gameId = matchedGame?['id'];
    if (gameId == null) return false;

    var changed = false;
    for (final type in missing) {
      final query = type == 'grids' ? '?dimensions=600x900' : '';
      final response = await _apiGet('/$type/game/$gameId$query', apiKey);
      final entries = response['data'];
      if (entries is! List) continue;

      for (final rawEntry in entries) {
        if (rawEntry is! Map) continue;
        final imageUrl = rawEntry['url']?.toString() ?? '';
        if (imageUrl.isEmpty) continue;
        final extension = _extensionFor(imageUrl, type);
        final destination = '${targets[type]}.$extension';
        if (await _downloadImage(imageUrl, destination)) {
          changed = true;
          break;
        }
      }
    }
    return changed;
  }

  static Future<Map<String, dynamic>> _apiGet(
    String endpoint,
    String apiKey,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final uri = Uri.parse('$_apiRoot$endpoint');
    final response = await (_clientOverride?.get(
              uri,
              headers: {'Authorization': 'Bearer $apiKey'},
            ) ??
            http.get(uri, headers: {'Authorization': 'Bearer $apiKey'}))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const HttpException('SteamGridDB rejected the API key.');
    }
    if (response.statusCode == 429) {
      throw const HttpException('SteamGridDB rate limit reached. Try again later.');
    }
    if (response.statusCode != 200) {
      throw HttpException('SteamGridDB returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid SteamGridDB response.');
    }
    if (decoded['success'] == false) {
      throw HttpException(
        'SteamGridDB request failed: ${decoded['errors'] ?? 'unknown error'}',
      );
    }
    return decoded;
  }

  static String _extensionFor(String url, String type) {
    final uri = Uri.tryParse(url);
    final extension = uri == null
        ? ''
        : path.extension(uri.path).replaceFirst('.', '').toLowerCase();
    if (const {'png', 'jpg', 'jpeg', 'webp'}.contains(extension)) {
      return extension;
    }
    return type == 'logos' || type == 'icons' ? 'png' : 'jpg';
  }

  static Future<bool> _hasImage(String basePath) async {
    for (final extension in const ['png', 'jpg', 'jpeg', 'webp']) {
      if (await File('$basePath.$extension').exists()) return true;
    }
    return false;
  }

  static Future<bool> _downloadImage(String url, String destination) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
      if (await _hasImage(path.withoutExtension(destination))) return false;

      final response = await (_clientOverride?.get(uri) ?? http.get(uri))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return false;

      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.isNotEmpty && !contentType.startsWith('image/')) {
        _log.w('SteamGridDB: Refusing non-image response for $url');
        return false;
      }

      final file = File(destination);
      await file.parent.create(recursive: true);
      await writeFileAtomically(file, response.bodyBytes);
      return true;
    } catch (e) {
      _log.w('SteamGridDB: Artwork download failed: $e');
      return false;
    }
  }
}
