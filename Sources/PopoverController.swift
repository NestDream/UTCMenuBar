import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class PopoverController {
    private let popover = NSPopover()
    private let statusItem: NSStatusItem
    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore
    private let onShowSettings: () -> Void
    private let onShowConverter: () -> Void
    private let onQuit: () -> Void

    init(
        statusItem: NSStatusItem,
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        displayOptionsProvider: @escaping () -> DisplayOptions,
        onShowSettings: @escaping () -> Void,
        onShowConverter: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.statusItem = statusItem
        self.styleStore = styleStore
        self.languageStore = languageStore
        self.onShowSettings = onShowSettings
        self.onShowConverter = onShowConverter
        self.onQuit = onQuit

        let viewModel = ClockPopoverViewModel(
            styleStore: styleStore,
            languageStore: languageStore,
            displayOptionsProvider: displayOptionsProvider
        )
        let hostingController = NSHostingController(
            rootView: ClockPopoverView(
                viewModel: viewModel,
                onSettings: onShowSettings,
                onConverter: onShowConverter,
                onQuit: onQuit
            )
        )
        popover.contentViewController = hostingController
        popover.behavior = .transient
        popover.animates = true
    }

    func toggle() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func close() {
        popover.performClose(nil)
    }
}
