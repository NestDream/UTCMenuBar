import Cocoa
import UTCMenuBarLib

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var displayOptions = DisplayOptions.default
    private let styleStore = StyleOptionsStore()
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        displayOptions = DisplayOptions.load()

        styleStore.addListener { [weak self] _ in
            guard let self else { return }
            self.buildMenu()
            self.updateTime()
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
            target: self,
            toggleShowDate: #selector(toggleShowDate),
            toggleCompactTime: #selector(toggleCompactTime),
            toggleCompactDate: #selector(toggleCompactDate),
            setFontFamily: #selector(setFontFamily(_:)),
            setFontWeight: #selector(setFontWeight(_:)),
            setFontSize: #selector(setFontSize(_:)),
            setTextColor: #selector(setTextColor(_:)),
            setDecorator: #selector(setDecorator(_:)),
            showSettings: #selector(showSettings),
            quit: #selector(quit)
        )
    }

    private func updateTime() {
        let plain = TimeFormatter.formatDisplay(date: Date(), options: displayOptions)
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
        styleStore.update { $0.fontFamily = v }
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
            settingsWindowController = SettingsWindowController(store: styleStore)
            _ = settingsWindowController!.window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController!.showWindow(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension Array {
    fileprivate subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
