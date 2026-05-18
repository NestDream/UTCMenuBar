import Foundation
import UTCMenuBarLib

/// Single source of truth for the current AppLanguage. Mirrors StyleOptionsStore.
@MainActor
final class LanguageStore {
    private(set) var current: AppLanguage
    private var listeners: [(AppLanguage) -> Void] = []
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = AppLanguage.load(from: defaults)
    }

    func update(_ newLanguage: AppLanguage) {
        guard newLanguage != current else { return }
        current = newLanguage
        current.save(to: defaults)
        for listener in listeners {
            listener(current)
        }
    }

    func addListener(_ block: @escaping (AppLanguage) -> Void) {
        listeners.append(block)
    }
}
