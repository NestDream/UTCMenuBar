import AppKit
import SwiftUI
import UTCMenuBarLib

/// Borderless panels refuse key status by default; the popover opts in so it
/// can receive Esc without activating the app (the standard non-activating
/// panel pattern; keyboard focus returns to the previous app on close).
private final class PopoverPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class PopoverController {
    private var panel: NSPanel?
    private let statusItem: NSStatusItem
    private let viewModel: ClockPopoverViewModel
    private var hostingView: NSHostingView<ClockPopoverView>?
    private var eventMonitor: Any?
    private var localEventMonitor: Any?
    private var isClosing = false
    /// Bumped on every show(). A close()'s fade-out completion only hides the
    /// panel if no newer show() superseded it, so rapid close-reopen can't end
    /// with the fresh popover ordered out and its monitors orphaned.
    private var showGeneration = 0

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

        let panel = PopoverPanel(
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
        showGeneration += 1

        let fittingSize = hostingView?.fittingSize ?? NSSize(width: 260, height: 200)
        panel.setContentSize(fittingSize)

        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        let origin = PopoverLayout.origin(
            buttonRect: screenRect,
            popoverSize: fittingSize,
            visibleFrame: (buttonWindow.screen ?? NSScreen.main)?.visibleFrame
        )

        // Origin-aware entrance: emerge downward from the menu bar (the
        // trigger) rather than materializing in place. Collapses to a plain
        // fade when the user asks for reduced motion.
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let slide: CGFloat = reduceMotion ? 0 : 6
        let finalFrame = NSRect(origin: origin, size: fittingSize)
        let startFrame = finalFrame.offsetBy(dx: 0, dy: slide)
        panel.setFrame(startFrame, display: false)
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        // Take key without activating the app so Esc and the displayed ⌘
        // shortcuts work. Deliberate trade-off (the Control Center pattern):
        // while the popover is open, keystrokes go to it rather than to the
        // previously focused app; focus returns there the instant it closes.
        panel.makeKey()

        viewModel.startTicking()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(finalFrame, display: true)
        }

        startEventMonitor()
    }

    func close() {
        guard let panel, panel.isVisible, !isClosing else { return }
        isClosing = true
        stopEventMonitor()
        viewModel.stopTicking()
        let generation = showGeneration
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.1
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                guard let self else {
                    panel.orderOut(nil)
                    return
                }
                // A reopen during the fade supersedes this close: hiding the
                // panel now would blank the fresh popover (show() already
                // reset isClosing and reinstalled the monitors).
                guard self.showGeneration == generation else { return }
                panel.orderOut(nil)
                self.isClosing = false
            }
        })
    }

    private func startEventMonitor() {
        // Global monitor: clicks delivered to other applications.
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
        // Local monitor: events delivered to this app. Clicks on our own
        // windows (Settings, converter) should also dismiss, and Esc closes
        // the popover while it is key.
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .keyDown]) { [weak self] event in
            guard let self else { return event }
            if event.type == .keyDown {
                let escKeyCode: UInt16 = 53
                if event.keyCode == escKeyCode, event.window === self.panel {
                    self.close()
                    return nil  // swallow the Esc that closed the popover
                }
                return event
            }
            // Clicks inside the popover itself, or on the status item (whose
            // action already toggles), must not dismiss.
            if event.window === self.panel { return event }
            if let button = self.statusItem.button, event.window === button.window { return event }
            self.close()
            return event
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }
}
