#if DEBUG
import AppKit
import SwiftUI
import UTCMenuBarLib

/// Development-only snapshot harness: `swift run UTCMenuBar --render-previews <dir>`
/// renders each UI surface to PNG in light and dark appearance so design
/// changes can be reviewed as pixels instead of imagined from code.
/// Compiled out of release builds.
@MainActor
enum PreviewRenderer {

    static func runIfRequested() {
        guard let idx = CommandLine.arguments.firstIndex(of: "--render-previews"),
              CommandLine.arguments.count > idx + 1 else { return }
        let dir = URL(fileURLWithPath: CommandLine.arguments[idx + 1], isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        render(into: dir)
        exit(0)
    }

    private static func render(into dir: URL) {
        // Isolated defaults so previews never touch the user's real settings.
        let suite = "com.utcmenubar.preview.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let defaults = UserDefaults(suiteName: suite) else { return }
        defer { defaults.removePersistentDomain(forName: suite) }

        let styleStore = StyleOptionsStore(defaults: defaults)
        let languageStore = LanguageStore(defaults: defaults)
        let converterStore = TimezoneConverterStore(defaults: defaults)

        for appearance in [NSAppearance.Name.darkAqua, .aqua] {
            let suffix = appearance == .darkAqua ? "dark" : "light"

            // Popover
            let popoverVM = ClockPopoverViewModel(
                languageStore: languageStore,
                displayOptionsProvider: { .default }
            )
            let popover = NSHostingView(rootView: ClockPopoverView(
                viewModel: popoverVM,
                onSettings: {}, onConverter: {}, onQuit: {}
            ))
            snapshot(popover, size: popover.fittingSize, appearance: appearance,
                     to: dir.appendingPathComponent("popover-\(suffix).png"))

            // Settings
            let settingsVM = SettingsViewModel2(
                styleStore: styleStore,
                languageStore: languageStore,
                loginItem: PreviewLoginItem(),
                displayOptions: .default,
                displayDefaults: defaults,
                onDisplayOptionsChanged: { _ in }
            )
            let settings = NSHostingView(rootView: SettingsView(
                viewModel: settingsVM,
                onPickCustomFont: {},
                onCheckForUpdates: {}
            ))
            snapshot(settings, size: settings.fittingSize, appearance: appearance,
                     to: dir.appendingPathComponent("settings-\(suffix).png"))

            // Timezone converter (AppKit window content). Clear the frame
            // autosave name so the harness can never write a (headless)
            // window frame into this process's persistent defaults.
            let converter = TimezoneConverterWindowController(
                converterStore: converterStore,
                languageStore: languageStore
            )
            converter.window?.setFrameAutosaveName("")
            if let content = converter.window?.contentView {
                snapshot(content, size: content.frame.size, appearance: appearance,
                         to: dir.appendingPathComponent("converter-\(suffix).png"))
            }
        }
        print("previews written to \(dir.path)")
    }

    private static func snapshot(_ view: NSView, size: NSSize, appearance: NSAppearance.Name, to url: URL) {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: appearance)
        window.isReleasedWhenClosed = false

        // Solid window-background container: cacheDisplay captures only the
        // view hierarchy, so light-on-dark text would otherwise land on a
        // transparent canvas and vanish when viewed over white.
        let container = NSView(frame: NSRect(origin: .zero, size: size))
        container.wantsLayer = true
        window.contentView = container
        view.frame = container.bounds
        container.addSubview(view)
        NSAppearance(named: appearance)?.performAsCurrentDrawingAppearance {
            container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        }

        window.orderFrontRegardless()
        window.layoutIfNeeded()
        view.layoutSubtreeIfNeeded()
        // Give SwiftUI/AppKit a few runloop turns to lay out and draw.
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        window.displayIfNeeded()

        guard let rep = container.bitmapImageRepForCachingDisplay(in: container.bounds) else { return }
        container.cacheDisplay(in: container.bounds, to: rep)
        if let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: url)
        }
        window.orderOut(nil)
    }

    private struct PreviewLoginItem: LoginItemControlling {
        var isEnabled: Bool { false }
        var requiresApproval: Bool { false }
        func setEnabled(_ enabled: Bool) throws {}
    }
}
#endif
