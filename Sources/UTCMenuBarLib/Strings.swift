import Foundation

public enum StringKey: String, CaseIterable, Sendable {
    // Top-level menu
    case menuShowDate
    case menuCompactTime
    case menuCompactDate
    case menuAppearance
    case menuSettings
    case menuQuit

    // Appearance submenu titles
    case appearanceFont
    case appearanceWeight
    case appearanceSize
    case appearanceColor
    case appearanceIcon
    case appearanceDecorator

    // FontFamily
    case fontFamilySystem
    case fontFamilyMenlo
    case fontFamilySFMono
    case fontFamilyCustom
    case fontFamilyCustomWithName // "%@" placeholder for picked font name

    // FontWeight
    case fontWeightRegular
    case fontWeightMedium
    case fontWeightSemibold
    case fontWeightBold

    // FontSize
    case fontSizeSmall
    case fontSizeStandard
    case fontSizeLarge

    // TextColor
    case colorDefault
    case colorBlue
    case colorGreen
    case colorOrange
    case colorPurple
    case colorRed

    // IconPrefix
    case iconGlobe
    case iconClock
    case iconCompass
    case iconEarth
    case iconNone

    // Decorator
    case decoratorNone
    case decoratorBrackets
    case decoratorParentheses
    case decoratorBars

    // Settings window
    case settingsWindowTitle
    case settingsLabelFont
    case settingsLabelWeight
    case settingsLabelSize
    case settingsLabelColor
    case settingsLabelIcon
    case settingsLabelDecorator
    case settingsLabelLanguage
    case settingsLabelPreview

    // Language section
    case menuLanguage
    case languageEnglish
    case languageChinese

    // Timezone converter
    case menuTimezoneConverter
    case converterWindowTitle
    case converterLabelTimezone
    case converterLabelUTC
    case converterLabelTarget
    case converterNowButton
    case converterCopyButton
    case converterErrorInvalidFormat
    case converterErrorYearOutOfRange
    case converterErrorUnknownTimezone

    // Launch at login
    case settingsSectionGeneral
    case settingsLaunchAtLogin
    case launchAtLoginRequiresApproval
    case launchAtLoginOpenSettings
    case launchAtLoginErrorTitle
}

public enum Strings {

    public static func t(_ key: StringKey, language: AppLanguage) -> String {
        switch language {
        case .zh: return zh[key] ?? en[key] ?? key.rawValue
        case .en: return en[key] ?? key.rawValue
        }
    }

    public static func formatCustomFont(name: String, language: AppLanguage) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return t(.fontFamilyCustom, language: language)
        }
        switch language {
        case .zh: return "自定义：\(trimmed)"
        case .en: return "Custom: \(trimmed)"
        }
    }

    private static let en: [StringKey: String] = [
        .menuShowDate: "Show date",
        .menuCompactTime: "Compact time",
        .menuCompactDate: "Compact date",
        .menuAppearance: "Appearance",
        .menuSettings: "Settings…",
        .menuQuit: "Quit",

        .appearanceFont: "Font",
        .appearanceWeight: "Weight",
        .appearanceSize: "Size",
        .appearanceColor: "Color",
        .appearanceIcon: "Icon",
        .appearanceDecorator: "Decorator",

        .fontFamilySystem: "System",
        .fontFamilyMenlo: "Menlo (mono)",
        .fontFamilySFMono: "SF Mono (mono)",
        .fontFamilyCustom: "Custom…",
        .fontFamilyCustomWithName: "Custom: %@",

        .fontWeightRegular: "Regular",
        .fontWeightMedium: "Medium",
        .fontWeightSemibold: "Semibold",
        .fontWeightBold: "Bold",

        .fontSizeSmall: "Small",
        .fontSizeStandard: "Standard",
        .fontSizeLarge: "Large",

        .colorDefault: "Default",
        .colorBlue: "Blue",
        .colorGreen: "Green",
        .colorOrange: "Orange",
        .colorPurple: "Purple",
        .colorRed: "Red",

        .iconGlobe: "Globe",
        .iconClock: "Clock",
        .iconCompass: "Compass",
        .iconEarth: "Earth",
        .iconNone: "No icon",

        .decoratorNone: "None",
        .decoratorBrackets: "[Brackets]",
        .decoratorParentheses: "(Parentheses)",
        .decoratorBars: "│Bars│",

        .settingsWindowTitle: "UTCMenuBar Settings",
        .settingsLabelFont: "Font",
        .settingsLabelWeight: "Weight",
        .settingsLabelSize: "Size",
        .settingsLabelColor: "Color",
        .settingsLabelIcon: "Icon",
        .settingsLabelDecorator: "Decorator",
        .settingsLabelLanguage: "Language",
        .settingsLabelPreview: "Preview",

        .menuLanguage: "Language",
        .languageEnglish: "English",
        .languageChinese: "中文",

        .menuTimezoneConverter: "Time Zone Converter…",
        .converterWindowTitle: "Time Zone Converter",
        .converterLabelTimezone: "Time Zone",
        .converterLabelUTC: "UTC",
        .converterLabelTarget: "Target",
        .converterNowButton: "Now",
        .converterCopyButton: "Copy",
        .converterErrorInvalidFormat: "Invalid format. Use YYYY-MM-DD HH:MM:SS",
        .converterErrorYearOutOfRange: "Year out of range (1900-2100)",
        .converterErrorUnknownTimezone: "Unknown timezone",

        .settingsSectionGeneral: "General",
        .settingsLaunchAtLogin: "Launch at login",
        .launchAtLoginRequiresApproval: "Pending approval — open System Settings to enable",
        .launchAtLoginOpenSettings: "Open Login Items…",
        .launchAtLoginErrorTitle: "Couldn't change launch-at-login setting",
    ]

    private static let zh: [StringKey: String] = [
        .menuShowDate: "显示日期",
        .menuCompactTime: "紧凑时间",
        .menuCompactDate: "紧凑日期",
        .menuAppearance: "外观",
        .menuSettings: "设置…",
        .menuQuit: "退出",

        .appearanceFont: "字体",
        .appearanceWeight: "字重",
        .appearanceSize: "字号",
        .appearanceColor: "颜色",
        .appearanceIcon: "图标",
        .appearanceDecorator: "装饰",

        .fontFamilySystem: "系统字体",
        .fontFamilyMenlo: "Menlo（等宽）",
        .fontFamilySFMono: "SF Mono（等宽）",
        .fontFamilyCustom: "自定义…",
        .fontFamilyCustomWithName: "自定义：%@",

        .fontWeightRegular: "常规",
        .fontWeightMedium: "中等",
        .fontWeightSemibold: "半粗",
        .fontWeightBold: "粗体",

        .fontSizeSmall: "小",
        .fontSizeStandard: "标准",
        .fontSizeLarge: "大",

        .colorDefault: "默认",
        .colorBlue: "蓝色",
        .colorGreen: "绿色",
        .colorOrange: "橙色",
        .colorPurple: "紫色",
        .colorRed: "红色",

        .iconGlobe: "地球仪",
        .iconClock: "时钟",
        .iconCompass: "指南针",
        .iconEarth: "地球",
        .iconNone: "无图标",

        .decoratorNone: "无装饰",
        .decoratorBrackets: "[方括号]",
        .decoratorParentheses: "(圆括号)",
        .decoratorBars: "│竖线│",

        .settingsWindowTitle: "UTCMenuBar 设置",
        .settingsLabelFont: "字体",
        .settingsLabelWeight: "字重",
        .settingsLabelSize: "字号",
        .settingsLabelColor: "颜色",
        .settingsLabelIcon: "图标",
        .settingsLabelDecorator: "装饰",
        .settingsLabelLanguage: "语言",
        .settingsLabelPreview: "预览",

        .menuLanguage: "语言",
        .languageEnglish: "English",
        .languageChinese: "中文",

        .menuTimezoneConverter: "时区转换…",
        .converterWindowTitle: "时区转换",
        .converterLabelTimezone: "时区",
        .converterLabelUTC: "UTC",
        .converterLabelTarget: "目标",
        .converterNowButton: "现在",
        .converterCopyButton: "复制",
        .converterErrorInvalidFormat: "无法解析时间，请使用 YYYY-MM-DD HH:MM:SS 格式",
        .converterErrorYearOutOfRange: "年份超出范围（1900-2100）",
        .converterErrorUnknownTimezone: "未知时区",

        .settingsSectionGeneral: "通用",
        .settingsLaunchAtLogin: "开机启动",
        .launchAtLoginRequiresApproval: "等待系统授权 — 请前往「系统设置」启用",
        .launchAtLoginOpenSettings: "打开登录项设置…",
        .launchAtLoginErrorTitle: "无法更改开机启动设置",
    ]
}
