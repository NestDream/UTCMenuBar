import Foundation
import UTCMenuBarLib

/// Tests for the pure update logic: AppVersion parsing/ordering, GitHub
/// release JSON parsing, availability decisions, auto-check throttling, and
/// UpdatePreferences persistence.
/// **Validates: in-app-update Properties P1-P6**

enum UpdateCheckerTests {

    // MARK: P1 — version parsing

    static func testVersionParsing() {
        print("  Running: testVersionParsing...")
        guard AppVersion.parse("1.2.3") == AppVersion(major: 1, minor: 2, patch: 3) else {
            fatalError("FAIL: plain x.y.z should parse")
        }
        guard AppVersion.parse("v10.0.1") == AppVersion(major: 10, minor: 0, patch: 1) else {
            fatalError("FAIL: v-prefixed tag should parse")
        }
        for bad in ["", "1.2", "1.2.3.4", "0.0.0-dev", "1.2.x", "v", "1..3", "a.b.c", "—"] {
            guard AppVersion.parse(bad) == nil else {
                fatalError("FAIL: '\(bad)' should not parse, got \(AppVersion.parse(bad)!)")
            }
        }
        print("  ✓ testVersionParsing passed")
    }

    // MARK: P2 — ordering matches lexicographic segment comparison (property)

    static func testVersionOrderingProperty() {
        print("  Running: testVersionOrderingProperty (100 iterations)...")
        for i in 0..<100 {
            let a = AppVersion(major: Int.random(in: 0...3), minor: Int.random(in: 0...3), patch: Int.random(in: 0...3))
            let b = AppVersion(major: Int.random(in: 0...3), minor: Int.random(in: 0...3), patch: Int.random(in: 0...3))
            let expected = [a.major, a.minor, a.patch].lexicographicallyPrecedes([b.major, b.minor, b.patch])
            guard (a < b) == expected else {
                fatalError("FAIL iter \(i): \(a) < \(b) should be \(expected)")
            }
        }
        print("  ✓ testVersionOrderingProperty passed")
    }

    // MARK: P3 — release JSON parsing

    private static func releaseJSON(
        tag: String = "v9.9.9",
        draft: Bool = false,
        prerelease: Bool = false,
        assetNames: [String] = ["UTCMenuBar-v9.9.9.zip"]
    ) -> Data {
        let assets = assetNames.map {
            #"{"name": "\#($0)", "browser_download_url": "https://example.com/\#($0)"}"#
        }.joined(separator: ",")
        let json = #"""
        {
          "tag_name": "\#(tag)",
          "html_url": "https://github.com/NestDream/UTCMenuBar/releases/tag/\#(tag)",
          "draft": \#(draft),
          "prerelease": \#(prerelease),
          "assets": [\#(assets)]
        }
        """#
        return Data(json.utf8)
    }

    static func testParseLatestRelease() {
        print("  Running: testParseLatestRelease...")
        guard let info = UpdateChecker.parseLatestRelease(json: releaseJSON()) else {
            fatalError("FAIL: valid release should parse")
        }
        guard info.version == AppVersion(major: 9, minor: 9, patch: 9),
              info.tagName == "v9.9.9",
              info.assetName == "UTCMenuBar-v9.9.9.zip" else {
            fatalError("FAIL: parsed fields wrong: \(info)")
        }
        guard UpdateChecker.parseLatestRelease(json: releaseJSON(draft: true)) == nil else {
            fatalError("FAIL: draft must not parse")
        }
        guard UpdateChecker.parseLatestRelease(json: releaseJSON(prerelease: true)) == nil else {
            fatalError("FAIL: prerelease must not parse")
        }
        guard UpdateChecker.parseLatestRelease(json: releaseJSON(tag: "nightly")) == nil else {
            fatalError("FAIL: unparsable tag must not parse")
        }
        guard UpdateChecker.parseLatestRelease(json: releaseJSON(assetNames: ["source.tar.gz"])) == nil else {
            fatalError("FAIL: release without a zip asset must not parse")
        }
        guard UpdateChecker.parseLatestRelease(json: Data("not json".utf8)) == nil else {
            fatalError("FAIL: garbage input must not parse")
        }
        // Prefers the UTCMenuBar-*.zip over other zips.
        guard let multi = UpdateChecker.parseLatestRelease(
            json: releaseJSON(assetNames: ["symbols.zip", "UTCMenuBar-v9.9.9.zip"])) else {
            fatalError("FAIL: multi-asset release should parse")
        }
        guard multi.assetName == "UTCMenuBar-v9.9.9.zip" else {
            fatalError("FAIL: should prefer UTCMenuBar-*.zip, got \(multi.assetName)")
        }
        print("  ✓ testParseLatestRelease passed")
    }

    // MARK: P4 — availability decision

    static func testAvailableUpdate() {
        print("  Running: testAvailableUpdate...")
        let latest = UpdateChecker.parseLatestRelease(json: releaseJSON(tag: "v2.0.0", assetNames: ["UTCMenuBar-v2.0.0.zip"]))!

        guard UpdateChecker.availableUpdate(currentVersion: "1.9.9", latest: latest) == latest else {
            fatalError("FAIL: strictly newer version should be offered")
        }
        guard UpdateChecker.availableUpdate(currentVersion: "2.0.0", latest: latest) == nil else {
            fatalError("FAIL: equal version must not be offered")
        }
        guard UpdateChecker.availableUpdate(currentVersion: "2.0.1", latest: latest) == nil else {
            fatalError("FAIL: older release must not be offered")
        }
        guard UpdateChecker.availableUpdate(currentVersion: "0.0.0-dev", latest: latest) == nil else {
            fatalError("FAIL: dev build must never be offered updates")
        }
        guard UpdateChecker.availableUpdate(currentVersion: "1.0.0", latest: latest, skippedTag: "v2.0.0") == nil else {
            fatalError("FAIL: skipped tag must not be offered")
        }
        guard UpdateChecker.availableUpdate(currentVersion: "1.0.0", latest: latest, skippedTag: "v1.5.0") == latest else {
            fatalError("FAIL: skipping another tag must not block this one")
        }
        print("  ✓ testAvailableUpdate passed")
    }

    // MARK: P5 — auto-check throttle

    static func testShouldAutoCheck() {
        print("  Running: testShouldAutoCheck...")
        let now = Date(timeIntervalSince1970: 1_000_000)
        guard !UpdateChecker.shouldAutoCheck(now: now, preferences: UpdatePreferences(autoCheck: false)) else {
            fatalError("FAIL: disabled switch must never auto-check")
        }
        guard UpdateChecker.shouldAutoCheck(now: now, preferences: UpdatePreferences(autoCheck: true, lastCheckAt: nil)) else {
            fatalError("FAIL: never-checked should auto-check")
        }
        let recent = UpdatePreferences(autoCheck: true, lastCheckAt: now.addingTimeInterval(-3600))
        guard !UpdateChecker.shouldAutoCheck(now: now, preferences: recent) else {
            fatalError("FAIL: checked 1h ago must not re-check")
        }
        let stale = UpdatePreferences(autoCheck: true, lastCheckAt: now.addingTimeInterval(-86_400))
        guard UpdateChecker.shouldAutoCheck(now: now, preferences: stale) else {
            fatalError("FAIL: checked 24h ago should re-check")
        }
        print("  ✓ testShouldAutoCheck passed")
    }

    // MARK: P6 — preferences persistence round-trip

    static func testPreferencesRoundTrip() {
        print("  Running: testPreferencesRoundTrip...")
        let name = "com.utcmenubar.test.updates.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: name) else { fatalError("FAIL: suite create") }
        defer { defaults.removePersistentDomain(forName: name) }

        // Untouched defaults load as the documented default.
        guard UpdatePreferences.load(from: defaults) == .default else {
            fatalError("FAIL: fresh load should equal .default")
        }

        let prefs = UpdatePreferences(
            autoCheck: false,
            skippedTag: "v3.1.4",
            lastCheckAt: Date(timeIntervalSince1970: 1_234_567))
        prefs.save(to: defaults)
        guard UpdatePreferences.load(from: defaults) == prefs else {
            fatalError("FAIL: save/load round trip mismatch")
        }

        // Clearing optionals persists as removal, not stale values.
        var cleared = prefs
        cleared.skippedTag = nil
        cleared.lastCheckAt = nil
        cleared.save(to: defaults)
        guard UpdatePreferences.load(from: defaults) == cleared else {
            fatalError("FAIL: cleared optionals should load as nil")
        }
        print("  ✓ testPreferencesRoundTrip passed")
    }

    static func runAll() {
        print("UpdateChecker Unit Tests")
        print("========================")
        testVersionParsing()
        testVersionOrderingProperty()
        testParseLatestRelease()
        testAvailableUpdate()
        testShouldAutoCheck()
        testPreferencesRoundTrip()
        print("\nAll UpdateChecker unit tests passed ✓")
    }
}
