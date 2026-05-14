import Foundation
import UTCMenuBarLib

/// **Validates: Requirements 4.1, 4.2**
/// Property 4: DisplayOptions persistence round-trip consistency
/// For any DisplayOptions value, saving to UserDefaults then loading should yield
/// a value equal to the original.

enum DisplayOptionsPropertyTests {

    static func testPersistenceRoundTrip() {
        print("  Running Property 4: DisplayOptions persistence round-trip (100 iterations)...")
        for i in 0..<100 {
            let suiteName = "com.utcmenubar.test.roundtrip.\(i).\(randomSuffix())"
            guard let testDefaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Failed to create UserDefaults suite: \(suiteName)")
            }

            defer {
                testDefaults.removePersistentDomain(forName: suiteName)
            }

            let original = DisplayOptions(
                showDate: Bool.random(),
                compactTime: Bool.random(),
                compactDate: Bool.random()
            )

            original.save(to: testDefaults)
            let loaded = DisplayOptions.load(from: testDefaults)

            guard loaded == original else {
                fatalError("FAIL: Round-trip failed at iteration \(i): original=\(original), loaded=\(loaded)")
            }
        }
        print("  ✓ Property 4 passed (100/100 iterations)")
    }

    private static func randomSuffix() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }

    static func runAll() {
        print("DisplayOptions Property Tests")
        print("=============================")
        testPersistenceRoundTrip()
        print("\nAll property tests passed ✓")
    }
}
