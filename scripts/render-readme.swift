import AppKit
import SwiftUI
import UTCMenuBarLib

/// Documentation-only capture entry point. Builds with the actual app views.
@main
@MainActor
enum ReadmeRenderer {
    static let sampleUTC = "2026-09-25 14:30:00"
    static let sampleDate = try! TimezoneConverter.parseUTC(sampleUTC).get()
    static let emphasis = StyleOptions(
        fontFamily: .menlo, fontWeight: .semibold, textColor: .blue,
        decorator: .brackets, iconPrefix: .globe
    )

    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            fatalError("Expected output directory")
        }
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let screenshots = output.appendingPathComponent("screenshots", isDirectory: true)
        try FileManager.default.createDirectory(at: screenshots, withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: output.appendingPathComponent(".render-complete"))

        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = NSAppearance(named: name)!
            let suffix = name == .aqua ? "light" : "dark"
            app.appearance = appearance
            try snapshot(StyleExamples(), size: NSSize(width: 900, height: 208),
                         appearance: appearance,
                         to: output.appendingPathComponent("styles-\(suffix).png"))

            for language in [AppLanguage.en, .zh] {
                try renderViews(language: language, appearance: appearance,
                                suffix: suffix, into: screenshots)
            }
        }
        try Data("complete\n".utf8).write(to: output.appendingPathComponent(".render-complete"))
    }

    static func renderViews(language: AppLanguage, appearance: NSAppearance,
                            suffix: String, into directory: URL) throws {
        let suite = "com.utcmenubar.documentation.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let styles = StyleOptionsStore(defaults: defaults)
        styles.update { $0 = emphasis }
        let languages = LanguageStore(defaults: defaults)
        languages.update(language)
        let converterStore = TimezoneConverterStore(defaults: defaults)
        converterStore.update { $0.targetTimezone = "America/Los_Angeles" }
        let tag = language == .en ? "en" : "zh"
        func destination(_ surface: String) -> URL {
            directory.appendingPathComponent("\(surface)-\(tag)-\(suffix).png")
        }

        let clock = ClockPopoverViewModel(
            languageStore: languages, displayOptionsProvider: { .default })
        clock.timeText = TimeFormatter.formatTime(date: sampleDate, compact: true)
        clock.dateText = TimeFormatter.formatDate(date: sampleDate, compact: false)
        let popover = NSHostingView(rootView: ClockPopoverView(
            viewModel: clock, onSettings: {}, onConverter: {}, onQuit: {}))
        try snapshot(popover, size: popover.fittingSize, appearance: appearance,
                     to: destination("popover"))

        let settingsVM = SettingsViewModel2(
            styleStore: styles, languageStore: languages, loginItem: PreviewLoginItem(),
            displayOptions: .default, displayDefaults: defaults,
            onDisplayOptionsChanged: { _ in })
        settingsVM.previewText = TimeFormatter.formatDisplay(date: sampleDate, options: .default)
        let settings = NSHostingView(rootView: SettingsView(
            viewModel: settingsVM, onPickCustomFont: {}, onCheckForUpdates: {}))
        try snapshot(settings, size: settings.fittingSize, appearance: appearance,
                     to: destination("settings-general"))
        try snapshot(settings, size: settings.fittingSize, appearance: appearance,
                     to: destination("settings"), scrollToBottom: true)

        let converter = TimezoneConverterWindowController(
            converterStore: converterStore, languageStore: languages)
        let window = converter.window!
        window.setFrameAutosaveName("")
        let content = window.contentView!
        let inputs = descendants(content).compactMap { $0 as? NSTextField }
            .filter { $0.isEditable }
        guard inputs.count == 2 else { fatalError("Converter input layout changed") }
        inputs[0].stringValue = sampleUTC
        NotificationCenter.default.post(name: NSControl.textDidChangeNotification, object: inputs[0])
        guard inputs[1].stringValue == "2026-09-25 07:30:00" else {
            fatalError("Sample UTC conversion did not match")
        }
        try snapshot(content, size: content.frame.size, appearance: appearance,
                     to: destination("converter"))
    }

    static func descendants(_ view: NSView) -> [NSView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }

    static func snapshot(_ view: NSView, size: NSSize, appearance: NSAppearance,
                         to url: URL, scrollToBottom: Bool = false) throws {
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size),
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = appearance
        window.isReleasedWhenClosed = false
        let container = NSView(frame: NSRect(origin: .zero, size: size))
        container.wantsLayer = true
        window.contentView = container
        view.frame = container.bounds
        view.appearance = appearance
        container.addSubview(view)
        appearance.performAsCurrentDrawingAppearance {
            container.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        }
        window.orderFrontRegardless()
        window.layoutIfNeeded()
        view.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        if scrollToBottom {
            guard let scroll = descendants(view).compactMap({ $0 as? NSScrollView }).first,
                  let document = scroll.documentView else {
                fatalError("Settings scroll view not found")
            }
            let y = document.isFlipped ? max(0, document.bounds.height - scroll.contentView.bounds.height) : 0
            scroll.contentView.scroll(to: NSPoint(x: 0, y: y))
            scroll.reflectScrolledClipView(scroll.contentView)
            RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        }
        window.displayIfNeeded()
        // Explicit 2× backing makes the committed images independent of display scale.
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(size.width * 2),
            pixelsHigh: Int(size.height * 2), bitsPerSample: 8, samplesPerPixel: 4,
            hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
            bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = size
        container.cacheDisplay(in: container.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else {
            fatalError("Could not encode \(url.lastPathComponent)")
        }
        try png.write(to: url)
        window.orderOut(nil)
    }

    private struct PreviewLoginItem: LoginItemControlling {
        var isEnabled: Bool { false }
        var requiresApproval: Bool { false }
        func setEnabled(_ enabled: Bool) throws {}
    }
}

/// An illustration, not a screenshot of a live menu bar. Clock text goes
/// through the same formatter and attributed-string builder as the real item.
@MainActor
final class StyleExamples: NSView {
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let dark = effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        let background = dark
            ? NSColor(srgbRed: 0.07, green: 0.10, blue: 0.14, alpha: 1)
            : NSColor(srgbRed: 0.95, green: 0.97, blue: 0.98, alpha: 1)
        background.setFill()
        NSBezierPath(rect: bounds).fill()
        let accent = dark
            ? NSColor(srgbRed: 0.33, green: 0.78, blue: 0.94, alpha: 1)
            : NSColor(srgbRed: 0.03, green: 0.44, blue: 0.60, alpha: 1)
        let title = "ONE CLOCK. YOUR STYLE."
        drawText(title, at: NSPoint(x: 28, y: 25), font: .systemFont(ofSize: 11, weight: .semibold),
                 color: accent)

        let examples: [(String, String, StyleOptions, DisplayOptions)] = [
            ("01", "As shipped", .default, .default),
            ("02", "A little emphasis", ReadmeRenderer.emphasis, .default),
            ("03", "Just the essentials",
             StyleOptions(fontFamily: .system, fontWeight: .medium, iconPrefix: .none),
             DisplayOptions(showDate: false, compactTime: true, compactDate: true))
        ]
        for (index, example) in examples.enumerated() {
            let x = CGFloat(index) * 284 + 28
            let card = NSRect(x: x, y: 66, width: 274, height: 64)
            (dark ? NSColor.white.withAlphaComponent(0.05) : NSColor.white).setFill()
            NSBezierPath(roundedRect: card, xRadius: 10, yRadius: 10).fill()
            NSColor.separatorColor.withAlphaComponent(0.22).setStroke()
            let border = NSBezierPath(roundedRect: card, xRadius: 10, yRadius: 10)
            border.lineWidth = 0.5
            border.stroke()
            let text = TimeFormatter.formatDisplay(
                date: ReadmeRenderer.sampleDate, options: example.3, iconPrefix: example.2.iconPrefix)
            let attributed = NSMutableAttributedString(
                attributedString: StyledTextBuilder.buildAttributedString(text: text, style: example.2))
            // A status button inherits its default text color from AppKit.
            // Supply that context when drawing directly onto the illustration.
            if example.2.textColor == .default {
                attributed.addAttribute(.foregroundColor, value: NSColor.labelColor,
                                        range: NSRange(location: 0, length: attributed.length))
            }
            let textSize = attributed.size()
            attributed.draw(at: NSPoint(x: card.midX - textSize.width / 2,
                                       y: card.midY - textSize.height / 2))
            drawText(example.0, at: NSPoint(x: x, y: 148),
                     font: .monospacedSystemFont(ofSize: 11, weight: .medium), color: accent)
            drawText(example.1, at: NSPoint(x: x + 27, y: 146),
                     font: .systemFont(ofSize: 13), color: .secondaryLabelColor)
        }
    }

    private func drawText(_ value: String, at point: NSPoint, font: NSFont, color: NSColor) {
        (value as NSString).draw(at: point, withAttributes: [.font: font, .foregroundColor: color])
    }
}
