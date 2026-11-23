/// Catalog of dashboard identities supported by ECLIPSE's experience system.
///
/// These entries describe presentation profiles, not emulator availability.
/// A profile may be previewed even when its console emulator is not installed.
class EclipseExperience {
  const EclipseExperience({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.supportsDualScreen = false,
    this.supportsPointer = false,
    this.integrationId,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final bool supportsDualScreen;
  final bool supportsPointer;
  final String? integrationId;
}

abstract final class EclipseExperienceCatalog {
  static const defaultExperienceId = 'ps5';

  static const experiences = <EclipseExperience>[
    EclipseExperience(
      id: 'ps5',
      name: 'PlayStation 5',
      category: 'PlayStation',
      description: 'Cinematic hero dashboard and game-focused home.',
    ),
    EclipseExperience(
      id: 'ps4',
      name: 'PlayStation 4',
      category: 'PlayStation',
      description: 'Horizontal game carousel and content rows.',
    ),
    EclipseExperience(
      id: 'ps3',
      name: 'PlayStation 3',
      category: 'PlayStation',
      description: 'XMB-inspired horizontal categories and vertical lists.',
    ),
    EclipseExperience(
      id: 'ps2',
      name: 'PlayStation 2',
      category: 'PlayStation',
      description: 'Minimal dark-blue system menu and memory-card atmosphere.',
    ),
    EclipseExperience(
      id: 'ps1',
      name: 'Original PlayStation',
      category: 'PlayStation',
      description:
          'Classic disc library and memory-card-inspired presentation.',
    ),
    EclipseExperience(
      id: 'ps-classic',
      name: 'PlayStation Classic',
      category: 'PlayStation',
      description: 'Curated retro game carousel.',
    ),
    EclipseExperience(
      id: 'psp',
      name: 'PSP',
      category: 'PlayStation',
      description: 'XMB waves, icon rows and portable game library.',
    ),
    EclipseExperience(
      id: 'psp-go',
      name: 'PSP Go',
      category: 'PlayStation',
      description: 'Compact digital-first XMB-inspired library.',
    ),
    EclipseExperience(
      id: 'ps-vita',
      name: 'PS Vita',
      category: 'PlayStation',
      description: 'LiveArea-inspired bubbles and touch-first pages.',
      integrationId: 'vita3k',
    ),
    EclipseExperience(
      id: 'xbox-series',
      name: 'Xbox Series',
      category: 'Xbox',
      description: 'Modern content rows, pinned games and quick access.',
    ),
    EclipseExperience(
      id: 'xbox-one',
      name: 'Xbox One',
      category: 'Xbox',
      description: 'Tile-based dashboard with pins and entertainment rows.',
    ),
    EclipseExperience(
      id: 'xbox-360',
      name: 'Xbox 360',
      category: 'Xbox',
      description: 'Blades-inspired navigation and nostalgic transitions.',
    ),
    EclipseExperience(
      id: 'xbox-original',
      name: 'Original Xbox',
      category: 'Xbox',
      description: 'Classic green system dashboard.',
    ),
    EclipseExperience(
      id: 'switch-2',
      name: 'Nintendo Switch 2',
      category: 'Nintendo',
      description: 'Refined modern game grid and system bar.',
    ),
    EclipseExperience(
      id: 'switch',
      name: 'Nintendo Switch',
      category: 'Nintendo',
      description: 'Clean game carousel and compact system controls.',
    ),
    EclipseExperience(
      id: 'wii-u',
      name: 'Wii U',
      category: 'Nintendo',
      description: 'TV and GamePad-inspired dual-screen experience.',
      supportsDualScreen: true,
      supportsPointer: true,
    ),
    EclipseExperience(
      id: 'wii',
      name: 'Wii',
      category: 'Nintendo',
      description: 'Channel grid with motion-style pointer navigation.',
      supportsPointer: true,
    ),
    EclipseExperience(
      id: 'gamecube',
      name: 'GameCube',
      category: 'Nintendo',
      description: 'Cube-inspired boot and memory-card-style menus.',
    ),
    EclipseExperience(
      id: 'n64',
      name: 'Nintendo 64',
      category: 'Nintendo',
      description: 'Three-dimensional cartridge library.',
    ),
    EclipseExperience(
      id: '3ds',
      name: 'Nintendo 3DS',
      category: 'Nintendo',
      description: 'Icon grid, folders and dual-screen touch controls.',
      supportsDualScreen: true,
      supportsPointer: true,
    ),
    EclipseExperience(
      id: 'ds',
      name: 'Nintendo DS',
      category: 'Nintendo',
      description: 'Dual-screen library with touchscreen pointer.',
      supportsDualScreen: true,
      supportsPointer: true,
    ),
    EclipseExperience(
      id: 'gba',
      name: 'Game Boy Advance',
      category: 'Nintendo',
      description: 'Portable 32-bit game shelf.',
    ),
    EclipseExperience(
      id: 'gbc',
      name: 'Game Boy Color',
      category: 'Nintendo',
      description: 'Colorful handheld library.',
    ),
    EclipseExperience(
      id: 'gameboy',
      name: 'Original Game Boy',
      category: 'Nintendo',
      description: 'Monochrome portable presentation.',
    ),
    EclipseExperience(
      id: 'genesis',
      name: 'Sega Genesis / Mega Drive',
      category: 'Sega',
      description: 'Cartridge-inspired 16-bit game shelf.',
    ),
    EclipseExperience(
      id: 'saturn',
      name: 'Sega Saturn',
      category: 'Sega',
      description: 'Polygon-inspired system menu.',
    ),
    EclipseExperience(
      id: 'dreamcast',
      name: 'Dreamcast',
      category: 'Sega',
      description: 'Dreamlike startup and VMU-inspired library.',
    ),
    EclipseExperience(
      id: 'game-gear',
      name: 'Game Gear',
      category: 'Sega',
      description: 'Colorful portable retro dashboard.',
    ),
    EclipseExperience(
      id: 'master-system',
      name: 'Master System',
      category: 'Sega',
      description: 'Classic Sega-inspired game library.',
    ),
    EclipseExperience(
      id: 'neogeo',
      name: 'Neo Geo',
      category: 'Arcade & Retro',
      description: 'Arcade cabinet-inspired game selection.',
    ),
    EclipseExperience(
      id: 'neogeo-pocket',
      name: 'Neo Geo Pocket Color',
      category: 'Arcade & Retro',
      description: 'Pocket-sized arcade collection.',
    ),
    EclipseExperience(
      id: 'atari-2600',
      name: 'Atari 2600',
      category: 'Arcade & Retro',
      description: 'Minimalist classic arcade library.',
    ),
    EclipseExperience(
      id: 'atari-lynx',
      name: 'Atari Lynx',
      category: 'Arcade & Retro',
      description: 'Portable arcade-inspired presentation.',
    ),
    EclipseExperience(
      id: 'atari-jaguar',
      name: 'Atari Jaguar',
      category: 'Arcade & Retro',
      description: 'Futuristic 1990s-inspired dashboard.',
    ),
    EclipseExperience(
      id: 'pc-engine',
      name: 'PC Engine / TurboGrafx-16',
      category: 'Arcade & Retro',
      description: 'Arcade-inspired console library.',
    ),
    EclipseExperience(
      id: 'wonderswan',
      name: 'WonderSwan',
      category: 'Arcade & Retro',
      description: 'Distinctive portable game shelf.',
    ),
    EclipseExperience(
      id: 'nes',
      name: 'NES / Famicom',
      category: 'Nintendo',
      description: 'Classic 8-bit game selection.',
    ),
    EclipseExperience(
      id: 'snes',
      name: 'SNES',
      category: 'Nintendo',
      description: 'Colorful 16-bit game library.',
    ),
    EclipseExperience(
      id: 'amiga',
      name: 'Amiga',
      category: 'Computers',
      description: 'Retro desktop-inspired game environment.',
    ),
    EclipseExperience(
      id: 'dos',
      name: 'DOS Gaming',
      category: 'Computers',
      description: 'Command-line-inspired retro PC library.',
    ),
    EclipseExperience(
      id: 'steamos',
      name: 'SteamOS Gaming Mode',
      category: 'PC Gaming',
      description: 'Controller-first PC library and quick settings.',
      integrationId: 'steam',
    ),
    EclipseExperience(
      id: 'gamenative',
      name: 'GameNative',
      category: 'PC Gaming',
      description: 'Unified entry point for supported GameNative titles.',
      integrationId: 'gamenative',
    ),
    EclipseExperience(
      id: 'gamehub',
      name: 'GameHub / GameHub Lite',
      category: 'PC Gaming',
      description: 'Unified entry point for supported GameHub titles.',
      integrationId: 'gamehub',
    ),
    EclipseExperience(
      id: 'fire-tv',
      name: 'Entertainment Mode',
      category: 'Entertainment',
      description: 'Streaming apps, media rows and installed-app shortcuts.',
    ),
  ];

  static EclipseExperience? byId(String id) {
    for (final experience in experiences) {
      if (experience.id == id) return experience;
    }
    return null;
  }

  static List<String> get categories => experiences
      .map((experience) => experience.category)
      .toSet()
      .toList(growable: false);
}
