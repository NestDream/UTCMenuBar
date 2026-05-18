import Cocoa
import UTCMenuBarLib

enum MenuPropertyTests {

    private static func build(options: DisplayOptions, style: StyleOptions = .default, language: AppLanguage = .zh) -> NSMenu {
        MenuBuilder.buildMenu(
            options: options,
            styleOptions: style,
            language: language,
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
            setLanguage: nil,
            showSettings: nil,
            quit: nil
        )
    }

    private static func randomStyle() -> StyleOptions {
        StyleOptions(
            fontFamily: FontFamily.allCases.randomElement()!,
            fontWeight: FontWeight.allCases.randomElement()!,
            fontSize: FontSize.allCases.randomElement()!,
            textColor: TextColorOption.allCases.randomElement()!,
            decorator: Decorator.allCases.randomElement()!,
            iconPrefix: IconPrefix.allCases.randomElement()!,
            customFontName: ""
        )
    }

    /// **Validates: Requirements 6.2, 6.3 (display options)**
    /// For any DisplayOptions, each display item's checkmark state matches its bool.
    static func testDisplayOptionCheckmarkMatchesValues() {
        print("  Running Property: display option checkmarks (100 iterations)...")
        for i in 0..<100 {
            let options = DisplayOptions(
                showDate: Bool.random(),
                compactTime: Bool.random(),
                compactDate: Bool.random()
            )
            let menu = build(options: options)
            let pairs: [(String, NSMenuItem, Bool)] = [
                ("showDate", menu.items[0], options.showDate),
                ("compactTime", menu.items[1], options.compactTime),
                ("compactDate", menu.items[2], options.compactDate),
            ]
            for (name, item, expected) in pairs {
                let want: NSControl.StateValue = expected ? .on : .off
                guard item.state == want else {
                    fatalError("FAIL iter \(i): \(name) state \(item.state.rawValue) expected \(want.rawValue)")
                }
            }
        }
        print("  ✓ Display option checkmarks passed (100/100 iterations)")
    }

    /// **Validates: Requirements 3.1, 6.4**
    static func testCompactDateAvailabilityDependsOnShowDate() {
        print("  Running Property: compactDate enabled iff showDate (100 iterations)...")
        for i in 0..<100 {
            let options = DisplayOptions(
                showDate: Bool.random(),
                compactTime: Bool.random(),
                compactDate: Bool.random()
            )
            let menu = build(options: options)
            let compactDateItem = menu.items[2]
            guard compactDateItem.isEnabled == options.showDate else {
                fatalError("FAIL iter \(i): compactDate isEnabled=\(compactDateItem.isEnabled), expected \(options.showDate)")
            }
        }
        print("  ✓ compactDate availability passed (100/100 iterations)")
    }

    /// **Validates: visual-distinction Property 7 — appearance submenus have exactly one .on item, in the right slot.**
    static func testAppearanceRadioInvariant() {
        print("  Running Property 7: appearance radio invariant (100 iterations)...")
        for i in 0..<100 {
            let style = randomStyle()
            let menu = build(options: .default, style: style)
            guard let appearance = menu.items[4].submenu else {
                fatalError("FAIL iter \(i): appearance submenu missing")
            }
            let expected: [(String, Int)] = [
                ("字体", FontFamily.allCases.firstIndex(of: style.fontFamily)!),
                ("字重", FontWeight.allCases.firstIndex(of: style.fontWeight)!),
                ("字号", FontSize.allCases.firstIndex(of: style.fontSize)!),
                ("颜色", TextColorOption.allCases.firstIndex(of: style.textColor)!),
                ("图标", IconPrefix.allCases.firstIndex(of: style.iconPrefix)!),
                ("装饰", Decorator.allCases.firstIndex(of: style.decorator)!),
                ("语言", AppLanguage.allCases.firstIndex(of: .zh)!),
            ]
            for (j, (name, expectedIndex)) in expected.enumerated() {
                guard appearance.items[j].title == name else {
                    fatalError("FAIL iter \(i): appearance[\(j)] title '\(appearance.items[j].title)' expected '\(name)'")
                }
                guard let submenu = appearance.items[j].submenu else {
                    fatalError("FAIL iter \(i): \(name) has no submenu")
                }
                let onItems = submenu.items.enumerated().filter { $0.element.state == .on }
                guard onItems.count == 1 else {
                    fatalError("FAIL iter \(i): \(name) has \(onItems.count) .on items, expected 1")
                }
                guard onItems[0].offset == expectedIndex else {
                    fatalError("FAIL iter \(i): \(name) .on at index \(onItems[0].offset), expected \(expectedIndex)")
                }
            }
        }
        print("  ✓ Property 7 passed (100/100 iterations)")
    }

    static func runAll() {
        print("Menu Property Tests")
        print("====================")
        testDisplayOptionCheckmarkMatchesValues()
        testCompactDateAvailabilityDependsOnShowDate()
        testAppearanceRadioInvariant()
        print("\nAll menu property tests passed ✓")
    }
}
