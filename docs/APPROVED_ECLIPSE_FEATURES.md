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

## Additional approved scope — 2026-11-20

The following ideas were explicitly approved for implementation:

10. Game Universes
    - A game-specific hub that brings together its existing artwork, screenshots, videos, metadata, achievements, and launch actions.
    - Reuse locally available assets and existing metadata providers; never fabricate media or metadata.
11. Universal Search
    - Search games, installed entertainment apps, systems, and supported settings from one entry point.
    - Results must use existing library and Android package discovery data.
12. Activity Feed
    - A chronological feed of real game launches, achievements, scans, and supported app activity.
    - Do not invent events or imply visibility into other apps' private activity.
13. Dynamic Atmospheres
    - Adapt backgrounds and visual presentation to the selected game, system, or entertainment area.
    - Respect performance settings and reduced-motion preferences.
14. Game Carousel Mode
    - An optional full-width horizontal library browsing mode with controller and touch support.
15. Storage Manager
    - Show storage usage only where Android exposes reliable values; clearly distinguish app-managed files from data ECLIPSE cannot safely manage.
    - No automatic deletion. Require explicit confirmation for destructive actions.
16. Ambient Mode
    - An idle presentation using clock, owned artwork, and optional local media visualizations.
    - Provide a timeout/exit path and avoid unnecessary battery use.
17. Layout Presets
    - Handheld, TV, Desktop, and Minimal presets that adapt existing navigation and layout rather than duplicate screens.
18. Game Discovery
    - Filter and browse the user's own library by available genre, developer, year, and platform metadata.
    - Do not imply access to a remote store/catalog unless a supported provider is connected.
19. Notification Center
    - A central view for real ECLIPSE events such as scans, controller state, achievements, and updates.
    - Use existing event sources; avoid duplicate notifications.

20. ECLIPSE AI Assistant
    - A first-party assistant surface accessible throughout the frontend, with controller, touch, and voice entry points where supported.
    - Local command handling for navigation and supported ECLIPSE actions (e.g. opening Systems, Discovery, Settings, Achievements, Android Apps, or Search).
    - Conversational AI responses through an explicitly configured provider; never ship a hard-coded API key or silently transmit user data.
    - Clear local-only/cloud processing indicators, privacy controls, microphone permission prompts, and a way to disable voice/cloud features.
    - Voice input must use supported Android speech-recognition APIs and degrade gracefully when unavailable.
    - Assistant actions must be allowlisted, confirmed when consequential, and report failures honestly. It must not claim to control unsupported system settings or inspect other apps.
    - No always-listening wake word by default. A push-to-talk/controller shortcut is the initial voice interaction model.


## Additional approved scope — 2026-11-20 (ideas 88–92)

The following concepts were explicitly approved for implementation. They are roadmap approvals, not claims that the features already exist.

88. Emulator Workshop
    - Provide a focused management view for emulator apps already installed on the device and systems they can launch.
    - Surface verified availability, supported launch configuration, and relevant per-emulator status.
    - Reuse existing system definitions and launch integrations; do not create a duplicate emulator backend or imply that ECLIPSE installs/configures emulators when it cannot.

89. Library Curator
    - Help review duplicate entries, missing metadata/artwork, unavailable game paths, and incomplete library records.
    - Offer clear review and repair actions backed by existing scanner, metadata, and library services.
    - Never silently delete entries or files; distinguish a duplicate display record from duplicate game data and require confirmation for changes.

90. Local Multiplayer Lounge
    - Provide a place to prepare local multiplayer sessions using games and systems in the user's library.
    - Show player-count and controller compatibility only when supported by reliable metadata or explicit user configuration.
    - Help users identify and test connected controllers before launch; do not promise matchmaking, online play, or automatic player detection where unsupported.

91. Gaming Museum
    - Present a curated, browsable archive of the user's gaming collection and verified personal milestones.
    - Reuse owned game artwork, metadata, and confirmed achievement/session records.
    - Keep this as an archival/presentation experience, distinct from the operational Activity Feed and Achievement Center; never fabricate history or milestones.

92. System Fun Facts
    - Add a rotating fun-fact experience covering every gaming system supported by the user's ECLIPSE setup.
    - Facts may cover hardware, release history, controllers, technical capabilities, notable games, and unusual trivia.
    - Associate each fact with the correct system and show it in relevant system surfaces as well as a browsable facts view.
    - Use a curated, verified fact catalogue with source/provenance records; do not invent facts or show facts for unsupported systems.
    - Support a graceful empty state when a system has no verified facts yet.
