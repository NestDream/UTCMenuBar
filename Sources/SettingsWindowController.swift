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
        onDisplayOptionsChanged: @escaping (DisplayOptions) -> Void
    ) {
        let vm = SettingsViewModel2(
            styleStore: styleStore,
            languageStore: languageStore,
            displayOptions: displayOptions,
            onDisplayOptionsChanged: onDisplayOptionsChanged
        )
        self.viewModel = vm

        let settingsView = SettingsView(viewModel: vm, onPickCustomFont: onPickCustomFont)
        let hosting = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 480),
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
}
