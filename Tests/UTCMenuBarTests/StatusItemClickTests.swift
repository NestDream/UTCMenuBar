import AppKit
import UTCMenuBarLib

/// Tests for status-item click classification: right-click and Control+left-click
/// open the menu; a plain left-click does not (it toggles the popover).

enum StatusItemClickTests {

    static func testRightClickIsSecondary() {
        print("  Running: testRightClickIsSecondary...")
        guard StatusItemClick.isSecondary(eventType: .rightMouseUp, modifiers: []) else {
            fatalError("FAIL: right-click should be secondary")
        }
        // Modifiers on a right-click don't change the classification.
        guard StatusItemClick.isSecondary(eventType: .rightMouseUp, modifiers: [.option, .shift]) else {
            fatalError("FAIL: right-click with modifiers should stay secondary")
        }
        print("  ✓ testRightClickIsSecondary passed")
    }

    static func testControlLeftClickIsSecondary() {
        print("  Running: testControlLeftClickIsSecondary...")
        guard StatusItemClick.isSecondary(eventType: .leftMouseUp, modifiers: [.control]) else {
            fatalError("FAIL: Control+left-click should be secondary (macOS convention)")
        }
        guard StatusItemClick.isSecondary(eventType: .leftMouseUp, modifiers: [.control, .shift]) else {
            fatalError("FAIL: Control+Shift+left-click should stay secondary")
        }
        print("  ✓ testControlLeftClickIsSecondary passed")
    }

    static func testPlainLeftClickIsPrimary() {
        print("  Running: testPlainLeftClickIsPrimary...")
        guard !StatusItemClick.isSecondary(eventType: .leftMouseUp, modifiers: []) else {
            fatalError("FAIL: plain left-click should be primary")
        }
        // Non-Control modifiers don't make a left-click secondary.
        for mods: NSEvent.ModifierFlags in [[.option], [.shift], [.command]] {
            guard !StatusItemClick.isSecondary(eventType: .leftMouseUp, modifiers: mods) else {
                fatalError("FAIL: left-click with \(mods) should be primary")
            }
        }
        print("  ✓ testPlainLeftClickIsPrimary passed")
    }

    static func testUnrelatedEventTypesArePrimary() {
        print("  Running: testUnrelatedEventTypesArePrimary...")
        guard !StatusItemClick.isSecondary(eventType: .otherMouseUp, modifiers: [.control]) else {
            fatalError("FAIL: other mouse buttons should not classify as secondary")
        }
        print("  ✓ testUnrelatedEventTypesArePrimary passed")
    }

    static func runAll() {
        print("StatusItemClick Unit Tests")
        print("==========================")
        testRightClickIsSecondary()
        testControlLeftClickIsSecondary()
        testPlainLeftClickIsPrimary()
        testUnrelatedEventTypesArePrimary()
        print("\nAll StatusItemClick unit tests passed ✓")
    }
}
