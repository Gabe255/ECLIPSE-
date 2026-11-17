# ECLIPSE Pegasus-to-Flutter Port Plan

Status: active audit. The audit has inspected the Flutter models/services and selected Pegasus model/providers. No Pegasus source or assets have been copied into the app yet.

## Source of truth

- Working Flutter base: `Gabe255/ECLIPSE-` (NeoStation-derived Flutter/Dart app).
- Reference project: `Gabe255/pegasus-frontend` (C++11, Qt/QML).
- Legacy ECLIPSE app: `Gabe255/ECLIPSE` (Vite/Capacitor; retain as backup/reference until migration is verified).
- Imported duplicate repositories are not build dependencies and can be removed by the repository owner after confirming they contain no unique work.

## Architecture decision

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
| Play count | Pegasus exposes a separate play-count value; the inspected Flutter game/database models expose last-played and total playtime but no play-count field | Confirm whether the SQLite schema already tracks count; if not, design a versioned migration and tests before adding it |
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

1. Complete the feature matrix, including SQLite schema and tests for play-count and missing-game parity.
2. Select one verified gap with low migration risk and define acceptance criteria.
3. Implement the gap natively in Flutter, preserving the existing system menu and console-specific startup/home experiences.
4. Add unit/widget/database migration tests and run Flutter analysis plus Android debug build.
5. Repeat for themes, navigation, collections, metadata, and playtime only where gaps are confirmed.
6. Integrate remaining ECLIPSE product features after the port audit; avoid speculative feature additions until the base is stable.
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
