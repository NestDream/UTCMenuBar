# Changelog

All notable changes to UTCMenuBar will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

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
