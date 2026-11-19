# ECLIPSE — Product Roadmap

ECLIPSE is an Android-first gaming frontend and customizable gaming universe. This document separates capabilities already documented in the repository from planned product work. A roadmap entry is not a claim that the feature is already implemented.

## Existing capabilities documented in the repository

These are listed in the current project README and should be preserved during redesign:

- Flutter-based, multi-platform application (Android, Windows, Linux, macOS).
- ECLIPSE visual identity, customizable themes, animations, and library wallpaper.
- ECLIPSE Shelf: horizontal platform layout, hero artwork, and controller navigation.
- ROM and platform collection management.
- Multi-disc ROM organization with generated M3U playlists.
- RetroArch and standalone emulator integration and auto-detection.
- ScreenScraper metadata and media scraping.
- RetroAchievements support.
- NeoSync account and cloud-save sync functionality.
- Gamepad and keyboard navigation.
- Twelve-language localization.
- System/emulator definitions and OTA systems-manifest updates.

## Product direction and previously agreed design requirements

These are established project requirements/design decisions; implementation should be verified feature by feature:

- ECLIPSE should have its own identity and interface, not be a NeoStation reskin.
- NeoStation is the Flutter/Android foundation; preserve applicable upstream notices and GPL-3.0 obligations.
- Pegasus is a layout/customization inspiration, not a required UI dependency.
- iiSU is visual inspiration for icon/theme direction, including Prism Flow.
- Cocoon is inspiration for wide horizontal rows and console-style presentation; do not copy its identity.
- Purple-black cosmic ECLIPSE visual identity.
- Customizable home and settings pages.
- Wide horizontal game rows and console-style home presentation.
- Customizable dock, widgets, startup page, and saved folders.
- Rescan control and Treat as Game option.
- Controller hints and smooth, controller-first navigation.
- Apps Library that can display installed apps.
- Quick Control Center shortcuts for Bluetooth, Wi-Fi, brightness, and volume.

## New roadmap additions

### 1. ECLIPSE home and navigation

- Living Game Banners: cinematic hero banners with game artwork/gameplay-inspired backgrounds, title, and useful game information.
- Game Universe home: configurable horizontal shelves for favorites, recently played, installed games, collections, and platforms.
- Universal Search across games, apps, collections, emulators, and settings.
- Quick access to saved folders and pinned destinations.
- Consistent controller, touch, keyboard, and remote navigation.

### 2. Console experiences

- Console-specific startup and home experiences for supported device profiles.
- Custom boot and shutdown animations, with user-selectable sounds.
- Handheld, tablet, Android TV, and dual-screen presentation modes where supported.
- Per-profile startup destination and navigation behavior.

### 3. ECLIPSE Studio and visual customization

- ECLIPSE Studio / Theme Workshop for creating and managing themes.
- Custom wallpapers, icons, accent colors, layouts, animations, and sounds.
- Prism Flow theme direction inspired by iiSU.
- Atmosphere Engine: adapt interface accents and backgrounds to the selected game or platform.
- Preview themes before applying them; provide safe defaults and reset controls.

### 4. Game library and game pages

- Dedicated Game Profiles with artwork, metadata, description, platform, emulator, launch options, and play history.
- Automatic artwork and metadata scraping with manual correction.
- Rescan library control, Treat as Game, and duplicate-safe scanning.
- Recently played history and playtime tracking.
- Smart Resume / Quick Resume shortcuts, limited to what the selected emulator or streaming provider supports.
- Custom collections, favorites, and folders.
- Apps Library for installed Android apps.
- Storage Manager showing library locations and storage usage.

### 5. Widgets and system controls

- Live dashboard widgets for clock, battery, storage, and available system information.
- Quick Control Center with Bluetooth, Wi-Fi, brightness, and volume shortcuts.
- Performance information only where the operating system exposes reliable data.
- Configurable widget placement and visibility.

### 6. Gaming identity and stats

- Eclipse Identity profiles and customizable avatars.
- Gaming statistics such as playtime and recently played titles.
- Achievement aggregation where supported by an integration, including existing RetroAchievements support.
- Optional local profiles; do not require an online account for core launcher use.

### 7. Integrations and controller support

- Preserve RetroArch and standalone emulator integrations.
- Preserve gamepad and keyboard navigation.
- Expand controller mapping and per-device/controller profiles.
- Preserve existing game streaming integrations and add providers only when technically and legally supportable.
- Clear per-game launch configuration and error feedback.

### 8. Reliability, maintenance, and delivery

- Update Center / ECLIPSE Hub for app and supported system-definition updates.
- Backup and restore for settings, themes, and library configuration.
- Offline-first access to the local library and settings.
- Recovery/reset path for broken themes or configuration.
- Robust scanning, scraping, and launch error handling.
- APK build and release validation in CI.
- Verify install-over-update compatibility using the same application ID and signing certificate.
- Keep release signing secrets out of source control.

## Suggested implementation order

1. Finish and verify the core redesigned home, navigation, and controller experience.
2. Complete Living Game Banners and Game Profiles using existing library metadata.
3. Add Universal Search and improve library scanning / Treat as Game / rescan flows.
4. Build ECLIPSE Studio with safe theme previews and customization.
5. Add Atmosphere Engine and configurable widgets / Quick Control Center.
6. Add console-specific startup profiles and device layouts.
7. Expand identity, statistics, controller mapping, backup/restore, and update experiences.
8. Validate APK builds, release signing, upgrades, and device compatibility.

## Definition of done

A feature is complete only when its implementation exists in the app, is connected to the relevant UI and persistence/integration, passes appropriate tests, and is verified on a supported device or build. Roadmap documentation alone does not mean a feature has shipped.
