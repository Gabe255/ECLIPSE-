# ECLIPSE Pegasus-to-Flutter Port Plan

Status: active port. Pegasus is a behavioral/UX reference; compatible features are being reimplemented natively in Flutter/Dart. No Qt/QML runtime or unverified Pegasus assets are being added.

## Source of truth

- Working Flutter base: `Gabe255/ECLIPSE-` (NeoStation-derived Flutter/Dart app).
- Reference project: `Gabe255/pegasus-frontend` (C++11, Qt/QML).
- Legacy ECLIPSE app: `Gabe255/ECLIPSE` (Vite/Capacitor; retain as backup/reference until migration is verified).
- Imported duplicate repositories are not build dependencies and can be removed by the repository owner after confirming they contain no unique work.

## Product identity and architecture decision

ECLIPSE owns the product identity, but its appearance must be user-selectable rather than locked to purple/black. Provide four clear appearance modes: ECLIPSE (signature cosmic palette), Light, Dark, and System (follow Android brightness). Existing extra themes and imported themes remain available. Console-specific startup sequences and console home experiences remain core ECLIPSE behavior. Pegasus is the primary UX reference for a substantial library/menu redesign: port its useful layout, browsing, collection, sorting, filtering, and customization concepts natively in Flutter. Do not embed Qt/QML or copy Pegasus branding/assets. The redesign must replace the weak current library presentation, not merely recolor it.

Keep Flutter/Dart and the existing NeoStation layered architecture. Do not embed Qt/QML or attempt to compile Pegasus UI inside Flutter.

NeoStation already has:
- Presentation screens and reusable widgets under `lib/screens/` and `lib/widgets/`.
- Provider-based state under `lib/providers/`.
- Services under `lib/services/`.
- Repositories and SQLite data sources under `lib/repositories/` and `lib/data/datasources/`.
- Game, collection, system, emulator, and play-session models.
- Existing gamepad navigation and game-library browsing.

Pegasus should be studied as a reference for interaction and product behavior, then compatible behavior should be implemented using Flutter widgets, Dart state, and existing NeoStation services/repositories.

## Audited feature matrix

| Pegasus capability | Flutter audit result | Decision |
|---|---|---|
| Game metadata and artwork | Present in `GameModel`, `DatabaseGameModel`, file provider, and scraper pipeline | Reuse; do not duplicate metadata storage |
| Favorites | Present through `GameModel.isFavorite`, `FavoritesService`, and `GameRepository` | Reuse existing persisted favorite flow |
| Collections | Present through `CollectionModel`, collection repository/provider, manual and smart collection screens | Reuse; compare UX and sorting details before changing |
| Playtime and last played | Present through `GameModel`, `GameSessionManager`, `PlaytimeMeter`, and session persistence | Reuse; compare aggregation and interrupted-session behavior |
| Play count | Additive `user_rom_play_stats` table; confirmed session launches increment it; carousel focus panel displays the count | Implemented end-to-end in Flutter. Counter and `last_played` update share one SQLite transaction; lifecycle resume refreshes the visible count. Regression tests cover incrementing, per-game isolation, empty paths, and rollback. CI/device verification is still pending. Historical launches remain zero because no trustworthy old count exists |
| Missing-game state | Pegasus model exposes a missing flag | Not yet confirmed in Flutter; inspect scanner/library behavior before deciding whether a separate flag is needed |
| Gamepad navigation | Flutter has dedicated gamepad navigation utilities and focused list/grid components | Reuse; test focus/axis/button parity rather than replacing navigation wholesale |
| Themes | Flutter has ThemeProvider and custom theme services | Reuse; inspect Pegasus theme configuration only for genuinely missing customization options |
| Launch parameters | Flutter has Android/desktop placeholder resolution and launch services | Preserve current platform-safe launcher; port only compatible metadata/configuration ideas |
| Assets/collections model links | Flutter has game artwork lookup and collection membership | Compare model relationships and caching before making changes |

### Files inspected for this audit

Flutter:
- `ARCHITECTURE.md`
- `lib/models/game_model.dart`
- `lib/models/database_game_model.dart`
- `lib/models/collection_model.dart`
- `lib/repositories/game_repository.dart`
- `lib/services/game/favorites_service.dart`
- `lib/services/game/game_session_manager.dart`
- `lib/services/game/playtime_meter.dart`
- `lib/screens/game_screen/game_list_view.dart`
- `lib/screens/collections_screen/collections_browser_screen.dart`
- `lib/providers/theme_provider.dart`

Pegasus:
- `README.md` and `LICENSE.md`
- `src/backend/model/gaming/Game.h`
- `src/backend/model/gaming/Collection.h`
- `src/backend/providers/pegasus_favorites/Favorites.cpp`
- `src/backend/providers/pegasus_playtime/PlaytimeStats.cpp`
- `src/backend/model/internal/GamepadAxisNavigation.*`
- `src/backend/model/internal/GamepadButtonNavigation.*`

## Porting map

| Pegasus concept | Flutter destination / approach |
|---|---|
| QML theme and menu composition | Flutter screens/widgets and the existing ThemeProvider |
| Game and collection QObject models | Existing GameModel / CollectionModel and repositories; extend only where a real gap exists |
| QML list/grid presentation | Existing game list, collection browser, and reusable Flutter components |
| Gamepad axis/button navigation | Existing gamepad navigation utilities; compare behavior and add tests before changing |
| Metadata/assets providers | Existing scraper/repository pipeline; reuse existing integrations rather than duplicating them |
| Playtime statistics | Existing GameSessionManager and playtime persistence; investigate play-count parity separately |
| Launch commands | Existing launcher services; do not bypass Android launch validation |

## Safe implementation sequence

1. Complete the feature matrix, including missing-game parity; play-count UI/storage is implemented, so validate it with the regression suite and Android builds.
2. Implement verified gaps natively in Flutter, preserving ECLIPSE visuals, the system selector, and all console-specific startup/home experiences.
3. Add unit/widget/database tests and run Flutter analysis plus Android debug build; no feature is considered complete until checks pass.
4. Compare Pegasus navigation, sorting, collections, metadata, and themes against existing Flutter behavior; port only measurable gaps.
5. Smooth the end-to-end flow (system selector → boot → console home → game selection → launch) without changing the established visual identity.
6. Integrate remaining ECLIPSE product features only after the core port is stable.
7. Verify signed APK update compatibility with the original application ID and signing certificate before publishing any release.

## Licensing and asset checks

Both repositories identify GPLv3 licensing for their main application code. If Pegasus source code is copied or adapted into the distributed ECLIPSE application, preserve required copyright notices, license text, modification notices, and GPLv3 source-distribution obligations. Confirm compatibility and distribution requirements before shipping.

Do not assume every file in Pegasus is GPLv3. Its README explicitly warns that some logos/product symbols and trademarks may have separate restrictions. Check each asset's own license before reusing it. The bundled Roboto font has a separate Apache 2.0 license file; preserve its notice if that font is redistributed. Prefer ECLIPSE-created visuals or properly licensed assets where possible.

## Non-goals

- Do not replace the existing NeoStation system menu.
- Do not discard console-specific startup and home experiences.
- Do not paste C++/Qt code into Dart files.
- Do not copy Pegasus logos, product marks, or artwork without checking rights.
- Do not create a release or APK claim until a real build and signing verification succeed.


## Expanded ECLIPSE product scope (requested)

This scope is additive to the existing NeoStation-derived app. Keep its system selector, console-specific startup sequences, and console home screens, while redesigning the general library/menu experience around Pegasus-inspired UX. The ECLIPSE signature palette is one selectable theme, not the only visual mode.


### Pegasus-inspired ECLIPSE interface redesign

- Treat the current library/menu presentation as a redesign target; do not preserve it merely for visual continuity.
- Port Pegasus-inspired browsing patterns into native Flutter: clean horizontal/vertical navigation, strong selected-game presentation, metadata hierarchy, collection browsing, sorting/filtering, favorites, and configurable layouts.
- Keep the existing NeoStation data layer, ROM scanning, emulator launch integrations, RetroAchievements, gamepad navigation, and console-specific startup/home experiences. Reuse these instead of rebuilding duplicate systems.
- Make the ECLIPSE, Light, Dark, and System modes first-class choices in Settings. ECLIPSE is the purple/cosmic signature theme; Light and Dark are neutral palettes; System follows Android brightness.
- Keep the UI legible and controller-friendly on handhelds such as the Odin, including safe-area handling, focus states, and scalable layouts.
- Do not claim the Pegasus-inspired UI port is complete until the redesigned screens are implemented and tested on Android.

### Library presentation and media

- Add optional per-system video previews (ES-DE-style) using locally cached or user-configured media. Videos must be muted, lightweight, lifecycle-aware, and disabled/reduced on low-power devices; never autoplay audio.
- Support system banner/hero artwork and game hero/banner artwork as distinct media roles, with fallbacks to existing box art/scraped artwork.
- Preserve system art packs already supplied by NeoStation. Theme/deck imports such as iiSU Dark are optional, user-selectable presentation packs; they must not replace the built-in system art pack.
- Keep artwork and video sources configurable and cache-aware. Do not bundle scraped copyrighted artwork/videos in the app package.

### Display modes

- Provide explicit Auto / Single display / Dual display preferences.
- Auto uses the existing secondary-display subsystem when a second display is available and falls back cleanly to the primary display.
- Single display keeps navigation, library, details, and playback controls usable on one screen.
- Dual display assigns complementary surfaces to each display (for example, library/navigation on the primary display and selected-game details/media on the secondary display), with no duplicated focus ownership or controller event handling.
- Handle display attach/detach, orientation changes, window resizing, and Android devices that expose no secondary display. Verify against the existing secondary_screen implementation before changing platform channels.

### Requested systems catalogue

Treat this as the requested catalogue, not a claim that every emulator/core or launcher is bundled. A system is selectable only when its platform definition exists; launch requires a user-installed compatible emulator/core and valid game files.

- Nintendo: NES, SNES, Nintendo 64, GameCube, Wii, Wii U, Switch, Game Boy, Game Boy Color, Game Boy Advance, Nintendo DS, DSi (optional alias/profile for DS), Nintendo 3DS, Virtual Boy, Pokémon Mini.
- Sony: PlayStation, PlayStation 2, PlayStation 3, PlayStation 4, PlayStation 5, PSP, PS Vita.
- Microsoft / PC: Xbox, Xbox 360, Steam, Windows PC, Android Games, Xbox Cloud Gaming (shortcut/integration only; requires the official supported app/service and user sign-in).
- Sega: Master System, Genesis/Mega Drive, Saturn, Dreamcast.
- Atari: 2600, 5200, 7800, Lynx, Jaguar.
- Other systems should remain extensible through user-defined platform profiles rather than being hard-coded into UI layouts.

Avoid duplicate system entries where aliases describe the same platform. Steam and Windows PC are separate library sources; Android Games is a separate user-managed source. Xbox Cloud Gaming is not a ROM platform.

### Metadata and scraping provider responsibilities

Implement providers behind a common interface, with per-provider enable/disable, API-key/account settings, attribution, rate-limit handling, cache, and field-level source priority. Never overwrite a user's manual edits without consent.

- IGDB: game metadata lookup (requires Twitch developer credentials and OAuth flow).
- ScreenScraper: metadata and media scraping (requires user account credentials; respect service limits).
- LaunchBox: metadata/media provider where permitted by its service/API terms.
- HowLongToBeat: play-length estimates only; do not treat it as an artwork provider or promise an official public API if access is unavailable.
- SteamGridDB: artwork roles such as grids, heroes, logos, and banners (requires user API key).
- RetroAchievements: account linking, supported-game matching, achievement progress, and profile data; achievements depend on supported cores/emulators and successful game identification.

- Existing NeoStation scraper integrations must be audited and reused where suitable rather than duplicated.

Provider credentials must be stored using platform-secure storage where available, never committed to source control, logs, exported config, or analytics. Scraping must be opt-in/configurable and respect each provider's terms and rate limits.

### Steam and play activity

- Distinguish Steam library/account integration from SteamGridDB artwork lookup. Steam sign-in/library access requires an approved, supported authentication/API approach; never collect a Steam password or imitate the Steam login page.
- Investigate GameNative as an optional Android/Steam compatibility/launch integration, not a required dependency. Only show titles and launch actions actually available through the installed integration.
- Expand play activity into daily activity history, per-game play count, total playtime, last played, and top-ranked games. Keep timezone-aware day boundaries and avoid double-counting interrupted sessions.
- Add a Players area for installed/available emulator and core profiles, with detected paths and launch capability status. It is a manager/view, not a promise to bundle emulators.

### First-run onboarding and branding

- Add a friendly original ECLIPSE mascot guide for first-run setup. Walk users through ROM/library folder selection, optional Steam connection, optional provider/API keys (including SteamGridDB), emulator/core detection, and display mode.
- Every step must be skippable and revisitable from Settings. Never require credentials to finish onboarding.
- Replace the Android launcher/app icon only after creating and validating the complete adaptive icon asset set (foreground/background/monochrome where supported) and checking the existing application ID/signing setup. Do not change the application ID or signing certificate as part of branding.

### Delivery gates (not optional)

1. Audit existing code and assets before adding duplicate systems, providers, or display services.
2. Implement core Pegasus parity and data integrity first; add tests for play count/session history.
3. Add system catalogue and source/provider adapters with credentials protected.
4. Add system/game video previews and hero/banner artwork with caching and fallback behavior.
5. Add explicit single/dual display preferences and verify actual secondary-display behavior on target hardware.
6. Add daily activity, top games, Players view, and first-run mascot onboarding.
7. Replace launcher icon assets and verify adaptive icon rendering.
8. Run formatting, Flutter analysis, tests, and Android debug build. Verify runtime behavior on single and dual displays.
9. Verify release signing compatibility before producing a distributable APK. No APK/release is complete until the build artifact and signing identity are confirmed.

Current PR work is still an initial slice, not completion of this expanded scope.

## CI workflow triggers and release safety

- **PR Checks** runs on pull-request events and on pushes to `main`. Pushing a commit to this open migration PR branch emits a pull-request synchronize event and is the safe way to request validation of this branch.
- **Build and Deploy** runs on a `v*` tag or manual workflow dispatch. It is a release pipeline, not the normal PR validation workflow.
- The Android release job must stop if any original signing secret is absent. Never create a release tag to work around missing signing credentials; a debug APK is not an update-compatible release.
- A successful PR debug build validates compilation only. It does not prove the original release certificate is available or that an APK can update an already-installed ECLIPSE build.


## Android handheld frontend checklist (additional requirements)

The following requirements were supplied as external product feedback and are now part of the ECLIPSE acceptance checklist. They complement the expanded scope above; they do not imply the features already exist.

### Metadata and library discovery
- Keep metadata providers behind the existing scraper/provider architecture. Audit TheGamesDB and other candidate sources for current API access, licensing, attribution, and rate limits before selecting an adapter.
- Support box art, screenshots, videos, descriptions, release metadata, and platform-specific media roles where the provider actually supplies them.
- Preserve manual metadata overrides and show which provider supplied a field; cache results and make scraping opt-in.
- Allow multiple ROM roots at once, including internal storage and SD-card/removable-storage locations. Persist Android Storage Access Framework tree permissions, associate each root with its system/profile, and handle revoked permissions or removed media without silently deleting library entries.
- Support user-defined system/emulator profiles through a documented XML import/export format. Validate imported XML, show a preview, reject unsafe or unsupported launch placeholders, and never execute arbitrary commands from an imported definition. Profiles for Yuzu or other standalone apps are configuration only; launching is available only when a compatible installed app and supported Android intent/API are detected.

### Controller-first navigation and touch usability
- Treat gamepad/controller navigation as a primary interaction model: predictable focus order, visible focus, axis repeat/dead-zone tuning, button mapping, back behavior, and no focus traps.
- Keep touch fully supported, especially in Settings, folder selection, metadata editing, and onboarding. Large touch targets and controller focus should coexist rather than forcing either interaction style.
- Add a configurable console-style / hide-Android-clutter mode. It should provide a focused full-screen launcher experience where Android permits it, with a clear escape path to system settings and no misleading promise that a normal app can hide system UI or replace the system HOME role without user authorization.

### Emulator and core launch integrations
- Support standalone emulator profiles (including Dolphin, PPSSPP, Vita3K, and other installed compatible apps) alongside RetroArch cores.
- Build a capability-based integration registry: detect installed apps and supported launch contracts, expose only verified launch options, and report missing/incompatible apps clearly. Do not bundle, download, or imply support for an emulator solely because its name appears in a catalogue.
- Keep per-system and per-profile launch arguments/configuration separate, validate URI/intent handling, and preserve user-selected emulator preferences.

### Dual-screen and performance
- Extend the existing Auto / Single / Dual display design to make the secondary surface useful for Now Playing, selected-game details, widgets, or optional touch controls. Let users choose the secondary-screen layout and retain a clean single-screen fallback.
- Keep browsing lightweight: lazy-load artwork, bound image/video caches, pause media when not visible or app is backgrounded, avoid expensive blur/animation on low-power devices, and expose a performance mode.
- Measure startup time, memory use, scroll/focus responsiveness, and preview decode behavior on representative Android handhelds rather than claiming performance from code inspection alone.

### Portable configuration and backups
- Add an explicit export/import flow for portable ECLIPSE configuration: system definitions, emulator profiles, library roots (as paths/URI references, not copied ROM data), theme/preferences, collections, and user metadata overrides.
- Keep credentials and secrets out of portable exports by default. Offer a separate opt-in secure migration flow only if a safe platform-supported mechanism is available.
- Make imports versioned, validate before applying, support backup/restore, and explain that SD-card URIs or absolute paths may need relinking on another device.

### Acceptance checks
- Test two or more ROM roots across internal storage and removable storage, including a revoked folder permission and a removed SD card.
- Test controller-only navigation through onboarding, library, settings, profile selection, and dialogs; repeat with touch-only navigation.
- Import/export a custom XML profile and verify invalid XML and unsafe launch templates are rejected.
- Test standalone emulator detection and launch only against apps actually installed on the test device; separately test RetroArch core selection.
- Verify console-style mode has a safe exit and behaves within Android's HOME/immersive-mode restrictions.
- Exercise secondary-screen Now Playing/details/widgets and hot-unplug fallback.
- Export settings on one device and restore on another without exporting credentials or ROM contents.
- Record performance measurements on target handheld hardware with media previews enabled and disabled.


## AYN handheld implementation target (Odin 3 + Thor)

This section is the hardware-specific product contract for ECLIPSE. It takes precedence over generic handheld assumptions above. The Odin 3 is a first-class single-screen target; the Thor is a first-class dual-screen target. Neither is treated as a reduced version of the other.

### Existing implementation discovered during the audit

The Flutter branch already contains substantial reusable groundwork:
- `SecondaryDisplayStateData` carries selected-game artwork, screenshot/video preview state, mute state, scraper progress, RetroAchievements, Now Playing/session data, dock apps, and display activity.
- `SqliteConfigSecondaryDisplay` handles secondary-display connect/disconnect, visibility, state synchronization, and accessibility-state updates.
- Android `SecondaryAppsPresentation` hosts the secondary Flutter engine and app dock channel.
- `StandaloneEmulatorModel`, `CoreEmulatorModel`, and `EmulatorModel` already distinguish standalone apps from RetroArch/Libretro cores.
- The systems catalogue already includes many requested platforms, including DS, 3DS, PS2, PSP, Wii U, Switch, PS3, Vita, and Xbox 360 definitions.

These are code-audit findings, not claims that every feature is polished or verified on Odin 3 / Thor hardware. Preserve and extend these implementations. Do not create a second secondary-display service, duplicate emulator registry, or duplicate platform catalogue.

### Device profiles and defaults

Ship editable device presets, with all recommendations overridable by the user.

| Capability | AYN Odin 3 | AYN Thor |
|---|---|---|
| Default display mode | Single | Auto / Dual when the second panel is detected |
| Main browsing surface | Full-screen library grid, carousel, or cover flow | Top-screen library grid, carousel, or cover flow |
| Companion surface | Hidden; optional user-selected secondary/external display if Android exposes one | Bottom-screen details, art, preview, and interactive control deck |
| Default system emphasis | Switch, PS3, Wii U, GameCube, PS2, PSP, and other installed-capability systems | DS, 3DS, PS2, PSP, Game Boy families, and other installed-capability systems |
| Performance policy | High-performance recommendation tier; never imply an emulator is installed | Balanced handheld recommendation tier; heavier systems hidden or marked advanced by default |
| User override | Always available | Always available |

Device detection must be capability-based and fail safely. A device name alone must never imply that a display, emulator, GPU feature, or Android permission is available. If detection is unavailable, use a generic profile and let the user select a preset manually.

### Thor dual-screen interaction contract

- Top screen owns primary browsing focus and controller navigation.
- Bottom screen supports assignable surfaces: selected-game details, artwork gallery, screenshots, muted preview, Now Playing, RetroAchievements, app dock, and an interactive control deck.
- Provide per-screen assignment, swap, and reset-to-default controls.
- Provide the established L3/R3 swap shortcut as a configurable binding; do not hard-code it if the controller mapping conflicts with a game or system action.
- Bottom-screen touch must not steal controller focus from the top-screen library. Preserve the non-focusable secondary presentation behavior.
- When a game launches, the top screen remains available to the emulator; the bottom screen may show supported Now Playing/achievement/artwork content. Do not promise overlays, live game input, cheat injection, or a mini-map unless a specific emulator integration exposes a safe supported API.
- On disconnect, hide secondary-only controls and move all essential navigation/details to the primary screen without losing selection.
- The Odin 3 and any single-screen device must never show empty secondary-display placeholders.

### Emulator profile contract

Support standalone Android emulator applications and RetroArch cores as separate launch targets. User-defined profiles may be imported from JSON/XML and must validate before use.

A profile may declare: stable ID, display name, supported system IDs, launch kind (Android package / RetroArch core / approved desktop executable), package or core identifier, supported ROM extensions, URI/path argument template, optional documented intent action, and user-visible notes.

Validation rules:
- Reject arbitrary shell commands, shell metacharacters, and untrusted executable scripts.
- Never collect emulator account passwords or silently install emulator apps.
- Resolve Android apps through package/intent APIs and verify the package is installed before enabling Launch.
- Resolve RetroArch cores only when the selected core is installed and supports the selected content.
- Keep user-defined profiles isolated from built-in defaults; export/import must not overwrite built-ins without explicit confirmation.
- Only advertise tested launch integrations. Eden/Yuzu, RPCS3, Cemu, Azahar, melonDS/WatermelonDS, and PPSSPP are target examples, not proof of working launch adapters.

### Metadata and in-session companion behavior

Reuse existing ScreenScraper and media lookup/cache paths first. Add TheGamesDB only behind the same provider abstraction, with provider enable/disable, attribution, rate limiting, source priority, cache, and manual-edit protection. Artwork roles must remain distinct (box/front, back, screenshot, fanart, wheel/logo, hero/banner, marquee, video).

On Thor, the bottom screen should be able to show the selected game's scraped media while browsing and an appropriate Now Playing surface during gameplay. Preview video must be muted by default, lifecycle-aware, cache-aware, and disabled on low-power settings. ES-DE companion mode is a separate integration mode: ECLIPSE may display companion content only when a documented external signal/API or user-selected media source exists. Do not claim to control ES-DE's top-screen process or read its private state without a supported integration.

### Controller and Android integration

- All primary flows must be usable without a keyboard: onboarding, library, settings, emulator selection, dialogs, and display assignment.
- Touch remains supported on both screens.
- Add configurable shortcuts for back-to-frontend and display swap. The AYN home button may be supported only through a documented Android input/accessibility mechanism and explicit user-granted permission; do not promise global interception where Android/device firmware blocks it.
- Never trap the user in kiosk/immersive mode. Android HOME and system escape behavior must remain available.

### Performance policy

- Lazy-load artwork and video; use bounded caches and cancel stale requests.
- Pause secondary-screen animation/video when the display sleeps, disconnects, or the app is backgrounded.
- Offer preview quality / motion reduction / low-power controls.
- Heavy-system recommendations must be informational, not a guarantee of playable performance. Do not auto-hide a user's manually pinned systems.
- Record startup time, library-scroll frame stability, artwork decode/cache behavior, and preview memory use on actual Odin 3 and Thor hardware before calling the experience optimized.

### Hardware acceptance gate

A release candidate is not handheld-ready until the following are checked on physical devices:
1. Odin 3: cold start, single-screen library, controller-only navigation, touch settings, emulator detection, launch/return, and no phantom second-screen UI.
2. Thor: top/bottom assignment, touch on both panels, L3/R3 swap, hot connect/disconnect, screen sleep/wake, launch/return, Now Playing, and bottom-screen focus isolation.
3. Both: import/export a valid custom profile; reject invalid/unsafe profiles; verify standalone package and RetroArch core launch separately.
4. Both: compare default system recommendations, then verify manual overrides persist.
5. Both: measure scrolling and preview performance with media enabled and disabled.
6. ES-DE companion mode: test only against a documented/available integration; otherwise clearly label it unavailable rather than simulating live linkage.

No device-level acceptance result is implied until these tests are run on the named hardware.
