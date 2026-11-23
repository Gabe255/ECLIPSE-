import 'package:flutter_test/flutter_test.dart';
import 'package:neostation/models/eclipse_experience_catalog.dart';

void main() {
  group('EclipseExperienceCatalog', () {
    test('contains 44 uniquely identified dashboard experiences', () {
      final experiences = EclipseExperienceCatalog.experiences;
      final ids = experiences.map((experience) => experience.id).toSet();

      expect(experiences, hasLength(44));
      expect(ids, hasLength(44));
    });

    test('uses the PS5 profile as its default experience', () {
      final experience = EclipseExperienceCatalog.byId(
        EclipseExperienceCatalog.defaultExperienceId,
      );

      expect(experience?.id, 'ps5');
      expect(experience?.name, 'PlayStation 5');
    });

    test('marks dual-screen and pointer-focused profiles explicitly', () {
      final wiiU = EclipseExperienceCatalog.byId('wii-u');
      final ds = EclipseExperienceCatalog.byId('ds');
      final ps5 = EclipseExperienceCatalog.byId('ps5');

      expect(wiiU?.supportsDualScreen, isTrue);
      expect(wiiU?.supportsPointer, isTrue);
      expect(ds?.supportsDualScreen, isTrue);
      expect(ds?.supportsPointer, isTrue);
      expect(ps5?.supportsDualScreen, isFalse);
    });

    test('keeps Vita presentation separate from its emulator integration', () {
      final vita = EclipseExperienceCatalog.byId('ps-vita');

      expect(vita?.integrationId, 'vita3k');
      expect(vita?.name, 'PS Vita');
    });

    test('returns null for unknown experience ids', () {
      expect(EclipseExperienceCatalog.byId('not-a-console'), isNull);
    });
  });
}
