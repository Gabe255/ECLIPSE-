import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PS4 system hands PKG files to Bachata S4 on Android', () {
    final config = jsonDecode(
      File('assets/systems/ps4.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(config['system']['id'], 'ps4');
    expect(config['system']['extensions'], contains('pkg'));

    final emulators = config['emulators'] as List<dynamic>;
    expect(emulators, hasLength(1));

    final bachata = emulators.single as Map<String, dynamic>;
    expect(bachata['unique_id'], 'ps4.com.bachatas4.android');
    expect(bachata['default_standalone'], isTrue);

    final android = bachata['platforms']['android'] as Map<String, dynamic>;
    final arguments = android['launch_arguments'] as String;
    expect(arguments, contains('com.bachatas4.android'));
    expect(arguments, contains('android.intent.action.VIEW'));
    expect(arguments, contains('{file.uri}'));
    expect(android['keep_saf_uri'], isTrue);
  });
}
