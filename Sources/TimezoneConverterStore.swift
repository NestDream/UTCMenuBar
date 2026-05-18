import Foundation
import UTCMenuBarLib

/// Single source of truth for the app's TimezoneConverterOptions.
/// Mirrors StyleOptionsStore: load on init, mutate+save+notify on update.
@MainActor
final class TimezoneConverterStore {
    private(set) var current: TimezoneConverterOptions
    private var listeners: [(TimezoneConverterOptions) -> Void] = []
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = TimezoneConverterOptions.load(from: defaults)
    }

    func update(_ mutate: (inout TimezoneConverterOptions) -> Void) {
        mutate(&current)
        current.save(to: defaults)
        for listener in listeners {
            listener(current)
        }
    }

    func addListener(_ block: @escaping (TimezoneConverterOptions) -> Void) {
        listeners.append(block)
    }
}
