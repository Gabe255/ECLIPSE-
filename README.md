# ECLIPSE — Your Gaming Universe

<div align="center">

**One home for your games, systems, emulators, and entertainment.**

![ECLIPSE — Your Gaming Universe](assets/branding/eclipse-banner.svg)

[![PR Checks](https://github.com/Gabe255/ECLIPSE-/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/Gabe255/ECLIPSE-/actions/workflows/pr-checks.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE.md)
[![GitHub stars](https://img.shields.io/github/stars/Gabe255/ECLIPSE-?style=flat)](https://github.com/Gabe255/ECLIPSE-/stargazers)

[Source](https://github.com/Gabe255/ECLIPSE-) · [Roadmap](docs/APPROVED_ECLIPSE_FEATURES.md) · [Releases](https://github.com/Gabe255/ECLIPSE-/releases) · [Report a bug](https://github.com/Gabe255/ECLIPSE-/issues/new)

</div>

---

## The idea

ECLIPSE is an Android-first gaming frontend built around one simple idea: **your games should feel like one connected universe, not a pile of separate apps.**

Bring your game library, systems, emulator handoffs, Android apps, and personal collections into a single customizable space. ECLIPSE is designed for handhelds, controllers, and TV-sized screens.

The visual identity blends deep-space surfaces, eclipse-inspired light, and restrained violet/cyan accents. ECLIPSE is the signature theme; other built-in and imported themes remain available.

## What is here

- **Game library** — scan configured folders, browse systems, and organize games.
- **Artwork and metadata** — use existing scraping and artwork services, including optional SteamGridDB support.
- **Collections and favorites** — keep a personal library organized.
- **Emulator handoff** — configure RetroArch and supported standalone emulators; ECLIPSE launches apps you have installed rather than bundling emulators.
- **Controller-first navigation** — browse the frontend with compatible gamepads and keyboards.
- **Personalization** — themes, library wallpaper, system art, and supported layout options.
- **Achievements and play history** — connect supported RetroAchievements features and track confirmed play sessions.
- **Android entertainment area** — discover and launch compatible apps installed on your device.
- **12 interface languages** — English, Spanish, Portuguese, Russian, Simplified Chinese, Traditional Chinese, French, German, Italian, Indonesian, Japanese, and Korean.

Some areas are actively evolving. The ECLIPSE AI panel is an early command-and-voice interface, not a fully connected cloud AI. The PS4/Bachata S4 path is experimental and depends on the separate emulator app. Check the roadmap and release notes for current status.

## Visual direction

| Element | ECLIPSE identity |
|---|---|
| Core palette | Void #100C19, deep plum #171022, lunar #F3EEFF |
| Primary accent | Eclipse violet #9B7BFF |
| Secondary accent | Aurora cyan #65D9E8 |
| Shape language | Soft rounded panels, orbital lines, clean focus rings |
| Motion | Smooth, purposeful transitions; reduced motion where appropriate |
| Voice | Confident, atmospheric, clear — never noisy or cluttered |

See the [brand guide](docs/BRAND_GUIDE.md) for the full visual rules.

## Get ECLIPSE

The official place for installable builds is the [GitHub Releases page](https://github.com/Gabe255/ECLIPSE-/releases). A CI validation APK is not the same as a signed public release. Release builds must use the project's original Android application ID and signing certificate so existing installs can update safely.

No public release is advertised here until a compatible release asset has actually been published.

## Build from source

Requirements: the Flutter SDK pinned in .fvmrc, Java 17 for Android builds, Git, and the Android SDK.

Clone and build a debug APK:

    git clone https://github.com/Gabe255/ECLIPSE-.git
    cd ECLIPSE-
    flutter pub get
    flutter build apk --debug

The APK is written to build/app/outputs/flutter-apk/app-debug.apk.

For a reproducible setup, use the Flutter version pinned by .fvmrc and enforce the committed lockfile:

    fvm install
    fvm flutter pub get --enforce-lockfile
    fvm flutter test
    fvm flutter analyze

### Android release signing

A release APK must be signed with the same certificate as the existing ECLIPSE installation if it is expected to update that installation. Configure android/key.properties using the example file and keep the keystore and passwords private. Release builds intentionally fail when the original signing configuration is unavailable. Do not replace it with a new debug or self-generated key.

## Project map

- assets/ — artwork, system definitions, device profiles, and branding
- android/ — Android application and platform integration
- lib/data/ — SQLite data sources
- lib/l10n/ — localization
- lib/models/ — domain models
- lib/providers/ — app state
- lib/repositories/ — data access
- lib/screens/ — frontend pages
- lib/services/ — launch, metadata, sync, and platform services
- lib/themes/ — visual themes
- lib/widgets/ — reusable UI
- test/ — Flutter regression tests
- docs/ — product roadmap, architecture, and brand guide

## Project identity and credits

ECLIPSE is the product, brand, and user-facing direction of this repository. The Flutter codebase originated from the open-source NeoStation project and still contains inherited internal package names and compatible upstream components while the migration continues. Those internal identifiers are not the ECLIPSE product name. Existing upstream work and third-party packages remain subject to their original licenses and attribution requirements.

ECLIPSE does not embed Pegasus or reuse its branding. Pegasus is one of the UX references informing the native Flutter redesign.

## Contributing

Bug reports, focused fixes, and thoughtful design feedback are welcome through [GitHub Issues](https://github.com/Gabe255/ECLIPSE-/issues). Before proposing a large feature, check the [approved roadmap](docs/APPROVED_ECLIPSE_FEATURES.md) and [port plan](docs/PEGASUS_FLUTTER_PORT_PLAN.md).
