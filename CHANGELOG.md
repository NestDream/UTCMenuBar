# Changelog

All notable changes to UTCMenuBar will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Debug builds accept `--render-previews <dir>` to snapshot every UI surface
  to PNG in light and dark appearance (design review harness; compiled out of
  release builds).

### Changed

- Popover redesigned as a proper glance card: large monospaced-digit time,
  a cyan "UTC" badge echoing the icon's prime meridian, and the full date as
  a secondary line (the old single-string layout wrapped badly with the date
  enabled and read the emoji icon into the hero text). The fake arrow nub is
  gone — it's now a plain rounded panel like system menu bar extras. The
  popover no longer mirrors the menu bar's icon/decorator styling; that lives
  in the menu bar and the Settings preview.
- Settings: the live preview is pinned above the form as a miniature menu bar
  strip, next to the Appearance controls it reflects, instead of a section at
  the bottom that scrolled out of view; the display toggles got a proper
  section header.
- Converter: the UTC and target fields now read as one bidirectional group
  (swap glyph between them, error text aligned to the field column), the
  label column no longer truncates "Time Zone", and the copy buttons are
  properly icon-only — they used to draw the "Copy" title over the icon.

### Fixed

## [1.2.0] - 2026-08-28

### Added

- In-app updates: "Check for Updates…" in the context menu and Settings, plus
  a daily automatic check (toggle in Settings). Updates download, validate
  (bundle id + version), swap the bundle, and relaunch — no more Gatekeeper
  dance after the first install. See `specs/in-app-update/`.
- Release notes now carry bilingual install instructions and the asset's
  SHA-256 automatically.

### Changed

- New app icon: a proper macOS squircle (the old art was an opaque gray
  square) with a dial-plus-graticule design; the accent line is the prime
  meridian. Rendered from code (`scripts/render-icon.swift`), so it can be
  regenerated at any size.
- README first-launch guidance updated for macOS 15+, where right-click →
  Open no longer bypasses Gatekeeper.

### Fixed

## [1.1.0] - 2026-08-28

### Added

- Control+left-click on the status item now opens the context menu, matching
  the macOS secondary-click convention.
- Esc closes the popover; clicks on the app's own windows (Settings, converter)
  now dismiss it too. The popover's displayed shortcuts (⌘, ⌘T ⌘Q) actually
  work while it is open, and it slides in from the menu bar (plain fade under
  Reduce Motion).
- Status item tooltip and a localized VoiceOver label ("UTC Time <time>"
  instead of the emoji being read aloud).
- Release pipeline: pushing a `v*` tag builds a universal (arm64 + x86_64)
  bundle, zips it, and publishes a GitHub Release. CI now also smoke-builds
  the .app bundle.
- `build-app.sh --universal` flag, ad-hoc code signature, and
  `LSApplicationCategoryType` / `NSHumanReadableCopyright` in Info.plist.

### Changed

- System font now uses the monospaced-digit variant, so the ticking clock keeps
  a constant width and neighboring menu bar items no longer shift every second.
- Ticks that change nothing (same text, style, language) skip the status-item
  relayout; timers carry a small tolerance so the system can coalesce wakeups
  (lower energy use). The two-phase align-then-repeat timers were replaced by
  single boundary-aligned repeating timers.

### Fixed

- "Compact date" is now really disabled in the context menu while "Show date"
  is off (NSMenu autoenabling silently re-enabled it at display time).
- Time zone converter UTC offsets refresh when the window regains key, instead
  of staying frozen at first-open values across DST changes.
- macOS 14+ "secure coding for restorable state" console warning on launch.
- Clock-change/wake notifications are now observed on the main queue; the
  selector-based observers could be delivered off-main and trap the main-actor
  assertion under Swift 6.
- Rapidly reopening the popover during its close fade no longer hides the
  fresh popover and leaks its event monitors.
- Settings preview renders the actual resolved font, color, and decorator
  instead of a hard-coded 18pt monospaced sample.

## [1.0.0] - 2026-06-02

First stable release: a pre-release audit hardening pass plus a testability
refactor.

### Added

- Minute-aligned timer for compact time so the displayed minute updates on the
  minute boundary.

### Changed

- Refactored for testability: view models and stores moved into the library
  behind a `LoginItemControlling` seam.
- Grew the test suite from 106 to 142 tests.

### Fixed

- First-launch defaults now apply correctly.
- Popover position is clamped to the screen, and a double-toggle issue was
  fixed.
- Custom-font desync between the menu bar display and settings.
- Hardened UTC handling for safety.
- Timezone converter polish.

## [0.7.0] - 2026-05-29

### Added

- About section.
- Bundle version is now derived from the latest git tag at build time.

## [0.6.0] - 2026-05-29

### Added

- Launch at login via `SMAppService`.

## [0.5.1] - 2026-05-20

### Fixed

- Font-panel infinite-loop freeze.

## [0.5.0] - 2026-05-20

### Added

- SwiftUI rewrite of the Settings window.

### Changed

- Performance improvements: cached `DateFormatter`s and an adaptive timer.
- Default display is now date + compact time.
- UI polish.

## [0.4.2] - 2026-05-18

### Changed

- Center the Settings and Converter windows when they open.

## [0.4.1] - 2026-05-18

### Changed

- Popover UI polish: transparent panel with an arrow.

## [0.4.0] - 2026-05-18

### Added

- Liquid Glass popover: left-click opens the popover, right-click shows the
  classic menu.

## [0.3.0] - 2026-05-18

### Added

- Bidirectional timezone converter.

## [0.2.0] - 2026-05-18

### Added

- Runtime English / Chinese language switch.

## [0.1.0] - 2026-05-15

First public release.

### Added

- Visual distinction options: font, weight, size, color, icon, and decorator.
- Settings window.

[Unreleased]: https://github.com/NestDream/UTCMenuBar/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.7.0...v1.0.0
[0.7.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/NestDream/UTCMenuBar/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/NestDream/UTCMenuBar/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/NestDream/UTCMenuBar/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/NestDream/UTCMenuBar/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/NestDream/UTCMenuBar/releases/tag/v0.1.0
