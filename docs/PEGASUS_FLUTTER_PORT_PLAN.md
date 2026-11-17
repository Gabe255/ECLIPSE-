# ECLIPSE Pegasus-to-Flutter Port Plan

Status: planning/audit only. This document does not claim that Pegasus code has been migrated.

## Source of truth

- Working Flutter base: `Gabe255/ECLIPSE-` (NeoStation-derived Flutter/Dart app).
- Reference project: `Gabe255/pegasus-frontend` (C++11, Qt/QML).
- Legacy ECLIPSE app: `Gabe255/ECLIPSE` (Vite/Capacitor; retain as backup/reference until migration is verified).
- The imported duplicate repositories are not build dependencies and can be removed by the repository owner after confirming they contain no unique work.

## Architecture decision

Keep Flutter/Dart and the existing NeoStation layered architecture. Do not embed Qt/QML or attempt to compile Pegasus UI inside the Flutter app.

NeoStation already has:
- Presentation screens and reusable widgets under `lib/screens/` and `lib/widgets/`.
- Provider-based state under `lib/providers/`.
- Services under `lib/services/`.
- Repositories and SQLite data sources under `lib/repositories/` and `lib/data/datasources/`.
- Game, collection, system, emulator, and play-session models.
- Existing gamepad navigation and game-library browsing.

Pegasus should be studied as a reference for interaction and product behavior, then compatible behavior should be implemented using Flutter widgets, Dart state, and existing NeoStation services/repositories.

## Pegasus areas to study

1. Game and collection model behavior: metadata, assets, favorites, missing entries, play count, play time, and last-played state.
2. Theme and layout system: flexible screens, theme configuration, responsive layout, and reusable UI patterns.
3. Navigation: keyboard/gamepad focus, axis dead zones, button navigation, selection behavior, and predictable focus restoration.
4. Library organization: collections, sorting, filtering, favorites, folders, and metadata presentation.
5. Launch/session behavior: launch parameters, play-session tracking, and error handling.
6. Android-specific behavior and platform boundaries.

## Porting map

| Pegasus concept | Flutter destination / approach |
|---|---|
| QML theme and menu composition | Flutter screens/widgets and the existing ThemeProvider |
| Game and collection QObject models | Existing GameModel / CollectionModel and repositories; extend only where a real gap exists |
| QML list/grid presentation | Existing game list, collection browser, and reusable Flutter components |
| Gamepad axis/button navigation | Existing gamepad navigation utilities; compare behavior and add tests before changing |
| Metadata/assets providers | Existing scraper/repository pipeline; reuse existing integrations rather than duplicating them |
| Playtime statistics | Existing GameService and playtime persistence; verify edge cases |
| Launch commands | Existing LauncherService / GameService; do not bypass Android launch validation |

## Safe implementation sequence

1. Inventory the current NeoStation screens, models, providers, services, tests, and Android launch flow.
2. Build a Pegasus feature matrix: existing, missing, partial, and not relevant to ECLIPSE.
3. Select one low-risk vertical slice (for example, game browsing/focus behavior) and document acceptance criteria.
4. Implement the slice natively in Flutter without replacing existing system selection or console-specific startup/home work.
5. Add unit/widget tests and run Flutter analysis plus Android debug build.
6. Repeat for collections, themes, metadata, gamepad behavior, and playtime only where gaps are confirmed.
7. Integrate remaining ECLIPSE product features after the port audit; avoid speculative feature additions until the base is stable.
8. Verify signed APK update compatibility with the original application ID and signing certificate before publishing any release.

## Licensing and asset checks

Both repositories identify GPLv3 licensing for their main application code. If Pegasus source code is copied or adapted into the distributed ECLIPSE application, preserve required copyright notices, license text, modification notices, and GPLv3 source-distribution obligations. Confirm compatibility and distribution requirements before shipping.

Do not assume every file in Pegasus is GPLv3. Its README explicitly warns that some logos/product symbols and trademarks may have separate restrictions. Check each asset's own license before reusing it. The bundled Roboto font has a separate Apache 2.0 license file; preserve its notice if that font is redistributed. Prefer ECLIPSE-created visuals or properly licensed assets where possible.

## Non-goals

- Do not replace the existing NeoStation system menu.
- Do not discard console-specific startup and home experiences.
- Do not paste C++/Qt code into Dart files.
- Do not copy Pegasus logos, product marks, or artwork without checking rights.
- Do not create a release or APK claim until a real build and signing verification succeed.

## Current audit notes

- NeoStation's architecture document describes a layered Flutter application with Provider state, services, repositories, and SQLite.
- Pegasus README describes a C++11/Qt 5.15+ application with QML/QtQuick UI.
- Pegasus game models expose useful concepts such as metadata, collections, favorites, play count, play time, last played, assets, and launch parameters.
- The two stacks are different; the port is a behavior/design adaptation, not a direct source-file merge.
