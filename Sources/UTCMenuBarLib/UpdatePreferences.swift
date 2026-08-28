import Foundation

/// Persistence for the update feature: the auto-check switch, the tag the
/// user chose to skip, and the last check timestamp. Mirrors DisplayOptions'
/// save/load shape.
public struct UpdatePreferences: Equatable, Sendable {
    public var autoCheck: Bool
    public var skippedTag: String?
    public var lastCheckAt: Date?

    public static let autoCheckKey = "updates.autoCheck"
    public static let skippedTagKey = "updates.skippedTag"
    public static let lastCheckAtKey = "updates.lastCheckAt"

    public static let `default` = UpdatePreferences(autoCheck: true, skippedTag: nil, lastCheckAt: nil)

    public init(autoCheck: Bool = true, skippedTag: String? = nil, lastCheckAt: Date? = nil) {
        self.autoCheck = autoCheck
        self.skippedTag = skippedTag
        self.lastCheckAt = lastCheckAt
    }

    public func save(to defaults: UserDefaults = .standard) {
        defaults.set(autoCheck, forKey: Self.autoCheckKey)
        if let skippedTag {
            defaults.set(skippedTag, forKey: Self.skippedTagKey)
        } else {
            defaults.removeObject(forKey: Self.skippedTagKey)
        }
        if let lastCheckAt {
            defaults.set(lastCheckAt.timeIntervalSince1970, forKey: Self.lastCheckAtKey)
        } else {
            defaults.removeObject(forKey: Self.lastCheckAtKey)
        }
    }

    public static func load(from defaults: UserDefaults = .standard) -> UpdatePreferences {
        let auto = defaults.object(forKey: autoCheckKey) == nil
            ? `default`.autoCheck
            : defaults.bool(forKey: autoCheckKey)
        let skipped = defaults.string(forKey: skippedTagKey)
        let last = defaults.object(forKey: lastCheckAtKey) == nil
            ? nil
            : Date(timeIntervalSince1970: defaults.double(forKey: lastCheckAtKey))
        return UpdatePreferences(autoCheck: auto, skippedTag: skipped, lastCheckAt: last)
    }
}
