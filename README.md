# UTCMenuBar

A lightweight macOS menu bar app that shows **UTC time**, designed to be visually
distinct from your system clock so you never confuse the two.

```
🌐 14:30:25 UTC
```

> Status: pre-1.0. Two features shipped (display options, visual distinction).
> Timezone converter is the next planned feature.

---

## Why this exists

If you work across timezones — on-call rotations, distributed teams, aviation /
shipping logs, log files in UTC, AWS console regions, etc. — you usually want
both your local time **and** UTC visible at a glance.

The standard approaches all have issues:

- macOS lets you switch the system clock to UTC, but then you lose local time.
- Adding a second clock via iStat Menus or There costs money and brings a lot
  of features you may not need.
- Most free menu-bar UTC clocks render UTC in the **same font, weight, and
  color** as the system clock right next to them, which defeats the point —
  you have to read the digits to tell them apart.

UTCMenuBar's whole pitch: show UTC, and let you make it look obviously
different from the system clock with a few clicks. No account, no subscription,
no telemetry, ~5 MB binary.

---

## Features

- **UTC time in the menu bar**, prefixed with `🌐` and suffixed with `UTC`
- **Display options** (toggleable from the dropdown):
  - Show date alongside time
  - Compact time (`HH:mm` instead of `HH:mm:ss`)
  - Compact date (`MM/dd` instead of `yyyy-MM-dd`)
- **Visual distinction options** (Appearance submenu and Settings window):
  - Font family — System / Menlo / SF Mono
  - Weight — Regular / Medium / Semibold / Bold
  - Size — Small / Standard / Large (±2pt around the menu bar default)
  - Color — Default / Blue / Green / Orange / Purple / Red (system dynamic colors, dark-mode safe)
  - Decorator — none / `[brackets]` / `(parentheses)` / `│bars│`
- **Settings window** with live preview, opens with `⌘,`
- **Persists** all settings to `UserDefaults`; survives restarts
- **Dock-less** (`LSUIElement`); pure menu bar accessory app
- **Free, open source, no account, no telemetry, no network requests**

### Screenshots

> The screenshots below are placeholders. **TODO for the maintainer**: capture
> these and drop the PNGs into `docs/screenshots/`.

Default view in the menu bar:

![menu bar default](docs/screenshots/menubar-default.png) <!-- TODO: add screenshot -->

Dropdown menu showing display + appearance options:

![dropdown menu](docs/screenshots/dropdown-menu.png) <!-- TODO: add screenshot -->

Settings window with live preview:

![settings window](docs/screenshots/settings-window.png) <!-- TODO: add screenshot -->

UTC styled distinctly next to the system clock (the point of the app):

![visual distinction](docs/screenshots/visual-distinction.png) <!-- TODO: add screenshot -->

---

## Install

### Build from source (currently the only option)

Requirements: macOS 13+, Xcode 15+ (Swift 6 toolchain).

```bash
git clone <this repo>
cd UTCClock
./scripts/build-app.sh         # produces UTCMenuBar.app in repo root
open UTCMenuBar.app
```

To launch on every login: drag `UTCMenuBar.app` into
`System Settings → General → Login Items → Open at Login`.

### Run as an SPM executable (for development)

```bash
swift run UTCMenuBar
```

This works but the menu bar icon only stays visible while the process is
running — it is not daemonized. Use the `.app` bundle for daily driving.

---

## Usage

Click the `🌐` icon in the menu bar to open the dropdown:

- Toggle **显示日期 / 紧凑时间 / 紧凑日期** (show date / compact time /
  compact date)
- Open the **外观 (Appearance)** submenu to pick font / weight / size / color /
  decorator
- Open **设置… (`⌘,`)** for the same controls in a window with a live preview
- **退出 (`⌘Q`)** to quit

> The in-app menu strings are Chinese. The README is English. If localization
> matters to you, see [Roadmap](#roadmap).

---

## Build & test

```bash
swift build                   # debug build
swift run UTCMenuBar          # run from CLI
./scripts/test.sh             # run the full test suite
./scripts/build-app.sh        # build release UTCMenuBar.app
./scripts/build-app.sh debug  # build debug UTCMenuBar.app
```

The test suite is a custom runner (no XCTest / swift-testing) — see
[`Tests/UTCMenuBarTests/`](Tests/UTCMenuBarTests/). Property tests run 100
randomized iterations per case.

---

## Architecture

```
Package.swift                  # SPM manifest, single source of truth
Sources/
  main.swift                   # AppDelegate + NSApp entry point
  SettingsWindowController.swift
  StyleOptionsStore.swift      # observable single source of truth for StyleOptions
  UTCMenuBarLib/               # testable, Sendable-clean library
    DisplayOptions.swift       # show date / compact time / compact date
    StyleOptions.swift         # font / weight / size / color / decorator enums
    TimeFormatter.swift        # Date + DisplayOptions -> "🌐 14:30:25 UTC"
    StyledTextBuilder.swift    # plain text + StyleOptions -> NSAttributedString
    MenuBuilder.swift          # builds the NSMenu from current options
    SettingsViewModel.swift    # backing model for the Settings window
Tests/UTCMenuBarTests/         # custom runner; one file per module
specs/
  display-options/             # requirements.md / design.md / tasks.md
  visual-distinction/          # requirements.md / design.md / tasks.md
scripts/
  build-app.sh                 # assembles UTCMenuBar.app
  test.sh                      # runs the test executable
```

Three small modules in `UTCMenuBarLib`:

- **`DisplayOptions`** — toggleable display flags + UserDefaults round-trip.
- **`TimeFormatter`** — pure function: `(Date, DisplayOptions) -> String`,
  always wrapping in `🌐 … UTC`.
- **`StyleOptions` + `StyledTextBuilder`** — visual styling enums and the
  `NSAttributedString` builder applied to the status item's `attributedTitle`.
- **`MenuBuilder`** — stateless builder that re-emits the whole `NSMenu` on
  every change (cheap; small menu).

The `AppDelegate` in `main.swift` wires those together with a 1 s `Timer`,
the `NSStatusItem`, and the `StyleOptionsStore` listener.

For deeper docs, see the per-feature spec directories (`specs/<feature>/`)
and [`CLAUDE.md`](CLAUDE.md). Specs follow a requirements / design / tasks
split, written in Chinese and using EARS-style (`WHEN` / `IF` / `THE`)
acceptance criteria.

---

## How UTCMenuBar compares to other Mac timezone apps

Be honest about scope: UTCMenuBar is **not** a multi-timezone power tool. It
shows UTC, beautifully and distinctly. If you need to track teammates across
five cities, [There](https://there.pm/) or iStat Menus will serve you better.

| Feature                              | **UTCMenuBar** | There.pm | Menu World Time | iStat Menus | SwiftUTCMenuClock | ZuluBar |
| ------------------------------------ | -------------- | -------- | --------------- | ----------- | ----------------- | ------- |
| **Open source**                      | Yes (planned MIT) | Yes      | No              | No          | Yes (MIT)         | Yes     |
| **Free**                             | Yes            | Yes      | Paid (App Store)| Paid        | Yes               | Yes     |
| **Account / sign-in required**       | No             | No       | No              | No          | No                | No      |
| **Telemetry**                        | None           | None stated | ?            | ?           | None              | None    |
| **macOS minimum**                    | 13             | 13       | varies          | varies      | 10.15             | 14      |
| **Shows UTC in menu bar**            | Yes            | Via offset | Yes           | Yes         | Yes               | Yes     |
| **Multiple timezones in menu bar**   | No             | Yes      | Yes             | Yes         | No                | No      |
| **Per-timezone labels / avatars**    | No             | Yes      | Yes             | Limited     | No                | No      |
| **Visually distinct UTC styling**    | **Yes (5 axes)** | No     | No              | Limited     | No                | Limited |
| **— font family**                    | Yes            | No       | No              | No          | No                | No      |
| **— font weight**                    | Yes            | No       | No              | No          | No                | No      |
| **— font size**                      | Yes            | No       | No              | No          | No                | No      |
| **— color**                          | Yes            | No       | No              | No          | No                | No      |
| **— decorator (brackets / bars)**    | Yes            | No       | No              | No          | No                | Yes (suffix only) |
| **Compact time / date toggles**      | Yes            | n/a      | ?               | Yes         | ?                 | Yes (seconds) |
| **Date prefix**                      | Yes            | n/a      | Yes             | Yes         | ?                 | Yes     |
| **Click-to-copy timestamp**          | No             | No       | No              | No          | No                | Yes (3 formats) |
| **Calendar / meeting integration**   | No             | No       | Limited         | Yes         | No                | No      |
| **Sun / moon / weather data**        | No             | Limited  | No              | Yes         | No                | No      |
| **iOS / cross-platform**             | No             | No       | No              | No          | No                | No      |
| **Actively maintained (2026)**       | Yes            | Yes      | ?               | Yes         | No (last 2021)    | Yes     |

Sources: vendor pages and GitHub repos as of 2026-05.
[There](https://there.pm/),
[iStat Menus](https://bjango.com/mac/istatmenus/),
[SwiftUTCMenuClock](https://github.com/jonblatho/SwiftUTCMenuClock),
[ZuluBar](https://github.com/tra0x/ZuluBar).
A `?` means the app likely has the feature but the public page doesn't make it
unambiguous.

### Where each one fits

- **There.pm** — best if you want to see *people across multiple timezones*
  (with names and avatars) and don't care specifically about UTC. Genuinely
  great app; UTCMenuBar does not try to compete with it.
- **iStat Menus** — best if you also want CPU / RAM / network / battery /
  weather widgets in the menu bar. Worth the price if you'd buy it for those.
- **Menu World Time / World Clock Pro** — App Store paid options for
  multi-timezone display in the menu bar. Closed source.
- **SwiftUTCMenuClock** — closest in spirit to UTCMenuBar (Swift, MIT, free,
  UTC-only) but appears unmaintained since 2021 and has no visual styling
  controls.
- **ZuluBar** — recently active OSS UTC clock with a thoughtful copy-formats
  feature (display string / Unix epoch / RFC 3339). UTCMenuBar focuses more
  on visual distinction; ZuluBar focuses more on copy interactions. Pick
  whichever matters more to you — they are reasonable substitutes.
- **UTCMenuBar** — best if your primary need is *"show me UTC, make it look
  obviously different from my system clock, in an open-source app I can
  audit, with no payment / login / telemetry"*.

### Honest limitations

- Single timezone (UTC) only. If you need to display, say, UTC and PT side by
  side, UTCMenuBar can't do it today. (See [Roadmap](#roadmap).)
- No menu bar icon customization beyond the `🌐` emoji prefix.
- No iOS app, no widgets, no iCloud sync.
- No calendar / meeting integration; this is not a meeting planner.
- Not yet on the Mac App Store; build from source for now.
- Not widely tested in the wild yet — bug reports are welcome.

---

## Roadmap

Concrete next steps, roughly in priority order:

- [ ] **Timezone converter (UTC ↔ other zones, bidirectional).**
  Type a UTC time and see the equivalent in selected local zones, or type a
  local time and see UTC. Currently in design phase under `specs/`.
- [ ] **Custom prefix / suffix.** Replace `🌐` and `UTC` with user-supplied
  strings (e.g. `Z`, `Zulu`, no prefix at all).
- [ ] **English localization** of menu strings (currently Chinese-only).
- [ ] **Click-to-copy** the current UTC timestamp in multiple formats (Unix
  epoch, ISO 8601 / RFC 3339).
- [ ] **Launch at login** toggle inside the app (currently a manual System
  Settings step).
- [ ] **Mac App Store** distribution (only after the converter ships).
- [ ] **Signed / notarized release builds** + GitHub Releases artifacts.

Lower priority:

- [ ] Multiple-timezone menu bar display (would expand scope significantly —
  may stay out of scope on purpose).
- [ ] Custom hotkey to open the Settings window or the (planned) converter.
- [ ] More decorators / more colors / per-glyph styling.

---

## Contributing

Contributions are welcome. The project follows a spec-driven workflow:

1. Open an issue to discuss the feature first.
2. Add `specs/<feature>/{requirements,design,tasks}.md` mirroring the existing
   two specs (Chinese is fine; English also fine — match the existing style
   if you're extending an existing spec).
3. Implement against `tasks.md`, ticking boxes as you go.
4. Add a corresponding test file under `Tests/UTCMenuBarTests/` and register
   it in `TestRunner.swift`. Each correctness property in `design.md` should
   have a matching test.
5. Run `./scripts/test.sh` and `./scripts/build-app.sh` before sending a PR.

Conventions worth knowing:

- No external dependencies. AppKit + Foundation only.
- Library code in `UTCMenuBarLib` must be `public` and `Sendable`-clean.
- UserDefaults keys use a feature-prefix (`displayOptions.*`,
  `styleOptions.*`).
- Don't edit anything under `_archive/` — that's a frozen Xcode project.

See [`CLAUDE.md`](CLAUDE.md) for the full set of conventions.

---

## License

MIT recommended.

> **TODO for the maintainer**: add a `LICENSE` file at the repo root with the
> MIT license text and your copyright line, then update this section to a
> normal "Licensed under [MIT](LICENSE)." sentence. Until that file lands,
> consider this project source-available but unlicensed by default — i.e.,
> external contributors should not assume any rights beyond reading the code.
