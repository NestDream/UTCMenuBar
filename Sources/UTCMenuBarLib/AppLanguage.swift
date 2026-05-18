import Foundation

public enum AppLanguage: String, CaseIterable, Sendable {
    case zh
    case en

    public static let userDefaultsKey = "app.language"

    public static var systemDefault: AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("zh") ? .zh : .en
    }

    public var nativeName: String {
        switch self {
        case .zh: return "中文"
        case .en: return "English"
        }
    }

    public func displayName(for language: AppLanguage) -> String {
        switch (self, language) {
        case (.zh, .zh): return "中文"
        case (.zh, .en): return "Chinese"
        case (.en, .zh): return "英文"
        case (.en, .en): return "English"
        }
    }

    public static func load(from defaults: UserDefaults = .standard) -> AppLanguage {
        if let raw = defaults.string(forKey: userDefaultsKey),
           let lang = AppLanguage(rawValue: raw) {
            return lang
        }
        return systemDefault
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(rawValue, forKey: AppLanguage.userDefaultsKey)
    }
}
