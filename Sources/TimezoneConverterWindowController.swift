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
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 240),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        setupContent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupContent() {
        let language = languageStore.current

        // Configure timezone popup
        timezoneIdentifiers = TimeZone.knownTimeZoneIdentifiers.sorted()
        timezonePopup.target = self
        timezonePopup.action = #selector(timezoneChanged(_:))
        populateTimezonePopup()
        selectCurrentTimezone()

        // Configure text fields
        utcField.placeholderString = "YYYY-MM-DD HH:MM:SS"
        utcField.isEditable = true
        utcField.isBezeled = true
        utcField.bezelStyle = .roundedBezel

        targetField.placeholderString = "YYYY-MM-DD HH:MM:SS"
        targetField.isEditable = true
        targetField.isBezeled = true
        targetField.bezelStyle = .roundedBezel

        // Observe text changes via NotificationCenter
        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: utcField)
        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: targetField)

        // Configure copy buttons
        copyUTCButton.bezelStyle = .rounded
        copyUTCButton.target = self
        copyUTCButton.action = #selector(copyClicked(_:))

        copyTargetButton.bezelStyle = .rounded
        copyTargetButton.target = self
        copyTargetButton.action = #selector(copyClicked(_:))

        // Configure now button
        nowButton.bezelStyle = .rounded
        nowButton.target = self
        nowButton.action = #selector(nowClicked)

        // Configure error label
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true

        // Build labels
        timezoneLabel = NSTextField(labelWithString: "")
        utcLabel = NSTextField(labelWithString: "")
        targetLabel = NSTextField(labelWithString: "")

        // Layout
        let timezoneRow = row(timezoneLabel, timezonePopup)
        let utcRow = rowWithButton(utcLabel, utcField, copyUTCButton)
        let targetRow = rowWithButton(targetLabel, targetField, copyTargetButton)

        let nowContainer = NSStackView(views: [nowButton])
        nowContainer.orientation = .horizontal
        nowContainer.alignment = .trailing

        let outer = NSStackView(views: [
            timezoneRow,
            utcRow,
            targetRow,
            errorLabel,
            nowContainer,
        ])
        outer.orientation = .vertical
        outer.spacing = 12
        outer.alignment = .leading
        outer.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        outer.translatesAutoresizingMaskIntoConstraints = false

        let content = NSView()
        content.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            outer.topAnchor.constraint(equalTo: content.topAnchor),
            outer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])
        window?.contentView = content

        // Width constraints for fields
        utcField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        targetField.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        timezonePopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true

        // Trailing alignment for now button container
        nowContainer.trailingAnchor.constraint(equalTo: outer.trailingAnchor).isActive = true

        applyLanguage(language)

        languageStore.addListener { [weak self] lang in
            guard let self else { return }
            self.applyLanguage(lang)
        }
    }

    private func applyLanguage(_ lang: AppLanguage) {
        window?.title = Strings.t(.converterWindowTitle, language: lang)
        timezoneLabel.stringValue = Strings.t(.converterLabelTimezone, language: lang)
        utcLabel.stringValue = Strings.t(.converterLabelUTC, language: lang)
        targetLabel.stringValue = Strings.t(.converterLabelTarget, language: lang)
        copyUTCButton.title = Strings.t(.converterCopyButton, language: lang)
        copyTargetButton.title = Strings.t(.converterCopyButton, language: lang)
        nowButton.title = Strings.t(.converterNowButton, language: lang)

        // Update error label if visible
        if !errorLabel.isHidden {
            // Keep whatever error is showing; it will be refreshed on next conversion
        }

        // Repopulate timezone popup to refresh offset strings
        let selected = timezonePopup.indexOfSelectedItem
        populateTimezonePopup()
        if selected >= 0 && selected < timezonePopup.numberOfItems {
            timezonePopup.selectItem(at: selected)
        }
    }

    private func populateTimezonePopup() {
        timezonePopup.removeAllItems()
        let now = Date()
        for id in timezoneIdentifiers {
            let offset = TimezoneConverterWindowController.offsetString(for: id, at: now)
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
        let absSeconds = abs(seconds)
        let hours = absSeconds / 3600
        let minutes = (absSeconds % 3600) / 60
        return "UTC\(sign)\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
    }

    // MARK: - Actions

    @objc private func timezoneChanged(_ sender: NSPopUpButton) {
        let idx = sender.indexOfSelectedItem
        guard idx >= 0 && idx < timezoneIdentifiers.count else { return }
        let selectedId = timezoneIdentifiers[idx]
        converterStore.update { $0.targetTimezone = selectedId }
        reconvert()
    }

    @objc private func nowClicked() {
        let targetId = converterStore.current.targetTimezone
        guard let result = TimezoneConverter.now(targetTimezoneId: targetId) else { return }
        isProgrammaticUpdate = true
        utcField.stringValue = result.utc
        targetField.stringValue = result.target
        isProgrammaticUpdate = false
        errorLabel.isHidden = true
    }

    @objc private func copyClicked(_ sender: NSButton) {
        let field: NSTextField
        if sender === copyUTCButton {
            field = utcField
        } else {
            field = targetField
        }
        guard !field.stringValue.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(field.stringValue, forType: .string)
    }

    @objc private func textDidChange(_ notification: Notification) {
        guard !isProgrammaticUpdate else { return }
        guard let field = notification.object as? NSTextField else { return }
        if field === utcField {
            convertFromUTC()
        } else if field === targetField {
            convertFromTarget()
        }
    }

    private func convertFromUTC() {
        let input = utcField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            isProgrammaticUpdate = true
            targetField.stringValue = ""
            isProgrammaticUpdate = false
            errorLabel.isHidden = true
            return
        }
        let targetId = converterStore.current.targetTimezone
        let result = TimezoneConverter.convertUTCToTarget(input, targetTimezoneId: targetId)
        switch result {
        case .success(let converted):
            isProgrammaticUpdate = true
            targetField.stringValue = converted
            isProgrammaticUpdate = false
            errorLabel.isHidden = true
        case .failure(let error):
            showError(error)
        }
    }

    private func convertFromTarget() {
        let input = targetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            isProgrammaticUpdate = true
            utcField.stringValue = ""
            isProgrammaticUpdate = false
            errorLabel.isHidden = true
            return
        }
        let targetId = converterStore.current.targetTimezone
        let result = TimezoneConverter.convertTargetToUTC(input, targetTimezoneId: targetId)
        switch result {
        case .success(let converted):
            isProgrammaticUpdate = true
            utcField.stringValue = converted
            isProgrammaticUpdate = false
            errorLabel.isHidden = true
        case .failure(let error):
            showError(error)
        }
    }

    /// Re-convert based on whichever field has content (prefer UTC field).
    private func reconvert() {
        let utcInput = utcField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !utcInput.isEmpty {
            convertFromUTC()
            return
        }
        let targetInput = targetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !targetInput.isEmpty {
            convertFromTarget()
        }
    }

    private func showError(_ error: TimezoneConverter.ConversionError) {
        let lang = languageStore.current
        switch error {
        case .invalidFormat:
            errorLabel.stringValue = Strings.t(.converterErrorInvalidFormat, language: lang)
        case .yearOutOfRange:
            errorLabel.stringValue = Strings.t(.converterErrorYearOutOfRange, language: lang)
        case .unknownTimezone:
            errorLabel.stringValue = Strings.t(.converterErrorUnknownTimezone, language: lang)
        }
        errorLabel.isHidden = false
    }

    // MARK: - Layout helpers

    private func row(_ label: NSTextField, _ control: NSView) -> NSStackView {
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let stack = NSStackView(views: [label, control])
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.alignment = .firstBaseline
        return stack
    }

    private func rowWithButton(_ label: NSTextField, _ field: NSTextField, _ button: NSButton) -> NSStackView {
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let stack = NSStackView(views: [label, field, button])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .firstBaseline
        return stack
    }
}
