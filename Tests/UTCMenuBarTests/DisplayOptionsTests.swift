import Foundation
import UTCMenuBarLib

/// Unit tests for DisplayOptions default values and empty UserDefaults behavior.
/// **Validates: Requirements 1.4, 2.4, 3.4, 4.3**

enum DisplayOptionsTests {

    /// Verify that DisplayOptions.default has the expected values.
    static func testDefaultValues() {
        print("  Running: testDefaultValues...")
        let defaults = DisplayOptions.default

        guard defaults.showDate == true else {
            fatalError("FAIL: DisplayOptions.default.showDate should be true, got \(defaults.showDate)")
        }
        guard defaults.compactTime == true else {
            fatalError("FAIL: DisplayOptions.default.compactTime should be true, got \(defaults.compactTime)")
        }
        guard defaults.compactDate == true else {
            fatalError("FAIL: DisplayOptions.default.compactDate should be true, got \(defaults.compactDate)")
        }
        print("  ✓ testDefaultValues passed")
    }

    /// Verify that loading from a fresh/empty UserDefaults suite returns the
    /// intended first-launch defaults (.default == all true), not all-false.
    static func testLoadFromEmptyDefaults() {
        print("  Running: testLoadFromEmptyDefaults...")
        let suiteName = "com.utcmenubar.test.empty.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let emptyDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: Could not create UserDefaults suite: \(suiteName)")
        }
        defer {
            emptyDefaults.removePersistentDomain(forName: suiteName)
        }

        let loaded = DisplayOptions.load(from: emptyDefaults)

        guard loaded == .default else {
            fatalError("FAIL: Loading from empty UserDefaults should equal .default, got \(loaded)")
        }
        print("  ✓ testLoadFromEmptyDefaults passed")
    }

    /// Verify that an explicitly-saved all-false state round-trips correctly
    /// (i.e. a user who turns everything off is respected, not overridden by .default).
    static func testLoadRespectsExplicitFalse() {
        print("  Running: testLoadRespectsExplicitFalse...")
        let suiteName = "com.utcmenubar.test.explicitfalse.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: Could not create UserDefaults suite: \(suiteName)")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        DisplayOptions(showDate: false, compactTime: false, compactDate: false).save(to: defaults)
        let loaded = DisplayOptions.load(from: defaults)

        guard loaded == DisplayOptions(showDate: false, compactTime: false, compactDate: false) else {
            fatalError("FAIL: explicit all-false should round-trip, got \(loaded)")
        }
        print("  ✓ testLoadRespectsExplicitFalse passed")
    }

    /// Verify a partial save (only showDate written) keeps the explicit value and
    /// fills missing keys from .default.
    static func testLoadPartialKeysFillFromDefault() {
        print("  Running: testLoadPartialKeysFillFromDefault...")
        let suiteName = "com.utcmenubar.test.partial.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: Could not create UserDefaults suite: \(suiteName)")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(false, forKey: DisplayOptions.showDateKey)
        let loaded = DisplayOptions.load(from: defaults)

        guard loaded.showDate == false else {
            fatalError("FAIL: explicit showDate=false should be respected, got \(loaded.showDate)")
        }
        guard loaded.compactTime == DisplayOptions.default.compactTime,
              loaded.compactDate == DisplayOptions.default.compactDate else {
            fatalError("FAIL: missing keys should fall back to .default, got \(loaded)")
        }
        print("  ✓ testLoadPartialKeysFillFromDefault passed")
    }

    static func runAll() {
        print("DisplayOptions Unit Tests")
        print("=========================")
        testDefaultValues()
        testLoadFromEmptyDefaults()
        testLoadRespectsExplicitFalse()
        testLoadPartialKeysFillFromDefault()
        print("\nAll unit tests passed ✓")
    }
}
