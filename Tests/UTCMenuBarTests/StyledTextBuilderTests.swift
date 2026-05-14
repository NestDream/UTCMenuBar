import AppKit
import UTCMenuBarLib

/// Unit tests for StyledTextBuilder.
/// **Validates: Requirements 1.2, 2.2, 3.2-3.4, 4.2, 4.3, 4.5, 5.2, 5.3, 6.1, 6.3, 6.4**

enum StyledTextBuilderTests {

    static func testBuildAttributedStringContent() {
        print("  Running: testBuildAttributedStringContent...")
        let text = "🌐 12:00 UTC"
        let attr = StyledTextBuilder.buildAttributedString(text: text, style: .default)
        guard attr.string == text else {
            fatalError("FAIL: expected '\(text)', got '\(attr.string)'")
        }
        print("  ✓ testBuildAttributedStringContent passed")
    }

    static func testDecoratorBracketsWraps() {
        print("  Running: testDecoratorBracketsWraps...")
        let text = "🌐 12:00 UTC"
        var style = StyleOptions.default
        style.decorator = .brackets
        let attr = StyledTextBuilder.buildAttributedString(text: text, style: style)
        guard attr.string == "[🌐 12:00 UTC]" else {
            fatalError("FAIL: expected '[🌐 12:00 UTC]', got '\(attr.string)'")
        }
        print("  ✓ testDecoratorBracketsWraps passed")
    }

    static func testDecoratorAllCases() {
        print("  Running: testDecoratorAllCases...")
        let text = "T"
        let expected: [(Decorator, String)] = [
            (.none, "T"),
            (.brackets, "[T]"),
            (.parentheses, "(T)"),
            (.bars, "│T│"),
        ]
        for (dec, want) in expected {
            var style = StyleOptions.default
            style.decorator = dec
            let attr = StyledTextBuilder.buildAttributedString(text: text, style: style)
            guard attr.string == want else {
                fatalError("FAIL: decorator=\(dec) expected '\(want)', got '\(attr.string)'")
            }
        }
        print("  ✓ testDecoratorAllCases passed")
    }

    static func testDefaultColorOmitsForegroundAttribute() {
        print("  Running: testDefaultColorOmitsForegroundAttribute...")
        let attr = StyledTextBuilder.buildAttributedString(text: "abc", style: .default)
        let attrs = attr.attributes(at: 0, effectiveRange: nil)
        guard attrs[.foregroundColor] == nil else {
            fatalError("FAIL: .default color should omit .foregroundColor, got \(String(describing: attrs[.foregroundColor]))")
        }
        print("  ✓ testDefaultColorOmitsForegroundAttribute passed")
    }

    static func testNonDefaultColorAppliesForegroundAttribute() {
        print("  Running: testNonDefaultColorAppliesForegroundAttribute...")
        var style = StyleOptions.default
        style.textColor = .blue
        let attr = StyledTextBuilder.buildAttributedString(text: "abc", style: style)
        let color = attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        guard color == NSColor.systemBlue else {
            fatalError("FAIL: expected systemBlue, got \(String(describing: color))")
        }
        print("  ✓ testNonDefaultColorAppliesForegroundAttribute passed")
    }

    static func testFontAppliedAcrossFullRange() {
        print("  Running: testFontAppliedAcrossFullRange...")
        var style = StyleOptions.default
        style.fontSize = .large
        let text = "abcdef"
        let attr = StyledTextBuilder.buildAttributedString(text: text, style: style)
        let length = (attr.string as NSString).length
        for i in 0..<length {
            guard let f = attr.attribute(.font, at: i, effectiveRange: nil) as? NSFont else {
                fatalError("FAIL: missing .font at index \(i)")
            }
            guard f.pointSize == FontSize.large.pointSize else {
                fatalError("FAIL: pointSize mismatch at \(i): expected \(FontSize.large.pointSize), got \(f.pointSize)")
            }
        }
        print("  ✓ testFontAppliedAcrossFullRange passed")
    }

    static func testResolveFontSystem() {
        print("  Running: testResolveFontSystem...")
        let f = StyledTextBuilder.resolveFont(family: .system, weight: .bold, size: .standard)
        guard f.pointSize == FontSize.standard.pointSize else {
            fatalError("FAIL: system font pointSize mismatch")
        }
        print("  ✓ testResolveFontSystem passed")
    }

    static func testResolveFontSFMono() {
        print("  Running: testResolveFontSFMono...")
        let f = StyledTextBuilder.resolveFont(family: .sfMono, weight: .regular, size: .small)
        guard f.pointSize == FontSize.small.pointSize else {
            fatalError("FAIL: sfMono font pointSize mismatch")
        }
        print("  ✓ testResolveFontSFMono passed")
    }

    static func testResolveFontMenlo() {
        print("  Running: testResolveFontMenlo...")
        let f = StyledTextBuilder.resolveFont(family: .menlo, weight: .medium, size: .large)
        guard f.pointSize == FontSize.large.pointSize else {
            fatalError("FAIL: menlo font pointSize mismatch")
        }
        print("  ✓ testResolveFontMenlo passed")
    }

    static func testResolveFontCustomFallsBackWhenEmpty() {
        print("  Running: testResolveFontCustomFallsBackWhenEmpty...")
        let f = StyledTextBuilder.resolveFont(family: .custom, weight: .regular, size: .standard, customFontName: "")
        guard f.pointSize == FontSize.standard.pointSize else {
            fatalError("FAIL: empty customFontName should fall back; pointSize wrong")
        }
        print("  ✓ testResolveFontCustomFallsBackWhenEmpty passed")
    }

    static func testResolveFontCustomFallsBackWhenInvalid() {
        print("  Running: testResolveFontCustomFallsBackWhenInvalid...")
        let f = StyledTextBuilder.resolveFont(
            family: .custom,
            weight: .regular,
            size: .large,
            customFontName: "ThisFontDoesNotExistXYZ123"
        )
        guard f.pointSize == FontSize.large.pointSize else {
            fatalError("FAIL: invalid customFontName should fall back to system font")
        }
        print("  ✓ testResolveFontCustomFallsBackWhenInvalid passed")
    }

    static func testResolveFontCustomUsesNameWhenValid() {
        print("  Running: testResolveFontCustomUsesNameWhenValid...")
        let f = StyledTextBuilder.resolveFont(
            family: .custom,
            weight: .regular,
            size: .standard,
            customFontName: "Helvetica"
        )
        guard f.pointSize == FontSize.standard.pointSize else {
            fatalError("FAIL: pointSize wrong for custom Helvetica")
        }
        guard f.fontName.contains("Helvetica") else {
            fatalError("FAIL: custom font should be Helvetica family, got '\(f.fontName)'")
        }
        print("  ✓ testResolveFontCustomUsesNameWhenValid passed")
    }

    static func testResolveColorAllCases() {
        print("  Running: testResolveColorAllCases...")
        guard StyledTextBuilder.resolveColor(option: .default) == nil else {
            fatalError("FAIL: .default should resolve to nil")
        }
        guard StyledTextBuilder.resolveColor(option: .blue) == NSColor.systemBlue else {
            fatalError("FAIL: .blue should be systemBlue")
        }
        guard StyledTextBuilder.resolveColor(option: .green) == NSColor.systemGreen else {
            fatalError("FAIL: .green should be systemGreen")
        }
        guard StyledTextBuilder.resolveColor(option: .orange) == NSColor.systemOrange else {
            fatalError("FAIL: .orange should be systemOrange")
        }
        guard StyledTextBuilder.resolveColor(option: .purple) == NSColor.systemPurple else {
            fatalError("FAIL: .purple should be systemPurple")
        }
        guard StyledTextBuilder.resolveColor(option: .red) == NSColor.systemRed else {
            fatalError("FAIL: .red should be systemRed")
        }
        print("  ✓ testResolveColorAllCases passed")
    }

    static func runAll() {
        print("StyledTextBuilder Unit Tests")
        print("============================")
        testBuildAttributedStringContent()
        testDecoratorBracketsWraps()
        testDecoratorAllCases()
        testDefaultColorOmitsForegroundAttribute()
        testNonDefaultColorAppliesForegroundAttribute()
        testFontAppliedAcrossFullRange()
        testResolveFontSystem()
        testResolveFontSFMono()
        testResolveFontMenlo()
        testResolveFontCustomFallsBackWhenEmpty()
        testResolveFontCustomFallsBackWhenInvalid()
        testResolveFontCustomUsesNameWhenValid()
        testResolveColorAllCases()
        print("\nAll StyledTextBuilder unit tests passed ✓")
    }
}
