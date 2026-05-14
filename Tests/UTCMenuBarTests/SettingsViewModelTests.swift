import AppKit
import UTCMenuBarLib

/// Unit tests for SettingsViewModel: pure index ↔ enum mapping + preview rendering.

enum SettingsViewModelTests {

    static func testSelectedIndexFontFamily() {
        print("  Running: testSelectedIndexFontFamily...")
        for (i, v) in FontFamily.allCases.enumerated() {
            guard SettingsViewModel.selectedIndex(v) == i else {
                fatalError("FAIL: FontFamily.\(v) selectedIndex \(SettingsViewModel.selectedIndex(v)) expected \(i)")
            }
        }
        print("  ✓ testSelectedIndexFontFamily passed")
    }

    static func testSelectedIndexAllEnums() {
        print("  Running: testSelectedIndexAllEnums...")
        for (i, v) in FontWeight.allCases.enumerated() {
            guard SettingsViewModel.selectedIndex(v) == i else {
                fatalError("FAIL: FontWeight.\(v) index mismatch")
            }
        }
        for (i, v) in FontSize.allCases.enumerated() {
            guard SettingsViewModel.selectedIndex(v) == i else {
                fatalError("FAIL: FontSize.\(v) index mismatch")
            }
        }
        for (i, v) in TextColorOption.allCases.enumerated() {
            guard SettingsViewModel.selectedIndex(v) == i else {
                fatalError("FAIL: TextColorOption.\(v) index mismatch")
            }
        }
        for (i, v) in Decorator.allCases.enumerated() {
            guard SettingsViewModel.selectedIndex(v) == i else {
                fatalError("FAIL: Decorator.\(v) index mismatch")
            }
        }
        print("  ✓ testSelectedIndexAllEnums passed")
    }

    static func testValueAtIndexRoundTrip() {
        print("  Running: testValueAtIndexRoundTrip...")
        for (i, v) in FontFamily.allCases.enumerated() {
            guard SettingsViewModel.value(at: i, of: FontFamily.self) == v else {
                fatalError("FAIL: FontFamily round-trip at \(i)")
            }
        }
        for (i, v) in FontWeight.allCases.enumerated() {
            guard SettingsViewModel.value(at: i, of: FontWeight.self) == v else {
                fatalError("FAIL: FontWeight round-trip at \(i)")
            }
        }
        for (i, v) in FontSize.allCases.enumerated() {
            guard SettingsViewModel.value(at: i, of: FontSize.self) == v else {
                fatalError("FAIL: FontSize round-trip at \(i)")
            }
        }
        for (i, v) in TextColorOption.allCases.enumerated() {
            guard SettingsViewModel.value(at: i, of: TextColorOption.self) == v else {
                fatalError("FAIL: TextColorOption round-trip at \(i)")
            }
        }
        for (i, v) in Decorator.allCases.enumerated() {
            guard SettingsViewModel.value(at: i, of: Decorator.self) == v else {
                fatalError("FAIL: Decorator round-trip at \(i)")
            }
        }
        print("  ✓ testValueAtIndexRoundTrip passed")
    }

    static func testValueAtInvalidIndexReturnsNil() {
        print("  Running: testValueAtInvalidIndexReturnsNil...")
        guard SettingsViewModel.value(at: -1, of: FontFamily.self) == nil else {
            fatalError("FAIL: -1 should return nil")
        }
        guard SettingsViewModel.value(at: FontFamily.allCases.count, of: FontFamily.self) == nil else {
            fatalError("FAIL: out-of-range should return nil")
        }
        guard SettingsViewModel.value(at: 999, of: Decorator.self) == nil else {
            fatalError("FAIL: 999 should return nil")
        }
        print("  ✓ testValueAtInvalidIndexReturnsNil passed")
    }

    static func testPreviewAttributedStringMatchesBuilder() {
        print("  Running: testPreviewAttributedStringMatchesBuilder...")
        let style = StyleOptions(fontFamily: .menlo, fontWeight: .bold, fontSize: .large, textColor: .blue, decorator: .brackets)
        let sample = "🌐 14:30:25 UTC"
        let preview = SettingsViewModel.previewAttributedString(style: style, sample: sample)
        let direct = StyledTextBuilder.buildAttributedString(text: sample, style: style)
        guard preview.string == direct.string else {
            fatalError("FAIL: preview string '\(preview.string)' != builder '\(direct.string)'")
        }
        // Same font and color attribute at index 0
        let pFont = preview.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
        let dFont = direct.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
        guard pFont == dFont else { fatalError("FAIL: preview font differs from builder font") }
        let pColor = preview.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        let dColor = direct.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        guard pColor == dColor else { fatalError("FAIL: preview color differs from builder color") }
        print("  ✓ testPreviewAttributedStringMatchesBuilder passed")
    }

    static func runAll() {
        print("SettingsViewModel Unit Tests")
        print("============================")
        testSelectedIndexFontFamily()
        testSelectedIndexAllEnums()
        testValueAtIndexRoundTrip()
        testValueAtInvalidIndexReturnsNil()
        testPreviewAttributedStringMatchesBuilder()
        print("\nAll SettingsViewModel unit tests passed ✓")
    }
}
