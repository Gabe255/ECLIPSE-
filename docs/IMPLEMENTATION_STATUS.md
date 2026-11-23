# ECLIPSE Implementation Status

Last updated: 2026-11-23

## In this branch

- Native ECLIPSE home shell routed into the Systems tab.
- Existing SQLite-backed detected systems, ROM counts, recent-played data, and system selection are reused.
- Persistent searchable Console Experience Switcher.
- Catalog of 44 dashboard/presentation profiles.
- Product roadmap and architecture guardrails.

## Related open development work

- PR #2 / `feature/eclipse-console-quick-menu`: console Spotlight, controller-first Quick Menu, and Entertainment Mode.
- PR #3 / `feature/eclipse-next-gen-experiences`: user-data recovery service, setup-time restore flow, and recovery tests.

These branches are separate and must be integrated/reviewed before claiming their features are part of a released build.

## Not yet complete in this branch

- Full independent layouts and boot/shutdown sequences for every catalog profile.
- New game library and redesigned game detail pages.
- End-to-end emulator/app integrations and capability detection.
- Wii/Wii U pointer engine and dual-screen manager.
- Performance, controller, achievements, save, backup, compatibility, safe mode, and quality-assurance interfaces.
- ECLIPSE AI service/backend, opt-in diagnostic submission, and community feedback service.
- Creator Studio, downloadable content marketplace, and extension SDK.
- Final Android build and physical-device validation on AYN Odin 3 and Thor.

## Release rule

A catalog entry is a presentation profile, not proof of emulator availability. Features are only marked complete after implementation, error handling, automated tests, CI validation, and device verification.
