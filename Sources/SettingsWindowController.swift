import AppKit
import UTCMenuBarLib

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let store: StyleOptionsStore

    private let fontFamilyPopup    = NSPopUpButton()
    private let fontWeightPopup    = NSPopUpButton()
    private let fontSizeSegmented  = NSSegmentedControl()
    private let textColorPopup     = NSPopUpButton()
    private let iconPrefixPopup    = NSPopUpButton()
    private let decoratorPopup     = NSPopUpButton()
    private let previewLabel       = NSTextField(labelWithString: "")
    private let onPickCustomFont:  () -> Void

    init(store: StyleOptionsStore, onPickCustomFont: @escaping () -> Void = {}) {
        self.store = store
        self.onPickCustomFont = onPickCustomFont
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.title = "UTCMenuBar 设置"
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        setupContent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupContent() {
        configurePopup(fontFamilyPopup, titles: FontFamily.allCases.map(\.displayName))
        configurePopup(fontWeightPopup, titles: FontWeight.allCases.map(\.displayName))
        configurePopup(textColorPopup, titles: TextColorOption.allCases.map(\.displayName))
        configurePopup(iconPrefixPopup, titles: IconPrefix.allCases.map(\.displayName))
        configurePopup(decoratorPopup, titles: Decorator.allCases.map(\.displayName))

        let sizeTitles = FontSize.allCases.map(\.displayName)
        fontSizeSegmented.segmentCount = sizeTitles.count
        for (i, title) in sizeTitles.enumerated() {
            fontSizeSegmented.setLabel(title, forSegment: i)
        }
        fontSizeSegmented.trackingMode = .selectOne
        fontSizeSegmented.target = self
        fontSizeSegmented.action = #selector(segmentedChanged(_:))

        previewLabel.drawsBackground = true
        previewLabel.backgroundColor = .controlBackgroundColor
        previewLabel.isBezeled = false
        previewLabel.isEditable = false
        previewLabel.isSelectable = false
        previewLabel.alignment = .center

        let separator = NSBox()
        separator.boxType = .separator

        let previewHeading = NSTextField(labelWithString: "预览")
        let previewStack = NSStackView(views: [previewHeading, previewLabel])
        previewStack.orientation = .vertical
        previewStack.spacing = 4
        previewStack.alignment = .leading

        let outer = NSStackView(views: [
            row("字体", fontFamilyPopup),
            row("字重", fontWeightPopup),
            row("字号", fontSizeSegmented),
            row("颜色", textColorPopup),
            row("图标", iconPrefixPopup),
            row("装饰", decoratorPopup),
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

        refresh(from: store.current)

        store.addListener { [weak self] style in
            self?.refresh(from: style)
        }
    }

    func refresh(from style: StyleOptions) {
        let customIndex = SettingsViewModel.selectedIndex(FontFamily.custom)
        let customTitle: String
        if !style.customFontName.isEmpty {
            customTitle = "自定义：\(style.customFontName)"
        } else {
            customTitle = FontFamily.custom.displayName
        }
        if let item = fontFamilyPopup.item(at: customIndex) {
            item.title = customTitle
        }
        fontFamilyPopup.selectItem(at: SettingsViewModel.selectedIndex(style.fontFamily))
        fontWeightPopup.selectItem(at: SettingsViewModel.selectedIndex(style.fontWeight))
        textColorPopup.selectItem(at: SettingsViewModel.selectedIndex(style.textColor))
        iconPrefixPopup.selectItem(at: SettingsViewModel.selectedIndex(style.iconPrefix))
        decoratorPopup.selectItem(at: SettingsViewModel.selectedIndex(style.decorator))
        fontSizeSegmented.selectedSegment = SettingsViewModel.selectedIndex(style.fontSize)
        previewLabel.attributedStringValue = SettingsViewModel.previewAttributedString(style: style)
    }

    @objc private func popupChanged(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        if sender === fontFamilyPopup, let v = SettingsViewModel.value(at: i, of: FontFamily.self) {
            if v == .custom {
                onPickCustomFont()
                refresh(from: store.current)
            } else {
                store.update { $0.fontFamily = v }
            }
        } else if sender === fontWeightPopup, let v = SettingsViewModel.value(at: i, of: FontWeight.self) {
            store.update { $0.fontWeight = v }
        } else if sender === textColorPopup, let v = SettingsViewModel.value(at: i, of: TextColorOption.self) {
            store.update { $0.textColor = v }
        } else if sender === iconPrefixPopup, let v = SettingsViewModel.value(at: i, of: IconPrefix.self) {
            store.update { $0.iconPrefix = v }
        } else if sender === decoratorPopup, let v = SettingsViewModel.value(at: i, of: Decorator.self) {
            store.update { $0.decorator = v }
        }
    }

    @objc private func segmentedChanged(_ sender: NSSegmentedControl) {
        if let v = SettingsViewModel.value(at: sender.selectedSegment, of: FontSize.self) {
            store.update { $0.fontSize = v }
        }
    }

    private func configurePopup(_ popup: NSPopUpButton, titles: [String]) {
        popup.removeAllItems()
        popup.addItems(withTitles: titles)
        popup.target = self
        popup.action = #selector(popupChanged(_:))
    }

    private func row(_ title: String, _ control: NSView) -> NSStackView {
        let label = NSTextField(labelWithString: title)
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let stack = NSStackView(views: [label, control])
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.alignment = .firstBaseline
        return stack
    }
}
