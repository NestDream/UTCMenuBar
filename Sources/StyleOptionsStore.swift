import Foundation
import UTCMenuBarLib

/// Single source of truth for the app's StyleOptions. Both AppDelegate (menu)
/// and SettingsWindowController write through this store; both subscribe to its
/// listeners so the menu, the menu bar attributedTitle, and the Settings window
/// stay in sync without depending on each other directly.
@MainActor
final class StyleOptionsStore {
    private(set) var current: StyleOptions
    private var listeners: [(StyleOptions) -> Void] = []
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.current = StyleOptions.load(from: defaults)
    }

    func update(_ mutate: (inout StyleOptions) -> Void) {
        mutate(&current)
        current.save(to: defaults)
        for listener in listeners {
            listener(current)
        }
    }

    func addListener(_ block: @escaping (StyleOptions) -> Void) {
        listeners.append(block)
    }
}
