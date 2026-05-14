import AppKit

public enum FontFamily: String, CaseIterable, Sendable {
    case system = "system"
    case menlo = "Menlo"
    case sfMono = "SF Mono"

    public var displayName: String {
        switch self {
        case .system: return "系统字体"
        case .menlo: return "Menlo（等宽）"
        case .sfMono: return "SF Mono（等宽）"
        }
    }
}

public enum FontWeight: String, CaseIterable, Sendable {
    case regular
    case medium
    case semibold
    case bold

    public var displayName: String {
        switch self {
        case .regular: return "常规"
        case .medium: return "中等"
        case .semibold: return "半粗"
        case .bold: return "粗体"
        }
    }

    public var nsWeight: NSFont.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}

public enum FontSize: String, CaseIterable, Sendable {
    case small
    case standard
    case large

    public var displayName: String {
        switch self {
        case .small: return "小"
        case .standard: return "标准"
        case .large: return "大"
        }
    }

    public var pointSize: CGFloat {
        let base = NSFont.menuBarFont(ofSize: 0).pointSize
        switch self {
        case .small: return base - 2
        case .standard: return base
        case .large: return base + 2
        }
    }
}

public enum TextColorOption: String, CaseIterable, Sendable {
    case `default`
    case blue
    case green
    case orange
    case purple
    case red

    public var displayName: String {
        switch self {
        case .default: return "默认"
        case .blue: return "蓝色"
        case .green: return "绿色"
        case .orange: return "橙色"
        case .purple: return "紫色"
        case .red: return "红色"
        }
    }

    public var nsColor: NSColor? {
        switch self {
        case .default: return nil
        case .blue: return .systemBlue
        case .green: return .systemGreen
        case .orange: return .systemOrange
        case .purple: return .systemPurple
        case .red: return .systemRed
        }
    }
}

public enum Decorator: String, CaseIterable, Sendable {
    case none
    case brackets
    case parentheses
    case bars

    public var displayName: String {
        switch self {
        case .none: return "无装饰"
        case .brackets: return "[方括号]"
        case .parentheses: return "(圆括号)"
        case .bars: return "│竖线│"
        }
    }

    public var prefix: String {
        switch self {
        case .none: return ""
        case .brackets: return "["
        case .parentheses: return "("
        case .bars: return "│"
        }
    }

    public var suffix: String {
        switch self {
        case .none: return ""
        case .brackets: return "]"
        case .parentheses: return ")"
        case .bars: return "│"
        }
    }
}

public struct StyleOptions: Equatable, Sendable {
    public var fontFamily: FontFamily
    public var fontWeight: FontWeight
    public var fontSize: FontSize
    public var textColor: TextColorOption
    public var decorator: Decorator

    public static let fontFamilyKey = "styleOptions.fontFamily"
    public static let fontWeightKey = "styleOptions.fontWeight"
    public static let fontSizeKey = "styleOptions.fontSize"
    public static let textColorKey = "styleOptions.textColor"
    public static let decoratorKey = "styleOptions.decorator"

    public static let `default` = StyleOptions(
        fontFamily: .system,
        fontWeight: .regular,
        fontSize: .standard,
        textColor: .default,
        decorator: .none
    )

    public init(
        fontFamily: FontFamily = .system,
        fontWeight: FontWeight = .regular,
        fontSize: FontSize = .standard,
        textColor: TextColorOption = .default,
        decorator: Decorator = .none
    ) {
        self.fontFamily = fontFamily
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.textColor = textColor
        self.decorator = decorator
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(fontFamily.rawValue, forKey: StyleOptions.fontFamilyKey)
        defaults.set(fontWeight.rawValue, forKey: StyleOptions.fontWeightKey)
        defaults.set(fontSize.rawValue, forKey: StyleOptions.fontSizeKey)
        defaults.set(textColor.rawValue, forKey: StyleOptions.textColorKey)
        defaults.set(decorator.rawValue, forKey: StyleOptions.decoratorKey)
    }

    public static func load(from defaults: UserDefaults = .standard) -> StyleOptions {
        let family = (defaults.string(forKey: fontFamilyKey).flatMap(FontFamily.init(rawValue:))) ?? .system
        let weight = (defaults.string(forKey: fontWeightKey).flatMap(FontWeight.init(rawValue:))) ?? .regular
        let size = (defaults.string(forKey: fontSizeKey).flatMap(FontSize.init(rawValue:))) ?? .standard
        let color = (defaults.string(forKey: textColorKey).flatMap(TextColorOption.init(rawValue:))) ?? .default
        let decorator = (defaults.string(forKey: decoratorKey).flatMap(Decorator.init(rawValue:))) ?? .none
        return StyleOptions(
            fontFamily: family,
            fontWeight: weight,
            fontSize: size,
            textColor: color,
            decorator: decorator
        )
    }
}
