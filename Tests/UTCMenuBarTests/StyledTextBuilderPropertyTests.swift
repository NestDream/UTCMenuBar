import AppKit
import UTCMenuBarLib

/// **Validates: Property 1 (decorated content), Property 2 (font), Property 3 (color), Property 6 (uniformity)**

enum StyledTextBuilderPropertyTests {

    private static func randomStyleOptions() -> StyleOptions {
        StyleOptions(
            fontFamily: FontFamily.allCases.randomElement()!,
            fontWeight: FontWeight.allCases.randomElement()!,
            fontSize: FontSize.allCases.randomElement()!,
            textColor: TextColorOption.allCases.randomElement()!,
            decorator: Decorator.allCases.randomElement()!
        )
    }

    private static func randomText() -> String {
        // ASCII + emoji mix similar to real menu bar content
        let pool = ["🌐 12:00 UTC", "🌐 2025-01-01 00:00 UTC", "abc", "Hello 👋 World", "!@#$%"]
        return pool.randomElement()!
    }

    /// Property 1: result.string == decorator.prefix + text + decorator.suffix
    static func testDecoratedContent() {
        print("  Running Property 1: decorated content (100 iterations)...")
        for i in 0..<100 {
            let text = randomText()
            let style = randomStyleOptions()
            let attr = StyledTextBuilder.buildAttributedString(text: text, style: style)
            let expected = style.decorator.prefix + text + style.decorator.suffix
            guard attr.string == expected else {
                fatalError("FAIL: iter \(i) expected '\(expected)', got '\(attr.string)' (style=\(style))")
            }
        }
        print("  ✓ Property 1 passed (100/100 iterations)")
    }

    /// Property 2: resolveFont returns non-nil font with pointSize == size.pointSize.
    static func testFontResolution() {
        print("  Running Property 2: font resolution (100 iterations)...")
        for i in 0..<100 {
            let family = FontFamily.allCases.randomElement()!
            let weight = FontWeight.allCases.randomElement()!
            let size = FontSize.allCases.randomElement()!
            let f = StyledTextBuilder.resolveFont(family: family, weight: weight, size: size)
            guard f.pointSize == size.pointSize else {
                fatalError("FAIL: iter \(i) family=\(family) weight=\(weight) size=\(size): expected pointSize \(size.pointSize), got \(f.pointSize)")
            }
        }
        print("  ✓ Property 2 passed (100/100 iterations)")
    }

    /// Property 3: .default → nil; non-default → non-nil.
    static func testColorResolution() {
        print("  Running Property 3: color resolution (all cases)...")
        for option in TextColorOption.allCases {
            let resolved = StyledTextBuilder.resolveColor(option: option)
            if option == .default {
                guard resolved == nil else { fatalError("FAIL: .default should resolve to nil") }
            } else {
                guard resolved != nil else { fatalError("FAIL: \(option) should resolve to non-nil") }
            }
        }
        print("  ✓ Property 3 passed")
    }

    /// Property 6: Attributes are uniform across the full string range.
    static func testAttributeUniformity() {
        print("  Running Property 6: attribute uniformity (100 iterations)...")
        for i in 0..<100 {
            let text = randomText()
            let style = randomStyleOptions()
            let attr = StyledTextBuilder.buildAttributedString(text: text, style: style)
            let length = (attr.string as NSString).length
            guard length > 0 else { continue }

            let firstFont = attr.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
            let firstColor = attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor

            for idx in 0..<length {
                let f = attr.attribute(.font, at: idx, effectiveRange: nil) as? NSFont
                let c = attr.attribute(.foregroundColor, at: idx, effectiveRange: nil) as? NSColor
                guard f == firstFont else {
                    fatalError("FAIL: iter \(i) font differs at index \(idx)")
                }
                guard c == firstColor else {
                    fatalError("FAIL: iter \(i) color differs at index \(idx)")
                }
            }
        }
        print("  ✓ Property 6 passed (100/100 iterations)")
    }

    static func runAll() {
        print("StyledTextBuilder Property Tests")
        print("================================")
        testDecoratedContent()
        testFontResolution()
        testColorResolution()
        testAttributeUniformity()
        print("\nAll StyledTextBuilder property tests passed ✓")
    }
}
