import Foundation

/// Single source of truth for the current AppLanguage. Mirrors StyleOptionsStore.
@MainActor
public final class LanguageStore {
    public private(set) var current: AppLanguage
    private var listeners: [UUID: (AppLanguage) -> Void] = [:]
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = AppLanguage.load(from: defaults)
    }

    public func update(_ newLanguage: AppLanguage) {
        guard newLanguage != current else { return }
        current = newLanguage
        current.save(to: defaults)
        for listener in listeners.values {
            listener(current)
        }
    }

    @discardableResult
    public func addListener(_ block: @escaping (AppLanguage) -> Void) -> UUID {
        let token = UUID()
        listeners[token] = block
        return token
    }

    public func removeListener(_ token: UUID) {
        listeners[token] = nil
    }
}
