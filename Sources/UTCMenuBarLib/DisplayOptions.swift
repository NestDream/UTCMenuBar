@_exported import Foundation

public struct DisplayOptions: Equatable, Sendable {
    public var showDate: Bool
    public var compactTime: Bool
    public var compactDate: Bool

    public static let showDateKey = "displayOptions.showDate"
    public static let compactTimeKey = "displayOptions.compactTime"
    public static let compactDateKey = "displayOptions.compactDate"

    public static let `default` = DisplayOptions(showDate: false, compactTime: false, compactDate: false)

    public init(showDate: Bool = false, compactTime: Bool = false, compactDate: Bool = false) {
        self.showDate = showDate
        self.compactTime = compactTime
        self.compactDate = compactDate
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(showDate, forKey: DisplayOptions.showDateKey)
        defaults.set(compactTime, forKey: DisplayOptions.compactTimeKey)
        defaults.set(compactDate, forKey: DisplayOptions.compactDateKey)
    }

    public static func load(from defaults: UserDefaults = .standard) -> DisplayOptions {
        return DisplayOptions(
            showDate: defaults.bool(forKey: showDateKey),
            compactTime: defaults.bool(forKey: compactTimeKey),
            compactDate: defaults.bool(forKey: compactDateKey)
        )
    }
}
