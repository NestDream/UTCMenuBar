import AppKit

public enum FontFamily: String, CaseIterable, Sendable {
    case system = "system"
    case menlo = "Menlo"
    case sfMono = "SF Mono"
    case custom = "custom"

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .system: return Strings.t(.fontFamilySystem, language: language)
        case .menlo: return Strings.t(.fontFamilyMenlo, language: language)
        case .sfMono: return Strings.t(.fontFamilySFMono, language: language)
        case .custom: return Strings.t(.fontFamilyCustom, language: language)
        }
    }
}

public enum FontWeight: String, CaseIterable, Sendable {
    case regular
    case medium
    case semibold
    case bold

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .regular: return Strings.t(.fontWeightRegular, language: language)
        case .medium: return Strings.t(.fontWeightMedium, language: language)
        case .semibold: return Strings.t(.fontWeightSemibold, language: language)
        case .bold: return Strings.t(.fontWeightBold, language: language)
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

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .small: return Strings.t(.fontSizeSmall, language: language)
        case .standard: return Strings.t(.fontSizeStandard, language: language)
        case .large: return Strings.t(.fontSizeLarge, language: language)
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

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .default: return Strings.t(.colorDefault, language: language)
        case .blue: return Strings.t(.colorBlue, language: language)
        case .green: return Strings.t(.colorGreen, language: language)
        case .orange: return Strings.t(.colorOrange, language: language)
        case .purple: return Strings.t(.colorPurple, language: language)
        case .red: return Strings.t(.colorRed, language: language)
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

public enum IconPrefix: String, CaseIterable, Sendable {
    case globe = "globe"
    case clock = "clock"
    case compass = "compass"
    case earth = "earth"
    case none = "none"

    public static let `default` = IconPrefix.globe

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .globe: return Strings.t(.iconGlobe, language: language)
        case .clock: return Strings.t(.iconClock, language: language)
        case .compass: return Strings.t(.iconCompass, language: language)
        case .earth: return Strings.t(.iconEarth, language: language)
        case .none: return Strings.t(.iconNone, language: language)
        }
    }

    public var prefix: String {
        switch self {
        case .globe: return "🌐 "
        case .clock: return "🕐 "
        case .compass: return "🧭 "
        case .earth: return "🌍 "
        case .none: return ""
        }
    }
}

public enum Decorator: String, CaseIterable, Sendable {
    case none
    case brackets
    case parentheses
    case bars

    public func displayName(for language: AppLanguage) -> String {
        switch self {
        case .none: return Strings.t(.decoratorNone, language: language)
        case .brackets: return Strings.t(.decoratorBrackets, language: language)
        case .parentheses: return Strings.t(.decoratorParentheses, language: language)
        case .bars: return Strings.t(.decoratorBars, language: language)
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
    public var iconPrefix: IconPrefix
    public var customFontName: String

    public static let fontFamilyKey = "styleOptions.fontFamily"
    public static let fontWeightKey = "styleOptions.fontWeight"
    public static let fontSizeKey = "styleOptions.fontSize"
    public static let textColorKey = "styleOptions.textColor"
    public static let decoratorKey = "styleOptions.decorator"
    public static let iconPrefixKey = "styleOptions.iconPrefix"
    public static let customFontNameKey = "styleOptions.customFontName"

    public static let `default` = StyleOptions(
        fontFamily: .system,
        fontWeight: .regular,
        fontSize: .standard,
        textColor: .default,
        decorator: .none,
        iconPrefix: .globe,
        customFontName: ""
    )

    public init(
        fontFamily: FontFamily = .system,
        fontWeight: FontWeight = .regular,
        fontSize: FontSize = .standard,
        textColor: TextColorOption = .default,
        decorator: Decorator = .none,
        iconPrefix: IconPrefix = .globe,
        customFontName: String = ""
    ) {
        self.fontFamily = fontFamily
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.textColor = textColor
        self.decorator = decorator
        self.iconPrefix = iconPrefix
        self.customFontName = customFontName
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(fontFamily.rawValue, forKey: StyleOptions.fontFamilyKey)
        defaults.set(fontWeight.rawValue, forKey: StyleOptions.fontWeightKey)
        defaults.set(fontSize.rawValue, forKey: StyleOptions.fontSizeKey)
        defaults.set(textColor.rawValue, forKey: StyleOptions.textColorKey)
        defaults.set(decorator.rawValue, forKey: StyleOptions.decoratorKey)
        defaults.set(iconPrefix.rawValue, forKey: StyleOptions.iconPrefixKey)
        defaults.set(customFontName, forKey: StyleOptions.customFontNameKey)
    }

    public static func load(from defaults: UserDefaults = .standard) -> StyleOptions {
        let family = (defaults.string(forKey: fontFamilyKey).flatMap(FontFamily.init(rawValue:))) ?? .system
        let weight = (defaults.string(forKey: fontWeightKey).flatMap(FontWeight.init(rawValue:))) ?? .regular
        let size = (defaults.string(forKey: fontSizeKey).flatMap(FontSize.init(rawValue:))) ?? .standard
        let color = (defaults.string(forKey: textColorKey).flatMap(TextColorOption.init(rawValue:))) ?? .default
        let decorator = (defaults.string(forKey: decoratorKey).flatMap(Decorator.init(rawValue:))) ?? .none
        let icon = (defaults.string(forKey: iconPrefixKey).flatMap(IconPrefix.init(rawValue:))) ?? .globe
        let customName = defaults.string(forKey: customFontNameKey) ?? ""
        return StyleOptions(
            fontFamily: family,
            fontWeight: weight,
            fontSize: size,
            textColor: color,
            decorator: decorator,
            iconPrefix: icon,
            customFontName: customName
        )
    }
}
