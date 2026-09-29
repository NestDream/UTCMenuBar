import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private var viewModel: SettingsViewModel2?

    init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        displayOptions: DisplayOptions,
        onPickCustomFont: @escaping () -> Void,
        onCheckForUpdates: @escaping () -> Void,
        onDisplayOptionsChanged: @escaping (DisplayOptions) -> Void
    ) {
        let vm = SettingsViewModel2(
            styleStore: styleStore,
            languageStore: languageStore,
            loginItem: SMAppServiceLoginItem(),
            displayOptions: displayOptions,
            onDisplayOptionsChanged: onDisplayOptionsChanged
        )
        self.viewModel = vm

        let settingsView = SettingsView(
            viewModel: vm,
            onPickCustomFont: onPickCustomFont,
            onCheckForUpdates: onCheckForUpdates
        )
        let hosting = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: InterfaceStyle.settingsSize),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.title = Strings.t(.settingsWindowTitle, language: languageStore.current)
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = hosting

        super.init(window: window)
        window.delegate = self

        languageStore.addListener { [weak window] lang in
            window?.title = Strings.t(.settingsWindowTitle, language: lang)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateDisplayOptions(_ opts: DisplayOptions) {
        viewModel?.updateDisplayOptions(opts)
    }

    func windowDidBecomeKey(_ notification: Notification) {
        viewModel?.refreshLaunchAtLogin()
    }
}
