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

    // Status item (tooltip + VoiceOver label prefix)
    case statusItemToolTip

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
    case converterBidirectional
    case converterErrorInvalidFormat
    case converterErrorYearOutOfRange
    case converterErrorUnknownTimezone

    // Common
    case commonOK
    case commonCancel

    // In-app updates
    case menuCheckForUpdates
    case updateAvailableTitle
    case updateInstall
    case updateLater
    case updateViewRelease
    case updateSkipVersion
    case updateUpToDateTitle
    case updateDownloading
    case updateFailedTitle
    case updateFailedBody
    case updateAutoCheck
    case updateCannotReplace

    // Settings sections
    case settingsSectionDisplay

    // Launch at login
    case settingsSectionGeneral
    case settingsLaunchAtLogin
    case launchAtLoginRequiresApproval
    case launchAtLoginOpenSettings
    case launchAtLoginErrorTitle

    // About section
    case settingsSectionAbout
    case aboutVersion
    case aboutViewReleases
}

public enum Strings {

    public static func t(_ key: StringKey, language: AppLanguage) -> String {
        switch language {
        case .zh: return zh[key] ?? en[key] ?? key.rawValue
        case .en: return en[key] ?? key.rawValue
        }
    }

    public static func formatUpdateAvailable(newVersion: String, currentVersion: String, language: AppLanguage) -> String {
        switch language {
        case .zh: return "新版本 \(newVersion) 可用（当前版本 \(currentVersion)）。"
        case .en: return "Version \(newVersion) is available. You have \(currentVersion)."
        }
    }

    public static func formatUpToDate(currentVersion: String, language: AppLanguage) -> String {
        switch language {
        case .zh: return "UTCMenuBar \(currentVersion) 已是最新版本。"
        case .en: return "UTCMenuBar \(currentVersion) is the latest version."
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

        .statusItemToolTip: "UTC Time",

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
        .converterBidirectional: "Converts in both directions",
        .converterErrorInvalidFormat: "Invalid format. Use YYYY-MM-DD HH:MM:SS",
        .converterErrorYearOutOfRange: "Year out of range (1900-2100)",
        .converterErrorUnknownTimezone: "Unknown timezone",

        .commonOK: "OK",
        .commonCancel: "Cancel",

        .menuCheckForUpdates: "Check for Updates…",
        .updateAvailableTitle: "Update Available",
        .updateInstall: "Install Now",
        .updateLater: "Later",
        .updateViewRelease: "View Release Page",
        .updateSkipVersion: "Skip this version",
        .updateUpToDateTitle: "You're up to date",
        .updateDownloading: "Downloading update…",
        .updateFailedTitle: "Update failed",
        .updateFailedBody: "The update could not be installed. You can download it manually from the releases page.",
        .updateAutoCheck: "Automatically check for updates",
        .updateCannotReplace: "The app can't replace itself at its current location. Please download the new version manually.",

        .settingsSectionDisplay: "Display",

        .settingsSectionGeneral: "General",
        .settingsLaunchAtLogin: "Launch at login",
        .launchAtLoginRequiresApproval: "Pending approval — open System Settings to enable",
        .launchAtLoginOpenSettings: "Open Login Items…",
        .launchAtLoginErrorTitle: "Couldn't change launch-at-login setting",

        .settingsSectionAbout: "About",
        .aboutVersion: "Version",
        .aboutViewReleases: "View releases on GitHub",
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

        .statusItemToolTip: "UTC 时间",

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
        .converterBidirectional: "双向转换",
        .converterErrorInvalidFormat: "无法解析时间，请使用 YYYY-MM-DD HH:MM:SS 格式",
        .converterErrorYearOutOfRange: "年份超出范围（1900-2100）",
        .converterErrorUnknownTimezone: "未知时区",

        .commonOK: "好",
        .commonCancel: "取消",

        .menuCheckForUpdates: "检查更新…",
        .updateAvailableTitle: "发现新版本",
        .updateInstall: "立即更新",
        .updateLater: "稍后",
        .updateViewRelease: "查看发行页",
        .updateSkipVersion: "跳过此版本",
        .updateUpToDateTitle: "已是最新版本",
        .updateDownloading: "正在下载更新…",
        .updateFailedTitle: "更新失败",
        .updateFailedBody: "更新未能完成安装，可从发行页手动下载。",
        .updateAutoCheck: "自动检查更新",
        .updateCannotReplace: "无法在当前位置自动替换应用，请手动下载新版本。",

        .settingsSectionDisplay: "显示",

        .settingsSectionGeneral: "通用",
        .settingsLaunchAtLogin: "开机启动",
        .launchAtLoginRequiresApproval: "等待系统授权 — 请前往「系统设置」启用",
        .launchAtLoginOpenSettings: "打开登录项设置…",
        .launchAtLoginErrorTitle: "无法更改开机启动设置",

        .settingsSectionAbout: "关于",
        .aboutVersion: "版本",
        .aboutViewReleases: "在 GitHub 查看发行版",
    ]
}
