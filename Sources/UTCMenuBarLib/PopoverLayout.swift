import CoreGraphics

/// Pure geometry for positioning the menu-bar popover. Lives in the library
/// (not the app target) so it can be unit-tested without AppKit/NSWindow.
public enum PopoverLayout {

    /// Computes the popover's bottom-left origin: horizontally centered under the
    /// status item, just below the menu bar, then clamped to stay within the
    /// screen's visible frame (which already excludes the menu bar and notch).
    ///
    /// - Parameters:
    ///   - buttonRect: the status item button's rect in screen coordinates.
    ///   - popoverSize: the popover's content size.
    ///   - visibleFrame: the target screen's `visibleFrame`, or nil to skip clamping.
    ///   - gap: vertical gap between the menu bar and the popover top edge.
    public static func origin(
        buttonRect: CGRect,
        popoverSize: CGSize,
        visibleFrame: CGRect?,
        gap: CGFloat = 4
    ) -> CGPoint {
        var x = buttonRect.midX - popoverSize.width / 2
        var y = buttonRect.minY - popoverSize.height - gap

        if let frame = visibleFrame {
            let minX = frame.minX + gap
            let maxX = frame.maxX - popoverSize.width - gap
            if maxX >= minX {
                x = min(max(x, minX), maxX)
            }
            let minY = frame.minY + gap
            if y < minY { y = minY }
        }
        return CGPoint(x: x, y: y)
    }
}
