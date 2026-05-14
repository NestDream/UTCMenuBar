import Cocoa
import UTCMenuBarLib

/// Unit tests for menu structure verification.
/// **Validates: Requirements 1.1, 2.1, 6.1 (display) + visual-distinction Requirement 8 (menu structure)**

enum MenuTests {

    private static func buildDefault(
        options: DisplayOptions = .default,
        styleOptions: StyleOptions = .default
    ) -> NSMenu {
        MenuBuilder.buildMenu(
            options: options,
            styleOptions: styleOptions,
            target: nil,
            toggleShowDate: nil,
            toggleCompactTime: nil,
            toggleCompactDate: nil,
            setFontFamily: nil,
            setFontWeight: nil,
            setFontSize: nil,
            setTextColor: nil,
            setIconPrefix: nil,
            setDecorator: nil,
            showSettings: nil,
            quit: nil
        )
    }

    /// Top-level menu has 8 items in this order:
    /// 0 显示日期, 1 紧凑时间, 2 紧凑日期, 3 separator, 4 外观▶, 5 设置… ⌘,, 6 separator, 7 Quit ⌘Q
    static func testMenuStructure() {
        print("  Running: testMenuStructure...")
        let menu = buildDefault()

        guard menu.items.count == 8 else {
            fatalError("FAIL: Expected 8 menu items, got \(menu.items.count)")
        }

        guard menu.items[0].title == "显示日期" else { fatalError("FAIL: item 0 title '\(menu.items[0].title)'") }
        guard menu.items[1].title == "紧凑时间" else { fatalError("FAIL: item 1 title '\(menu.items[1].title)'") }
        guard menu.items[2].title == "紧凑日期" else { fatalError("FAIL: item 2 title '\(menu.items[2].title)'") }
        guard menu.items[3].isSeparatorItem else { fatalError("FAIL: item 3 should be separator") }
        guard menu.items[4].title == "外观" else { fatalError("FAIL: item 4 title '\(menu.items[4].title)'") }
        guard menu.items[4].submenu != nil else { fatalError("FAIL: item 4 should have a submenu") }
        guard menu.items[5].title == "设置…" else { fatalError("FAIL: item 5 title '\(menu.items[5].title)'") }
        guard menu.items[6].isSeparatorItem else { fatalError("FAIL: item 6 should be separator") }
        guard menu.items[7].title == "Quit" else { fatalError("FAIL: item 7 title '\(menu.items[7].title)'") }
        guard menu.items[7].keyEquivalent == "q" else { fatalError("FAIL: Quit keyEquivalent '\(menu.items[7].keyEquivalent)'") }

        print("  ✓ testMenuStructure passed")
    }

    static func testSettingsItemKeyEquivalent() {
        print("  Running: testSettingsItemKeyEquivalent...")
        let menu = buildDefault()
        let settings = menu.items[5]
        guard settings.keyEquivalent == "," else {
            fatalError("FAIL: settings keyEquivalent should be ',', got '\(settings.keyEquivalent)'")
        }
        guard settings.keyEquivalentModifierMask.contains(.command) else {
            fatalError("FAIL: settings should have .command modifier")
        }
        print("  ✓ testSettingsItemKeyEquivalent passed")
    }

    static func testAppearanceSubmenuStructure() {
        print("  Running: testAppearanceSubmenuStructure...")
        let menu = buildDefault()
        guard let appearance = menu.items[4].submenu else {
            fatalError("FAIL: appearance submenu missing")
        }
        let expected = ["字体", "字重", "字号", "颜色", "图标", "装饰"]
        guard appearance.items.count == expected.count else {
            fatalError("FAIL: expected \(expected.count) appearance items, got \(appearance.items.count)")
        }
        for (i, title) in expected.enumerated() {
            guard appearance.items[i].title == title else {
                fatalError("FAIL: appearance item \(i) expected '\(title)', got '\(appearance.items[i].title)'")
            }
            guard appearance.items[i].submenu != nil else {
                fatalError("FAIL: appearance item \(i) ('\(title)') should have a submenu")
            }
        }
        print("  ✓ testAppearanceSubmenuStructure passed")
    }

    private static func appearanceSubmenu(at index: Int, style: StyleOptions = .default) -> NSMenu {
        guard let appearance = buildDefault(styleOptions: style).items[4].submenu else {
            fatalError("FAIL: appearance submenu missing")
        }
        guard let submenu = appearance.items[index].submenu else {
            fatalError("FAIL: appearance.items[\(index)].submenu missing")
        }
        return submenu
    }

    static func testRadioForFontFamily() {
        print("  Running: testRadioForFontFamily...")
        for (i, family) in FontFamily.allCases.enumerated() {
            var style = StyleOptions.default
            style.fontFamily = family
            let submenu = appearanceSubmenu(at: 0, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: fontFamily=\(family) item \(j) state \(item.state.rawValue) expected \(expected.rawValue)")
                }
                guard item.tag == j else {
                    fatalError("FAIL: fontFamily item \(j) tag \(item.tag) expected \(j)")
                }
            }
        }
        print("  ✓ testRadioForFontFamily passed")
    }

    static func testRadioForFontWeight() {
        print("  Running: testRadioForFontWeight...")
        for (i, weight) in FontWeight.allCases.enumerated() {
            var style = StyleOptions.default
            style.fontWeight = weight
            let submenu = appearanceSubmenu(at: 1, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: fontWeight=\(weight) item \(j) state mismatch")
                }
            }
        }
        print("  ✓ testRadioForFontWeight passed")
    }

    static func testRadioForFontSize() {
        print("  Running: testRadioForFontSize...")
        for (i, size) in FontSize.allCases.enumerated() {
            var style = StyleOptions.default
            style.fontSize = size
            let submenu = appearanceSubmenu(at: 2, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: fontSize=\(size) item \(j) state mismatch")
                }
            }
        }
        print("  ✓ testRadioForFontSize passed")
    }

    static func testRadioForTextColor() {
        print("  Running: testRadioForTextColor...")
        for (i, color) in TextColorOption.allCases.enumerated() {
            var style = StyleOptions.default
            style.textColor = color
            let submenu = appearanceSubmenu(at: 3, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: textColor=\(color) item \(j) state mismatch")
                }
            }
        }
        print("  ✓ testRadioForTextColor passed")
    }

    static func testRadioForIconPrefix() {
        print("  Running: testRadioForIconPrefix...")
        for (i, icon) in IconPrefix.allCases.enumerated() {
            var style = StyleOptions.default
            style.iconPrefix = icon
            let submenu = appearanceSubmenu(at: 4, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: iconPrefix=\(icon) item \(j) state \(item.state.rawValue) expected \(expected.rawValue)")
                }
                guard item.tag == j else {
                    fatalError("FAIL: iconPrefix item \(j) tag \(item.tag) expected \(j)")
                }
            }
        }
        print("  ✓ testRadioForIconPrefix passed")
    }

    static func testRadioForDecorator() {
        print("  Running: testRadioForDecorator...")
        for (i, decorator) in Decorator.allCases.enumerated() {
            var style = StyleOptions.default
            style.decorator = decorator
            let submenu = appearanceSubmenu(at: 5, style: style)
            for (j, item) in submenu.items.enumerated() {
                let expected: NSControl.StateValue = (i == j) ? .on : .off
                guard item.state == expected else {
                    fatalError("FAIL: decorator=\(decorator) item \(j) state mismatch")
                }
            }
        }
        print("  ✓ testRadioForDecorator passed")
    }

    static func testFontSubmenuIncludesCustom() {
        print("  Running: testFontSubmenuIncludesCustom...")
        let submenu = appearanceSubmenu(at: 0, style: .default)
        let titles = submenu.items.map(\.title)
        guard titles.contains("自定义…") else {
            fatalError("FAIL: font submenu should include '自定义…' option, got titles \(titles)")
        }
        var style = StyleOptions.default
        style.fontFamily = .custom
        style.customFontName = "Helvetica"
        let withCustom = appearanceSubmenu(at: 0, style: style)
        let customIndex = FontFamily.allCases.firstIndex(of: .custom)!
        guard withCustom.items[customIndex].title == "自定义：Helvetica" else {
            fatalError("FAIL: custom font item title should reflect customFontName, got '\(withCustom.items[customIndex].title)'")
        }
        guard withCustom.items[customIndex].state == .on else {
            fatalError("FAIL: custom font item should be checked when fontFamily=.custom")
        }
        print("  ✓ testFontSubmenuIncludesCustom passed")
    }

    static func runAll() {
        print("Menu Unit Tests")
        print("================")
        testMenuStructure()
        testSettingsItemKeyEquivalent()
        testAppearanceSubmenuStructure()
        testRadioForFontFamily()
        testRadioForFontWeight()
        testRadioForFontSize()
        testRadioForTextColor()
        testRadioForIconPrefix()
        testRadioForDecorator()
        testFontSubmenuIncludesCustom()
        print("\nAll menu unit tests passed ✓")
    }
}
