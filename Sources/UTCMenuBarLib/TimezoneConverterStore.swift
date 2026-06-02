import Foundation

/// Single source of truth for the app's TimezoneConverterOptions.
/// Mirrors StyleOptionsStore: load on init, mutate+save+notify on update.
@MainActor
public final class TimezoneConverterStore {
    public private(set) var current: TimezoneConverterOptions
    private var listeners: [UUID: (TimezoneConverterOptions) -> Void] = [:]
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = TimezoneConverterOptions.load(from: defaults)
    }

    public func update(_ mutate: (inout TimezoneConverterOptions) -> Void) {
        mutate(&current)
        current.save(to: defaults)
        for listener in listeners.values {
            listener(current)
        }
    }

    @discardableResult
    public func addListener(_ block: @escaping (TimezoneConverterOptions) -> Void) -> UUID {
        let token = UUID()
        listeners[token] = block
        return token
    }

    public func removeListener(_ token: UUID) {
        listeners[token] = nil
    }
}
