import Foundation
import UTCMenuBarLib

enum StringsTests {

    static func testAllKeysHaveBothLanguages() {
        print("  Running: testAllKeysHaveBothLanguages (covers \(StringKey.allCases.count) keys)...")
        for key in StringKey.allCases {
            let zh = Strings.t(key, language: .zh)
            let en = Strings.t(key, language: .en)
            guard !zh.isEmpty else { fatalError("FAIL: \(key.rawValue) zh translation empty") }
            guard !en.isEmpty else { fatalError("FAIL: \(key.rawValue) en translation empty") }
            // English fallback policy: zh should not silently equal the rawValue.
            guard zh != key.rawValue else { fatalError("FAIL: \(key.rawValue) zh fell back to raw key") }
            guard en != key.rawValue else { fatalError("FAIL: \(key.rawValue) en fell back to raw key") }
        }
        print("  ✓ testAllKeysHaveBothLanguages passed")
    }

    static func testCoreUIStrings() {
        print("  Running: testCoreUIStrings...")
        guard Strings.t(.menuShowDate, language: .zh) == "显示日期" else { fatalError("FAIL: menuShowDate zh") }
        guard Strings.t(.menuShowDate, language: .en) == "Show date" else { fatalError("FAIL: menuShowDate en") }
        guard Strings.t(.menuQuit, language: .zh) == "退出" else { fatalError("FAIL: menuQuit zh") }
        guard Strings.t(.menuQuit, language: .en) == "Quit" else { fatalError("FAIL: menuQuit en") }
        guard Strings.t(.menuAppearance, language: .en) == "Appearance" else { fatalError("FAIL: menuAppearance en") }
        guard Strings.t(.menuLanguage, language: .zh) == "语言" else { fatalError("FAIL: menuLanguage zh") }
        print("  ✓ testCoreUIStrings passed")
    }

    static func testFormatCustomFont() {
        print("  Running: testFormatCustomFont...")
        guard Strings.formatCustomFont(name: "Helvetica", language: .zh) == "自定义：Helvetica" else {
            fatalError("FAIL: zh formatCustomFont")
        }
        guard Strings.formatCustomFont(name: "Helvetica", language: .en) == "Custom: Helvetica" else {
            fatalError("FAIL: en formatCustomFont")
        }
        // Empty name falls back to plain "Custom…" / "自定义…"
        guard Strings.formatCustomFont(name: "", language: .zh) == "自定义…" else {
            fatalError("FAIL: empty zh formatCustomFont should be plain custom label")
        }
        guard Strings.formatCustomFont(name: "  ", language: .en) == "Custom…" else {
            fatalError("FAIL: whitespace en formatCustomFont should be plain custom label")
        }
        print("  ✓ testFormatCustomFont passed")
    }

    static func runAll() {
        print("Strings Unit Tests")
        print("==================")
        testAllKeysHaveBothLanguages()
        testCoreUIStrings()
        testFormatCustomFont()
        print("\nAll Strings unit tests passed ✓")
    }
}
