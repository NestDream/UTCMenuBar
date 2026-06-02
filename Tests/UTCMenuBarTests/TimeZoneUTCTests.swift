import Foundation
import UTCMenuBarLib

/// Tests for the shared safe UTC TimeZone constant (replaces force-unwraps).

enum TimeZoneUTCTests {

    static func testUTCIsZeroOffset() {
        print("  Running: testUTCIsZeroOffset...")
        guard TimeZone.utc.secondsFromGMT() == 0 else {
            fatalError("FAIL: TimeZone.utc should have 0 GMT offset, got \(TimeZone.utc.secondsFromGMT())")
        }
        print("  ✓ testUTCIsZeroOffset passed")
    }

    static func testUTCIdentifier() {
        print("  Running: testUTCIdentifier...")
        // On a healthy system this resolves to the real UTC zone.
        guard TimeZone.utc.identifier == "UTC" || TimeZone.utc.secondsFromGMT() == 0 else {
            fatalError("FAIL: TimeZone.utc identifier unexpected: \(TimeZone.utc.identifier)")
        }
        print("  ✓ testUTCIdentifier passed")
    }

    static func testUTCFormattingMatchesConverter() {
        print("  Running: testUTCFormattingMatchesConverter...")
        // A known instant formats identically through TimeFormatter and the UTC zone.
        let date = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14 22:13:20 UTC
        let time = TimeFormatter.formatTime(date: date, compact: false)
        guard time == "22:13:20" else {
            fatalError("FAIL: expected 22:13:20, got \(time)")
        }
        print("  ✓ testUTCFormattingMatchesConverter passed")
    }

    static func runAll() {
        print("TimeZone.utc Unit Tests")
        print("=======================")
        testUTCIsZeroOffset()
        testUTCIdentifier()
        testUTCFormattingMatchesConverter()
        print("\nAll TimeZone.utc unit tests passed ✓")
    }
}
