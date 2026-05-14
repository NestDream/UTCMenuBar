import AppKit

public enum StyledTextBuilder {

    /// Build the menu bar's NSAttributedString from a plain text and StyleOptions.
    /// - Wraps text with `style.decorator.prefix` / `.suffix`
    /// - Always sets `.font`
    /// - Sets `.foregroundColor` only when `style.textColor != .default`
    public static func buildAttributedString(text: String, style: StyleOptions) -> NSAttributedString {
        let font = resolveFont(
            family: style.fontFamily,
            weight: style.fontWeight,
            size: style.fontSize,
            customFontName: style.customFontName
        )
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        if let color = resolveColor(option: style.textColor) {
            attributes[.foregroundColor] = color
        }
        let decorated = style.decorator.prefix + text + style.decorator.suffix
        return NSAttributedString(string: decorated, attributes: attributes)
    }

    public static func resolveFont(
        family: FontFamily,
        weight: FontWeight,
        size: FontSize,
        customFontName: String = ""
    ) -> NSFont {
        let pt = size.pointSize
        switch family {
        case .system:
            return NSFont.systemFont(ofSize: pt, weight: weight.nsWeight)
        case .menlo:
            if let f = NSFont(name: "Menlo", size: pt) {
                return applyWeight(to: f, weight: weight)
            }
            return NSFont.monospacedSystemFont(ofSize: pt, weight: weight.nsWeight)
        case .sfMono:
            return NSFont.monospacedSystemFont(ofSize: pt, weight: weight.nsWeight)
        case .custom:
            let trimmed = customFontName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, let f = NSFont(name: trimmed, size: pt) {
                return applyWeight(to: f, weight: weight)
            }
            return NSFont.systemFont(ofSize: pt, weight: weight.nsWeight)
        }
    }

    public static func resolveColor(option: TextColorOption) -> NSColor? {
        return option.nsColor
    }

    private static func applyWeight(to font: NSFont, weight: FontWeight) -> NSFont {
        let descriptor = font.fontDescriptor.addingAttributes([
            .traits: [NSFontDescriptor.TraitKey.weight: weight.nsWeight]
        ])
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
    }
}
