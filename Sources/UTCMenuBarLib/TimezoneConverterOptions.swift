import Foundation

public struct TimezoneConverterOptions: Equatable, Sendable {
    public var targetTimezone: String

    public static let targetTimezoneKey = "timezoneConverter.targetTimezone"

    public static var `default`: TimezoneConverterOptions {
        TimezoneConverterOptions(targetTimezone: TimeZone.current.identifier)
    }

    public init(targetTimezone: String) {
        self.targetTimezone = targetTimezone
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(targetTimezone, forKey: TimezoneConverterOptions.targetTimezoneKey)
    }

    public static func load(from defaults: UserDefaults = .standard) -> TimezoneConverterOptions {
        let raw = defaults.string(forKey: targetTimezoneKey) ?? ""
        let valid = TimeZone(identifier: raw) != nil
        return TimezoneConverterOptions(
            targetTimezone: valid ? raw : TimeZone.current.identifier
        )
    }
}
