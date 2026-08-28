import AppKit

/// Pure classification of status-item clicks, extracted so the left/right/
/// Control-click routing is unit-testable without an NSStatusItem.
public enum StatusItemClick {
    /// Whether the event should open the context menu instead of the popover.
    /// True for a right-click, and for Control+left-click (the macOS
    /// convention for a secondary click).
    public static func isSecondary(
        eventType: NSEvent.EventType,
        modifiers: NSEvent.ModifierFlags
    ) -> Bool {
        if eventType == .rightMouseUp { return true }
        return eventType == .leftMouseUp && modifiers.contains(.control)
    }
}
