# ECLIPSE approved product features

This scope was approved on 2026-11-19 for the active Flutter port in PR #1.
Target repository: Gabe255/ECLIPSE-
Implementation branch: migration/pegasus-flutter-port

## Approved for implementation

1. Cinematic Home
   - Featured-game hero with artwork/video preview when local media exists.
   - Title, platform, metadata, and clear Play / Details actions.
   - Artwork fallback when no local video is available.
2. Quick Control Center
   - Gamepad- and touch-accessible overlay.
   - Expose only controls backed by supported Android APIs or existing app settings.
   - Avoid fake controls for unsupported system-level brightness, volume, or Wi-Fi access.
3. Achievement Center
   - Build on the existing RetroAchievements integration; do not create a duplicate achievement backend.
   - Surface progress, recent unlocks, and library entry points using verified local/API data.
4. Theme Studio
   - Build on ThemeProvider, existing theme catalogue, custom themes, wallpaper picker, and System Art store.
   - Preview before applying; persist selections through existing configuration.
5. Continue Playing
   - Use confirmed game-session history and launch timestamps.
   - Provide resume/launch and details actions; handle empty history.
6. Custom Boot Designer
   - Configure supported app-level startup presentation, logo, animation, and optional sound.
   - Do not imply Android bootloader/system boot replacement; this is the ECLIPSE app startup experience.
7. Controller Hub
   - Build on the existing gamepad navigation and mapping infrastructure.
   - Show connected controller state where detectable and provide supported mapping/test workflows.
8. Performance Dashboard
   - Show device/app metrics only when available from supported APIs.
   - Clearly label unavailable metrics; avoid claiming privileged CPU/GPU/temperature access.
9. Fire TV-style Entertainment Home
   - Add a dedicated entertainment area inspired by streaming-device home screens.
   - Discover installed entertainment apps (e.g. YouTube, Hulu, Disney+, Netflix) and launch them using Android package handoff.
   - Feature a hero/continue row and categorized horizontal app rows.
   - Do not bundle streaming services, bypass subscriptions, scrape protected catalogs, or claim playback integration; this is an installed-app launcher.

## Deferred / not approved yet

- User Profiles: maybe; do not implement until separately approved.
- Smart Collections: maybe; existing smart-collection functionality should be preserved, but no new expansion is approved here.

## Engineering requirements

- Preserve the ECLIPSE application ID and signing certificate.
- Preserve existing ROM scanning, metadata, artwork, gamepad navigation, emulator launch, Android app handoff, and NeoAssets integration.
- Reuse existing providers/services instead of duplicating them.
- Keep touch and controller navigation usable on handhelds; adapt layout for larger screens.
- Add focused tests for new models/state and navigation.
- Run formatter, Flutter tests, analyzer, and Android build before claiming completion.
- Do not publish an APK/release until build and signing compatibility are verified.

This file records approved scope and acceptance criteria. It does not claim these features are implemented.
