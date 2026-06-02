# Security Policy

UTCMenuBar is a small, hobby macOS menu bar app. This document explains which
versions get security fixes, how to report a problem, and the app's overall
security posture so you can decide how much to trust it.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

Security fixes are made against the latest `1.0.x` release. Older pre-1.0
releases are not maintained — please update to the latest version.

## Reporting a Vulnerability

Please report security issues **privately** rather than opening a public issue:

1. Go to the repository's **Security** tab:
   <https://github.com/NestDream/UTCMenuBar/security>
2. Choose **Report a vulnerability** to open a private security advisory via
   GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability).

Please include enough detail to reproduce the issue (affected version, macOS
version, and steps). If you have a suggested fix, a draft is welcome but not
required.

### What to expect

This is a spare-time project with no commercial backing or SLA, so all timelines
are **best-effort**:

- An acknowledgement when the report is seen, typically within a couple of weeks.
- A fix or a clear explanation of why it isn't considered an issue, prioritized
  by severity and available time.
- Credit in the advisory and release notes once a fix ships, if you'd like it.

Please give a reasonable window for a fix before any public disclosure.

## Security Posture

UTCMenuBar is intentionally minimal, which keeps its attack surface small:

- **No network activity.** The app never makes network requests. It only reads
  the system clock and renders the time in UTC. There is no telemetry, no
  analytics, and no auto-update mechanism.
- **No accounts or secrets.** It collects no personal data and stores no
  credentials.
- **Local preferences only.** The only data it persists is your UI preferences
  (display format, visual style, language, timezone-converter state, launch-at-login
  toggle), stored in macOS `UserDefaults` under `displayOptions.*` / `styleOptions.*`
  keys. Nothing leaves your machine.
- **No special entitlements.** The app requests no extra permissions, no sandbox
  exceptions, and no access to files, contacts, location, or other sensitive
  resources. Launch-at-login uses Apple's standard `SMAppService` API.
- **No third-party dependencies.** The build uses only Apple's AppKit,
  Foundation, and SwiftUI/Combine frameworks — there is no external Swift Package
  Manager dependency to audit or compromise.

## Distribution and Trust

Prebuilt binaries are distributed **unsigned** (the project has no Apple
Developer account). On first launch macOS Gatekeeper will warn about the app;
the documented workaround is to right-click the app and choose **Open**.

Because the binaries are unsigned, you should only trust them as far as you
trust the source:

- **Build from source** if you'd rather not run a prebuilt binary you can't
  verify. The full source is in this repository, and `./scripts/build-app.sh`
  produces the app bundle locally with no external dependencies.
- **Verify the download.** Each GitHub release publishes **SHA-256 checksums**
  for its artifacts. Compare the checksum of your download against the one in
  the release before opening the app:

  ```sh
  shasum -a 256 UTCMenuBar.app.zip
  ```

  If the value doesn't match the release notes, do not run it.
