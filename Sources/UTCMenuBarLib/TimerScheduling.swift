import Foundation

/// Pure helpers for menu-bar tick scheduling, extracted so the timing logic is
/// testable without a running RunLoop.
public enum TimerScheduling {

    /// The repeating interval to use for the status-item tick.
    /// - When seconds are visible (`compactTime == false`) we tick every second.
    /// - When only HH:mm is shown we tick once a minute.
    public static func interval(compactTime: Bool) -> TimeInterval {
        compactTime ? 60.0 : 1.0
    }

    /// Seconds remaining until the next aligned boundary for the given interval,
    /// measured from `date`'s position within the current minute.
    /// - For a 1s interval the result is the sub-second remainder to the next whole second.
    /// - For a 60s interval the result is the seconds remaining to the top of the next minute.
    /// Always returns a value in `(0, interval]` so a freshly scheduled timer fires
    /// on the boundary rather than `interval` seconds after an arbitrary start moment.
    public static func delayToNextBoundary(
        after date: Date,
        interval: TimeInterval,
        calendar: Calendar = TimerScheduling.utcCalendar
    ) -> TimeInterval {
        guard interval > 0 else { return 0 }
        let seconds = Double(calendar.component(.second, from: date))
        let nanos = Double(calendar.component(.nanosecond, from: date)) / 1_000_000_000.0
        let secondsIntoMinute = seconds + nanos

        if interval <= 1.0 {
            let frac = secondsIntoMinute - secondsIntoMinute.rounded(.down)
            let remainder = 1.0 - frac
            return remainder == 0 ? 1.0 : remainder
        } else {
            let remainder = interval - secondsIntoMinute.truncatingRemainder(dividingBy: interval)
            return remainder == 0 ? interval : remainder
        }
    }

    /// Timer tolerance for a repeating tick. A non-zero tolerance lets the
    /// system coalesce wakeups with other work (saving energy for a process
    /// that otherwise wakes every second, forever). Tolerance only delays a
    /// fire, never advances it, so the cap keeps the displayed value from
    /// ever being visibly stale: 10% of the interval, at most 1.5s.
    public static func tolerance(for interval: TimeInterval) -> TimeInterval {
        guard interval > 0 else { return 0 }
        return min(interval * 0.1, 1.5)
    }

    /// The one shared recipe for the app's clock tick, used by both the status
    /// item and the popover so their cadences can't drift apart: a repeating
    /// timer whose first fire lands on the next boundary (whole second, or top
    /// of the minute in compact mode), with tolerance for wakeup coalescing.
    /// Repeating fire dates derive from the original fire date, so per-fire
    /// tolerance never accumulates drift. The returned timer is already added
    /// to the main run loop in `.common` mode (so it ticks during menu and
    /// event tracking); callers keep it to invalidate later.
    @MainActor
    public static func makeAlignedTimer(
        compactTime: Bool,
        onTick: @escaping @MainActor () -> Void
    ) -> Timer {
        let interval = Self.interval(compactTime: compactTime)
        let delay = Self.delayToNextBoundary(after: Date(), interval: interval)
        let timer = Timer(fire: Date().addingTimeInterval(delay), interval: interval, repeats: true) { _ in
            // Timers added to the main run loop fire on the main thread.
            MainActor.assumeIsolated { onTick() }
        }
        timer.tolerance = Self.tolerance(for: interval)
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    public static let utcCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .utc
        return c
    }()
}
