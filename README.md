<p align="center">
  <img src="icon.png" width="160" height="160" alt="UTCMenuBar app icon: a clock dial crossed by a cyan prime meridian">
</p>

<h1 align="center">UTCMenuBar</h1>

<p align="center">
  A UTC clock for your Mac's menu bar.
</p>

<p align="center">
  <a href="https://github.com/NestDream/UTCMenuBar/releases/latest"><img src="https://img.shields.io/github/v/release/NestDream/UTCMenuBar?style=flat-square&amp;color=086F98" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-086F98?style=flat-square" alt="macOS 13 or later">
  <img src="https://img.shields.io/badge/Apple%20Silicon%20%2B%20Intel-333333?style=flat-square" alt="Apple Silicon and Intel">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-086F98?style=flat-square" alt="MIT license"></a>
</p>

<p align="center">
  <a href="#install">Download</a> ·
  <a href="#screenshots">Screenshots</a> ·
  <a href="#build-from-source">Build from source</a> ·
  <a href="README.zh-CN.md">简体中文</a>
</p>

UTCMenuBar displays UTC in the menu bar while your system clock stays on local time. You can change its font, color, and style to tell the two apart. It also includes a converter for looking up times in other time zones.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/styles-dark.png">
    <img src="docs/assets/styles-light.png" width="900" alt="Three UTC clock styles: the default globe with date, a blue Menlo clock in brackets, and a minimal time-only clock">
  </picture>
</p>

<p align="center"><sub>Example menu bar styles, rendered with the app's formatter.</sub></p>

## Install

**[Download the latest release](https://github.com/NestDream/UTCMenuBar/releases/latest)** for macOS 13 Ventura or later. The same ZIP works on Apple Silicon and Intel.

1. Unzip `UTCMenuBar-vX.Y.Z.zip` and move **UTCMenuBar.app** to **Applications**.
2. Open the app. The clock appears in the menu bar, with no Dock icon.
3. To start it automatically, enable **Settings → Launch at login**.

> [!NOTE]
> Release builds are ad-hoc signed but not notarized by Apple. If macOS blocks the first launch, confirm that you downloaded it from this repository, then go to **System Settings → Privacy & Security → Open Anyway**. You can also [build from source](#build-from-source).

Release notes include a SHA-256 checksum. To check your download:

```sh
shasum -a 256 ~/Downloads/UTCMenuBar-vX.Y.Z.zip
```

For later versions, right-click the clock and choose **Check for Updates…**. The app asks before downloading and installing an update.

## Screenshots

These images use the app's views with sample data. See the [full gallery](docs/SCREENSHOTS.md) for light and dark versions in English and 简体中文.

<table>
  <tr><th>Clock panel</th><th>Time zone converter</th></tr>
  <tr>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/popover-en-dark.png"><img src="docs/assets/screenshots/popover-en-light.png" width="280" alt="UTC popover showing 14:30, the full date, and shortcuts for Settings, Time Zone Converter, and Quit"></picture></td>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/converter-en-dark.png"><img src="docs/assets/screenshots/converter-en-light.png" width="520" alt="Time Zone Converter showing 2026-09-25 14:30 UTC as 07:30 in America/Los_Angeles, with a copy button for each value"></picture></td>
  </tr>
</table>

## Usage

| Action | What happens |
| --- | --- |
| Click the clock | Show UTC time, the full date, and shortcuts to Settings and the converter |
| Right-click or Control-click | Open display options, appearance, language, and updates |
| ⌘, | Open Settings |
| ⌘T | Open the time zone converter |
| Esc | Close the clock panel |
| ⌘Q | Quit |

Keyboard shortcuts work while the clock panel is open.

The default display is `🌐 09/25 14:30 UTC`. Turn off **Compact time** to show seconds, turn off **Compact date** for `2026-09-25`, or turn off **Show date** to hide the date. The clock uses 24-hour time, and the date is always in UTC.

## Appearance

In **Settings → Appearance**, you can change the font, weight, size, color, icon, and surrounding brackets or bars. Choose System, Menlo, SF Mono, or another installed font. The preview updates as you make changes.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/settings-en-dark.png">
    <img src="docs/assets/screenshots/settings-en-light.png" width="380" alt="UTCMenuBar Settings scrolled to appearance options, language, and About, with a blue bracketed Menlo clock preview pinned above">
  </picture>
</p>

Settings also lets you switch between English and 简体中文 without restarting. Your preferences are saved for the next launch.

## Time zone conversion

Open **Time Zone Converter…**, choose a target time zone, and enter a time in either field. The other field updates to match:

```text
UTC                    2026-09-25 14:30:00
America/Los_Angeles     2026-09-25 07:30:00
```

Use `YYYY-MM-DD HH:MM:SS`. **Now** fills in the current time, and the copy buttons copy either value. The app remembers your selected time zone and uses macOS time-zone rules, including daylight saving time.

The converter works with one target zone at a time. The menu bar clock always shows UTC.

## Privacy and updates

The clock and converter work offline using your Mac's system time and time-zone data. Settings are stored locally. There are no accounts, ads, or telemetry.

Update checks contact GitHub. Automatic checks are on by default and run at launch if at least 24 hours have passed since the last successful check. You can turn them off in **Settings → Automatically check for updates**.

## Build from source

Requires macOS 13+ and a Swift 6 toolchain with the macOS SDK. The project uses Swift Package Manager and has no external dependencies.

```sh
git clone https://github.com/NestDream/UTCMenuBar.git
cd UTCMenuBar
./scripts/build-app.sh
open UTCMenuBar.app
```

This builds a release app for your Mac's architecture. To build for both Apple Silicon and Intel:

```sh
./scripts/build-app.sh release --universal
```

For development:

```sh
swift build                     # debug build
./scripts/test.sh               # custom test runner
./scripts/build-app.sh debug    # debug app bundle
```

Tests use a custom executable runner; run `scripts/test.sh` rather than `swift test`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the project layout and contribution guide, [CHANGELOG.md](CHANGELOG.md) for release history, and the [roadmap](docs/ROADMAP.md) for planned features.

## License

[MIT](LICENSE)
