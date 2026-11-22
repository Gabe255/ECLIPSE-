# ECLIPSE Backend Reuse Boundary

Status: approved implementation direction — 2026-11-22

## Product boundary

ECLIPSE owns the product, navigation, visual design, console startup experiences, and all user-facing screens. Reuse compatible backend capabilities from the NeoStation-derived Flutter foundation; do not import or revive NeoStation's presentation layer as a second frontend.

Keep the existing Flutter/Dart application, SQLite library, provider state, Android storage integrations, emulator handoff, and system definitions. Do not create a parallel ROM database or a second scanning/scraping pipeline.

## Reuse map

| Capability | Existing ECLIPSE/Flutter component | Direction |
|---|---|---|
| ROM discovery and rescans | `SqliteDatabaseService`, coordinated by `SqliteConfigProvider` and its scanning part | Preserve the existing scanner, including Android Storage Access Framework support, recursive scans, extension filtering, and database synchronization. Connect ECLIPSE library actions to this service rather than implementing another scanner. |
| ROM-folder and data-directory resolution | `ConfigService`, `FileProvider`, `SqliteConfigProvider` | Preserve configured paths and user-selected Android folder grants. Keep ROM roots distinct from ECLIPSE app-support/user-data and media directories. Never silently replace a user-selected path. |
| Metadata and artwork scraping | `ScreenScraperService` (documented in `ARCHITECTURE.md`), `ScraperRepository`, existing scraper configuration and cache | Reuse the current provider, credentials flow, rate/concurrency controls, and persistence. ECLIPSE screens should call existing state/services; do not add a duplicate scraper or store secrets in UI state. |
| System art packs | `NeoAssetsService` and `AppConfig` NeoAssets catalog/CDN endpoints | Keep the existing public pack catalog/download/cache integration. Treat packs as optional user-selected assets and retain attribution/pack metadata. Do not copy assets from unrelated projects without license/permission review. |
| Emulator paths and handoff | `EmulatorRepository` and existing launcher services | Preserve existing configured emulator paths and launch validation. |

## Non-goals

- Do not copy NeoStation screens, navigation, widgets, branding, or application identity into ECLIPSE.
- Do not fork the ROM database or duplicate game, system, emulator, metadata, or artwork models.
- Do not bundle ROMs, BIOS files, emulator binaries, or copyrighted game media.
- Do not assume Android grants unrestricted filesystem access; use the existing SAF/user-grant flow.
- Do not overwrite user-selected ROM, data, or media directories during migration.

## Implementation sequence

1. Audit the existing scanner, path, scraper, and art-pack call sites on the active branch.
2. Map ECLIPSE library/settings surfaces to those existing providers and services.
3. Fix only verified gaps; avoid a broad backend rewrite.
4. Add regression tests for path persistence, rescans, metadata cache behavior, and art-pack download/cache behavior.
5. Run formatter, Flutter tests, analyzer, and Android debug build before marking the integration complete.

This document records the integration boundary and audited component ownership. It does not claim the end-to-end wiring or validation steps are complete.
