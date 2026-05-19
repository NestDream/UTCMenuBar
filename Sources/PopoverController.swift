import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class PopoverController {
    private var panel: NSPanel?
    private let statusItem: NSStatusItem
    private var hostingView: NSHostingView<ClockPopoverView>?
    private var eventMonitor: Any?

    var isShown: Bool { panel?.isVisible ?? false }

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

        let fittingSize = hostingView?.fittingSize ?? NSSize(width: 260, height: 200)
        panel.setContentSize(fittingSize)

        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)

        let x = screenRect.midX - fittingSize.width / 2
        let y = screenRect.minY - fittingSize.height - 4

        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        startEventMonitor()
    }

    func close() {
        guard let panel, panel.isVisible else { return }
        stopEventMonitor()
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.1
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.close()
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
