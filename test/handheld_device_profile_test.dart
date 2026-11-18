import 'package:flutter_test/flutter_test.dart';
import 'package:neostation/models/handheld_device_profile.dart';

void main() {
  group('HandheldDeviceProfile', () {
    test('parses Thor dual-screen recommendations', () {
      final profile = HandheldDeviceProfile.fromJson({
        'schema_version': 1,
        'id': 'ayn-thor',
        'display_name': 'AYN Thor',
        'display': {'mode': 'auto'},
        'systems': {
          'recommended': ['DS', '3DS', 'PS2'],
          'advanced': ['Switch'],
          'allow_user_override': true,
        },
      });

      expect(profile.id, 'ayn-thor');
      expect(profile.displayMode, 'auto');
      expect(profile.recommendedSystems, ['ds', '3ds', 'ps2']);
      expect(profile.advancedSystems, ['switch']);
      expect(profile.allowUserOverride, isTrue);
    });

    test('matches only supported AYN handheld models', () {
      expect(
        HandheldDeviceProfile.assetPathForDevice('AYN', 'Thor'),
        'assets/device_profiles/ayn-thor.json',
      );
      expect(
        HandheldDeviceProfile.assetPathForDevice('AYN', 'Odin 3'),
        'assets/device_profiles/odin3.json',
      );
      expect(HandheldDeviceProfile.assetPathForDevice('Other', 'Thor'), isNull);
      expect(
        HandheldDeviceProfile.assetPathForDevice('AYN', 'Unknown'),
        isNull,
      );
    });

    test('rejects unsupported schema versions', () {
      expect(
        () => HandheldDeviceProfile.fromJson({'schema_version': 2}),
        throwsFormatException,
      );
    });

    test('rejects invalid display modes', () {
      expect(
        () => HandheldDeviceProfile.fromJson({
          'schema_version': 1,
          'id': 'bad',
          'display_name': 'Bad',
          'display': {'mode': 'triple'},
          'systems': {
            'recommended': [],
            'advanced': [],
            'allow_user_override': true,
          },
        }),
        throwsFormatException,
      );
    });
  });
}
