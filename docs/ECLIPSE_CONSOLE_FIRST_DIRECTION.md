# ECLIPSE — Console-first direction

This document records the approved product direction for the ECLIPSE frontend.

## Locked decisions

- **Scope priority:** all previously approved ECLIPSE features remain in scope. Work should be sequenced by dependencies and user priority, not by dropping lower-ranked approved features.
- **Boot experience:** cinematic.
- **Interface:** console-first. Each detected system should open into a distinct, controller-first environment with ECLIPSE visual identity rather than a pixel-for-pixel copy of another launcher.
- **Startup audio:** adaptive. Use a system-specific startup sound where a licensed/owned sound asset is available; otherwise fall back gracefully to an ECLIPSE sound or silence. Respect global SFX enablement, volume, and device screen state.
- **Transitions:** seamless handoff from ECLIPSE startup to the selected system environment to the existing game launch flow.

## Protected foundations

Do not replace or regress the existing emulator/game-launch engine, ROM-folder onboarding, system artwork, game database/library, folder rescan, metadata/media storage, or controller navigation infrastructure. New presentation layers must call into these existing services rather than duplicate them.

Do not implement User Profiles or Smart Collections without separate approval.

## Priority order

1. Console-style startup and system environments, including adaptive audio and seamless transitions.
2. Complete the Fire TV-style Entertainment Center for installed Android apps, retaining the existing installed-app discovery and launch flow.
3. Custom Boot Designer, Controller Hub, and Performance Dashboard.
4. SteamGridDB runtime verification and end-to-end artwork download checks.
5. Full app icon, adaptive icon, native splash, Flutter startup, and residual legacy-branding audit.
6. Complete the remaining previously approved ECLIPSE features: Cinematic Home, Quick Control Center, Achievement Center, Theme Studio, Continue Playing, and related polish.

## Definition of done

A feature is not complete merely because a screen or placeholder exists. It must:
- use real application/device data where applicable;
- support handheld and controller navigation;
- handle loading, empty, unavailable, and error states;
- respect lifecycle, battery, screen-off, and external-app/game handoffs;
- preserve existing game launch and storage behavior;
- include focused automated tests and pass the relevant CI checks;
- be exercised on target Android handheld hardware before being described as device-verified.

## Console boot and transition acceptance checks

- The app can show an ECLIPSE-branded startup and then the selected system's own boot sequence without a jarring visual jump.
- Each system environment has a coherent, recognizable visual treatment while retaining original ECLIPSE design language.
- Startup audio is selected from configured system-specific assets only when available and allowed; missing assets never block boot.
- User input can skip or complete the animation without leaving navigation stuck.
- Opening a library and launching a game preserves the current emulator integration and restores controller focus on return.
- Reduced-motion/performance preferences and silent mode are respected.

## Verification status

This file records approved direction and acceptance criteria; it does not claim that the listed features are implemented or verified. Current console experience code already contains per-system boot/home foundations, but app-wide startup orchestration, adaptive boot audio, and end-to-end seamless transition verification remain work items.
