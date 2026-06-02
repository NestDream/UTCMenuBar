import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class PopoverController {
    private var panel: NSPanel?
    private let statusItem: NSStatusItem
    private let viewModel: ClockPopoverViewModel
    private var hostingView: NSHostingView<ClockPopoverView>?
    private var eventMonitor: Any?
    private var isClosing = false

    var isShown: Bool { (panel?.isVisible ?? false) && !isClosing }

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

        let viewModel = ClockPopoverViewModel(
            styleStore: styleStore,
            languageStore: languageStore,
            displayOptionsProvider: displayOptionsProvider
        )
        self.viewModel = viewModel

        let contentView = ClockPopoverView(
            viewModel: viewModel,
            onSettings: { [weak self] in
                self?.close()
                onShowSettings()
            },
            onConverter: { [weak self] in
                self?.close()
                onShowConverter()
            },
            onQuit: onQuit
        )

        let hosting = NSHostingView(rootView: contentView)
        self.hostingView = hosting

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.isMovableByWindowBackground = false
        panel.contentView = hosting
        panel.isReleasedWhenClosed = false
        self.panel = panel
    }

    func toggle() {
        if isShown {
            close()
        } else {
            show()
        }
    }

    func show() {
        guard let panel, let button = statusItem.button, let buttonWindow = button.window else { return }
        isClosing = false

        let fittingSize = hostingView?.fittingSize ?? NSSize(width: 260, height: 200)
        panel.setContentSize(fittingSize)

        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        let origin = PopoverLayout.origin(
            buttonRect: screenRect,
            popoverSize: fittingSize,
            visibleFrame: (buttonWindow.screen ?? NSScreen.main)?.visibleFrame
        )

        panel.setFrameOrigin(origin)
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        viewModel.startTicking()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        startEventMonitor()
    }

    func close() {
        guard let panel, panel.isVisible, !isClosing else { return }
        isClosing = true
        stopEventMonitor()
        viewModel.stopTicking()
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.1
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                panel.orderOut(nil)
                self?.isClosing = false
            }
        })
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self else { return }
            // Ignore clicks on the status item itself — those are handled by
            // statusItemClicked → toggle(), which closes the popover. Letting the
            // monitor also fire would double-toggle (close then immediately reopen).
            if let button = self.statusItem.button,
               let window = button.window {
                let buttonScreenRect = window.convertToScreen(button.convert(button.bounds, to: nil))
                let mouse = NSEvent.mouseLocation
                if buttonScreenRect.contains(mouse) { return }
            }
            self.close()
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
