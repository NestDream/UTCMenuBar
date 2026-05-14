import Foundation
import UTCMenuBarLib

/// **Validates: Property 4 (round-trip), Property 5 (tolerant load)**

enum StyleOptionsPropertyTests {

    private static func randomStyleOptions() -> StyleOptions {
        let names = ["", "Helvetica", "Helvetica Neue", "Times-Roman", "Courier"]
        return StyleOptions(
            fontFamily: FontFamily.allCases.randomElement()!,
            fontWeight: FontWeight.allCases.randomElement()!,
            fontSize: FontSize.allCases.randomElement()!,
            textColor: TextColorOption.allCases.randomElement()!,
            decorator: Decorator.allCases.randomElement()!,
            iconPrefix: IconPrefix.allCases.randomElement()!,
            customFontName: names.randomElement()!
        )
    }

    private static func randomSuffix() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }

    /// Property 4: For any StyleOptions value, save → load returns equal value.
    static func testPersistenceRoundTrip() {
        print("  Running Property 4: StyleOptions round-trip (100 iterations)...")
        for i in 0..<100 {
            let suiteName = "com.utcmenubar.test.styleopts.roundtrip.\(i).\(randomSuffix())"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("FAIL: could not create UserDefaults suite")
            }
            defer { defaults.removePersistentDomain(forName: suiteName) }

            let original = randomStyleOptions()
            original.save(to: defaults)
            let loaded = StyleOptions.load(from: defaults)
            guard loaded == original else {
                fatalError("FAIL: round-trip mismatch at iteration \(i): original=\(original), loaded=\(loaded)")
            }
        }
        print("  ✓ Property 4 passed (100/100 iterations)")
    }

    /// Property 5: For arbitrary invalid raw strings, load returns valid StyleOptions
    /// where each field is in its enum's allCases (i.e., always falls back gracefully).
    static func testTolerantLoad() {
        print("  Running Property 5: StyleOptions tolerant load (100 iterations)...")
        for i in 0..<100 {
            let suiteName = "com.utcmenubar.test.styleopts.tolerant.\(i).\(randomSuffix())"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("FAIL: could not create UserDefaults suite")
            }
            defer { defaults.removePersistentDomain(forName: suiteName) }

            // Write garbage strings to all keys.
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.fontFamilyKey)
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.fontWeightKey)
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.fontSizeKey)
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.textColorKey)
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.decoratorKey)
            defaults.set("garbage-\(randomSuffix())", forKey: StyleOptions.iconPrefixKey)

            let loaded = StyleOptions.load(from: defaults)

            guard FontFamily.allCases.contains(loaded.fontFamily) else {
                fatalError("FAIL: tolerant load produced invalid fontFamily at iteration \(i)")
            }
            guard FontWeight.allCases.contains(loaded.fontWeight) else {
                fatalError("FAIL: tolerant load produced invalid fontWeight at iteration \(i)")
            }
            guard FontSize.allCases.contains(loaded.fontSize) else {
                fatalError("FAIL: tolerant load produced invalid fontSize at iteration \(i)")
            }
            guard TextColorOption.allCases.contains(loaded.textColor) else {
                fatalError("FAIL: tolerant load produced invalid textColor at iteration \(i)")
            }
            guard Decorator.allCases.contains(loaded.decorator) else {
                fatalError("FAIL: tolerant load produced invalid decorator at iteration \(i)")
            }
            guard IconPrefix.allCases.contains(loaded.iconPrefix) else {
                fatalError("FAIL: tolerant load produced invalid iconPrefix at iteration \(i)")
            }
        }
        print("  ✓ Property 5 passed (100/100 iterations)")
    }

    static func runAll() {
        print("StyleOptions Property Tests")
        print("===========================")
        testPersistenceRoundTrip()
        testTolerantLoad()
        print("\nAll StyleOptions property tests passed ✓")
    }
}
