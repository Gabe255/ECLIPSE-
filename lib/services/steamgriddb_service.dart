import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../data/datasources/sqlite_service.dart';
import '../services/config_service.dart';
import '../services/credential_store.dart';
import '../services/logger_service.dart';
import '../utils/atomic_file_writer.dart';

/// SteamGridDB artwork provider. It only fills missing artwork, so it never
/// overwrites a user's files or artwork supplied by another scraper.
class SteamGridDbService {
  static const _credentialKey = 'steamgriddb_api_key';
  static const _apiRoot = 'https://www.steamgriddb.com/api/v2';
  static final _log = LoggerService.instance;
  static http.Client? _clientOverride;

  @visibleForTesting
  static void debugUseHttpClient(http.Client? client) {
    _clientOverride = client;
  }

  static Future<http.Response> _get(Uri uri, String apiKey,
      {bool image = false}) {
    final client = _clientOverride;
    final request = client?.get(uri) ?? http.get(uri);
    return request.timeout(Duration(seconds: image ? 60 : 20));
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

  /// Scrapes all library entries with a system folder, filling only absent
  /// box art, fanart, logos, and icons. Returns the number of games updated.
  static Future<int> scrapeLibrary({void Function(int done, int total)? onProgress}) async {
    final apiKey = await CredentialStore.read(_credentialKey);
    if (apiKey == null || apiKey.trim().isEmpty) return 0;

    final db = await SqliteService.getDatabase();
    final games = await db.rawQuery('''
      SELECT ur.app_system_id, ur.filename, s.folder_name,
             COALESCE(NULLIF(m.real_name, ''), ur.filename) AS game_title
      FROM user_roms ur
      JOIN app_systems s ON s.id = ur.app_system_id
      LEFT JOIN user_screenscraper_metadata m
        ON m.app_system_id = ur.app_system_id
       AND m.filename = ur.filename COLLATE NOCASE
      WHERE s.folder_name IS NOT NULL AND s.folder_name != ''
      ORDER BY s.folder_name, ur.filename
    ''');

    var updated = 0;
    var done = 0;
    for (final game in games) {
      done++;
      try {
        final filename = game['filename']?.toString() ?? '';
        final systemFolder = game['folder_name']?.toString() ?? '';
        final title = game['game_title']?.toString() ?? filename;
        if (filename.isEmpty || systemFolder.isEmpty || title.isEmpty) {
          onProgress?.call(done, games.length);
          continue;
        }
        final changed = await _scrapeGame(
          apiKey: apiKey,
          title: _cleanTitle(title),
          systemFolder: systemFolder,
          filename: filename,
        );
        if (changed) updated++;
      } catch (e) {
        _log.w('SteamGridDB: Skipped ${game['filename']}: $e');
      }
      onProgress?.call(done, games.length);
    }
    _log.i('SteamGridDB: Updated artwork for $updated of ${games.length} games.');
    return updated;
  }

  static String _cleanTitle(String value) {
    final noExtension = value.replaceFirst(RegExp(r'\\.[^.]+$'), '');
    return noExtension
        .replaceAll(RegExp(r'\\s*\\([^)]*\\)|\\s*\\[[^]]*\\]'), '')
        .replaceAll(RegExp(r'[_\\.]+'), ' ')
        .trim();
  }

  static Future<bool> _scrapeGame({
    required String apiKey,
    required String title,
    required String systemFolder,
    required String filename,
  }) async {
    final mediaRoot = await ConfigService.getMediaPath();
    final baseName = path.basenameWithoutExtension(filename);
    final targets = <String, String>{
      'grids': path.join(mediaRoot, systemFolder, 'box2d', baseName),
      'heroes': path.join(mediaRoot, systemFolder, 'fanarts', baseName),
      'logos': path.join(mediaRoot, systemFolder, 'wheels', baseName),
      'icons': path.join(mediaRoot, systemFolder, 'icons', baseName),
    };

    final missing = <String>[];
    for (final entry in targets.entries) {
      if (!await _hasImage(entry.value)) missing.add(entry.key);
    }
    if (missing.isEmpty) return false;

    final search = await _apiGet('/search/autocomplete/' + Uri.encodeComponent(title), apiKey);
    final searchData = search['data'];
    if (searchData is! List || searchData.isEmpty) return false;
    final gameId = searchData.first is Map ? searchData.first['id'] : null;
    if (gameId == null) return false;

    var changed = false;
    for (final type in missing) {
      final data = await _apiGet('/$type/game/$gameId', apiKey);
      final entries = data['data'];
      if (entries is! List || entries.isEmpty || entries.first is! Map) continue;
      final imageUrl = entries.first['url']?.toString();
      if (imageUrl == null || imageUrl.isEmpty) continue;
      final ext = _extensionFor(imageUrl, type);
      final destination = '${targets[type]}.$ext';
      if (await _downloadImage(imageUrl, destination, apiKey)) changed = true;
    }
    return changed;
  }

  static Future<Map<String, dynamic>> _apiGet(String endpoint, String apiKey) async {
    final uri = Uri.parse('$_apiRoot$endpoint');
    final client = _clientOverride;
    final response = await (client?.get(uri, headers: {'Authorization': 'Bearer $apiKey'}) ??
        http.get(uri, headers: {'Authorization': 'Bearer $apiKey'}))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const HttpException('SteamGridDB rejected the API key.');
    }
    if (response.statusCode != 200) {
      throw HttpException('SteamGridDB returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid SteamGridDB response.');
    }
    return decoded;
  }

  static String _extensionFor(String url, String type) {
    final uri = Uri.tryParse(url);
    final ext = uri == null ? '' : path.extension(uri.path).replaceFirst('.', '').toLowerCase();
    if (const {'png', 'jpg', 'jpeg', 'webp'}.contains(ext)) return ext;
    return type == 'logos' || type == 'icons' ? 'png' : 'jpg';
  }

  static Future<bool> _hasImage(String basePath) async {
    for (final ext in const ['png', 'jpg', 'jpeg', 'webp']) {
      if (await File('$basePath.$ext').exists()) return true;
    }
    return false;
  }

  static Future<bool> _downloadImage(String url, String destination, String apiKey) async {
    try {
      final file = File(destination);
      if (await _hasImage(path.withoutExtension(destination))) return false;
      final response = await (_clientOverride?.get(Uri.parse(url)) ?? http.get(Uri.parse(url)))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return false;
      await file.parent.create(recursive: true);
      await writeFileAtomically(file, response.bodyBytes);
      return true;
    } catch (e) {
      _log.w('SteamGridDB: Artwork download failed: $e');
      return false;
    }
  }
}
