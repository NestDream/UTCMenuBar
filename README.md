# UTCMenuBar

A lightweight macOS menu bar app that shows **UTC time**, designed to be visually
distinct from your system clock so you never confuse the two.

```
🌐 14:30:25 UTC
```

> Status: 1.0. Shipped: display options, visual distinction, English + 中文 UI
> (switchable at runtime), bidirectional timezone converter, Liquid-Glass
> popover, in-app launch-at-login, and an About/version panel.

---

## Why this exists

If you work across timezones — on-call rotations, distributed teams, aviation /
shipping logs, log files in UTC, AWS console regions, etc. — you usually want
both your local time **and** UTC visible at a glance.

The standard approaches all have issues:

- macOS lets you switch the system clock to UTC, but then you lose local time.
- Adding a second clock via iStat Menus costs money and brings a lot of
  features you may not need; full multi-timezone planners like Clocker or
  There work great but optimize for tracking *people across cities*, not
  for one clean UTC display.
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
  - Font family — System / Menlo / SF Mono, **plus any installed font** via the
    macOS font panel
  - Weight — Regular / Medium / Semibold / Bold
  - Size — Small / Standard / Large (±2pt around the menu bar default)
  - Color — Default / Blue / Green / Orange / Purple / Red (system dynamic colors, dark-mode safe)
  - Icon prefix — Globe `🌐` / Clock `🕐` / Compass `🧭` / Earth `🌍` / none (5 options)
  - Decorator — none / `[brackets]` / `(parentheses)` / `│bars│`
- **Liquid-Glass popover** — left-click the menu bar icon to open a popover
  (`ultraThinMaterial`) with a large live UTC readout and quick buttons for
  Settings, the Converter, and Quit. Right-click still shows the classic menu.
- **Bidirectional timezone converter** (`⌘T`) — type a UTC time and see the
  equivalent in selected zones, or type a local time and read back UTC.
- **Localized UI** — English and Simplified Chinese, switchable at runtime from
  the Appearance ▸ Language submenu or the Settings window; defaults to your
  system language on first launch.
- **Launch at login** — toggle inside Settings (backed by `SMAppService`); no
  manual System Settings drag required.
- **Settings window** with live preview, opens with `⌘,`
- **About / version panel** — shows the version baked in from the release tag
- **Persists** all settings to `UserDefaults`; survives restarts
- **Multi-display aware** — the popover clamps its position to the active
  screen's visible frame (menu-bar/notch safe)
- **Dock-less** (`LSUIElement`); pure menu bar accessory app
- **Free, open source, no account, no telemetry, no network requests**

### Screenshots

> Screenshots are being added — see [Releases](https://github.com/NestDream/UTCMenuBar/releases)
> for the app in the meantime.

<!-- Screenshots will be placed in docs/screenshots/ and linked here:
- menubar-default.png    — the styled UTC item in the menu bar
- dropdown-menu.png      — the left-click Liquid-Glass popover
- settings-window.png    — the Settings window with live preview
- visual-distinction.png — UTC styled distinctly next to the system clock
-->


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

To launch on every login: open **Settings (`⌘,`)** and toggle **Launch at
login** — the app registers itself via `SMAppService`, no manual drag needed.

### Run as an SPM executable (for development)

```bash
swift run UTCMenuBar
```

This works but the menu bar icon only stays visible while the process is
running — it is not daemonized. Use the `.app` bundle for daily driving.

---

## Usage

**Left-click** the `🌐` icon to open the Liquid-Glass popover — a large live
UTC readout with quick buttons for Settings, the Converter, and Quit.

**Right-click** the icon for the classic dropdown menu:

- Toggle **Show date / Compact time / Compact date**
- Open the **Appearance** submenu to pick font / weight / size / color /
  icon / decorator (pick **Custom…** under font to choose any installed font)
- Pick a **Language** (English / 中文) — same submenu, switches instantly
- Open the **Timezone converter (`⌘T`)** to convert UTC ↔ other zones
- Open **Settings… (`⌘,`)** for the same controls in a window with live preview,
  plus the **Launch at login** toggle
- **Quit (`⌘Q`)** to exit

> UI is available in English and Simplified Chinese. The app picks one based
> on your system language on first launch and you can switch any time.

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

Most pages like this overclaim. Below is a feature-by-feature comparison
against the Mac menu-bar timezone tools that actually exist on GitHub or in
the wild as of **May 2026**, with star counts and last-commit dates so you
can sanity-check the landscape yourself.

UTCMenuBar is deliberately narrow: **show UTC, make it visually distinct.**
It is not a meeting planner, world-clock dashboard, or people tracker.
For those, the right answer is one of the other tools below.

### What's actually out there (May 2026)

A search for `macos menu bar UTC clock`, `macos status bar timezone swift`,
and `topic:menubar timezone` on GitHub plus the well-known paid players
turns up roughly four useful clusters of tools:

1. **UTC-only OSS clocks.** `netik/UTCMenuClock`, `jonblatho/SwiftUTCMenuClock`,
   `tra0x/ZuluBar`, and this project.
2. **Multi-timezone OSS clocks / planners.** `n0shake/Clocker`,
   `dena-sohrabi/There`, `kartik-venugopal/world-clock`,
   `patrik-bernas/whenish`, `shivanshthapliyal/meridian`.
3. **Closed-source paid suites.** [iStat Menus](https://bjango.com/mac/istatmenus/)
   (system monitoring + clocks); App Store options like *Menu World Time* and
   *World Clock Pro* (closed source, paid, not benchmarked here because public
   feature pages don't disclose enough to compare fairly).
4. **The "people, not timezones" niche.** [There](https://there.pm/) — a
   distributed-team tracker that the open-source `dena-sohrabi/There` repo
   mirrors.

### Activity / popularity reality check

| Project | Stars | Last push | License | Notes |
| --- | ---: | --- | --- | --- |
| `n0shake/Clocker` | 608 | 2026-05-13 | MIT | Most-starred OSS option; full meeting planner |
| `dena-sohrabi/There` | 272 | 2024-09-18 | MIT | Free; closely tied to [there.pm](https://there.pm/) |
| `netik/UTCMenuClock` | 252 | 2025-12-12 | Apache-2.0 | The OG; macOS 15+; Objective-C |
| `amiantos/dotbeat` | 40 | 2024-06-16 | MPL-2.0 | Swatch Internet Time, not regular zones |
| `kartik-venugopal/world-clock` | 21 | 2024-01-10 | MIT | macOS 10.12+; minimal |
| `jonblatho/SwiftUTCMenuClock` | 13 | 2021-10-26 | MIT | Effectively abandoned (no commits in 4+ years) |
| `tra0x/ZuluBar` | 0 | 2026-05-10 | MIT | New; signed build is $5, source build free |
| `patrik-bernas/whenish` | 0 | 2026-05-09 | MIT | New; multi-zone with availability bars |
| `shivanshthapliyal/meridian` | 2 | 2026-04-01 | MIT | New; macOS 26.0 (Tahoe) only |
| `NestDream/UTCMenuBar` (this) | n/a | active | MIT (planned) | UTC-only, focuses on visual distinction |

> Takeaway: most OSS UTC-specific tools are either dead (SwiftUTCMenuClock)
> or pre-1.0 (ZuluBar, this project). The OG `netik/UTCMenuClock` is alive
> again as of late 2025 but requires macOS 15+ and is Objective-C only. The
> well-maintained options are multi-timezone planners (Clocker, There,
> Whenish), not bare UTC clocks.

### Feature comparison

The columns below are: **UTCMenuBar** (this app), **netik/UTCMenuClock**
(the OG OSS UTC clock), **ZuluBar** (recent OSS UTC clock), **Clocker**
(most-starred OSS multi-timezone), **There** (people tracker, OSS + paid web
companion), **iStat Menus** (commercial system suite). Cells: ✓ = supported,
✗ = not supported, ◐ = partial, ? = not documented on the public page.

| Dimension | UTCMenuBar | UTCMenuClock | ZuluBar | Clocker | There | iStat Menus |
| --- | :---: | :---: | :---: | :---: | :---: | :---: |
| License / cost | MIT, free | Apache-2.0, free | MIT (free source / $5 signed build) | MIT, free | MIT, free | Closed source, paid <sup>1</sup> |
| Last commit (2026-05) | active | 2025-12 | 2026-05 | 2026-05 | 2024-09 | continuous |
| macOS minimum | 13 | 15 | 14 | 14 | 13 | varies (current 6.x) |
| Open-source | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| No account / no telemetry | ✓ | ✓ | ✓ | ✓ | ✓ | ? |
| **Time display** | | | | | | |
| Shows UTC in menu bar | ✓ | ✓ | ✓ | ✓ <sup>2</sup> | ◐ <sup>3</sup> | ✓ |
| Multiple timezones in menu bar | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ |
| Per-timezone labels / avatars | ✗ | ✗ | ✗ | ✓ (custom labels) | ✓ (photos/handles) | ✓ (custom labels) |
| 24h / 12h toggle | ✗ <sup>4</sup> | ✓ | ? | ✓ | ✓ | ✓ |
| Show seconds toggle | ✓ | ✓ | ✓ | ✓ | ? | ✓ |
| Date display | ✓ | ✓ | ✓ | ? | ? | ✓ |
| Compact time / date format | ✓ | ✗ | ◐ (seconds only) | ◐ (compact menubar mode) | ? | ✓ |
| ISO-8601 / RFC 3339 menubar | ✗ | ✓ | ✗ | ? | ✗ | ? |
| Custom format string | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| **Visual distinction** | | | | | | |
| Custom font family | ✓ (System / Menlo / SF Mono + any installed font) | ✗ | ✗ | ✗ | ✗ | ? |
| Custom font weight | ✓ | ✗ | ✗ | ✗ | ✗ | ? |
| Custom font size | ✓ (±2pt) | ✗ | ✗ | ✗ | ✗ | ? |
| Custom color | ✓ (6 system-dynamic colors) | ✗ | ✗ | ✓ (4 themes, popover only) | ✗ | ? |
| Decorator / brackets / bars | ✓ (4 styles) | ✗ | ◐ (`Z` / `UTC` suffix) | ✗ | ✗ | ✗ |
| Custom emoji prefix | ✓ (5 options) | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Interactions** | | | | | | |
| Click-to-copy current time | ✗ <sup>4</sup> | ✓ (current format + ISO-8601) | ✓ (display / Unix / RFC 3339) | ? | ✗ | ? |
| Bidirectional timezone converter | ✓ | ✗ | ✗ | ◐ (time scrubber) | ✗ | ? |
| Time-travel slider / scrubber | ✗ | ✗ | ✗ | ✓ (±7 days, 15-min steps) | ✗ | ✗ |
| Global hotkey | ✗ | ✗ | ✓ | ✓ (⌘L) | ? | ? |
| Settings window with live preview | ✓ | ✗ | ✗ | ✓ | ✓ | ✓ |
| **Integrations** | | | | | | |
| Launch at login (in-app) | ✓ | ✓ | ? | ✓ | ? | ✓ |
| Calendar / meeting integration | ✗ | ✗ | ✗ | ✓ (Apple Calendar, one-click join Zoom/Meet/Teams) | ✗ | ✓ |
| Sun / moon data | ✗ | ✗ | ✗ | ◐ (day/night) | ✗ | ✓ |
| Weather data | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| iCloud sync | ✗ | ✗ | ✗ | ✓ | ✗ | ? |
| Multi-display awareness | ✗ <sup>5</sup> | ✗ <sup>5</sup> | ✗ <sup>5</sup> | ✗ <sup>5</sup> | ✗ <sup>5</sup> | ✗ <sup>5</sup> |
| Localization (UI) | ✓ (English + 中文) | ✗ (English) | ✗ (English) | ✓ (Crowdin community) | ✗ (English) | ✓ |
| Distribution (.app available) | source-build only | unsigned binary on GitHub | source build free / signed $5 | Homebrew cask + GitHub release | Homebrew cask + there.pm | direct buy + Setapp |

<sup>1</sup> iStat Menus' single-license price is no longer published on the
vendor's public page (shows as `$?` placeholder); historically it has been
in the ~US$10–15 range. It is also bundled in [Setapp](https://setapp.com/)
at $9.99/month.
<sup>2</sup> Clocker can pin any timezone to the menu bar, including UTC,
but it's a multi-timezone tool first.
<sup>3</sup> There supports raw UTC offsets per person, but its primary unit
is "a person in a city," not "UTC."
<sup>4</sup> On the [Roadmap](#roadmap) for UTCMenuBar.
<sup>5</sup> No menu-bar app on macOS gets per-display menu bars; this is a
macOS limitation, not a per-app one.

Sources verified May 2026: GitHub repo metadata (stars, last push, license)
via the GitHub API; READMEs of
[Clocker](https://github.com/n0shake/Clocker),
[There](https://github.com/dena-sohrabi/There),
[UTCMenuClock](https://github.com/netik/UTCMenuClock),
[ZuluBar](https://github.com/tra0x/ZuluBar),
[SwiftUTCMenuClock](https://github.com/jonblatho/SwiftUTCMenuClock),
[world-clock](https://github.com/kartik-venugopal/world-clock),
[whenish](https://github.com/patrik-bernas/whenish),
[meridian](https://github.com/shivanshthapliyal/meridian);
vendor pages [there.pm](https://there.pm/),
[iStat Menus](https://bjango.com/mac/istatmenus/),
[abhishekbanthia.com/clocker](https://abhishekbanthia.com/clocker).
A `?` means the public docs don't say either way — not a guess.

### Pick the right tool

This list isn't trying to win every row. Pick the one that matches *your*
job:

- **Pick UTCMenuBar if** you only need UTC, you want it to look
  unambiguously different from the system clock right next to it, you want a
  Swift / AppKit OSS app you can audit, no account / payment / telemetry,
  and you'd use the built-in UTC ↔ zone converter. Best for: SREs / on-call /
  aviation / log triage / AWS console work.

- **Pick `netik/UTCMenuClock` if** you want a long-established OSS UTC
  clock with built-in launch-at-login and click-to-copy in ISO-8601, and
  you're already on macOS 15+. It's the most-starred UTC-only OSS option
  (252 stars, active again in late 2025); Objective-C, no visual styling,
  but solid.

- **Pick `tra0x/ZuluBar` if** click-to-copy in multiple formats (display,
  Unix epoch, RFC 3339) and a global hotkey are your top priorities, and
  you don't need visual styling. Pay $5 for the signed build or build from
  source. Brand-new project, low star count — buyer beware on stability.

- **Pick `n0shake/Clocker` if** you need a real meeting planner — multiple
  timezones, calendar integration, time scrubbing, one-click Zoom/Meet/Teams
  join, iCloud sync. It's the most capable OSS option and it's free. Worth
  trying first if you're not sure you specifically need *UTC*.

- **Pick There ([there.pm](https://there.pm/) or
  [the GitHub project](https://github.com/dena-sohrabi/There)) if** you
  manage a distributed team and want to see *people* (with photos and
  Twitter/Telegram handles) rather than timezones. Free. Shines in 1:1 lead
  / IC contexts.

- **Pick `patrik-bernas/whenish` if** you want a free OSS multi-timezone
  view with per-city availability bars and overlap visualization, and don't
  care about UTC specifically.

- **Pick iStat Menus if** you already want CPU / RAM / network / battery /
  weather widgets in the menu bar — its world clock is a small bonus. Don't
  buy it just for the clock.

### Honest limitations of UTCMenuBar

Things competitors do better, today:

- **Single timezone (UTC) in the menu bar.** If you need UTC and PT *both
  pinned in the menu bar* at once, UTCMenuBar can't do it today. Clocker,
  There, Whenish, world-clock, and Meridian all can. (The shipped converter
  handles ad-hoc UTC ↔ zone math, but that's a different shape from
  "multi-timezone in the menu bar.")
- **No click-to-copy yet.** ZuluBar and UTCMenuClock both ship this; it's on
  the roadmap here.
- **No 24h/12h toggle.** Currently 24h-only. (Planned.)
- **No calendar / meeting integration.** Clocker is the gold standard here;
  this app explicitly does not try to compete.
- **No Mac App Store build, no signed/notarized release artifacts yet.**
  Build from source for now.
- **Just reached 1.0** — young project, modest star count, not yet
  battle-tested. Bug reports welcome.

---

## Roadmap

Concrete next steps, roughly in priority order:

- [ ] **24h / 12h toggle.** Currently 24h-only.
- [ ] **Click-to-copy** the current UTC timestamp in multiple formats (Unix
  epoch, ISO 8601 / RFC 3339).
- [ ] **ISO-8601 / custom format string** for the menu bar readout.
- [ ] **Free-text prefix / suffix + full emoji picker.** Beyond the five
  built-in icons, let users supply any string or emoji (e.g. `Z`, `Zulu`).
- [ ] **Global hotkey** to open the popover, Settings, or the converter.
- [ ] **Mac App Store** distribution.
- [ ] **Signed / notarized release builds** + GitHub Releases artifacts.

Lower priority:

- [ ] Multiple-timezone menu bar display (would expand scope significantly —
  may stay out of scope on purpose).
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

Licensed under [MIT](LICENSE).
