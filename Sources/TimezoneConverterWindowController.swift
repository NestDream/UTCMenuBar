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
    private let hintLabel = NSTextField(labelWithString: "")

    private var timezoneLabel: NSTextField!
    private var utcLabel: NSTextField!
    private var targetLabel: NSTextField!
    private let swapIcon = NSImageView()

    private var isProgrammaticUpdate = false
    private var timezoneIdentifiers: [String] = []
    private var currentError: TimezoneConverter.ConversionError?
    private var copyFeedbackTasks: [ObjectIdentifier: Task<Void, Never>] = [:]

    init(converterStore: TimezoneConverterStore, languageStore: LanguageStore) {
        self.converterStore = converterStore
        self.languageStore = languageStore
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: InterfaceStyle.converterSize),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("TimezoneConverter")
        if !window.setFrameUsingName("TimezoneConverter") { window.center() }
        // Restore the user's position, but use the current layout's dimensions.
        window.setContentSize(InterfaceStyle.converterSize)
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
            field.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
            field.heightAnchor.constraint(equalToConstant: 34).isActive = true
            field.setContentHuggingPriority(.defaultLow, for: .horizontal)
            field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        utcField.identifier = NSUserInterfaceItemIdentifier("converter.utc")
        targetField.identifier = NSUserInterfaceItemIdentifier("converter.target")
        timezonePopup.identifier = NSUserInterfaceItemIdentifier("converter.timezone")

        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: utcField)
        NotificationCenter.default.addObserver(
            self, selector: #selector(textDidChange(_:)),
            name: NSControl.textDidChangeNotification, object: targetField)

        for btn in [copyUTCButton, copyTargetButton] {
            btn.bezelStyle = .rounded
            btn.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
            btn.imagePosition = .imageOnly
            btn.target = self
            btn.action = #selector(copyClicked(_:))
            btn.setContentHuggingPriority(.required, for: .horizontal)
            btn.widthAnchor.constraint(equalToConstant: 34).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }
        copyUTCButton.identifier = NSUserInterfaceItemIdentifier("converter.copyUTC")
        copyTargetButton.identifier = NSUserInterfaceItemIdentifier("converter.copyTarget")

        nowButton.bezelStyle = .rounded
        nowButton.target = self
        nowButton.action = #selector(nowClicked)
        nowButton.identifier = NSUserInterfaceItemIdentifier("converter.now")

        // Error label stays in the layout permanently; we toggle its text rather
        // than its visibility so showing an error never shifts the other rows.
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 11)
        errorLabel.stringValue = ""
        errorLabel.maximumNumberOfLines = 2
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        errorLabel.setAccessibilityIdentifier("converter.error")
        errorLabel.identifier = NSUserInterfaceItemIdentifier("converter.error")
        hintLabel.font = .systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabelColor

        timezoneLabel = NSTextField(labelWithString: "")
        utcLabel = NSTextField(labelWithString: "")
        targetLabel = NSTextField(labelWithString: "")

        for label in [timezoneLabel!, utcLabel!, targetLabel!] {
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabelColor
            label.setContentHuggingPriority(.required, for: .horizontal)
        }
        utcLabel.textColor = InterfaceStyle.accentColor

        timezonePopup.heightAnchor.constraint(equalToConstant: 28).isActive = true
        timezonePopup.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let tzRow = fieldGroup(label: timezoneLabel, control: timezonePopup)
        let utcRow = fieldGroup(label: utcLabel, control: hstack([utcField, copyUTCButton]))
        let targetRow = fieldGroup(label: targetLabel, control: hstack([targetField, copyTargetButton]))

        swapIcon.image = NSImage(
            systemSymbolName: "arrow.up.arrow.down",
            accessibilityDescription: nil)
        swapIcon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        swapIcon.contentTintColor = .secondaryLabelColor
        swapIcon.setAccessibilityElement(false)

        let conversionGroup = NSStackView(views: [utcRow, targetRow])
        conversionGroup.orientation = .vertical
        conversionGroup.spacing = 18
        conversionGroup.alignment = .left
        for row in [utcRow, targetRow] {
            row.widthAnchor.constraint(equalTo: conversionGroup.widthAnchor).isActive = true
        }

        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let buttonRow = hstack([swapIcon, hintLabel, spacer, nowButton])

        // Any spare height belongs below the controls, not between a label
        // and its field. Keep every field group at its natural height.
        let bottomSpacer = NSView()
        bottomSpacer.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .vertical)
        let outer = NSStackView(views: [tzRow, conversionGroup, buttonRow, errorLabel, bottomSpacer])
        outer.orientation = .vertical
        outer.spacing = 16
        outer.setCustomSpacing(6, after: buttonRow)
        outer.setCustomSpacing(0, after: errorLabel)
        outer.alignment = .left
        outer.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 16, right: 24)
        outer.translatesAutoresizingMaskIntoConstraints = false
        for view in [tzRow, conversionGroup, buttonRow, errorLabel] {
            view.widthAnchor.constraint(equalTo: outer.widthAnchor, constant: -48).isActive = true
            view.setContentHuggingPriority(.required, for: .vertical)
        }

        let content = window!.contentView!
        content.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            outer.topAnchor.constraint(equalTo: content.topAnchor),
            outer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])

        applyLanguage(languageStore.current)
        updateCopyButtons()

        languageStore.addListener { [weak self] lang in
            self?.applyLanguage(lang)
        }
    }

    private func fieldGroup(label: NSTextField, control: NSView) -> NSStackView {
        let group = NSStackView(views: [label, control])
        group.orientation = .vertical
        group.alignment = .left
        group.spacing = 8
        group.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        control.setContentHuggingPriority(.required, for: .vertical)
        control.widthAnchor.constraint(equalTo: group.widthAnchor).isActive = true
        return group
    }

    private func hstack(_ views: [NSView]) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        return stack
    }

    private func applyLanguage(_ lang: AppLanguage) {
        resetCopyFeedback()
        window?.title = Strings.t(.converterWindowTitle, language: lang)
        timezoneLabel.stringValue = Strings.t(.converterLabelTimezone, language: lang)
        utcLabel.stringValue = Strings.t(.converterLabelUTC, language: lang)
        targetLabel.stringValue = Strings.t(.converterLabelTarget, language: lang)
        utcField.setAccessibilityLabel(utcLabel.stringValue)
        targetField.setAccessibilityLabel(targetLabel.stringValue)
        timezonePopup.setAccessibilityLabel(timezoneLabel.stringValue)
        let copyTitle = Strings.t(.converterCopyButton, language: lang)
        // Icon-only buttons: the name lives in the tooltip and, for VoiceOver,
        // in an explicit accessibility label. Setting `title` too would draw
        // text over the symbol despite imagePosition = .imageOnly.
        copyUTCButton.toolTip = copyTitle
        copyTargetButton.toolTip = copyTitle
        copyUTCButton.setAccessibilityLabel("\(copyTitle) UTC")
        copyTargetButton.setAccessibilityLabel("\(copyTitle) \(Strings.t(.converterLabelTarget, language: lang))")
        hintLabel.stringValue = Strings.t(.converterBidirectional, language: lang)
        nowButton.title = Strings.t(.converterNowButton, language: lang)
        showError(currentError)
        // The timezone popup items (identifier + UTC offset) are language-independent,
        // so there is no need to rebuild all ~450 of them on a language change.
    }

    /// The one place the popup's item title format lives. Item `i` always
    /// corresponds to `timezoneIdentifiers[i]`; keep that invariant if the
    /// popup ever gains separators or sections.
    private static func popupTitle(for identifier: String, at date: Date) -> String {
        "\(identifier) (\(offsetString(for: identifier, at: date)))"
    }

    private func populateTimezonePopup() {
        timezonePopup.removeAllItems()
        let now = Date()
        for id in timezoneIdentifiers {
            timezonePopup.addItem(withTitle: Self.popupTitle(for: id, at: now))
        }
    }

    /// The window is created once and reused, so offsets computed at creation
    /// go stale across DST transitions. Refresh titles in place (keeps the
    /// selection) whenever the window regains key; offsets change only a few
    /// times a year, so skip the writes when nothing differs.
    func windowDidBecomeKey(_ notification: Notification) {
        let now = Date()
        for (i, id) in timezoneIdentifiers.enumerated() {
            let title = Self.popupTitle(for: id, at: now)
            if let item = timezonePopup.item(at: i), item.title != title {
                item.title = title
            }
        }
    }

    func windowWillClose(_ notification: Notification) {
        resetCopyFeedback()
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
        guard let result = TimezoneConverter.now(targetTimezoneId: converterStore.current.targetTimezone) else {
            showError(.unknownTimezone)
            return
        }
        resetCopyFeedback()
        isProgrammaticUpdate = true
        utcField.stringValue = result.utc
        targetField.stringValue = result.target
        isProgrammaticUpdate = false
        showError(nil)
    }

    @objc private func copyClicked(_ sender: NSButton) {
        let value = (sender === copyUTCButton) ? utcField.stringValue : targetField.stringValue
        guard currentError == nil, !value.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        let identifier = ObjectIdentifier(sender)
        copyFeedbackTasks[identifier]?.cancel()
        sender.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: nil)
        sender.contentTintColor = InterfaceStyle.accentColor
        let copied = Strings.t(.converterCopied, language: languageStore.current)
        sender.toolTip = copied
        let fieldName = sender === copyUTCButton
            ? "UTC" : Strings.t(.converterLabelTarget, language: languageStore.current)
        sender.setAccessibilityLabel("\(copied) \(fieldName)")
        // Fixed button geometry, immediate feedback, and no motion for keyboard users.
        copyFeedbackTasks[identifier] = Task { @MainActor [weak self, weak sender] in
            do { try await Task.sleep(for: .milliseconds(1200)) } catch { return }
            guard let self, let sender else { return }
            self.restoreCopyButton(sender)
            self.copyFeedbackTasks[identifier] = nil
        }
    }

    @objc private func textDidChange(_ notification: Notification) {
        guard !isProgrammaticUpdate else { return }
        resetCopyFeedback()
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
            showError(nil)
            return
        }
        switch TimezoneConverter.convertUTCToTarget(input, targetTimezoneId: converterStore.current.targetTimezone) {
        case .success(let converted):
            isProgrammaticUpdate = true
            targetField.stringValue = converted
            isProgrammaticUpdate = false
            showError(nil)
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
            showError(nil)
            return
        }
        switch TimezoneConverter.convertTargetToUTC(input, targetTimezoneId: converterStore.current.targetTimezone) {
        case .success(let converted):
            isProgrammaticUpdate = true
            utcField.stringValue = converted
            isProgrammaticUpdate = false
            showError(nil)
        case .failure(let err):
            showError(err)
        }
    }

    private func reconvert() {
        resetCopyFeedback()
        let utcInput = utcField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !utcInput.isEmpty { convertFromUTC(); return }
        let targetInput = targetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !targetInput.isEmpty { convertFromTarget() }
    }

    private func showError(_ error: TimezoneConverter.ConversionError?) {
        currentError = error
        let lang = languageStore.current
        switch error {
        case nil: errorLabel.stringValue = ""
        case .invalidFormat: errorLabel.stringValue = Strings.t(.converterErrorInvalidFormat, language: lang)
        case .yearOutOfRange: errorLabel.stringValue = Strings.t(.converterErrorYearOutOfRange, language: lang)
        case .unknownTimezone: errorLabel.stringValue = Strings.t(.converterErrorUnknownTimezone, language: lang)
        }
        updateCopyButtons()
    }

    private func updateCopyButtons() {
        copyUTCButton.isEnabled = currentError == nil && !utcField.stringValue.isEmpty
        copyTargetButton.isEnabled = currentError == nil && !targetField.stringValue.isEmpty
    }

    private func restoreCopyButton(_ button: NSButton) {
        button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        button.contentTintColor = nil
        let lang = languageStore.current
        let title = Strings.t(.converterCopyButton, language: lang)
        let field = button === copyUTCButton ? "UTC" : Strings.t(.converterLabelTarget, language: lang)
        button.toolTip = title
        button.setAccessibilityLabel("\(title) \(field)")
    }

    private func resetCopyFeedback() {
        for task in copyFeedbackTasks.values { task.cancel() }
        copyFeedbackTasks.removeAll()
        for button in [copyUTCButton, copyTargetButton] { restoreCopyButton(button) }
    }
}
