# ECLIPSE — Product Direction

ECLIPSE is the product identity and user experience built on the NeoStation Flutter codebase. Pegasus is a separate GPLv3 reference implementation used to study theme architecture, navigation flexibility, and library presentation. The Pegasus C++/Qt frontend is not merged into this Flutter application.

## Product principles

- One ECLIPSE app, one library, one settings system.
- Controller-first, with touch and mouse support.
- Landscape-first layouts that scale from handheld screens to Android TV and desktop.
- A dark cosmic visual identity with restrained purple accents, readable contrast, and smooth transitions.
- Preserve the existing scanning, emulator launching, gamepad, achievements, metadata, and save-sync services while replacing presentation incrementally.
- Never label a feature complete until it is implemented, tested, and verified on a device.

## Main experience

1. **ECLIPSE startup** — branded boot animation, then a short readiness transition. Startup must not block on optional network services.
2. **Home** — a featured hero area for the focused/recent game or selected platform, followed by horizontally navigable content rows.
3. **Platforms** — console-specific entry points. Selecting a platform opens its own themed landing view before showing that platform's games.
4. **Games** — horizontal shelves with clear titles, artwork, metadata, favorites, and playtime. A single available shelf expands into a featured hero instead of leaving a sparse screen.
5. **Collections** — user-created and smart collections, surfaced as their own shelves.
6. **Settings** — one predictable settings hub with clear categories, search, and consistent back behavior.

## First-run experience

- A small ECLIPSE guide mascot introduces the library setup.
- Explain why a ROM/game folder is needed before opening the platform folder picker.
- Ask where game data should be stored only when a feature actually needs a storage location; explain the choice and allow changing it later.
- Offer a clear route to add a platform, scan the library, or skip optional setup.
- Every first-run action must be reachable by touch and gamepad.

## Platform flow

The intended flow is:

`ECLIPSE startup → Home → Platform landing → Platform games → Game details → Launch`

Each platform landing page may use its own accent color and artwork, but navigation, controls, settings, and data remain consistent across platforms.

## Pegasus research notes

Use Pegasus as a reference for:
- user-controlled layouts and themes;
- clear, predictable navigation between library sections;
- flexible presentation of game collections;
- responsive artwork and metadata layouts.

Do not copy Pegasus product logos, console trademarks, or bundled artwork into ECLIPSE. The Pegasus source is GPLv3 with additional Section 7 terms and asset/trademark caveats; preserve its notices if any source code is ever adapted. Prefer original Flutter implementations of the interaction patterns.

## Implementation order

1. Rebrand the NeoStation-derived app shell as ECLIPSE without changing its internal Dart package namespace.
2. Establish the ECLIPSE cosmic theme and app identity.
3. Replace the top-level navigation and Systems landing presentation with the ECLIPSE home/shelf model while preserving existing gamepad navigation layers.
4. Add platform landing pages and per-platform startup transitions.
5. Add onboarding mascot and guided setup.
6. Add Treat as Game, home pinning, playtime presentation, and data-location prompts where missing.
7. Add customization for shelves, hero banners, home sections, and widgets.
8. Verify Android install/update signing, storage permissions, gamepad navigation, and emulator launch on real hardware.

## Compatibility and release safeguards

- Keep Android application ID `com.eclipse.launcher` for ECLIPSE update compatibility.
- Keep the Android signing certificate stable across releases. Changing the application ID or signing key can prevent in-place updates.
- Preserve NeoStation's upstream copyright and GPLv3 notices. Clearly mark ECLIPSE modifications.
- Pegasus is a separate repository and codebase; do not combine its Qt/C++ project into the Flutter app.
- Keep the original `Gabe255/ECLIPSE` repository untouched until the new fork is ready to replace it.
