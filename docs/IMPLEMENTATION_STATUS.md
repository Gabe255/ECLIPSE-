# ECLIPSE Implementation Status

Last updated: 2026-11-23

## In this branch

- Native ECLIPSE home shell routed into the Systems tab.
- Existing SQLite-backed detected systems, ROM counts, recent-played data, and system selection are reused.
- Persistent five-destination ECLIPSE dock for Library, Discover, Systems, Entertainment, and Settings.
- Native home search and Quick Menu entry points; the legacy global tab header is hidden on the ECLIPSE home to prevent overlapping navigation.
- Persistent searchable Console Experience Switcher with saved selection.
- Selected experience updates the home accent palette and active profile identity; this is a presentation adaptation, not yet a fully independent console dashboard.
- Catalog of 44 dashboard/presentation profiles.
- Quick Menu, Entertainment hub, console Spotlight updates, and Recovery Center/setup restore foundations integrated from the superseded feature branches.
- Product roadmap and architecture guardrails.

## Superseded development branches

- PR #2 / `feature/eclipse-console-quick-menu` was closed after its compatible Quick Menu, Entertainment, and Spotlight changes were integrated into this branch.
- PR #3 / `feature/eclipse-next-gen-experiences` was closed after its Recovery Center and setup restore foundations were integrated into this branch.

The integrated features still require full validation and device testing before release.

## Not yet complete in this branch

- Fully independent layouts, navigation behavior, and boot/shutdown sequences for console profiles; current profile switching changes identity and accent styling only.
- New game library and redesigned game detail pages.
- End-to-end emulator/app integrations and capability detection.
- Wii/Wii U pointer engine and dual-screen manager.
- Performance, controller, achievements, save, backup, compatibility, safe mode, and quality-assurance interfaces.
- ECLIPSE AI service/backend, opt-in diagnostic submission, and community feedback service.
- Creator Studio, downloadable content marketplace, and extension SDK.
- Fresh CI validation after the latest home changes, signed release APK, and physical-device validation on AYN Odin 3 and Thor.

## Release rule

A catalog entry is a presentation profile, not proof of emulator availability. Features are only marked complete after implementation, error handling, automated tests, CI validation, and device verification.
