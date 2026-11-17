# ECLIPSE — Console Experience Integration

ECLIPSE keeps the NeoStation-derived systems carousel, grid, scanning, gamepad navigation, settings, emulator integrations, and game library. This work adds a console-specific experience after a user selects a real system.

## Intended flow

`ECLIPSE app startup → existing systems carousel/grid → console boot → console home → existing game library → existing game launch flow`

The console home is an intermediate layer, not a replacement for the app's systems screen or game browser. Back returns from the game library to that console's home, then from the home to the existing systems screen.

## Design direction

Use the selected system's existing metadata (name, icon, accent color, manufacturer, ROM count, and optional description) to make its screen feel tied to that platform. Build original interfaces inspired by broad console navigation patterns:

- PSP-inspired horizontal XMB-style category navigation.
- Wii-inspired channel tiles.
- DS/3DS-inspired dual-panel layout that adapts to single-screen Android devices.
- A platform-themed home layout for other systems, with the same clear entry into the game library.

Do not copy Konsoru's source code, graphics, logos, or other assets. Its public release repository is binary-only. Recreate interaction patterns with original Flutter widgets and ECLIPSE's own assets.

## Integration rules

- Do not replace or redesign the existing NeoStation systems carousel/grid.
- Do not create a second game database or a second emulator launch pipeline.
- Reuse `SystemGamesList` and its existing launch, metadata, achievements, and gamepad behavior.
- Keep virtual entries such as Recent Games, All Games, Search, Collections, and Android apps on their existing navigation paths.
- Keep the current database schema compatible.
- Preserve the Android application ID `com.eclipse.launcher` and the same release signing certificate to support in-place updates.

## Current implementation

- Real console selections now open a console-specific boot transition.
- PSP, Wii, DS/3DS, and other platforms receive different home layouts.
- The console home opens the existing system game library; existing game launch behavior remains in place.
- The systems carousel and its virtual-system navigation remain the entry point.

## Verification still required

A successful source commit is not proof of a working APK. Run the Android build, resolve analyzer/compiler failures, then verify on-device: console selection, boot skip/timing, game library navigation, game launch, back navigation, touch, and controller input. Do not publish a release until the build and signing checks pass.
