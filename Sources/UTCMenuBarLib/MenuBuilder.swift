import Cocoa

public enum MenuBuilder {
    /// Build the menu bar app's full menu including display options, the appearance
    /// submenu, the Settings… item, and Quit.
    public static func buildMenu(
        options: DisplayOptions,
        styleOptions: StyleOptions,
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
        showSettings: Selector?,
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

        let appearanceItem = NSMenuItem(title: "外观", action: nil, keyEquivalent: "")
        appearanceItem.submenu = buildAppearanceSubmenu(
            styleOptions: styleOptions,
            target: target,
            setFontFamily: setFontFamily,
            setFontWeight: setFontWeight,
            setFontSize: setFontSize,
            setTextColor: setTextColor,
            setIconPrefix: setIconPrefix,
            setDecorator: setDecorator
        )
        menu.addItem(appearanceItem)

        let settingsItem = NSMenuItem(title: "设置…", action: showSettings, keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = target
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: quit, keyEquivalent: "q")
        quitItem.target = target
        menu.addItem(quitItem)

        return menu
    }

    private static func buildAppearanceSubmenu(
        styleOptions: StyleOptions,
        target: AnyObject?,
        setFontFamily: Selector?,
        setFontWeight: Selector?,
        setFontSize: Selector?,
        setTextColor: Selector?,
        setIconPrefix: Selector?,
        setDecorator: Selector?
    ) -> NSMenu {
        let menu = NSMenu(title: "外观")

        let fontItem = NSMenuItem(title: "字体", action: nil, keyEquivalent: "")
        fontItem.submenu = radioSubmenu(
            cases: FontFamily.allCases,
            current: styleOptions.fontFamily,
            displayName: { family in
                if family == .custom, !styleOptions.customFontName.isEmpty {
                    return "自定义：\(styleOptions.customFontName)"
                }
                return family.displayName
            },
            action: setFontFamily,
            target: target
        )
        menu.addItem(fontItem)

        let weightItem = NSMenuItem(title: "字重", action: nil, keyEquivalent: "")
        weightItem.submenu = radioSubmenu(
            cases: FontWeight.allCases,
            current: styleOptions.fontWeight,
            displayName: { $0.displayName },
            action: setFontWeight,
            target: target
        )
        menu.addItem(weightItem)

        let sizeItem = NSMenuItem(title: "字号", action: nil, keyEquivalent: "")
        sizeItem.submenu = radioSubmenu(
            cases: FontSize.allCases,
            current: styleOptions.fontSize,
            displayName: { $0.displayName },
            action: setFontSize,
            target: target
        )
        menu.addItem(sizeItem)

        let colorItem = NSMenuItem(title: "颜色", action: nil, keyEquivalent: "")
        colorItem.submenu = radioSubmenu(
            cases: TextColorOption.allCases,
            current: styleOptions.textColor,
            displayName: { $0.displayName },
            action: setTextColor,
            target: target
        )
        menu.addItem(colorItem)

        let iconItem = NSMenuItem(title: "图标", action: nil, keyEquivalent: "")
        iconItem.submenu = radioSubmenu(
            cases: IconPrefix.allCases,
            current: styleOptions.iconPrefix,
            displayName: { $0.displayName },
            action: setIconPrefix,
            target: target
        )
        menu.addItem(iconItem)

        let decoratorItem = NSMenuItem(title: "装饰", action: nil, keyEquivalent: "")
        decoratorItem.submenu = radioSubmenu(
            cases: Decorator.allCases,
            current: styleOptions.decorator,
            displayName: { $0.displayName },
            action: setDecorator,
            target: target
        )
        menu.addItem(decoratorItem)

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
