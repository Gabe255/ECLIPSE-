# ECLIPSE — 100-feature expansion

Status: approved expansion backlog, added 2026-11-22.
Target: `migration/pegasus-flutter-port`.

This is a product backlog, not a claim that these features are already implemented. Existing capabilities and the approved ECLIPSE roadmap remain the source of truth. Before implementation, each item must be checked against the current code and either reused, extended, or removed if it duplicates an existing capability.

## Guardrails

- Preserve the existing emulator engine, ROM scanner, SAF folder grants, SQLite database, scraping/metadata pipeline, artwork/system-art pipeline, launch routing, controller navigation, and Android app handoff.
- Reuse existing providers, services, repositories, and data models. No parallel game library or emulator backend.
- Do not bundle ROMs, BIOS, firmware, copyrighted media, or proprietary console assets.
- Only show device, controller, compatibility, or gameplay data when it is actually available and its source is clear.
- Destructive file actions require a preview and explicit confirmation. Never silently delete user data.
- Every user-facing string must be localized in all 12 supported languages; every full-screen flow must support controller navigation.
- Ship in small phases with tests. A backlog item is not complete until it is wired to real data and verified.

## 50 mini features

### Library polish
1. **Per-system sort memory** — remember the user's chosen sort order independently for each system.
2. **Quick filter chips** — one-tap filters for favorites, recently played, never played, and incomplete metadata.
3. **Resume-state badges** — distinguish a confirmed resume point from an ordinary last-played timestamp.
4. **Metadata completeness meter** — show which useful fields are present or missing for each game.
5. **Artwork quality flags** — identify missing, low-resolution, or mismatched artwork for review.
6. **Metadata source labels** — show which configured scraper or local source supplied a field.
7. **Cache freshness labels** — show when artwork or metadata was last refreshed.
8. **Region and revision tags** — display region/revision only when known from reliable metadata or filename parsing.
9. **Disc-set summary chips** — show the number of detected discs and whether the set looks incomplete.
10. **Game path details** — show the selected file/folder location with a copy action.
11. **Per-game personal rating** — let users rate their own library entries.
12. **Private game notes** — attach short notes to a game without changing scraped metadata.
13. **Custom game tags** — create and apply user-defined tags.
14. **Hide-from-home toggle** — keep a game installed while removing it from featured home shelves.
15. **Per-system empty-state tips** — explain how to add games when a system has no entries.

### Navigation and controls
16. **On-screen button legend** — context-sensitive A/B/X/Y and shoulder-button hints.
17. **Focus trail** — subtle visual breadcrumb showing the current system and navigation depth.
18. **Configurable focus sound** — choose from original ECLIPSE UI sound sets or silence.
19. **Animation intensity control** — reduce or increase UI motion independently of the global performance mode.
20. **Wallpaper dim control** — adjust artwork brightness behind readable interface panels.
21. **Card density presets** — compact, balanced, and spacious card layouts.
22. **Hold-to-confirm option** — optional hold confirmation for selected destructive actions.
23. **Controller reconnect notice** — clearly report when a controller disconnects or reconnects.
24. **Input tester overlay** — show live button and axis input for troubleshooting.
25. **Dead-zone calibration helper** — visualize stick drift and let users tune supported app-side thresholds.
26. **Controller profile labels** — name detected controller configurations.
27. **Navigation repeat tuning** — adjust D-pad repeat delay and rate.
28. **Quick return shortcut** — configurable controller shortcut back to ECLIPSE home.
29. **Focus restore memory** — return to the previously focused game after leaving a details view.
30. **Reduced-flash mode** — avoid rapid flashes and high-contrast transition effects.

### Scanning and maintenance
31. **Scan change preview** — summarize additions, changes, and missing paths before applying a scan.
32. **Scan pause/resume** — pause long library scans and continue later where the scanner supports it.
33. **Per-folder scan status** — show progress and last successful scan for each configured folder.
34. **Artwork-only refresh** — refresh artwork without repeating a full metadata scan.
35. **Metadata-only refresh** — refresh metadata without redownloading unchanged artwork.
36. **Failed-item retry queue** — retry only failed scraper or artwork tasks.
37. **Storage threshold alerts** — warn when app-managed cache or artwork storage crosses a user-set threshold.
38. **Cache size breakdown** — separate artwork, metadata, thumbnails, and other app-managed cache totals.
39. **Export scan report** — create a shareable diagnostic report without ROM contents or secrets.
40. **Library backup reminder** — remind users to back up configuration and app-managed library data.

### Play insights and personalization
41. **Per-system playtime totals** — summarize confirmed play sessions by system.
42. **Monthly play recap** — summarize verified launches and playtime for a selected month.
43. **Session labels** — let users privately label a play session.
44. **Personal completion marker** — mark a game as completed without claiming external achievement data.
45. **Backlog marker** — mark a game as something the user wants to play later.
46. **Quick screenshot gallery** — browse screenshots already captured and stored by supported sources.
47. **Favorite system shortcuts** — pin preferred systems to a compact navigation strip.
48. **Home shelf visibility toggles** — show or hide supported home sections.
49. **Theme preview snapshots** — compare the current theme with a pending theme before applying it.
50. **Local data export shortcut** — guide users through exporting supported ECLIPSE settings and personal records.

## 50 major features

### Game intelligence and launch quality
1. **Device Compatibility Lab** — maintain transparent per-device compatibility notes based on user-confirmed tests, not guessed ratings.
2. **Game Launch Profiles** — save supported per-game launch preferences and emulator arguments through existing configuration paths.
3. **Smart Emulator Routing** — choose among already-installed, compatible emulator options using explicit user rules and verified system support.
4. **Launch Diagnostics Center** — explain failed launches using real launcher results, permissions, missing apps, and file-access errors.
5. **Game File Integrity Inspector** — calculate supported hashes and compare them with trusted metadata sources where available.
6. **Duplicate ROM Review Studio** — compare candidate duplicates by hash, size, filename, region, and disc relationships before any user-approved cleanup.
7. **Multi-disc Set Manager** — group related discs, validate playlist references, and launch through existing multi-disc support.
8. **Game Version Shelf** — keep alternate revisions organized as separate entries linked to one parent game.
9. **Emulator Capability Matrix** — show which installed emulator supports each configured system and relevant file formats.
10. **Per-game Control Profiles** — save ECLIPSE-side controller preferences and supported mappings for individual games.
11. **Controller Compatibility Library** — let users record tested controller/system combinations and share anonymized compatibility notes.
12. **Launch Session Diagnostics** — collect opt-in local logs around launch and return-to-app behavior for troubleshooting.

### Personal gaming tools
13. **Game Journal** — create a private timeline of notes, milestones, screenshots, and memorable moments.
14. **Challenge Tracker** — define personal goals for a game and track progress manually or from verified supported data.
15. **Speedrun Toolkit** — provide an optional session timer, split notes, and personal-run history without claiming official leaderboard verification.
16. **Practice Session Planner** — organize user-created practice goals and reminders for selected games.
17. **Game Guide Library** — attach user-owned manuals, walkthrough documents, and notes to library entries.
18. **Manual Reader** — browse supported local PDF and image manuals inside ECLIPSE.
19. **Personal Review Studio** — write private reviews with pros, memories, and a personal score.
20. **Collection Milestone Cards** — create shareable cards from verified library and personal records.
21. **Play Session Timeline** — inspect confirmed sessions, duration, and user-added notes chronologically.
22. **Local Party Planner** — prepare a couch multiplayer session with selected games, player count, and controller checklist.
23. **Local Tournament Brackets** — create and track offline brackets for games in the user's collection.
24. **Family-Friendly Library Labels** — let users label titles with their own content notes and browsing preferences.

### Console and immersion systems
25. **Console Profile Packs** — save a complete set of console home layout, sound, motion, and navigation preferences per system.
26. **Console Home Layout Editor** — rearrange supported console-home panels without changing the underlying game library.
27. **System Startup Sequence Editor** — build original, skippable ECLIPSE startup sequences from approved visual and sound components.
28. **Living Game Scene Builder** — compose a game-focus screen from available local artwork, metadata, and media.
29. **Game Atmosphere Presets** — save artwork-derived background and motion settings per game or system.
30. **Ambient Scene Gallery** — create idle scenes from user-owned artwork and local media with sleep and battery safeguards.
31. **Dual-screen Workspace Profiles** — configure separate secondary-display layouts for game details, controller tools, and session information.
32. **Thor Companion Workspace** — a device-aware companion dashboard that uses the secondary display when supported and gracefully falls back to one screen.
33. **Console Soundscape Studio** — assign original ECLIPSE UI sounds to navigation, focus, confirmation, and transitions.
34. **Accessibility Preset Studio** — save combinations of reduced motion, contrast, text scale, focus visibility, and controller behavior.

### Device and performance intelligence
35. **Handheld Device Profiles** — save user-selected display, control, and performance preferences for each supported device.
36. **Per-system Performance Presets** — create app-side presets for supported UI effects and launch preferences, without pretending to control inaccessible hardware settings.
37. **Performance Benchmark Journal** — record user-run benchmark results with device, app version, and test conditions.
38. **Battery-aware UI Mode** — reduce optional animations and ambient effects when the device reports low battery.
39. **Thermal Awareness Mode** — react only to reliable thermal status exposed by supported APIs; otherwise show an unavailable state.
40. **Display Calibration Wizard** — guide users through safe UI scale, overscan, and refresh presentation checks.
41. **Storage Location Explorer** — map configured game folders and app-managed data with clear SAF permission status.
42. **External Storage Health Checks** — detect unavailable or revoked folder access and guide the user to restore permissions.
43. **Offline Readiness Center** — show which library metadata, artwork, manuals, and configuration are already available offline.
44. **Backup and Restore Studio** — preview and export supported settings, mappings, collections, and personal records with versioned backups.

### Sharing and ecosystem
45. **Local Network Library Transfer** — transfer user-selected files between devices on the same network with pairing, confirmation, and progress.
46. **ECLIPSE Device Handoff** — export a game/session handoff record so another ECLIPSE device can open the same library entry when its own ROM is available.
47. **Portable Configuration Bundles** — export/import themes, layouts, controller profiles, and system preferences without secrets or ROM data.
48. **Community Theme Gallery** — browse and import user-created ECLIPSE themes with clear provenance and safe file validation.
49. **Community Controller Profile Gallery** — share/import controller mappings with device and controller compatibility notes.
50. **Open Plugin Interface** — define a permission-scoped extension API for future integrations, with explicit user approval and no unrestricted access to ROMs or private data.

## Suggested delivery waves

- **Wave 1 — quality foundation:** mini features 1–10, 16–20, 23–29, and major features 1–4, 6–12.
- **Wave 2 — library mastery:** mini features 31–40 and major features 5, 7–9, 13–24.
- **Wave 3 — console experience:** mini features 11–15 and 41–50, plus major features 25–34.
- **Wave 4 — device ecosystem:** major features 35–50.

Prioritize features that can be backed by existing local data and APIs. Large items should be split into independently testable slices; no single release should attempt to ship all 100 at once.
