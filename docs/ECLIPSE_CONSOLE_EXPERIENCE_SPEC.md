# ECLIPSE Console Experience — Product Specification

## Product direction

ECLIPSE is a controller-first gaming environment, not a generic ROM grid. Its console experience should feel like entering a distinct system environment, then browsing a library that belongs to that environment. The experience is inspired by the interaction principles of KONSORU (authentic platform-specific layouts, clear focus, second-screen awareness, tactile transitions), but all ECLIPSE visuals, motion, navigation, and implementation remain original.

KONSORU's public release repository is binary-only. This document is based on its public feature descriptions and release notes, not copied source code or proprietary assets.

## Experience layers

1. **ECLIPSE home** — the user's personal gaming universe: Continue Playing, favorites, systems, Android entertainment, activity, widgets, and customizable shelves.
2. **System entry** — selecting a platform enters its own boot identity and console environment.
3. **Console home** — a platform-appropriate interface, not merely the same grid with a different accent color.
4. **Game focus / Living Game Dashboard** — focusing a title transforms the presentation around its artwork, metadata, media, achievements, play history, and launch action.
5. **Game launch** — a platform-appropriate launch transition, then hand off to the existing emulator/launcher integration.
6. **In-game companion** — optional quick controls and live session information; device capabilities determine which data is actually available.

## Console experience requirements

- Distinct platform families: PlayStation XMB-style systems, PSP, Wii channels, DS/3DS dual-screen layout, Xbox dashboard, Xbox 360 blades-inspired layout, Nintendo Switch, GameCube, N64, Game Boy family, Dreamcast, Sega, classic Nintendo, and arcade.
- Each family needs its own navigation grammar, visual hierarchy, selection treatment, sound profile, and transition language.
- Console boot is a short, skippable sequence with a platform identity reveal, loading state, and graceful fallback. It must never block library access for a fixed long period.
- Controller navigation is first-class: visible focus, predictable D-pad movement, confirm/back behavior, shoulder-button navigation where appropriate, and no touch-only critical actions.
- Console environments use the existing detected system and game data. They do not create a second ROM database or scanner.
- Game library browsing and launching remain connected to the existing SystemGamesList and GameService flow until a deliberate replacement is implemented and tested.

## Living Game Dashboard

When a game receives focus, show a rich game-specific environment:
- Cover, logo, fanart, and available gameplay preview.
- Title, platform, developer/publisher/year/genre when metadata exists.
- Prominent Play / Resume action.
- Total playtime, current/previous session, last played, and achievements when available.
- Screenshots, video, manuals, and related media only when locally available or supplied by the existing scraper.
- Context actions: favorite, view details, per-game settings, refresh metadata, and return to the library.
- Artwork-driven color atmosphere, subtle motion, and transitions that respect reduced-motion/performance settings.
- No fabricated gameplay footage, stats, achievements, or device telemetry.

## Home, customization, and system features

- **Prism Flow**: horizontal shelves, focus expansion, animated reflow, and theme-aware surfaces.
- **Layout Studio**: reorder, hide, resize, and configure home sections and widgets; save named layouts.
- **Theme Studio**: color palettes, backgrounds, typography, card styles, sounds, and motion presets.
- **Boot Designer**: custom ECLIPSE boot sequences, system-specific boot choices, sound toggle, skip behavior, and preview.
- **Quick Control Center**: controller-friendly access to display, audio, performance mode, brightness where supported, and app shortcuts.
- **Controller Hub**: connected controller status and configurable navigation mappings where supported.
- **Activity Center**: recent sessions, playtime, achievements, and library changes.
- **Cinema / Ambient**: idle presentation, artwork rotation, and optional visualizer when media is playing.
- **Discovery**: surface games already in the user's library; do not imply an online store or distribute game files.
- **Entertainment**: launch installed Android media apps through the existing app integration.
- **Dual-screen companion**: on devices that expose a supported secondary display, show context-sensitive game details, session information, shortcuts, and controls. On single-screen devices, this becomes an optional in-app panel rather than a requirement.

## Device-aware behavior

- Detect available display topology at runtime; do not assume every device has two screens.
- On AYN Thor, make use of the actual secondary display when the platform API and user settings allow it.
- For DS/3DS environments, use the two displays to reflect the platform's interaction model when possible. For other systems, the main display remains the primary console UI and the secondary display is a companion.
- Performance-sensitive effects must honor ECLIPSE performance mode and reduced-motion preferences.
- Battery, temperature, refresh rate, FPS, and other telemetry must only be shown when a reliable platform API supplies the value. Never display invented or guessed values.

## Implementation guardrails

- Preserve the current emulator engine, emulator integrations, game launch routing, ROM folder grants, database, scraping, metadata cache, and system art-pack pipeline.
- Reuse existing GameService, SystemGamesList, SqliteConfigProvider, FileProvider, scraping providers, and secondary-display state/services.
- Do not bundle ROMs, BIOS files, copyrighted game media, console firmware, or proprietary console boot sounds/artwork.
- Use original ECLIPSE artwork, motion, typography, and sound design. Platform-inspired layouts should communicate the interaction model without reproducing proprietary logos, assets, or firmware screens.
- Keep all important actions accessible by controller and touch.
- Implement in small, testable phases. Do not claim a feature is complete until it is wired to real data and verified on target hardware.

## Current repository observations

- EclipseHomeScreen already provides an ECLIPSE-branded landing page with Continue Playing, system shortcuts, and action navigation.
- ConsoleExperienceScreen already classifies many platform families and has separate boot/home builders, plus a controller navigation layer and a Wii pointer path.
- NowPlayingPanel already renders secondary-display game details, playtime, session time, last played, clock/battery status, and screenshot action.
- LauncherSettingsContent is currently a placeholder with no settings items.
- Existing game/session, scraping, metadata, and secondary-display services should be extended rather than duplicated.

## Delivery sequence

1. **Foundation audit and design system** — map current navigation, console families, session data, secondary display, themes, and settings; define reusable ECLIPSE console components.
2. **Console boot + home quality** — upgrade boot sequencing, focus states, sound hooks, responsive layouts, and controller behavior without breaking existing library launch.
3. **Living Game Dashboard** — connect real game metadata/media/session/achievement data to a focused game presentation and launch action.
4. **Prism Flow + Layout Studio** — reusable shelves, widgets, layout persistence, and theme controls.
5. **Quick Control Center + Controller Hub + Activity Center** — integrate only supported live state and existing services.
6. **Thor companion + DS/3DS dual-screen modes** — validate on actual hardware and preserve single-screen fallback.
7. **Cinema, Ambient, Discovery, and polish** — add idle experiences, discovery rows, transitions, sound profiles, and performance tuning.

## Acceptance criteria

- No duplicate scanner, database, or emulator engine.
- No regression in ROM access, scraping, metadata, art packs, game launching, or secondary-display operation.
- Every console environment has a deliberate, testable controller focus path.
- The selected game dashboard displays only available, real metadata and media.
- Boot sequences can be skipped and do not trap navigation.
- Single-screen and dual-screen layouts both remain usable.
- Performance mode and reduced motion meaningfully reduce expensive effects.