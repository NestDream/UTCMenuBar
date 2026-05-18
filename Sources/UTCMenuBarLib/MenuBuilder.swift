import Cocoa

public enum MenuBuilder {
    /// Build the menu bar app's full menu including display options, the appearance
    /// submenu (with the language sub-submenu), the Settings… item, and Quit.
    public static func buildMenu(
        options: DisplayOptions,
        styleOptions: StyleOptions,
        language: AppLanguage,
        target: AnyObject?,
        toggleShowDate: Selector?,
        toggleCompactTime: Selector?,
        toggleCompactDate: Selector?,
        setFontFamily: Selector?,
        setFontWeight: Selector?,
        setFontSize: Selector?,
        setTextColor: Selector?,
        setIconPrefix: Selector?,
        setDecorator: Selector?,
        setLanguage: Selector?,
        showSettings: Selector?,
        quit: Selector?
    ) -> NSMenu {
        let menu = NSMenu()

        let showDateItem = NSMenuItem(
            title: Strings.t(.menuShowDate, language: language),
            action: toggleShowDate,
            keyEquivalent: "")
        showDateItem.target = target
        showDateItem.state = options.showDate ? .on : .off
        menu.addItem(showDateItem)

        let compactTimeItem = NSMenuItem(
            title: Strings.t(.menuCompactTime, language: language),
            action: toggleCompactTime,
            keyEquivalent: "")
        compactTimeItem.target = target
        compactTimeItem.state = options.compactTime ? .on : .off
        menu.addItem(compactTimeItem)

        let compactDateItem = NSMenuItem(
            title: Strings.t(.menuCompactDate, language: language),
            action: toggleCompactDate,
            keyEquivalent: "")
        compactDateItem.target = target
        compactDateItem.state = options.compactDate ? .on : .off
        compactDateItem.isEnabled = options.showDate
        menu.addItem(compactDateItem)

        menu.addItem(NSMenuItem.separator())

        let appearanceItem = NSMenuItem(
            title: Strings.t(.menuAppearance, language: language),
            action: nil,
            keyEquivalent: "")
        appearanceItem.submenu = buildAppearanceSubmenu(
            styleOptions: styleOptions,
            language: language,
            target: target,
            setFontFamily: setFontFamily,
            setFontWeight: setFontWeight,
            setFontSize: setFontSize,
            setTextColor: setTextColor,
            setIconPrefix: setIconPrefix,
            setDecorator: setDecorator,
            setLanguage: setLanguage
        )
        menu.addItem(appearanceItem)

        let settingsItem = NSMenuItem(
            title: Strings.t(.menuSettings, language: language),
            action: showSettings,
            keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = target
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: Strings.t(.menuQuit, language: language),
            action: quit,
            keyEquivalent: "q")
        quitItem.target = target
        menu.addItem(quitItem)

        return menu
    }

    private static func buildAppearanceSubmenu(
        styleOptions: StyleOptions,
        language: AppLanguage,
        target: AnyObject?,
        setFontFamily: Selector?,
        setFontWeight: Selector?,
        setFontSize: Selector?,
        setTextColor: Selector?,
        setIconPrefix: Selector?,
        setDecorator: Selector?,
        setLanguage: Selector?
    ) -> NSMenu {
        let menu = NSMenu(title: Strings.t(.menuAppearance, language: language))

        let fontItem = NSMenuItem(
            title: Strings.t(.appearanceFont, language: language),
            action: nil,
            keyEquivalent: "")
        fontItem.submenu = radioSubmenu(
            cases: FontFamily.allCases,
            current: styleOptions.fontFamily,
            displayName: { family in
                if family == .custom, !styleOptions.customFontName.isEmpty {
                    return Strings.formatCustomFont(name: styleOptions.customFontName, language: language)
                }
                return family.displayName(for: language)
            },
            action: setFontFamily,
            target: target
        )
        menu.addItem(fontItem)

        let weightItem = NSMenuItem(
            title: Strings.t(.appearanceWeight, language: language),
            action: nil,
            keyEquivalent: "")
        weightItem.submenu = radioSubmenu(
            cases: FontWeight.allCases,
            current: styleOptions.fontWeight,
            displayName: { $0.displayName(for: language) },
            action: setFontWeight,
            target: target
        )
        menu.addItem(weightItem)

        let sizeItem = NSMenuItem(
            title: Strings.t(.appearanceSize, language: language),
            action: nil,
            keyEquivalent: "")
        sizeItem.submenu = radioSubmenu(
            cases: FontSize.allCases,
            current: styleOptions.fontSize,
            displayName: { $0.displayName(for: language) },
            action: setFontSize,
            target: target
        )
        menu.addItem(sizeItem)

        let colorItem = NSMenuItem(
            title: Strings.t(.appearanceColor, language: language),
            action: nil,
            keyEquivalent: "")
        colorItem.submenu = radioSubmenu(
            cases: TextColorOption.allCases,
            current: styleOptions.textColor,
            displayName: { $0.displayName(for: language) },
            action: setTextColor,
            target: target
        )
        menu.addItem(colorItem)

        let iconItem = NSMenuItem(
            title: Strings.t(.appearanceIcon, language: language),
            action: nil,
            keyEquivalent: "")
        iconItem.submenu = radioSubmenu(
            cases: IconPrefix.allCases,
            current: styleOptions.iconPrefix,
            displayName: { $0.displayName(for: language) },
            action: setIconPrefix,
            target: target
        )
        menu.addItem(iconItem)

        let decoratorItem = NSMenuItem(
            title: Strings.t(.appearanceDecorator, language: language),
            action: nil,
            keyEquivalent: "")
        decoratorItem.submenu = radioSubmenu(
            cases: Decorator.allCases,
            current: styleOptions.decorator,
            displayName: { $0.displayName(for: language) },
            action: setDecorator,
            target: target
        )
        menu.addItem(decoratorItem)

        let languageItem = NSMenuItem(
            title: Strings.t(.menuLanguage, language: language),
            action: nil,
            keyEquivalent: "")
        languageItem.submenu = radioSubmenu(
            cases: AppLanguage.allCases,
            current: language,
            displayName: { $0.nativeName },
            action: setLanguage,
            target: target
        )
        menu.addItem(languageItem)

        return menu
    }

    /// Build a submenu of mutually-exclusive radio items. Each item's `tag` is
    /// the case's index in `T.allCases`, letting an `@objc` action recover the
    /// selected case via `sender.tag`.
    private static func radioSubmenu<T: CaseIterable & Equatable>(
        cases allCases: T.AllCases,
        current: T,
        displayName: (T) -> String,
        action: Selector?,
        target: AnyObject?
    ) -> NSMenu {
        let submenu = NSMenu()
        for (index, value) in allCases.enumerated() {
            let item = NSMenuItem(title: displayName(value), action: action, keyEquivalent: "")
            item.target = target
            item.tag = index
            item.state = (value == current) ? .on : .off
            submenu.addItem(item)
        }
        return submenu
    }
}
