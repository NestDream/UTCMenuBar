import Cocoa

struct DisplayOptions: Equatable {
    var showDate: Bool = false
    var compactTime: Bool = false
    var compactDate: Bool = false

    static let showDateKey = "displayOptions.showDate"
    static let compactTimeKey = "displayOptions.compactTime"
    static let compactDateKey = "displayOptions.compactDate"

    static let `default` = DisplayOptions(showDate: false, compactTime: false, compactDate: false)

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(showDate, forKey: DisplayOptions.showDateKey)
        defaults.set(compactTime, forKey: DisplayOptions.compactTimeKey)
        defaults.set(compactDate, forKey: DisplayOptions.compactDateKey)
    }

    static func load(from defaults: UserDefaults = .standard) -> DisplayOptions {
        return DisplayOptions(
            showDate: defaults.bool(forKey: showDateKey),
            compactTime: defaults.bool(forKey: compactTimeKey),
            compactDate: defaults.bool(forKey: compactDateKey)
        )
    }
}

enum TimeFormatter {

    /// Format the time portion of a date.
    /// - compact=false → "HH:mm:ss"
    /// - compact=true  → "HH:mm"
    static func formatTime(date: Date, compact: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = compact ? "HH:mm" : "HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /// Format the date portion of a date.
    /// - compact=false → "yyyy-MM-dd"
    /// - compact=true  → "MM/dd"
    static func formatDate(date: Date, compact: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = compact ? "MM/dd" : "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /// Format the full menu bar display string.
    /// Always starts with "🌐 " and ends with " UTC".
    /// When showDate=true: "🌐 {date} {time} UTC"
    /// When showDate=false: "🌐 {time} UTC"
    static func formatDisplay(date: Date, options: DisplayOptions) -> String {
        let timePart = formatTime(date: date, compact: options.compactTime)
        if options.showDate {
            let datePart = formatDate(date: date, compact: options.compactDate)
            return "🌐 \(datePart) \(timePart) UTC"
        } else {
            return "🌐 \(timePart) UTC"
        }
    }
}

enum MenuBuilder {
    /// Build the display options menu.
    static func buildMenu(
        options: DisplayOptions,
        target: AnyObject?,
        toggleShowDate: Selector?,
        toggleCompactTime: Selector?,
        toggleCompactDate: Selector?,
        quit: Selector?
    ) -> NSMenu {
        let menu = NSMenu()

        let showDateItem = NSMenuItem(title: "显示日期", action: toggleShowDate, keyEquivalent: "")
        showDateItem.target = target
        showDateItem.state = options.showDate ? .on : .off
        menu.addItem(showDateItem)

        let compactTimeItem = NSMenuItem(title: "紧凑时间", action: toggleCompactTime, keyEquivalent: "")
        compactTimeItem.target = target
        compactTimeItem.state = options.compactTime ? .on : .off
        menu.addItem(compactTimeItem)

        let compactDateItem = NSMenuItem(title: "紧凑日期", action: toggleCompactDate, keyEquivalent: "")
        compactDateItem.target = target
        compactDateItem.state = options.compactDate ? .on : .off
        compactDateItem.isEnabled = options.showDate
        menu.addItem(compactDateItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: quit, keyEquivalent: "q")
        quitItem.target = target
        menu.addItem(quitItem)

        return menu
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var displayOptions = DisplayOptions.default

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        displayOptions = DisplayOptions.load()
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        RunLoop.current.add(timer!, forMode: .common)
        buildMenu()
    }

    private func buildMenu() {
        statusItem.menu = MenuBuilder.buildMenu(
            options: displayOptions,
            target: self,
            toggleShowDate: #selector(toggleShowDate),
            toggleCompactTime: #selector(toggleCompactTime),
            toggleCompactDate: #selector(toggleCompactDate),
            quit: #selector(quit)
        )
    }

    private func updateTime() {
        statusItem.button?.title = TimeFormatter.formatDisplay(date: Date(), options: displayOptions)
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

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
