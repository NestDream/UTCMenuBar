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

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        displayOptions = DisplayOptions.load()

        styleStore.addListener { [weak self] _ in
            guard let self else { return }
            self.buildMenu()
            self.updateTime()
        }

        languageStore.addListener { [weak self] _ in
            self?.buildMenu()
        }

        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateTime() }
        }
        RunLoop.current.add(timer!, forMode: .common)
        buildMenu()
    }

    private func buildMenu() {
        statusItem.menu = MenuBuilder.buildMenu(
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
            quit: #selector(quit)
        )
    }

    private func updateTime() {
        let plain = TimeFormatter.formatDisplay(
            date: Date(),
            options: displayOptions,
            iconPrefix: styleStore.current.iconPrefix
        )
        let styled = StyledTextBuilder.buildAttributedString(text: plain, style: styleStore.current)
        guard let button = statusItem.button else { return }
        button.title = styled.string
        button.attributedTitle = styled
    }

    @objc private func toggleShowDate() {
        displayOptions.showDate.toggle()
        displayOptions.save()
        buildMenu()
        updateTime()
    }

    @objc private func toggleCompactTime() {
        displayOptions.compactTime.toggle()
        displayOptions.save()
        buildMenu()
        updateTime()
    }

    @objc private func toggleCompactDate() {
        displayOptions.compactDate.toggle()
        displayOptions.save()
        buildMenu()
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
                languageStore: languageStore
            ) { [weak self] in
                self?.presentFontPanel()
            }
            _ = settingsWindowController!.window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController!.showWindow(nil)
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
