import Foundation
import UTCMenuBarLib

enum TimezoneConverterOptionsTests {

    static func testDefaultUsesCurrentTimezone() {
        print("  Running: testDefaultUsesCurrentTimezone...")
        let d = TimezoneConverterOptions.default
        guard d.targetTimezone == TimeZone.current.identifier else {
            fatalError("FAIL: default targetTimezone should be '\(TimeZone.current.identifier)', got '\(d.targetTimezone)'")
        }
        print("  ✓ testDefaultUsesCurrentTimezone passed")
    }

    static func testSaveLoadRoundTrip() {
        print("  Running: testSaveLoadRoundTrip...")
        let suiteName = "com.utcmenubar.test.tzopts.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let original = TimezoneConverterOptions(targetTimezone: "America/Los_Angeles")
        original.save(to: defaults)
        let loaded = TimezoneConverterOptions.load(from: defaults)
        guard loaded == original else {
            fatalError("FAIL: round-trip mismatch: got '\(loaded.targetTimezone)'")
        }
        print("  ✓ testSaveLoadRoundTrip passed")
    }

    static func testLoadFromEmptyFallsBackToCurrent() {
        print("  Running: testLoadFromEmptyFallsBackToCurrent...")
        let suiteName = "com.utcmenubar.test.tzopts.empty.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let loaded = TimezoneConverterOptions.load(from: defaults)
        guard loaded.targetTimezone == TimeZone.current.identifier else {
            fatalError("FAIL: empty should fall back to current, got '\(loaded.targetTimezone)'")
        }
        print("  ✓ testLoadFromEmptyFallsBackToCurrent passed")
    }

    static func testLoadWithInvalidTimezoneFallsBack() {
        print("  Running: testLoadWithInvalidTimezoneFallsBack...")
        let suiteName = "com.utcmenubar.test.tzopts.invalid.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("Not/A/Timezone", forKey: TimezoneConverterOptions.targetTimezoneKey)
        let loaded = TimezoneConverterOptions.load(from: defaults)
        guard loaded.targetTimezone == TimeZone.current.identifier else {
            fatalError("FAIL: invalid tz should fall back, got '\(loaded.targetTimezone)'")
        }
        print("  ✓ testLoadWithInvalidTimezoneFallsBack passed")
    }

    static func testEquatable() {
        print("  Running: testEquatable...")
        let a = TimezoneConverterOptions(targetTimezone: "Asia/Shanghai")
        let b = TimezoneConverterOptions(targetTimezone: "Asia/Shanghai")
        let c = TimezoneConverterOptions(targetTimezone: "Europe/London")
        guard a == b else { fatalError("FAIL: same tz should be ==") }
        guard a != c else { fatalError("FAIL: different tz should be !=") }
        print("  ✓ testEquatable passed")
    }

    static func runAll() {
        print("TimezoneConverterOptions Unit Tests")
        print("====================================")
        testDefaultUsesCurrentTimezone()
        testSaveLoadRoundTrip()
        testLoadFromEmptyFallsBackToCurrent()
        testLoadWithInvalidTimezoneFallsBack()
        testEquatable()
        print("\nAll TimezoneConverterOptions unit tests passed ✓")
    }
}
