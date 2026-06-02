# Contributing to UTCMenuBar

Thanks for your interest in improving UTCMenuBar — a lightweight macOS menu bar app that
shows UTC time, deliberately styled to look different from the system clock. Contributions of
all sizes are welcome: bug fixes, new features, tests, docs, and translations.

This document covers everything you need to get building and shipping a change. For the
deeper architectural picture (module-by-module breakdown, state flow, known traps), read
[CLAUDE.md](CLAUDE.md) — it's the canonical architecture doc.

## Prerequisites

- **macOS 13 (Ventura) or newer** — this is the deployment target, and several APIs we use
  (e.g. `SMAppService` for launch-at-login) require it.
- **Apple Silicon** — the project is developed and built for arm64.
- **Swift 6 toolchain** (developed against toolchain 6.2). The easiest way to get it is to
  install **Xcode** (which bundles the Swift toolchain and the macOS SDK) or the standalone
  **Command Line Tools**. Verify with:

  ```bash
  swift --version
  ```

> Note: this is a **Swift Package Manager** project, **not** an Xcode project. You build and
> test from the command line. There is a frozen legacy Xcode project under `_archive/` — do
> not edit it; all real work happens in the SPM sources.

There are **no external dependencies** to fetch — the project uses only AppKit, Foundation,
and a thin SwiftUI/Combine layer from the system SDK.

## Building

Debug build (fast, what you'll use while iterating):

```bash
swift build
```

Build a release `.app` bundle:

```bash
./scripts/build-app.sh           # release by default
./scripts/build-app.sh debug     # debug bundle
```

`build-app.sh` assembles `UTCMenuBar.app` and stamps the version from the latest git tag, so
make sure your tags are fetched if the version matters to you.

## Running

Run the executable directly during development:

```bash
swift run UTCMenuBar
```

The menu bar item appears while the process runs. **It is not a daemon** — if you stop the
process (Ctrl-C), the item disappears. For a real install experience, build the bundle and
open it:

```bash
./scripts/build-app.sh
open UTCMenuBar.app
```

### Unsigned builds

Builds are **unsigned** — there is no Apple Developer account behind this project. When you
(or a user) launch a freshly built `UTCMenuBar.app` for the first time, macOS Gatekeeper will
block it. Right-click the app in Finder and choose **Open**, then confirm. This is expected;
please don't add ad-hoc signing/notarization steps to the build script unless that becomes a
project goal.

## Testing

Run the full suite:

```bash
./scripts/test.sh
```

Under the hood this runs the test executable (`swift run UTCMenuBarTests`). All tests should
pass with **zero warnings** before you open a PR.

### The custom test runner

We do **not** use XCTest or swift-testing. Tests live in a plain executable target
(`Tests/UTCMenuBarTests/`) with a small hand-rolled runner. Follow these conventions:

- Each test file is an `enum` with `static func` methods — no instances, no `XCTestCase`.
- Assertions use `guard … else { fatalError("FAIL: …") }`. A passing run prints `Running:` /
  `✓ passed` lines; a failure aborts the process with a `FAIL:` message.
- Property-style tests typically run ~100 iterations with `Bool.random()`-style generators,
  and each test file maps back to one or more "Properties" from the relevant spec's
  correctness section.

**Adding a new test file:**

1. Create `Tests/UTCMenuBarTests/FooTests.swift`:

   ```swift
   enum FooTests {
       static func runAll() {
           // print("Running: …"); guard … else { fatalError("FAIL: …") }; print("✓ passed")
       }
   }
   ```

2. Register it by calling `FooTests.runAll()` from `main()` in
   [`Tests/UTCMenuBarTests/TestRunner.swift`](Tests/UTCMenuBarTests/TestRunner.swift). If it
   isn't registered there, it won't run.

3. **Isolate UserDefaults.** Models persist to shared `UserDefaults`, so each test must use a
   unique suite name and tear it down:

   ```swift
   let defaults = UserDefaults(suiteName: "com.utcmenubar.test.<unique>")!
   defer { defaults.removePersistentDomain(forName: "com.utcmenubar.test.<unique>") }
   ```

4. **Main-actor code.** View models and stores are main-actor isolated. When a test body needs
   to touch `@MainActor` API, wrap it with `MainActor.assumeIsolated { … }` so the synchronous
   runner can call into it without an async context.

## Architecture in brief

The split that matters for contributors:

- **`Sources/UTCMenuBarLib/`** holds the **pure, testable logic**: the option models
  (`DisplayOptions`, `StyleOptions`, `TimezoneConverterOptions`) with their UserDefaults
  round-tripping, formatters/converters, the i18n `Strings` table, `MenuBuilder`, view models,
  and pure helpers like `TimerScheduling` and `PopoverLayout`. The library is **`Sendable`-clean**.
- **The app target** (`Sources/main.swift` and the SwiftUI/AppKit files alongside it) is the UI
  glue: the `NSStatusItem`, the timer, the popover/menu/window controllers, and the stores that
  fan out changes to listeners.

The guiding principle: **put logic you'd want to test in the library** so it can be exercised
by the runner without spinning up AppKit. Anything in the lib that `main.swift` uses must be
`public`. See [CLAUDE.md](CLAUDE.md) for the full state-flow and store/listener model.

## Coding conventions

- **No external dependencies.** Keep `Package.swift` dependency-free — AppKit + Foundation +
  the small SwiftUI/Combine usage only. Don't add a SwiftPM dependency without discussion.
- **Never hard-code user-facing text.** All UI strings are **bilingual (English / 中文)** and
  live in the `Strings` table keyed by `StringKey`. To add or change copy, add a key with both
  translations rather than inlining a literal. Language is selected at runtime via `AppLanguage`.
- **Keep the library `Sendable`-clean** and main-actor-correct.
- **UserDefaults keys** use dotted, per-feature prefixes: `displayOptions.*`, `styleOptions.*`,
  `timezoneConverter.*`, `app.language`.
- **Don't drop `LSUIElement=true`** from `Info.plist` — it's what keeps the app out of the Dock.
- **Don't touch `_archive/`** — edit the SPM sources instead.

## Spec workflow

Non-trivial features are **designed before they're coded**. Each feature gets a
`specs/<name>/` directory with three files:

- **requirements.md** — user stories + numbered, EARS-style acceptance criteria
  (`WHEN` / `IF` / `THE`).
- **design.md** — architecture, data models, pseudocode, and a list of correctness
  **properties** (which become tests).
- **tasks.md** — a checkbox list, each task referencing the requirement numbers it satisfies.

Existing specs are written in **Chinese**; match that style for consistency. When implementing
from a spec, walk down `tasks.md` marking each item `[x]` as you finish it, and make sure every
property in `design.md` has a corresponding test. If you need to deviate from the acceptance
criteria, update the spec first.

For a small bug fix or polish change, a spec isn't required — use judgment.

## Commit & PR etiquette

- **Branch** off `main` for your work; don't commit directly to `main`.
- Write focused commits with clear messages. The history uses a light
  conventional-commit style — `feat:`, `fix:`, `docs:`, etc. (see `git log`); please match it.
- **Before opening a PR**, make sure:
  - `swift build` succeeds.
  - `./scripts/test.sh` passes with no warnings.
  - New behavior has tests (and, if it's a feature, a spec under `specs/`).
  - No new user-facing string is hard-coded (both translations added to `Strings`).
- Keep PRs scoped to one logical change, and explain *what* and *why* in the description.
  Reference the relevant spec or issue when there is one.

## Questions

If something here is unclear or out of date, open an issue — and if you spot a gap while
contributing, a PR to this file or [CLAUDE.md](CLAUDE.md) is just as welcome as a code change.
Happy hacking!
