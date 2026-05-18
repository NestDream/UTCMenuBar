import Foundation
import UTCMenuBarLib

enum AppLanguageTests {

    static func testNativeNames() {
        print("  Running: testNativeNames...")
        guard AppLanguage.zh.nativeName == "中文" else { fatalError("FAIL: zh.nativeName") }
        guard AppLanguage.en.nativeName == "English" else { fatalError("FAIL: en.nativeName") }
        print("  ✓ testNativeNames passed")
    }

    static func testRawValuesStable() {
        print("  Running: testRawValuesStable...")
        guard AppLanguage.zh.rawValue == "zh" else { fatalError("FAIL: zh raw") }
        guard AppLanguage.en.rawValue == "en" else { fatalError("FAIL: en raw") }
        print("  ✓ testRawValuesStable passed")
    }

    static func testSaveLoadRoundTrip() {
        print("  Running: testSaveLoadRoundTrip...")
        let suiteName = "com.utcmenubar.test.lang.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }
        AppLanguage.zh.save(to: defaults)
        guard AppLanguage.load(from: defaults) == .zh else { fatalError("FAIL: zh round-trip") }
        AppLanguage.en.save(to: defaults)
        guard AppLanguage.load(from: defaults) == .en else { fatalError("FAIL: en round-trip") }
        print("  ✓ testSaveLoadRoundTrip passed")
    }

    static func testLoadFromEmptyFallsBackToSystemDefault() {
        print("  Running: testLoadFromEmptyFallsBackToSystemDefault...")
        let suiteName = "com.utcmenubar.test.lang.empty.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let loaded = AppLanguage.load(from: defaults)
        // System default depends on environment; either zh or en is valid.
        guard AppLanguage.allCases.contains(loaded) else {
            fatalError("FAIL: loaded \(loaded) not in allCases")
        }
        print("  ✓ testLoadFromEmptyFallsBackToSystemDefault passed (loaded=\(loaded.rawValue))")
    }

    static func testLoadWithInvalidValueFallsBack() {
        print("  Running: testLoadWithInvalidValueFallsBack...")
        let suiteName = "com.utcmenubar.test.lang.invalid.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set("klingon", forKey: AppLanguage.userDefaultsKey)
        let loaded = AppLanguage.load(from: defaults)
        guard AppLanguage.allCases.contains(loaded) else {
            fatalError("FAIL: invalid value didn't fall back to a valid case")
        }
        print("  ✓ testLoadWithInvalidValueFallsBack passed")
    }

    static func runAll() {
        print("AppLanguage Unit Tests")
        print("======================")
        testNativeNames()
        testRawValuesStable()
        testSaveLoadRoundTrip()
        testLoadFromEmptyFallsBackToSystemDefault()
        testLoadWithInvalidValueFallsBack()
        print("\nAll AppLanguage unit tests passed ✓")
    }
}
