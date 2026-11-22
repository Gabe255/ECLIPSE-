import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neostation/services/eclipse_recovery_service.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('EclipseRecoveryService.inspectUserDataFolder', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'eclipse-recovery-test-',
      );
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('rejects a folder without data.sqlite', () async {
      final result = await EclipseRecoveryService.inspectUserDataFolder(
        tempDirectory.path,
      );

      expect(result.isValid, isFalse);
      expect(result.issue, contains('No data.sqlite'));
    });

    test('accepts an intact ECLIPSE database', () async {
      final databaseFile = File('${tempDirectory.path}/data.sqlite');
      final database = sqlite.sqlite3.open(databaseFile.path);
      database.execute('CREATE TABLE user_config (id INTEGER PRIMARY KEY)');
      database.execute('INSERT INTO user_config (id) VALUES (1)');
      database.execute('CREATE TABLE app_systems (id INTEGER PRIMARY KEY)');
      database.execute('PRAGMA user_version = 12');
      database.close();

      final result = await EclipseRecoveryService.inspectUserDataFolder(
        tempDirectory.path,
      );

      expect(result.isValid, isTrue);
      expect(result.schemaVersion, 12);
      expect(result.databaseBytes, greaterThan(0));
      expect(result.issue, isNull);
    });

    test(
      'rejects a healthy SQLite database with the wrong schema',
      () async {
      final databaseFile = File('${tempDirectory.path}/data.sqlite');
      final database = sqlite.sqlite3.open(databaseFile.path);
      database.execute('CREATE TABLE unrelated (id INTEGER PRIMARY KEY)');
      database.close();

      final result = await EclipseRecoveryService.inspectUserDataFolder(
        tempDirectory.path,
      );

      expect(result.isValid, isFalse);
        expect(result.issue, contains('required ECLIPSE tables'));
      },
    );

    test('rejects a corrupt database file', () async {
      await File('${tempDirectory.path}/data.sqlite').writeAsString(
        'this is not a SQLite database',
      );

      final result = await EclipseRecoveryService.inspectUserDataFolder(
        tempDirectory.path,
      );

      expect(result.isValid, isFalse);
      expect(result.issue, isNotNull);
    });
  });
}
