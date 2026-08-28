import Cocoa
import UTCMenuBarLib

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var displayOptions = DisplayOptions.default
    private let styleStore = StyleOptionsStore()
    private let languageStore = LanguageStore()
    private let converterStore = TimezoneConverterStore()
    private var settingsWindowController: SettingsWindowController?
    private var converterWindowController: TimezoneConverterWindowController?
    private var fontPanelDelegate: FontPanelDelegate?
    private var popoverController: PopoverController?
    /// What the status item currently renders. Dedupes redundant re-renders
    /// when several triggers fire for one state (a settings change reaches
    /// updateTime via both the store listener and the direct call) and no-op
    /// refreshes like a language change that doesn't alter the styled text.
    private var lastRendered: (text: String, style: StyleOptions, language: AppLanguage)?
    private var observerTokens: [(NotificationCenter, NSObjectProtocol)] = []
    private var updateController: UpdateController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        displayOptions = DisplayOptions.load()

        // Configure status item button for click handling (no persistent menu)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = Strings.t(.statusItemToolTip, language: languageStore.current)
        }

        // Initialize popover controller
        popoverController = PopoverController(
            statusItem: statusItem,
            styleStore: styleStore,
            languageStore: languageStore,
            displayOptionsProvider: { [weak self] in self?.displayOptions ?? .default },
            onShowSettings: { [weak self] in self?.showSettings() },
            onShowConverter: { [weak self] in self?.showTimezoneConverter() },
            onQuit: { [weak self] in self?.quit() }
        )

        styleStore.addListener { [weak self] _ in
            guard let self else { return }
            self.updateTime()
        }

        languageStore.addListener { [weak self] lang in
            guard let self else { return }
            self.statusItem.button?.toolTip = Strings.t(.statusItemToolTip, language: lang)
            self.updateTime()  // refreshes the localized accessibility label
        }

        updateTime()
        rebuildTimer()

        updateController = UpdateController(languageStore: languageStore)
        // Silent daily update check, a few seconds after launch so it never
        // competes with startup.
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(5))
            guard let self else { return }
            if UpdateChecker.shouldAutoCheck(now: Date(), preferences: UpdatePreferences.load()) {
                self.updateController?.checkForUpdates(userInitiated: false)
            }
        }

        // Block-based observers pinned to the main queue: selector-based
        // delivery happens on the posting thread, and .NSSystemClockDidChange
        // makes no main-thread promise. An off-main post would trap the
        // @MainActor isolation assertion in the selector thunk.
        observerTokens.append((NotificationCenter.default, NotificationCenter.default.addObserver(
            forName: .NSSystemClockDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.handleClockChange() }
        }))
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        observerTokens.append((workspaceCenter, workspaceCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.handleClockChange() }
        }))
    }

    private func rebuildTimer() {
        timer?.invalidate()
        timer = TimerScheduling.makeAlignedTimer(compactTime: displayOptions.compactTime) { [weak self] in
            self?.updateTime()
        }
    }

    private func handleClockChange() {
        updateTime()
        rebuildTimer()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        timer = nil
        for (center, token) in observerTokens {
            center.removeObserver(token)
        }
        observerTokens.removeAll()
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        if StatusItemClick.isSecondary(eventType: event.type, modifiers: event.modifierFlags) {
            // Right-click or Control+left-click shows the classic NSMenu.
            // Dismiss an open popover first: its monitors deliberately ignore
            // status-item clicks, so it would otherwise stack behind the menu.
            popoverController?.close()
            let menu = buildMenu()
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            // Left-click toggles the popover
            popoverController?.toggle()
        }
    }

    @discardableResult
    private func buildMenu() -> NSMenu {
        return MenuBuilder.buildMenu(
            options: displayOptions,
            styleOptions: styleStore.current,
            language: languageStore.current,
            target: self,
            toggleShowDate: #selector(toggleShowDate),
            toggleCompactTime: #selector(toggleCompactTime),
            toggleCompactDate: #selector(toggleCompactDate),
            setFontFamily: #selector(setFontFamily(_:)),
            setFontWeight: #selector(setFontWeight(_:)),
            setFontSize: #selector(setFontSize(_:)),
            setTextColor: #selector(setTextColor(_:)),
            setIconPrefix: #selector(setIconPrefix(_:)),
            setDecorator: #selector(setDecorator(_:)),
            setLanguage: #selector(setLanguage(_:)),
            showSettings: #selector(showSettings),
            showTimezoneConverter: #selector(showTimezoneConverter),
            checkForUpdates: #selector(checkForUpdates),
            quit: #selector(quit)
        )
    }

    private func updateTime() {
        guard let button = statusItem.button else { return }
        let now = Date()
        let style = styleStore.current
        let language = languageStore.current
        let plain = TimeFormatter.formatDisplay(
            date: now,
            options: displayOptions,
            iconPrefix: style.iconPrefix
        )
        if let last = lastRendered, last.text == plain, last.style == style, last.language == language {
            return
        }
        lastRendered = (plain, style, language)
        button.attributedTitle = StyledTextBuilder.buildAttributedString(text: plain, style: style)
        // VoiceOver reads the label instead of the emoji-prefixed title, so speak
        // a localized name plus the icon-free time (the plain text minus the
        // prefix, cheaper than a second formatter pass).
        let spoken = plain.dropFirst(style.iconPrefix.prefix.count)
        button.setAccessibilityLabel("\(Strings.t(.statusItemToolTip, language: language)) \(spoken)")
    }

    @objc private func toggleShowDate() {
        displayOptions.showDate.toggle()
        displayOptions.save()
        updateTime()
    }

    @objc private func toggleCompactTime() {
        displayOptions.compactTime.toggle()
        displayOptions.save()
        updateTime()
        rebuildTimer()
    }

    @objc private func toggleCompactDate() {
        displayOptions.compactDate.toggle()
        displayOptions.save()
        updateTime()
    }

    @objc private func setFontFamily(_ sender: NSMenuItem) {
        guard let v = FontFamily.allCases[safe: sender.tag] else { return }
        if v == .custom {
            presentFontPanel()
            return
        }
        styleStore.update { $0.fontFamily = v }
    }

    @objc private func setIconPrefix(_ sender: NSMenuItem) {
        guard let v = IconPrefix.allCases[safe: sender.tag] else { return }
        styleStore.update { $0.iconPrefix = v }
    }

    @objc private func setLanguage(_ sender: NSMenuItem) {
        guard let v = AppLanguage.allCases[safe: sender.tag] else { return }
        languageStore.update(v)
    }

    func presentFontPanel() {
        let manager = NSFontManager.shared
        let style = styleStore.current
        let initial = StyledTextBuilder.resolveFont(
            family: style.fontFamily,
            weight: style.fontWeight,
            size: style.fontSize,
            customFontName: style.customFontName
        )
        manager.setSelectedFont(initial, isMultiple: false)
        if fontPanelDelegate == nil {
            fontPanelDelegate = FontPanelDelegate(store: styleStore)
        }
        manager.target = fontPanelDelegate
        manager.action = #selector(FontPanelDelegate.changeFont(_:))
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSFontPanel.shared
        panel.makeKeyAndOrderFront(nil)
    }

    @objc private func setFontWeight(_ sender: NSMenuItem) {
        guard let v = FontWeight.allCases[safe: sender.tag] else { return }
        styleStore.update { $0.fontWeight = v }
    }

    @objc private func setFontSize(_ sender: NSMenuItem) {
        guard let v = FontSize.allCases[safe: sender.tag] else { return }
        styleStore.update { $0.fontSize = v }
    }

    @objc private func setTextColor(_ sender: NSMenuItem) {
        guard let v = TextColorOption.allCases[safe: sender.tag] else { return }
        styleStore.update { $0.textColor = v }
    }

    @objc private func setDecorator(_ sender: NSMenuItem) {
        guard let v = Decorator.allCases[safe: sender.tag] else { return }
        styleStore.update { $0.decorator = v }
    }

    @objc private func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(
                styleStore: styleStore,
                languageStore: languageStore,
                displayOptions: displayOptions,
                onPickCustomFont: { [weak self] in self?.presentFontPanel() },
                onCheckForUpdates: { [weak self] in self?.updateController?.checkForUpdates(userInitiated: true) },
                onDisplayOptionsChanged: { [weak self] opts in
                    self?.displayOptions = opts
                    self?.updateTime()
                    self?.rebuildTimer()
                }
            )
            _ = settingsWindowController!.window
        } else {
            settingsWindowController!.updateDisplayOptions(displayOptions)
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController!.showWindow(nil)
    }

    @objc private func checkForUpdates() {
        updateController?.checkForUpdates(userInitiated: true)
    }

    @objc private func showTimezoneConverter() {
        if converterWindowController == nil {
            converterWindowController = TimezoneConverterWindowController(
                converterStore: converterStore,
                languageStore: languageStore
            )
            _ = converterWindowController!.window
        }
        NSApp.activate(ignoringOtherApps: true)
        converterWindowController!.showWindow(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension Array {
    fileprivate subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

@MainActor
final class FontPanelDelegate: NSObject {
    private let store: StyleOptionsStore

    init(store: StyleOptionsStore) {
        self.store = store
    }

    @objc func changeFont(_ sender: Any?) {
        let manager = (sender as? NSFontManager) ?? NSFontManager.shared
        let style = store.current
        let current = StyledTextBuilder.resolveFont(
            family: style.fontFamily,
            weight: style.fontWeight,
            size: style.fontSize,
            customFontName: style.customFontName
        )
        let picked = manager.convert(current)
        let name = picked.fontName
        store.update {
            $0.fontFamily = .custom
            $0.customFontName = name
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
