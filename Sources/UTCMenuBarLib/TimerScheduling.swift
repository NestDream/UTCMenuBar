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

    public static let utcCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .utc
        return c
    }()
}
