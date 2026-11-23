# ECLIPSE Product Roadmap

This document records the agreed product direction. It is a roadmap, not a claim that every item is already implemented.

## Architecture guardrails

Preserve the existing ROM detection and scraping, emulator launch pipeline, artwork and metadata pipeline, storage permissions, and game database. Replace the launcher-facing home, navigation, platform library, game detail pages, settings presentation, and overall visual language. Do not fork or duplicate the existing library backend.

A dashboard profile is a presentation experience. It does not imply that an emulator is installed, compatible, or available. Show play actions only when a verified launch integration exists.

## Console and platform experiences

The catalog includes PlayStation 5, PlayStation 4, PlayStation 3, PlayStation 2, original PlayStation, PlayStation Classic, PSP, PSP Go, PS Vita, Xbox Series, Xbox One, Xbox 360, original Xbox, Nintendo Switch 2, Nintendo Switch, Wii U, Wii, GameCube, Nintendo 64, Nintendo 3DS, Nintendo DS, Game Boy Advance, Game Boy Color, original Game Boy, Sega Genesis/Mega Drive, Sega Saturn, Dreamcast, Game Gear, Master System, Neo Geo, Neo Geo Pocket Color, Atari 2600, Atari Lynx, Atari Jaguar, PC Engine/TurboGrafx-16, WonderSwan, NES/Famicom, SNES, Amiga, DOS Gaming, SteamOS Gaming Mode, GameNative, GameHub/GameHub Lite, and Fire TV-style Entertainment Mode.

Each console experience should eventually have its own boot sequence, home layout, sounds, transitions, game shelves, and controller-first interactions. The visual direction is inspired by the reference platforms, but the implementation and assets must be original.

## Dual-screen and pointer systems

- Shared pointer engine with gyro, right-stick, touch, sensitivity, smoothing, calibration, and per-game profiles.
- Wii pointer profile and Wii U GamePad-inspired profile.
- Dual-screen manager for supported devices and emulators, including top/bottom layout, swap, resize, touch mapping, and per-game persistence.
- Eden Duo and other emulator integrations must use documented capabilities and must not pretend to provide unsupported second-screen behavior.

## Library and dashboard

- New platform library, living game dashboard, animated covers, redesigned game details, Continue Playing, universal search, collections, activity history, trophy room, and game encyclopedia.
- Console Experience Switcher and persistent per-device preferences.
- Theme Studio, customizable layouts, widgets, pointer packs, sound packs, and cinematic boot designer.

## Gaming utilities

- Quick Menu / Control Center, controller-first navigation, Input Studio, Controller Hub, Performance Dashboard, In-Game Overlay, Achievement Center, Save Manager, Storage Intelligence, Offline Mode, Notification Center, Backup/Restore, Safe Mode, Recovery Center, Update Center, Compatibility Center, and Quality Assurance Center.

## Integrations and entertainment

- SteamOS-inspired PC gaming experience.
- GameNative, GameHub, and GameHub Lite detection and launch integration where their public integration surfaces permit.
- Fire TV-style Entertainment Mode that discovers installed media apps and launches them through Android intents where supported.
- Device Bridge for supported local transfer and sync.

## ECLIPSE Connect and Creator Hub

- Built-in ECLIPSE AI for help with the app and guided troubleshooting.
- Report a Problem and Suggest an Idea flows.
- Feedback HQ for triage, duplicate grouping, status, and community voting.
- Creator Studio and Community Hub for user-created themes, console experiences, layouts, boot packages, widgets, covers, pointers, and sound packs.
- Extension SDK with permissions, package validation, and compatibility metadata.

## Release strategy

### 1.0 foundations
Native ECLIPSE shell, new library navigation, real launch integration, core console experience, controller support, Quick Menu, first-run setup, basic Theme Studio, Recovery Center, reporting and suggestions, backup, compatibility checks, offline basics, safe update behavior, and device testing.

### 1.1 expanded ecosystem
Additional console experiences, dual-screen/pointer profiles, performance and achievement surfaces, broader emulator integrations, Device Bridge, advanced diagnostics, and community voting.

### 2.0 creator ecosystem
Creator Studio, downloadable community experiences, moderated marketplace, extension SDK, developer tools, and richer AI diagnostics.

## Definition of done

No fake buttons, placeholder success states, invented emulator support, or silent destructive actions. Each feature needs a real capability check, error handling, user consent for diagnostics, tests, and a documented fallback when hardware or emulator support is missing.
