# ECLIPSE Unified Build

## Foundation
- Base branch: `main` (the original ECLIPSE foundation selected for the rebuild).
- Working branch: `feature/eclipse-original-unified-home`.
- The NeoStation-derived migration branch is retained as a reference/backup and is not merged wholesale.

## Product direction
ECLIPSE is a unified gaming launcher with its own visual identity. The home experience may take usability cues from console dashboards (including a PS5-style layout), but must use original ECLIPSE branding, components, artwork treatment, and navigation rather than copying NeoStation's home screen.

## Approved scope

### Core library
- Detect and display installed game systems with recognizable system artwork/icons.
- Scan configured ROM folders and make scan/rescan status visible.
- Scrape game metadata and artwork; provide match selection and useful failure states.
- Game detail pages with artwork, metadata, launch actions, and available achievement information.
- Preserve local game data, metadata, and artwork across launches.

### ECLIPSE home and navigation
- Original custom home dashboard with a featured/continue-playing area.
- Horizontal game and system shelves with proper artwork and platform identity.
- User-customizable home layout and navigation destinations.
- Quick Control Center and useful widgets.
- Continue Playing and recent-game access.

### Personalization and console experience
- Theme Studio and Prism Flow-inspired theme option.
- Custom startup/boot designer.
- Controller Hub and gamepad-first navigation.
- Performance Dashboard using only metrics the platform can actually provide.
- Achievement Center.
- Entertainment area for supported installed media apps.

### Online services
- RetroAchievements sign-in using the user's own username and API key.
- Clear connected/disconnected state and safe credential storage.
- Game matching and per-game achievement progress where supported.

## Existing foundation to preserve
The `main` branch already contains substantial systems scanning, game database, ScreenScraper, game-detail, theme, gamepad, and RetroAchievements code. Reuse and repair these services instead of replacing them with placeholder implementations.

## Acceptance checks
- A clean install can add a ROM folder, scan it, and show detected systems with recognizable icons.
- A library containing ROMs can scrape metadata/artwork and explain unmatched or failed items.
- Opening a game shows its actual saved metadata/artwork and a working launch action.
- RetroAchievements login succeeds with a user's own credentials and survives restart when secure storage is available.
- Home navigation reaches the existing systems, discovery, achievements, saves, settings, and supported entertainment destinations.
- Gamepad/keyboard navigation remains functional throughout.
- Flutter format, analyze, unit/widget tests, and Android build all pass before a release is considered.
- Release signing is verified against the original ECLIPSE signing certificate before publishing.

## Explicitly not included without renewed approval
- User Profiles.
- Smart Collections.

## Implementation rule
Do not mark a feature complete because a screen or mock card exists. Completion requires a working data path, real navigation/action, and a test or reproducible verification.
