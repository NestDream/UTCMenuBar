import AppKit
import UTCMenuBarLib

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore

    private let fontFamilyPopup    = NSPopUpButton()
    private let fontWeightPopup    = NSPopUpButton()
    private let fontSizeSegmented  = NSSegmentedControl()
    private let textColorPopup     = NSPopUpButton()
    private let iconPrefixPopup    = NSPopUpButton()
    private let decoratorPopup     = NSPopUpButton()
    private let languagePopup      = NSPopUpButton()
    private let previewLabel       = NSTextField(labelWithString: "")
    private let onPickCustomFont:  () -> Void

    private var fontFamilyLabel: NSTextField!
    private var fontWeightLabel: NSTextField!
    private var fontSizeLabel: NSTextField!
    private var textColorLabel: NSTextField!
    private var iconPrefixLabel: NSTextField!
    private var decoratorLabel: NSTextField!
    private var languageLabel: NSTextField!
    private var previewHeading: NSTextField!

    init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        onPickCustomFont: @escaping () -> Void = {}
    ) {
        self.styleStore = styleStore
        self.languageStore = languageStore
        self.onPickCustomFont = onPickCustomFont
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 340),
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

        configurePopup(fontFamilyPopup)
        configurePopup(fontWeightPopup)
        configurePopup(textColorPopup)
        configurePopup(iconPrefixPopup)
        configurePopup(decoratorPopup)
        configurePopup(languagePopup)

        fontSizeSegmented.segmentCount = FontSize.allCases.count
        fontSizeSegmented.trackingMode = .selectOne
        fontSizeSegmented.target = self
        fontSizeSegmented.action = #selector(segmentedChanged(_:))

        previewLabel.drawsBackground = true
        previewLabel.backgroundColor = .controlBackgroundColor
        previewLabel.isBezeled = false
        previewLabel.isEditable = false
        previewLabel.isSelectable = false
        previewLabel.alignment = .center

        fontFamilyLabel = NSTextField(labelWithString: "")
        fontWeightLabel = NSTextField(labelWithString: "")
        fontSizeLabel = NSTextField(labelWithString: "")
        textColorLabel = NSTextField(labelWithString: "")
        iconPrefixLabel = NSTextField(labelWithString: "")
        decoratorLabel = NSTextField(labelWithString: "")
        languageLabel = NSTextField(labelWithString: "")
        previewHeading = NSTextField(labelWithString: "")

        let separator = NSBox()
        separator.boxType = .separator

        let previewStack = NSStackView(views: [previewHeading, previewLabel])
        previewStack.orientation = .vertical
        previewStack.spacing = 4
        previewStack.alignment = .leading

        let outer = NSStackView(views: [
            row(fontFamilyLabel, fontFamilyPopup),
            row(fontWeightLabel, fontWeightPopup),
            row(fontSizeLabel, fontSizeSegmented),
            row(textColorLabel, textColorPopup),
            row(iconPrefixLabel, iconPrefixPopup),
            row(decoratorLabel, decoratorPopup),
            row(languageLabel, languagePopup),
            separator,
            previewStack,
        ])
        outer.orientation = .vertical
        outer.spacing = 14
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

        previewLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true

        applyLanguage(language)
        refresh(from: styleStore.current)

        styleStore.addListener { [weak self] style in
            self?.refresh(from: style)
        }
        languageStore.addListener { [weak self] lang in
            guard let self else { return }
            self.applyLanguage(lang)
            self.refresh(from: self.styleStore.current)
        }
    }

    /// Re-render every static label, popup item, and the window title for the given language.
    private func applyLanguage(_ lang: AppLanguage) {
        window?.title = Strings.t(.settingsWindowTitle, language: lang)

        fontFamilyLabel.stringValue = Strings.t(.settingsLabelFont, language: lang)
        fontWeightLabel.stringValue = Strings.t(.settingsLabelWeight, language: lang)
        fontSizeLabel.stringValue = Strings.t(.settingsLabelSize, language: lang)
        textColorLabel.stringValue = Strings.t(.settingsLabelColor, language: lang)
        iconPrefixLabel.stringValue = Strings.t(.settingsLabelIcon, language: lang)
        decoratorLabel.stringValue = Strings.t(.settingsLabelDecorator, language: lang)
        languageLabel.stringValue = Strings.t(.settingsLabelLanguage, language: lang)
        previewHeading.stringValue = Strings.t(.settingsLabelPreview, language: lang)

        repopulate(fontFamilyPopup, titles: FontFamily.allCases.map { $0.displayName(for: lang) })
        repopulate(fontWeightPopup, titles: FontWeight.allCases.map { $0.displayName(for: lang) })
        repopulate(textColorPopup, titles: TextColorOption.allCases.map { $0.displayName(for: lang) })
        repopulate(iconPrefixPopup, titles: IconPrefix.allCases.map { $0.displayName(for: lang) })
        repopulate(decoratorPopup, titles: Decorator.allCases.map { $0.displayName(for: lang) })
        repopulate(languagePopup, titles: AppLanguage.allCases.map { $0.nativeName })

        for (i, title) in FontSize.allCases.map({ $0.displayName(for: lang) }).enumerated() {
            fontSizeSegmented.setLabel(title, forSegment: i)
        }
    }

    func refresh(from style: StyleOptions) {
        let lang = languageStore.current
        let customIndex = SettingsViewModel.selectedIndex(FontFamily.custom)
        if let item = fontFamilyPopup.item(at: customIndex) {
            if !style.customFontName.isEmpty {
                item.title = Strings.formatCustomFont(name: style.customFontName, language: lang)
            } else {
                item.title = FontFamily.custom.displayName(for: lang)
            }
        }
        fontFamilyPopup.selectItem(at: SettingsViewModel.selectedIndex(style.fontFamily))
        fontWeightPopup.selectItem(at: SettingsViewModel.selectedIndex(style.fontWeight))
        textColorPopup.selectItem(at: SettingsViewModel.selectedIndex(style.textColor))
        iconPrefixPopup.selectItem(at: SettingsViewModel.selectedIndex(style.iconPrefix))
        decoratorPopup.selectItem(at: SettingsViewModel.selectedIndex(style.decorator))
        languagePopup.selectItem(at: SettingsViewModel.selectedIndex(lang))
        fontSizeSegmented.selectedSegment = SettingsViewModel.selectedIndex(style.fontSize)
        previewLabel.attributedStringValue = SettingsViewModel.previewAttributedString(style: style)
    }

    @objc private func popupChanged(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        if sender === fontFamilyPopup, let v = SettingsViewModel.value(at: i, of: FontFamily.self) {
            if v == .custom {
                onPickCustomFont()
                refresh(from: styleStore.current)
            } else {
                styleStore.update { $0.fontFamily = v }
            }
        } else if sender === fontWeightPopup, let v = SettingsViewModel.value(at: i, of: FontWeight.self) {
            styleStore.update { $0.fontWeight = v }
        } else if sender === textColorPopup, let v = SettingsViewModel.value(at: i, of: TextColorOption.self) {
            styleStore.update { $0.textColor = v }
        } else if sender === iconPrefixPopup, let v = SettingsViewModel.value(at: i, of: IconPrefix.self) {
            styleStore.update { $0.iconPrefix = v }
        } else if sender === decoratorPopup, let v = SettingsViewModel.value(at: i, of: Decorator.self) {
            styleStore.update { $0.decorator = v }
        } else if sender === languagePopup, let v = SettingsViewModel.value(at: i, of: AppLanguage.self) {
            languageStore.update(v)
        }
    }

    @objc private func segmentedChanged(_ sender: NSSegmentedControl) {
        if let v = SettingsViewModel.value(at: sender.selectedSegment, of: FontSize.self) {
            styleStore.update { $0.fontSize = v }
        }
    }

    private func configurePopup(_ popup: NSPopUpButton) {
        popup.target = self
        popup.action = #selector(popupChanged(_:))
    }

    private func repopulate(_ popup: NSPopUpButton, titles: [String]) {
        popup.removeAllItems()
        popup.addItems(withTitles: titles)
    }

    private func row(_ label: NSTextField, _ control: NSView) -> NSStackView {
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 70).isActive = true
        let stack = NSStackView(views: [label, control])
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.alignment = .firstBaseline
        return stack
    }
}
