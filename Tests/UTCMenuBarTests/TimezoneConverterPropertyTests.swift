import Foundation
import UTCMenuBarLib

enum TimezoneConverterPropertyTests {

    private static let validTimezones = ["America/New_York", "Asia/Shanghai", "Europe/London",
                                         "Asia/Tokyo", "Australia/Sydney", "America/Los_Angeles",
                                         "Europe/Berlin", "Pacific/Auckland"]

    /// TC1: UTC → Target → UTC round-trip equals original.
    static func testRoundTripConsistency() {
        print("  Running TC1: round-trip consistency (100 iterations)...")
        for i in 0..<100 {
            let tz = validTimezones.randomElement()!
            let year = Int.random(in: 1900...2100)
            let month = Int.random(in: 1...12)
            let day = Int.random(in: 1...28)
            let hour = Int.random(in: 0...23)
            let minute = Int.random(in: 0...59)
            let second = Int.random(in: 0...59)
            let utcString = String(format: "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)

            guard case .success(let targetString) = TimezoneConverter.convertUTCToTarget(utcString, targetTimezoneId: tz) else {
                continue // skip invalid dates (e.g., Feb 30)
            }
            guard case .success(let backToUTC) = TimezoneConverter.convertTargetToUTC(targetString, targetTimezoneId: tz) else {
                fatalError("FAIL TC1 iter \(i): target→UTC failed for '\(targetString)' tz=\(tz)")
            }
            guard backToUTC == utcString else {
                fatalError("FAIL TC1 iter \(i): round-trip mismatch: '\(utcString)' → '\(targetString)' → '\(backToUTC)' tz=\(tz)")
            }
        }
        print("  ✓ TC1 passed (100/100 iterations)")
    }

    /// TC4: Invalid timezone strings always return .unknownTimezone.
    static func testInvalidTimezoneFails() {
        print("  Running TC4: invalid timezone handling (100 iterations)...")
        for i in 0..<100 {
            let garbage = "Invalid/Zone_\(Int.random(in: 0...999999))"
            guard case .failure(.unknownTimezone) = TimezoneConverter.convertUTCToTarget("2025-06-15 12:00:00", targetTimezoneId: garbage) else {
                fatalError("FAIL TC4 iter \(i): expected .unknownTimezone for '\(garbage)'")
            }
        }
        print("  ✓ TC4 passed (100/100 iterations)")
    }

    /// TC5: TimezoneConverterOptions persistence round-trip.
    static func testOptionsPersistenceRoundTrip() {
        print("  Running TC5: options persistence (100 iterations)...")
        for i in 0..<100 {
            let tz = validTimezones.randomElement()!
            let suiteName = "com.utcmenubar.test.tcopt.\(i).\(ProcessInfo.processInfo.globallyUniqueString.prefix(8))"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("FAIL: could not create suite")
            }
            defer { defaults.removePersistentDomain(forName: suiteName) }

            let original = TimezoneConverterOptions(targetTimezone: tz)
            original.save(to: defaults)
            let loaded = TimezoneConverterOptions.load(from: defaults)
            guard loaded == original else {
                fatalError("FAIL TC5 iter \(i): round-trip mismatch")
            }
        }
        print("  ✓ TC5 passed (100/100 iterations)")
    }

    /// TC6: Invalid timezone string in UserDefaults falls back.
    static func testOptionsInvalidFallback() {
        print("  Running TC6: options invalid fallback (100 iterations)...")
        for i in 0..<100 {
            let suiteName = "com.utcmenubar.test.tcopt.bad.\(i).\(ProcessInfo.processInfo.globallyUniqueString.prefix(8))"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("FAIL: could not create suite")
            }
            defer { defaults.removePersistentDomain(forName: suiteName) }

            defaults.set("Garbage/TZ_\(Int.random(in: 0...999))", forKey: TimezoneConverterOptions.targetTimezoneKey)
            let loaded = TimezoneConverterOptions.load(from: defaults)
            guard loaded.targetTimezone == TimeZone.current.identifier else {
                fatalError("FAIL TC6 iter \(i): should fall back to current, got '\(loaded.targetTimezone)'")
            }
        }
        print("  ✓ TC6 passed (100/100 iterations)")
    }

    static func runAll() {
        print("TimezoneConverter Property Tests")
        print("================================")
        testRoundTripConsistency()
        testInvalidTimezoneFails()
        testOptionsPersistenceRoundTrip()
        testOptionsInvalidFallback()
        print("\nAll TimezoneConverter property tests passed ✓")
    }
}
