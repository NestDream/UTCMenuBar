import Foundation

/// Single source of truth for the app's StyleOptions. Both AppDelegate (menu)
/// and the Settings window write through this store; both subscribe to its
/// listeners so the menu, the menu bar attributedTitle, and the Settings window
/// stay in sync without depending on each other directly.
@MainActor
public final class StyleOptionsStore {
    public private(set) var current: StyleOptions
    private var listeners: [UUID: (StyleOptions) -> Void] = [:]
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = StyleOptions.load(from: defaults)
    }

    public func update(_ mutate: (inout StyleOptions) -> Void) {
        mutate(&current)
        current.save(to: defaults)
        for listener in listeners.values {
            listener(current)
        }
    }

    @discardableResult
    public func addListener(_ block: @escaping (StyleOptions) -> Void) -> UUID {
        let token = UUID()
        listeners[token] = block
        return token
    }

    public func removeListener(_ token: UUID) {
        listeners[token] = nil
    }
}
