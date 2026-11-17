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
