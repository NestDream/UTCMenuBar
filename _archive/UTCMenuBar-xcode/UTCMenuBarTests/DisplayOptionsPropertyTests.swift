import Testing
import Foundation
@testable import UTCMenuBar

/// Property-based tests for DisplayOptions
/// **Validates: Requirements 4.1, 4.2**
struct DisplayOptionsPropertyTests {

    /// Property 4: DisplayOptions persistence round-trip consistency
    /// For any DisplayOptions value, saving to UserDefaults then loading
    /// should produce a value equal to the original.
    @Test("Property 4: DisplayOptions round-trip through UserDefaults")
    func persistenceRoundTripConsistency() {
        let suiteName = "com.utcmenubar.test.roundtrip"

        for i in 0..<100 {
            // Generate random DisplayOptions from all 8 Bool combinations
            // plus additional random variation
            let showDate = Bool.random()
            let compactTime = Bool.random()
            let compactDate = Bool.random()

            let original = DisplayOptions(
                showDate: showDate,
                compactTime: compactTime,
                compactDate: compactDate
            )

            // Save to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(original.showDate, forKey: DisplayOptions.showDateKey)
            defaults.set(original.compactTime, forKey: DisplayOptions.compactTimeKey)
            defaults.set(original.compactDate, forKey: DisplayOptions.compactDateKey)

            // Load from UserDefaults
            let loaded = DisplayOptions.load()

            // Verify round-trip consistency
            #expect(loaded == original,
                "Iteration \(i): loaded \(loaded) != original \(original)")

            // Clean up
            defaults.removeObject(forKey: DisplayOptions.showDateKey)
            defaults.removeObject(forKey: DisplayOptions.compactTimeKey)
            defaults.removeObject(forKey: DisplayOptions.compactDateKey)
        }
    }

    /// Additional round-trip test using the save() method directly
    @Test("Property 4: DisplayOptions save/load round-trip via save() method")
    func saveMethodRoundTripConsistency() {
        let defaults = UserDefaults.standard

        for i in 0..<100 {
            let original = DisplayOptions(
                showDate: Bool.random(),
                compactTime: Bool.random(),
                compactDate: Bool.random()
            )

            // Use the struct's own save method
            original.save()

            // Load using the struct's load method
            let loaded = DisplayOptions.load()

            #expect(loaded == original,
                "Iteration \(i): save/load round-trip failed - loaded \(loaded) != original \(original)")

            // Clean up
            defaults.removeObject(forKey: DisplayOptions.showDateKey)
            defaults.removeObject(forKey: DisplayOptions.compactTimeKey)
            defaults.removeObject(forKey: DisplayOptions.compactDateKey)
        }
    }
}
