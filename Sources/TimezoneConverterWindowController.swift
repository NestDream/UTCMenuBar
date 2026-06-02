import AppKit
import UTCMenuBarLib

@MainActor
final class TimezoneConverterWindowController: NSWindowController, NSWindowDelegate {
    private let converterStore: TimezoneConverterStore
    private let languageStore: LanguageStore

    private let timezonePopup = NSPopUpButton()
    private let utcField = NSTextField()
    private let targetField = NSTextField()
    private let copyUTCButton = NSButton()
    private let copyTargetButton = NSButton()
    private let nowButton = NSButton()
    private let errorLabel = NSTextField(labelWithString: "")

    private var timezoneLabel: NSTextField!
    private var utcLabel: NSTextField!
    private var targetLabel: NSTextField!

    private var isProgrammaticUpdate = false
    private var timezoneIdentifiers: [String] = []

    init(converterStore: TimezoneConverterStore, languageStore: LanguageStore) {
        self.converterStore = converterStore
        self.languageStore = languageStore
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("TimezoneConverter")
        if !window.setFrameUsingName("TimezoneConverter") { window.center() }
        super.init(window: window)
        window.delegate = self
        setupContent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupContent() {
        timezoneIdentifiers = TimeZone.knownTimeZoneIdentifiers.sorted()
        timezonePopup.target = self
        timezonePopup.action = #selector(timezoneChanged(_:))
        populateTimezonePopup()
        selectCurrentTimezone()

        for field in [utcField, targetField] {
            field.isEditable = true
            field.isBezeled = true
            field.bezelStyle = .roundedBezel
            field.placeholderString = "YYYY-MM-DD HH:MM:SS"
            field.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: utcField)
        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: targetField)

        for btn in [copyUTCButton, copyTargetButton] {
            btn.bezelStyle = .rounded
            btn.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy")
            btn.imagePosition = .imageOnly
            btn.target = self
            btn.action = #selector(copyClicked(_:))
            btn.setContentHuggingPriority(.required, for: .horizontal)
        }

        nowButton.bezelStyle = .rounded
        nowButton.target = self
        nowButton.action = #selector(nowClicked)

        // Error label stays in the layout permanently; we toggle its text rather
        // than its visibility so showing an error never shifts the other rows.
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 11)
        errorLabel.stringValue = ""
        errorLabel.maximumNumberOfLines = 1

        timezoneLabel = NSTextField(labelWithString: "")
        utcLabel = NSTextField(labelWithString: "")
        targetLabel = NSTextField(labelWithString: "")

        let labelWidth: CGFloat = 60
        for label in [timezoneLabel!, utcLabel!, targetLabel!] {
            label.alignment = .right
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        }

        let fieldWidth: CGFloat = 320
        utcField.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        targetField.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        timezonePopup.widthAnchor.constraint(equalToConstant: fieldWidth + 60).isActive = true

        let tzRow = hstack([timezoneLabel, timezonePopup])
        let utcRow = hstack([utcLabel, utcField, copyUTCButton])
        let targetRow = hstack([targetLabel, targetField, copyTargetButton])

        let buttonRow = NSStackView(views: [NSView(), nowButton])
        buttonRow.orientation = .horizontal
        buttonRow.distribution = .fill

        let outer = NSStackView(views: [tzRow, utcRow, targetRow, errorLabel, buttonRow])
        outer.orientation = .vertical
        outer.spacing = 12
        outer.alignment = .left
        outer.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)
        outer.translatesAutoresizingMaskIntoConstraints = false

        let content = window!.contentView!
        content.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            outer.topAnchor.constraint(equalTo: content.topAnchor),
            outer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])

        applyLanguage(languageStore.current)

        languageStore.addListener { [weak self] lang in
            self?.applyLanguage(lang)
        }
    }

    private func hstack(_ views: [NSView]) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        return stack
    }

    private func applyLanguage(_ lang: AppLanguage) {
        window?.title = Strings.t(.converterWindowTitle, language: lang)
        timezoneLabel.stringValue = Strings.t(.converterLabelTimezone, language: lang)
        utcLabel.stringValue = Strings.t(.converterLabelUTC, language: lang)
        targetLabel.stringValue = Strings.t(.converterLabelTarget, language: lang)
        let copyTitle = Strings.t(.converterCopyButton, language: lang)
        copyUTCButton.title = copyTitle
        copyTargetButton.title = copyTitle
        // Icon-only buttons need an explicit accessibility label for VoiceOver.
        copyUTCButton.setAccessibilityLabel("\(copyTitle) UTC")
        copyTargetButton.setAccessibilityLabel("\(copyTitle) \(Strings.t(.converterLabelTarget, language: lang))")
        nowButton.title = Strings.t(.converterNowButton, language: lang)
        // The timezone popup items (identifier + UTC offset) are language-independent,
        // so there is no need to rebuild all ~450 of them on a language change.
    }

    private func populateTimezonePopup() {
        timezonePopup.removeAllItems()
        let now = Date()
        for id in timezoneIdentifiers {
            let offset = Self.offsetString(for: id, at: now)
            timezonePopup.addItem(withTitle: "\(id) (\(offset))")
        }
    }

    private func selectCurrentTimezone() {
        let target = converterStore.current.targetTimezone
        if let idx = timezoneIdentifiers.firstIndex(of: target) {
            timezonePopup.selectItem(at: idx)
        }
    }

    private static func offsetString(for identifier: String, at date: Date) -> String {
        guard let tz = TimeZone(identifier: identifier) else { return "UTC+00:00" }
        let seconds = tz.secondsFromGMT(for: date)
        let sign = seconds >= 0 ? "+" : "-"
        let h = abs(seconds) / 3600
        let m = (abs(seconds) % 3600) / 60
        return "UTC\(sign)\(String(format: "%02d:%02d", h, m))"
    }

    @objc private func timezoneChanged(_ sender: NSPopUpButton) {
        let idx = sender.indexOfSelectedItem
        guard idx >= 0 && idx < timezoneIdentifiers.count else { return }
        converterStore.update { $0.targetTimezone = timezoneIdentifiers[idx] }
        reconvert()
    }

    @objc private func nowClicked() {
        guard let result = TimezoneConverter.now(targetTimezoneId: converterStore.current.targetTimezone) else { return }
        isProgrammaticUpdate = true
        utcField.stringValue = result.utc
        targetField.stringValue = result.target
        isProgrammaticUpdate = false
        errorLabel.stringValue = ""
    }

    @objc private func copyClicked(_ sender: NSButton) {
        let value = (sender === copyUTCButton) ? utcField.stringValue : targetField.stringValue
        guard !value.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }

    @objc private func textDidChange(_ notification: Notification) {
        guard !isProgrammaticUpdate else { return }
        guard let field = notification.object as? NSTextField else { return }
        if field === utcField { convertFromUTC() }
        else if field === targetField { convertFromTarget() }
    }

    private func convertFromUTC() {
        let input = utcField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            isProgrammaticUpdate = true
            targetField.stringValue = ""
            isProgrammaticUpdate = false
            errorLabel.stringValue = ""
            return
        }
        switch TimezoneConverter.convertUTCToTarget(input, targetTimezoneId: converterStore.current.targetTimezone) {
        case .success(let converted):
            isProgrammaticUpdate = true
            targetField.stringValue = converted
            isProgrammaticUpdate = false
            errorLabel.stringValue = ""
        case .failure(let err):
            showError(err)
        }
    }

    private func convertFromTarget() {
        let input = targetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            isProgrammaticUpdate = true
            utcField.stringValue = ""
            isProgrammaticUpdate = false
            errorLabel.stringValue = ""
            return
        }
        switch TimezoneConverter.convertTargetToUTC(input, targetTimezoneId: converterStore.current.targetTimezone) {
        case .success(let converted):
            isProgrammaticUpdate = true
            utcField.stringValue = converted
            isProgrammaticUpdate = false
            errorLabel.stringValue = ""
        case .failure(let err):
            showError(err)
        }
    }

    private func reconvert() {
        let utcInput = utcField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !utcInput.isEmpty { convertFromUTC(); return }
        let targetInput = targetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !targetInput.isEmpty { convertFromTarget() }
    }

    private func showError(_ error: TimezoneConverter.ConversionError) {
        let lang = languageStore.current
        switch error {
        case .invalidFormat: errorLabel.stringValue = Strings.t(.converterErrorInvalidFormat, language: lang)
        case .yearOutOfRange: errorLabel.stringValue = Strings.t(.converterErrorYearOutOfRange, language: lang)
        case .unknownTimezone: errorLabel.stringValue = Strings.t(.converterErrorUnknownTimezone, language: lang)
        }
        
    }
}
