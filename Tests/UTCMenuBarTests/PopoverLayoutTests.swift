import CoreGraphics
import UTCMenuBarLib

/// Tests for popover positioning geometry (centering + screen-edge/notch clamping).

enum PopoverLayoutTests {

    private static let size = CGSize(width: 260, height: 200)

    static func testCentersUnderButton() {
        print("  Running: testCentersUnderButton...")
        // Button in the middle of a roomy screen — no clamping.
        let screen = CGRect(x: 0, y: 0, width: 1440, height: 875)
        let button = CGRect(x: 700, y: 875, width: 30, height: 22)
        let origin = PopoverLayout.origin(buttonRect: button, popoverSize: size, visibleFrame: screen)
        guard abs(origin.x - (button.midX - size.width / 2)) < 0.001 else {
            fatalError("FAIL: x not centered: \(origin.x)")
        }
        guard origin.y == button.minY - size.height - 4 else {
            fatalError("FAIL: y not just below button: \(origin.y)")
        }
        print("  ✓ testCentersUnderButton passed")
    }

    static func testClampsRightEdge() {
        print("  Running: testClampsRightEdge...")
        // Status item near the right edge: naive centering would overflow maxX.
        let screen = CGRect(x: 0, y: 0, width: 1440, height: 875)
        let button = CGRect(x: 1430, y: 875, width: 30, height: 22)
        let origin = PopoverLayout.origin(buttonRect: button, popoverSize: size, visibleFrame: screen)
        guard origin.x + size.width <= screen.maxX - 4 + 0.001 else {
            fatalError("FAIL: popover overflows right edge: \(origin.x + size.width) > \(screen.maxX)")
        }
        print("  ✓ testClampsRightEdge passed")
    }

    static func testClampsLeftEdge() {
        print("  Running: testClampsLeftEdge...")
        // Multi-display: screen origin offset negative, button at far left.
        let screen = CGRect(x: -1440, y: 0, width: 1440, height: 875)
        let button = CGRect(x: -1438, y: 875, width: 30, height: 22)
        let origin = PopoverLayout.origin(buttonRect: button, popoverSize: size, visibleFrame: screen)
        guard origin.x >= screen.minX + 4 - 0.001 else {
            fatalError("FAIL: popover overflows left edge: \(origin.x) < \(screen.minX)")
        }
        print("  ✓ testClampsLeftEdge passed")
    }

    static func testClampsTopIntoVisibleFrame() {
        print("  Running: testClampsTopIntoVisibleFrame...")
        // visibleFrame.minY high (large dock/insets); ensure y never goes below it.
        let screen = CGRect(x: 0, y: 100, width: 1440, height: 700)
        let button = CGRect(x: 700, y: 120, width: 30, height: 22)
        let origin = PopoverLayout.origin(buttonRect: button, popoverSize: size, visibleFrame: screen)
        guard origin.y >= screen.minY + 4 - 0.001 else {
            fatalError("FAIL: popover y below visible frame: \(origin.y) < \(screen.minY)")
        }
        print("  ✓ testClampsTopIntoVisibleFrame passed")
    }

    static func testNoClampWhenVisibleFrameNil() {
        print("  Running: testNoClampWhenVisibleFrameNil...")
        let button = CGRect(x: 1430, y: 875, width: 30, height: 22)
        let origin = PopoverLayout.origin(buttonRect: button, popoverSize: size, visibleFrame: nil)
        guard abs(origin.x - (button.midX - size.width / 2)) < 0.001 else {
            fatalError("FAIL: with nil frame, x should be raw centered: \(origin.x)")
        }
        print("  ✓ testNoClampWhenVisibleFrameNil passed")
    }

    static func runAll() {
        print("PopoverLayout Unit Tests")
        print("========================")
        testCentersUnderButton()
        testClampsRightEdge()
        testClampsLeftEdge()
        testClampsTopIntoVisibleFrame()
        testNoClampWhenVisibleFrameNil()
        print("\nAll PopoverLayout unit tests passed ✓")
    }
}
