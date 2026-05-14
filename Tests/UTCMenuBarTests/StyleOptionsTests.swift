import Foundation
import UTCMenuBarLib

/// Unit tests for StyleOptions data model: defaults, equality, persistence, fault tolerance.
/// **Validates: Requirements 1.3, 2.3, 3.5, 4.4, 5.4, 7.1, 7.2, 7.3**

enum StyleOptionsTests {

    static func testDefaultValues() {
        print("  Running: testDefaultValues...")
        let d = StyleOptions.default
        guard d.fontFamily == .system else { fatalError("FAIL: default.fontFamily should be .system, got \(d.fontFamily)") }
        guard d.fontWeight == .regular else { fatalError("FAIL: default.fontWeight should be .regular, got \(d.fontWeight)") }
        guard d.fontSize == .standard else { fatalError("FAIL: default.fontSize should be .standard, got \(d.fontSize)") }
        guard d.textColor == .default else { fatalError("FAIL: default.textColor should be .default, got \(d.textColor)") }
        guard d.decorator == .none else { fatalError("FAIL: default.decorator should be .none, got \(d.decorator)") }
        print("  ✓ testDefaultValues passed")
    }

    static func testInitWithAllParams() {
        print("  Running: testInitWithAllParams...")
        let s = StyleOptions(
            fontFamily: .menlo,
            fontWeight: .bold,
            fontSize: .large,
            textColor: .blue,
            decorator: .brackets
        )
        guard s.fontFamily == .menlo else { fatalError("FAIL: fontFamily mismatch") }
        guard s.fontWeight == .bold else { fatalError("FAIL: fontWeight mismatch") }
        guard s.fontSize == .large else { fatalError("FAIL: fontSize mismatch") }
        guard s.textColor == .blue else { fatalError("FAIL: textColor mismatch") }
        guard s.decorator == .brackets else { fatalError("FAIL: decorator mismatch") }
        print("  ✓ testInitWithAllParams passed")
    }

    static func testEquatable() {
        print("  Running: testEquatable...")
        let a = StyleOptions(fontFamily: .menlo, fontWeight: .bold, fontSize: .large, textColor: .blue, decorator: .brackets)
        let b = StyleOptions(fontFamily: .menlo, fontWeight: .bold, fontSize: .large, textColor: .blue, decorator: .brackets)
        let c = StyleOptions(fontFamily: .menlo, fontWeight: .bold, fontSize: .large, textColor: .blue, decorator: .none)
        guard a == b else { fatalError("FAIL: equal values should be ==") }
        guard a != c else { fatalError("FAIL: differing decorator should make != true") }
        print("  ✓ testEquatable passed")
    }

    static func testSaveLoadRoundTripWithCustomDefaults() {
        print("  Running: testSaveLoadRoundTripWithCustomDefaults...")
        let suiteName = "com.utcmenubar.test.styleopts.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let original = StyleOptions(
            fontFamily: .sfMono,
            fontWeight: .semibold,
            fontSize: .small,
            textColor: .purple,
            decorator: .bars
        )
        original.save(to: defaults)
        let loaded = StyleOptions.load(from: defaults)
        guard loaded == original else { fatalError("FAIL: round-trip mismatch: original=\(original), loaded=\(loaded)") }
        print("  ✓ testSaveLoadRoundTripWithCustomDefaults passed")
    }

    static func testLoadFromEmptyDefaultsReturnsDefault() {
        print("  Running: testLoadFromEmptyDefaultsReturnsDefault...")
        let suiteName = "com.utcmenubar.test.styleopts.empty.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let loaded = StyleOptions.load(from: defaults)
        guard loaded == .default else { fatalError("FAIL: empty defaults should yield .default, got \(loaded)") }
        print("  ✓ testLoadFromEmptyDefaultsReturnsDefault passed")
    }

    static func testLoadWithInvalidRawValuesReturnsDefaults() {
        print("  Running: testLoadWithInvalidRawValuesReturnsDefaults...")
        let suiteName = "com.utcmenubar.test.styleopts.invalid.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("not-a-family", forKey: StyleOptions.fontFamilyKey)
        defaults.set("not-a-weight", forKey: StyleOptions.fontWeightKey)
        defaults.set("not-a-size", forKey: StyleOptions.fontSizeKey)
        defaults.set("not-a-color", forKey: StyleOptions.textColorKey)
        defaults.set("not-a-decorator", forKey: StyleOptions.decoratorKey)

        let loaded = StyleOptions.load(from: defaults)
        guard loaded == .default else { fatalError("FAIL: invalid raw values should fall back to .default, got \(loaded)") }
        print("  ✓ testLoadWithInvalidRawValuesReturnsDefaults passed")
    }

    static func runAll() {
        print("StyleOptions Unit Tests")
        print("=======================")
        testDefaultValues()
        testInitWithAllParams()
        testEquatable()
        testSaveLoadRoundTripWithCustomDefaults()
        testLoadFromEmptyDefaultsReturnsDefault()
        testLoadWithInvalidRawValuesReturnsDefaults()
        print("\nAll StyleOptions unit tests passed ✓")
    }
}
