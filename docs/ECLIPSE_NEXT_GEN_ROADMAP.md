# ECLIPSE Next-Generation Feature Roadmap

This roadmap records the approved ideas discussed for ECLIPSE. It is a delivery plan, not a claim that these features already exist.

## Product guardrails

- Target: Android APK for handhelds such as AYN Odin 3 and Thor.
- Preserve the existing emulator engine, game-launch routing, and per-system `ConsoleExperienceScreen` / Konsoru-style experiences.
- Home-screen console inspirations apply only to the ECLIPSE main home. They must never replace the interfaces opened after selecting an individual system.
- Keep the main home focused. Advanced tools live in dedicated destinations, contextual game pages, or quick-access panels.
- Prefer integration with existing services over duplicate systems.
- All optional experiences must be usable with touch and controller navigation.
- New data features must be permission-aware, recoverable, and safe against partial writes.
- AB DM remains the user's download manager; the Installation Manager should integrate with its supported hand-off mechanism rather than creating a second downloader. Do not assume an undocumented AB DM API.

## Existing foundations to reuse

The repository already contains substantial infrastructure for system/game libraries, themes, achievements, game sessions, save syncing, user-data relocation, SQLite snapshots, metadata, and secondary-display features. New work should extend these foundations and avoid parallel implementations.

In particular:
- Keep `ConsoleExperienceScreen` and its system-specific boot/home behavior unchanged.
- Reuse the existing user-data location and database snapshot mechanisms for recovery and migration.
- Reuse existing save-sync providers and per-system save-folder configuration for Save Sync Center.
- Reuse existing game-session and library metadata for timelines, welcome-back summaries, and game pages.
- Reuse the existing theme and asset systems for home experiences and creator tools.

## Approved priority order

### Priority 1 — Device Bridge
A secure, opt-in connection between compatible ECLIPSE devices. Initial scope: discover/pair devices on the local network, transfer user-approved files and ECLIPSE settings, show transfer progress, verify received files, and support cancellation. Do not silently transfer ROMs, credentials, or copyrighted content.

### Priority 2 — Recovery Center / Restore Point
Let users choose a durable backup location (including removable storage where Android permissions allow), create verified backups, and later point a fresh ECLIPSE install at that location. Preview backup contents before restoring. Restore launcher settings, home layouts, themes, library metadata, and supported save/configuration data. Never overwrite newer data without a clear confirmation. Detect incomplete or incompatible backups and fail safely.

### Priority 3 — Save Sync Center
A unified, understandable view of supported emulator save locations and existing sync providers. Show sync status, conflicts, backups, and restore actions. Do not imply every emulator or save format is supported.

### Priority 4 — One-Tap Migration
A guided device-to-device migration flow built on Device Bridge and Recovery Center. Preview what will transfer, verify destination capacity, and let users choose data categories.

## Main-home experience

These features affect only the ECLIPSE main home, never the individual-system Konsoru experiences:
- Console-inspired home layouts (PS5/PS4/Switch/Xbox-inspired arrangements).
- Living Game Dashboard and Living Game Covers.
- Home Layout Editor, saved Home Profiles, widget placement, and optional widget marketplace.
- Reality Shift / HoloDeck / Eclipse Universe interactive environments.
- Living wallpapers, ambient and time-based atmosphere, idle/Dream Mode, and soundscapes.
- Custom Transition Studio, Motion Designer, and Boot Identity Studio.
- Game Spotlight, Welcome Back, Quick Resume shelf, and Interactive Game Shelves.

Keep the default layout simple. Users opt into more elaborate experiences.

## Game experiences and discovery

- Game Pages and Game DNA: a richer per-game destination built from available metadata.
- Game Arrival Sequences / Portal Builder: optional launch presentations; must not interfere with launch reliability.
- Game Universe Map / Game Constellations / Franchise Journey / Series Timeline.
- Eclipse Curator and Mood Launcher: recommendations based on the user's own library and chosen interests.
- Game Museum, Digital Manual Library, Game Showcase, Character Gallery, and Infinite Gallery.
- Game Passport, Trophy Room / Trophy Universe, Collectible Cards, Completion Tracker, and Eclipse Wrapped.
- Game Timeline and Time Capsule using available session history.
- Blind Pick / game randomizer.

## In-game and device tools

- Eclipse Live Overlay / SideView / Live Game Companion, only where Android and the running emulator/game allow safe overlays or supported companion behavior.
- Per-game controller profiles and Smart Game Settings.
- Smart Storage Brain and Installation Manager integrated with AB DM.
- Notification Hub, Command Palette, Command Voice, and Eclipse Assistant.
- Screenshot/Replay Theater/Photo Lab, only for captures the device or emulator can actually provide.
- Device Bridge and local ECLIPSE Network.

## Creation and community

- Eclipse Creator Studio / Skin Engine / Motion Designer.
- Eclipse Extensions and optional community experiences.
- Eclipse Worlds Marketplace for complete user-created home experiences.
- Eclipse Link for sharing layouts, themes, and collections.
- User-created content must be sandboxed, permission-scoped, and removable.

## Delivery sequence

1. Audit existing code and map each idea to the correct existing subsystem.
2. Complete the recovery foundation and tests before broad UI work.
3. Deliver Device Bridge and migration with integrity checks and cancellation.
4. Deliver Save Sync Center by consolidating existing save/sync information.
5. Build main-home layouts and Living Game Dashboard without touching system console experiences.
6. Add game discovery, creator tools, extensions, and optional advanced experiences in separate, testable releases.

Each phase is complete only after implementation, formatting, analysis, relevant tests, and an Android build check. A feature is not considered shipped merely because it appears in this roadmap.
