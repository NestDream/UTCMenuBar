import Foundation
import UTCMenuBarLib

/// Tests for the pure timer-scheduling math (interval selection + boundary alignment).

enum TimerSchedulingTests {

    private static func utcDate(_ string: String) -> Date {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = .utc
        guard let d = f.date(from: string) else { fatalError("FAIL: bad test date \(string)") }
        return d
    }

    static func testInterval() {
        print("  Running: testInterval...")
        guard TimerScheduling.interval(compactTime: false) == 1.0 else {
            fatalError("FAIL: non-compact interval should be 1s")
        }
        guard TimerScheduling.interval(compactTime: true) == 60.0 else {
            fatalError("FAIL: compact interval should be 60s")
        }
        print("  ✓ testInterval passed")
    }

    static func testDelayToNextMinuteBoundary() {
        print("  Running: testDelayToNextMinuteBoundary...")
        // 14:30:45 → 15 seconds to the top of 14:31
        let d = utcDate("2025-06-15 14:30:45")
        let delay = TimerScheduling.delayToNextBoundary(after: d, interval: 60.0)
        guard abs(delay - 15.0) < 0.001 else {
            fatalError("FAIL: expected 15s to next minute, got \(delay)")
        }
        print("  ✓ testDelayToNextMinuteBoundary passed")
    }

    static func testDelayAtExactMinuteBoundaryIsFullInterval() {
        print("  Running: testDelayAtExactMinuteBoundaryIsFullInterval...")
        // Exactly on the boundary → next fire a full minute later (never 0).
        let d = utcDate("2025-06-15 14:30:00")
        let delay = TimerScheduling.delayToNextBoundary(after: d, interval: 60.0)
        guard abs(delay - 60.0) < 0.001 else {
            fatalError("FAIL: at boundary expected 60s, got \(delay)")
        }
        print("  ✓ testDelayAtExactMinuteBoundaryIsFullInterval passed")
    }

    static func testDelayToNextSecond() {
        print("  Running: testDelayToNextSecond...")
        // On a whole second, the next 1s fire is a full second away (never 0).
        let d = utcDate("2025-06-15 14:30:45")
        let delay = TimerScheduling.delayToNextBoundary(after: d, interval: 1.0)
        guard delay > 0 && delay <= 1.0 else {
            fatalError("FAIL: 1s delay should be in (0, 1], got \(delay)")
        }
        print("  ✓ testDelayToNextSecond passed")
    }

    static func testDelayBoundedByInterval() {
        print("  Running: testDelayBoundedByInterval (60 iterations across a minute)...")
        for second in 0..<60 {
            let d = utcDate(String(format: "2025-06-15 14:30:%02d", second))
            let delay = TimerScheduling.delayToNextBoundary(after: d, interval: 60.0)
            guard delay > 0 && delay <= 60.0 else {
                fatalError("FAIL: second \(second) delay out of (0,60]: \(delay)")
            }
            // delay + secondsIntoMinute should land exactly on 60 (or 0 case → 60)
            let expected = second == 0 ? 60.0 : Double(60 - second)
            guard abs(delay - expected) < 0.001 else {
                fatalError("FAIL: second \(second) expected \(expected), got \(delay)")
            }
        }
        print("  ✓ testDelayBoundedByInterval passed")
    }

    static func runAll() {
        print("TimerScheduling Unit Tests")
        print("==========================")
        testInterval()
        testDelayToNextMinuteBoundary()
        testDelayAtExactMinuteBoundaryIsFullInterval()
        testDelayToNextSecond()
        testDelayBoundedByInterval()
        print("\nAll TimerScheduling unit tests passed ✓")
    }
}
