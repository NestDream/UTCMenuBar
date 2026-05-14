import Foundation
import UTCMenuBarLib

/// Unit tests for DisplayOptions default values and empty UserDefaults behavior.
/// **Validates: Requirements 1.4, 2.4, 3.4, 4.3**

enum DisplayOptionsTests {

    /// Verify that DisplayOptions.default has all properties set to false.
    static func testDefaultValues() {
        print("  Running: testDefaultValues...")
        let defaults = DisplayOptions.default

        guard defaults.showDate == false else {
            fatalError("FAIL: DisplayOptions.default.showDate should be false, got \(defaults.showDate)")
        }
        guard defaults.compactTime == false else {
            fatalError("FAIL: DisplayOptions.default.compactTime should be false, got \(defaults.compactTime)")
        }
        guard defaults.compactDate == false else {
            fatalError("FAIL: DisplayOptions.default.compactDate should be false, got \(defaults.compactDate)")
        }
        print("  ✓ testDefaultValues passed")
    }

    /// Verify that loading from a fresh/empty UserDefaults suite returns default values (all false).
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

        guard loaded.showDate == false else {
            fatalError("FAIL: Loading from empty UserDefaults should have showDate=false, got \(loaded.showDate)")
        }
        guard loaded.compactTime == false else {
            fatalError("FAIL: Loading from empty UserDefaults should have compactTime=false, got \(loaded.compactTime)")
        }
        guard loaded.compactDate == false else {
            fatalError("FAIL: Loading from empty UserDefaults should have compactDate=false, got \(loaded.compactDate)")
        }
        print("  ✓ testLoadFromEmptyDefaults passed")
    }

    static func runAll() {
        print("DisplayOptions Unit Tests")
        print("=========================")
        testDefaultValues()
        testLoadFromEmptyDefaults()
        print("\nAll unit tests passed ✓")
    }
}
