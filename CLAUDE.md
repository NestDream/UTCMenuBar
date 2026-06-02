# UTCMenuBar

A lightweight macOS menu bar app that displays UTC time, designed to be visually distinct from the system clock. macOS 13+, Swift 6, AppKit + a thin SwiftUI layer (popover & Settings form via `NSHostingView`).

The status item shows e.g. `🌐 14:30:25 UTC`. Left-clicking opens a Liquid-Glass-style popover (live time + Settings/Converter/Quit); right-clicking opens the classic `NSMenu`. Users can toggle date / compact formats, customize font family/weight/size/color/icon-prefix/decorator, switch UI language (English / 中文), open a bidirectional timezone converter, and enable launch-at-login.

## Repo layout

```
.
├── Package.swift          # SPM manifest — single source of truth
├── Sources/
│   ├── UTCMenuBarLib/     # testable, AppKit-light library (pure logic)
│   │   ├── DisplayOptions / StyleOptions / TimezoneConverterOptions  (models + UserDefaults)
│   │   ├── TimeFormatter / StyledTextBuilder / TimezoneConverter     (formatting/conversion)
│   │   ├── MenuBuilder / SettingsViewModel                            (menu + control mapping)
│   │   ├── Strings / AppLanguage                                      (i18n table)
│   │   ├── TimerScheduling / TimeZone+UTC / PopoverLayout             (pure helpers)
│   ├── main.swift                       # AppDelegate: status item, timer, menu, windows
│   ├── PopoverController.swift          # NSPanel popover (left-click)
│   ├── ClockPopoverView(Model).swift    # SwiftUI popover content + VM
│   ├── SettingsView.swift               # SwiftUI Settings form + SettingsViewModel2
│   ├── SettingsWindowController.swift   # hosts SettingsView
│   ├── TimezoneConverterWindowController.swift
│   ├── StyleOptionsStore / LanguageStore / TimezoneConverterStore.swift  (token-based listeners)
│   └── LaunchAtLoginManager.swift       # SMAppService + BundleInfo
├── Tests/UTCMenuBarTests/ # custom test runner (no XCTest — uses fatalError)
├── scripts/
│   ├── build-app.sh       # builds UTCMenuBar.app bundle (version from latest git tag)
│   └── test.sh            # runs the test executable
├── specs/                 # feature specs (requirements / design / tasks)
│   ├── display-options/      # DONE
│   ├── visual-distinction/   # DONE
│   └── timezone-converter/   # DONE
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

**Library (`UTCMenuBarLib`)** — pure, testable logic. Models (`DisplayOptions`, `StyleOptions`, `TimezoneConverterOptions`) own their `*.` UserDefaults keys and `save`/`load`. `TimeFormatter` and `TimezoneConverter` cache their `DateFormatter`s and use the shared `TimeZone.utc` constant. `MenuBuilder` builds the `NSMenu` from options + language + selectors. `Strings`/`AppLanguage` back the i18n table. `TimerScheduling` / `PopoverLayout` are pure helpers extracted so timing and positioning are unit-testable.

**App target** — AppKit glue + a thin SwiftUI layer:
- `AppDelegate` holds the `NSStatusItem`, an interval-adaptive `Timer` (1s normally, 60s aligned to the minute in compact mode), and the three stores. Left-click → `PopoverController`; right-click → `MenuBuilder` menu. Listens for `NSSystemClockDidChange` + wake to re-tick.
- The three **stores** (`StyleOptionsStore`, `LanguageStore`, `TimezoneConverterStore`) are the single sources of truth. They use token-based `addListener`/`removeListener`; menu, popover, and Settings all subscribe.
- SwiftUI views (`ClockPopoverView`, `SettingsView`) are hosted in `NSHostingView`/`NSHostingController`. Their view models bridge the stores; `SettingsViewModel2` uses an `isSyncing` flag so store→VM syncs don't re-trigger VM→store writes.

State flow on a change: mutate via store `update {}` → store persists + fans out to listeners → menu/popover/menu-bar title refresh.

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

- **UI strings are bilingual** (English / 中文) via the `Strings` table keyed by `StringKey`; never hard-code a user-facing string — add a key with both translations. Language is chosen at runtime (`AppLanguage`), defaulting from the system locale.
- **UserDefaults keys** use dotted prefixes per feature: `displayOptions.*`, `styleOptions.*`, `timezoneConverter.*`, `app.language`.
- **Public API in UTCMenuBarLib** — anything used from `main.swift` must be `public`. The lib is `Sendable`-clean.
- **No external dependencies** in Package.swift. Stay AppKit + Foundation only.
- **`@_exported import Foundation`** is currently used in DisplayOptions.swift so `main.swift` doesn't need its own Foundation import. Don't add it elsewhere.

## Known traps

- `swift run UTCMenuBar` works but the process needs to keep running for the menu bar item to stay visible — it's not a daemon. The `.app` bundle is the proper deliverable.
- `LSUIElement=true` in Info.plist is what makes it Dock-less. Don't drop it.
- The Xcode project under `_archive/UTCMenuBar-xcode/` is a frozen copy. Do not edit it. If you need to update behavior, edit the SPM sources.
