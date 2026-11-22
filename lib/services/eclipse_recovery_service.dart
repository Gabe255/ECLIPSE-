import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// A read-only inspection of a folder that may contain an ECLIPSE user-data
/// database. Inspecting a candidate never changes the folder or its database.
class RecoveryFolderInspection {
  const RecoveryFolderInspection({
    required this.folderPath,
    required this.isValid,
    this.issue,
    this.schemaVersion,
    this.databaseBytes,
    this.lastModified,
  });

  final String folderPath;
  final bool isValid;
  final String? issue;
  final int? schemaVersion;
  final int? databaseBytes;
  final DateTime? lastModified;

  String get summary {
    if (!isValid) return issue ?? 'This folder is not a valid ECLIPSE data folder.';
    final size = databaseBytes == null
        ? 'unknown size'
        : '${(databaseBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
    final version = schemaVersion == null ? 'unknown' : 'v$schemaVersion';
    return 'ECLIPSE database found ($size, database schema $version).';
  }
}

/// Validates existing user-data folders before ECLIPSE reconnects to them.
///
/// The inspection is read-only: it checks SQLite integrity and the core ECLIPSE
/// tables before the setup wizard changes the configured data path.
class EclipseRecoveryService {
  EclipseRecoveryService._();

  static Future<RecoveryFolderInspection> inspectUserDataFolder(
    String folderPath,
  ) async {
    final normalized = path.normalize(path.absolute(folderPath));
    final databaseFile = File(path.join(normalized, 'data.sqlite'));

    if (!await databaseFile.exists()) {
      return RecoveryFolderInspection(
        folderPath: normalized,
        isValid: false,
        issue: 'No data.sqlite file was found in this folder.',
      );
    }

    try {
      final bytes = await databaseFile.length();
      final modified = await databaseFile.lastModified();
      final database = sqlite.sqlite3.open(
        databaseFile.path,
        mode: sqlite.OpenMode.readOnly,
      );
      try {
        final integrity = database.select('PRAGMA quick_check');
        if (integrity.length != 1 ||
            integrity.single.values.single.toString() != 'ok') {
          return RecoveryFolderInspection(
            folderPath: normalized,
            isValid: false,
            issue: 'The database did not pass SQLite integrity checks.',
            databaseBytes: bytes,
            lastModified: modified,
          );
        }

        final tables = database
            .select("SELECT name FROM sqlite_master WHERE type = 'table'")
            .map((row) => row['name'].toString())
            .toSet();
        const requiredTables = {'user_config', 'app_systems'};
        final missing = requiredTables.difference(tables);
        if (missing.isNotEmpty) {
          return RecoveryFolderInspection(
            folderPath: normalized,
            isValid: false,
            issue:
                'This database is missing required ECLIPSE tables: ${missing.join(', ')}.',
            databaseBytes: bytes,
            lastModified: modified,
          );
        }

        final configRows = database.select('SELECT id FROM user_config LIMIT 1');
        if (configRows.isEmpty) {
          return RecoveryFolderInspection(
            folderPath: normalized,
            isValid: false,
            issue: 'The ECLIPSE user configuration record is missing.',
            databaseBytes: bytes,
            lastModified: modified,
          );
        }

        final versionRows = database.select('PRAGMA user_version');
        final schemaVersion = versionRows.isEmpty
            ? null
            : int.tryParse(versionRows.single.values.single.toString());

        return RecoveryFolderInspection(
          folderPath: normalized,
          isValid: true,
          schemaVersion: schemaVersion,
          databaseBytes: bytes,
          lastModified: modified,
        );
      } finally {
        database.close();
      }
    } catch (error) {
      return RecoveryFolderInspection(
        folderPath: normalized,
        isValid: false,
        issue: 'The database could not be opened or checked: $error',
      );
    }
  }
}
