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
        guard d.iconPrefix == .globe else { fatalError("FAIL: default.iconPrefix should be .globe, got \(d.iconPrefix)") }
        guard d.customFontName == "" else { fatalError("FAIL: default.customFontName should be empty, got '\(d.customFontName)'") }
        print("  ✓ testDefaultValues passed")
    }

    static func testInitWithAllParams() {
        print("  Running: testInitWithAllParams...")
        let s = StyleOptions(
            fontFamily: .menlo,
            fontWeight: .bold,
            fontSize: .large,
            textColor: .blue,
            decorator: .brackets,
            iconPrefix: .clock,
            customFontName: "Helvetica"
        )
        guard s.fontFamily == .menlo else { fatalError("FAIL: fontFamily mismatch") }
        guard s.fontWeight == .bold else { fatalError("FAIL: fontWeight mismatch") }
        guard s.fontSize == .large else { fatalError("FAIL: fontSize mismatch") }
        guard s.textColor == .blue else { fatalError("FAIL: textColor mismatch") }
        guard s.decorator == .brackets else { fatalError("FAIL: decorator mismatch") }
        guard s.iconPrefix == .clock else { fatalError("FAIL: iconPrefix mismatch") }
        guard s.customFontName == "Helvetica" else { fatalError("FAIL: customFontName mismatch") }
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
            decorator: .bars,
            iconPrefix: .compass,
            customFontName: "Times-Roman"
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

    static func testIconPrefixDisplayAndRawValue() {
        print("  Running: testIconPrefixDisplayAndRawValue...")
        let pairs: [(IconPrefix, String, String, String)] = [
            (.globe, "🌐 ", "地球仪", "Globe"),
            (.clock, "🕐 ", "时钟", "Clock"),
            (.compass, "🧭 ", "指南针", "Compass"),
            (.earth, "🌍 ", "地球", "Earth"),
            (.none, "", "无图标", "No icon"),
        ]
        for (icon, prefix, zhName, enName) in pairs {
            guard icon.prefix == prefix else {
                fatalError("FAIL: \(icon).prefix expected '\(prefix)', got '\(icon.prefix)'")
            }
            guard icon.displayName(for: .zh) == zhName else {
                fatalError("FAIL: \(icon).displayName(.zh) expected '\(zhName)', got '\(icon.displayName(for: .zh))'")
            }
            guard icon.displayName(for: .en) == enName else {
                fatalError("FAIL: \(icon).displayName(.en) expected '\(enName)', got '\(icon.displayName(for: .en))'")
            }
        }
        guard IconPrefix.allCases.count == 5 else {
            fatalError("FAIL: IconPrefix.allCases should have 5 cases, got \(IconPrefix.allCases.count)")
        }
        print("  ✓ testIconPrefixDisplayAndRawValue passed")
    }

    static func testLoadPreservesLegacyFontFamilyWithoutNewKeys() {
        print("  Running: testLoadPreservesLegacyFontFamilyWithoutNewKeys...")
        let suiteName = "com.utcmenubar.test.styleopts.legacy.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("FAIL: could not create UserDefaults suite")
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(FontFamily.menlo.rawValue, forKey: StyleOptions.fontFamilyKey)
        defaults.set(FontWeight.bold.rawValue, forKey: StyleOptions.fontWeightKey)

        let loaded = StyleOptions.load(from: defaults)
        guard loaded.fontFamily == .menlo else { fatalError("FAIL: legacy fontFamily lost: \(loaded.fontFamily)") }
        guard loaded.fontWeight == .bold else { fatalError("FAIL: legacy fontWeight lost: \(loaded.fontWeight)") }
        guard loaded.iconPrefix == .globe else { fatalError("FAIL: missing iconPrefix should default to .globe, got \(loaded.iconPrefix)") }
        guard loaded.customFontName == "" else { fatalError("FAIL: missing customFontName should default to empty, got '\(loaded.customFontName)'") }
        print("  ✓ testLoadPreservesLegacyFontFamilyWithoutNewKeys passed")
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
        testIconPrefixDisplayAndRawValue()
        testLoadPreservesLegacyFontFamilyWithoutNewKeys()
        print("\nAll StyleOptions unit tests passed ✓")
    }
}
