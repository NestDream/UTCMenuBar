# UTCMenuBar

A lightweight macOS menu bar app that displays UTC time, designed to be visually distinct from the system clock. macOS 13+, Swift 6, AppKit.

The status item shows e.g. `🌐 14:30:25 UTC`. Users can toggle date display, compact time/date format, and (future feature) custom font/color/decorators via the dropdown menu.

## Repo layout

```
.
├── Package.swift          # SPM manifest — single source of truth
├── Sources/
│   ├── UTCMenuBarLib/     # testable library (DisplayOptions, TimeFormatter, MenuBuilder)
│   └── main.swift         # executable: AppDelegate + NSApp boot
├── Tests/UTCMenuBarTests/ # custom test runner (no XCTest — uses fatalError)
├── scripts/
│   ├── build-app.sh       # builds UTCMenuBar.app bundle
│   └── test.sh            # runs the test executable
├── specs/                 # feature specs (requirements / design / tasks)
│   ├── display-options/   # DONE — implemented in UTCMenuBarLib
│   └── visual-distinction/# TODO — designed, not yet implemented
├── AppIcon.icns           # bundle icon (also AppIcon.iconset/, icon.png source)
└── _archive/              # legacy Xcode project — do not modify (see _archive/README.md)
```

## Common commands

```bash
swift build                  # debug build
swift run UTCMenuBar         # run as a CLI process (menu item appears)
./scripts/test.sh            # run all tests
./scripts/build-app.sh       # build release UTCMenuBar.app
open UTCMenuBar.app          # launch the bundled app
```

## Architecture

Three small modules in `UTCMenuBarLib`:

- **[DisplayOptions](Sources/UTCMenuBarLib/DisplayOptions.swift)** — `Equatable, Sendable` struct holding `showDate`/`compactTime`/`compactDate` bools. Owns its UserDefaults keys (`displayOptions.*`) and `save`/`load` round-trip.
- **[TimeFormatter](Sources/UTCMenuBarLib/TimeFormatter.swift)** — pure functions that format a `Date` + `DisplayOptions` into the display string. Always wraps output in `🌐 ` … ` UTC`.
- **[MenuBuilder](Sources/UTCMenuBarLib/MenuBuilder.swift)** — builds the `NSMenu` from `DisplayOptions` and a set of selectors. Stateless; rebuilds the whole menu on every option change (cheap — 5 items).

`AppDelegate` in [main.swift](Sources/main.swift) wires it together: holds the `NSStatusItem`, a 1-second `Timer`, and the current `DisplayOptions`. On any toggle: mutate options → `save()` → `buildMenu()` → `updateTime()`.

## Testing conventions

The tests use a **custom runner**, not XCTest or swift-testing. Each test:
- Lives in an `enum` with `static func` test methods
- Uses `guard … else { fatalError("FAIL: …") }` for assertions
- Prints "Running:" / "✓ passed" lines
- Is registered in [TestRunner.swift](Tests/UTCMenuBarTests/TestRunner.swift)'s `main()`

Property tests run 100 iterations with `Bool.random()`-style generators. Each test file maps to one or more "Properties" from the spec's correctness section.

When adding a new test file:
1. Create `Tests/UTCMenuBarTests/FooTests.swift` with `enum FooTests { static func runAll() { … } }`
2. Add `FooTests.runAll()` to `TestRunner.main()`
3. UserDefaults isolation: use a unique suite name per test (`UserDefaults(suiteName: "com.utcmenubar.test.<unique>")`) and `removePersistentDomain` in `defer`.

## Spec workflow

Features are designed before being coded. Each feature gets a `specs/<name>/` directory with three files:

- **requirements.md** — user stories + numbered acceptance criteria (EARS-style: `WHEN`/`IF`/`THE`)
- **design.md** — architecture, data models, algorithm pseudocode, correctness properties
- **tasks.md** — checkbox list, each task referencing requirement numbers

Both existing specs are written in Chinese. Match that style for new specs in this repo.

When implementing from a spec: walk down `tasks.md`, mark each `[x]` as you complete it, and ensure each property in design.md has a corresponding test. Do not deviate from acceptance criteria without updating the spec first.

## Conventions

- **Menu strings are Chinese** (`显示日期`, `紧凑时间`, etc.). The Quit item stays English with `⌘Q`.
- **UserDefaults keys** use dotted prefixes per feature: `displayOptions.*`, `styleOptions.*`.
- **Public API in UTCMenuBarLib** — anything used from `main.swift` must be `public`. The lib is `Sendable`-clean.
- **No external dependencies** in Package.swift. Stay AppKit + Foundation only.
- **`@_exported import Foundation`** is currently used in DisplayOptions.swift so `main.swift` doesn't need its own Foundation import. Don't add it elsewhere.

## Known traps

- `swift run UTCMenuBar` works but the process needs to keep running for the menu bar item to stay visible — it's not a daemon. The `.app` bundle is the proper deliverable.
- `LSUIElement=true` in Info.plist is what makes it Dock-less. Don't drop it.
- The Xcode project under `_archive/UTCMenuBar-xcode/` is a frozen copy. Do not edit it. If you need to update behavior, edit the SPM sources.
