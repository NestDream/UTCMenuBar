@_exported import Foundation

public struct DisplayOptions: Equatable, Sendable {
    public var showDate: Bool
    public var compactTime: Bool
    public var compactDate: Bool

    public static let showDateKey = "displayOptions.showDate"
    public static let compactTimeKey = "displayOptions.compactTime"
    public static let compactDateKey = "displayOptions.compactDate"

    public static let `default` = DisplayOptions(showDate: true, compactTime: true, compactDate: true)

    public init(showDate: Bool = true, compactTime: Bool = true, compactDate: Bool = true) {
        self.showDate = showDate
        self.compactTime = compactTime
        self.compactDate = compactDate
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(showDate, forKey: DisplayOptions.showDateKey)
        defaults.set(compactTime, forKey: DisplayOptions.compactTimeKey)
        defaults.set(compactDate, forKey: DisplayOptions.compactDateKey)
    }

    /// Loads each option from UserDefaults. A key that has never been written
    /// falls back to its `.default` value (not `false`), so a first launch with
    /// no stored prefs shows the intended default (date + compact time + compact date).
    public static func load(from defaults: UserDefaults = .standard) -> DisplayOptions {
        func bool(_ key: String, default fallback: Bool) -> Bool {
            defaults.object(forKey: key) == nil ? fallback : defaults.bool(forKey: key)
        }
        return DisplayOptions(
            showDate: bool(showDateKey, default: `default`.showDate),
            compactTime: bool(compactTimeKey, default: `default`.compactTime),
            compactDate: bool(compactDateKey, default: `default`.compactDate)
        )
    }
}
