import 'package:flutter_test/flutter_test.dart';
import 'package:neostation/data/datasources/sqlite_service.dart';

import 'database_test_helper.dart';

void main() {
  final dbHelper = DatabaseTestHelper();
  late DatabaseAdapter db;

  const firstRom = '/roms/snes/Chrono Trigger.sfc';
  const secondRom = '/roms/snes/Secret of Mana.sfc';

  setUp(() async {
    db = await dbHelper.setUp();
    await db.insert('user_roms', {
      'rom_path': firstRom,
      'filename': 'Chrono Trigger.sfc',
      'app_system_id': 'snes',
    });
    await db.insert('user_roms', {
      'rom_path': secondRom,
      'filename': 'Secret of Mana.sfc',
      'app_system_id': 'snes',
    });
  });

  tearDown(() async {
    await dbHelper.tearDown();
  });

  group('ROM play statistics', () {
    test('returns zero before the statistics table is created', () async {
      expect(await SqliteService.getRomPlayCount(firstRom), 0);
    });

    test('increments only the launched game and updates last played', () async {
      await SqliteService.recordRomPlayed(firstRom);
      await SqliteService.recordRomPlayed(firstRom);

      expect(await SqliteService.getRomPlayCount(firstRom), 2);
      expect(await SqliteService.getRomPlayCount(secondRom), 0);

      final rows = await db.query(
        'user_roms',
        columns: ['last_played'],
        where: 'rom_path = ?',
        whereArgs: [firstRom],
        limit: 1,
      );
      expect(rows, hasLength(1));
      expect(rows.single['last_played'], isA<String>());
      expect(DateTime.tryParse(rows.single['last_played']! as String), isNotNull);
    });

    test('does not leave last played updated if the counter write fails', () async {
      await db.execute('''
        CREATE TABLE user_rom_play_stats (
          rom_path TEXT PRIMARY KEY COLLATE NOCASE,
          play_count INTEGER NOT NULL DEFAULT 0,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TRIGGER reject_play_stat
        BEFORE INSERT ON user_rom_play_stats
        BEGIN
          SELECT RAISE(ABORT, 'forced test failure');
        END
      ''');

      await expectLater(
        SqliteService.recordRomPlayed(firstRom),
        throwsA(anything),
      );

      final rows = await db.query(
        'user_roms',
        columns: ['last_played'],
        where: 'rom_path = ?',
        whereArgs: [firstRom],
        limit: 1,
      );
      expect(rows.single['last_played'], isNull);
      expect(await SqliteService.getRomPlayCount(firstRom), 0);
    });

    test('ignores an empty path', () async {
      await SqliteService.recordRomPlayed('  ');
      expect(await SqliteService.getRomPlayCount(firstRom), 0);
    });
  });
}
