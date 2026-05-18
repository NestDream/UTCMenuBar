import Foundation
import UTCMenuBarLib

enum TimezoneConverterTests {

    static func testParseUTCValid() {
        print("  Running: testParseUTCValid...")
        let result = TimezoneConverter.parseUTC("2025-06-15 12:00:00")
        guard case .success(let date) = result else {
            fatalError("FAIL: should parse valid UTC string, got \(result)")
        }
        let formatted = TimezoneConverter.format(date: date, in: TimeZone(identifier: "UTC")!)
        guard formatted == "2025-06-15 12:00:00" else {
            fatalError("FAIL: round-trip format mismatch: '\(formatted)'")
        }
        print("  ✓ testParseUTCValid passed")
    }

    static func testParseUTCInvalid() {
        print("  Running: testParseUTCInvalid...")
        let cases = ["", "abc", "12:00 PM", "2025-06-15", "not a date"]
        for s in cases {
            guard case .failure(.invalidFormat) = TimezoneConverter.parseUTC(s) else {
                fatalError("FAIL: '\(s)' should be .invalidFormat")
            }
        }
        print("  ✓ testParseUTCInvalid passed")
    }

    static func testParseYearOutOfRange() {
        print("  Running: testParseYearOutOfRange...")
        guard case .failure(.yearOutOfRange) = TimezoneConverter.parseUTC("1899-01-01 00:00:00") else {
            fatalError("FAIL: year 1899 should be out of range")
        }
        guard case .failure(.yearOutOfRange) = TimezoneConverter.parseUTC("2101-01-01 00:00:00") else {
            fatalError("FAIL: year 2101 should be out of range")
        }
        // Boundaries should pass
        guard case .success = TimezoneConverter.parseUTC("1900-01-01 00:00:00") else {
            fatalError("FAIL: year 1900 should be valid")
        }
        guard case .success = TimezoneConverter.parseUTC("2100-12-31 23:59:59") else {
            fatalError("FAIL: year 2100 should be valid")
        }
        print("  ✓ testParseYearOutOfRange passed")
    }

    static func testConvertUTCToShanghai() {
        print("  Running: testConvertUTCToShanghai...")
        let result = TimezoneConverter.convertUTCToTarget("2025-06-15 12:00:00", targetTimezoneId: "Asia/Shanghai")
        guard case .success(let target) = result else {
            fatalError("FAIL: conversion failed: \(result)")
        }
        guard target == "2025-06-15 20:00:00" else {
            fatalError("FAIL: expected '2025-06-15 20:00:00', got '\(target)'")
        }
        print("  ✓ testConvertUTCToShanghai passed")
    }

    static func testConvertTargetToUTC() {
        print("  Running: testConvertTargetToUTC...")
        let result = TimezoneConverter.convertTargetToUTC("2025-06-15 20:00:00", targetTimezoneId: "Asia/Shanghai")
        guard case .success(let utc) = result else {
            fatalError("FAIL: conversion failed: \(result)")
        }
        guard utc == "2025-06-15 12:00:00" else {
            fatalError("FAIL: expected '2025-06-15 12:00:00', got '\(utc)'")
        }
        print("  ✓ testConvertTargetToUTC passed")
    }

    static func testConvertUnknownTimezone() {
        print("  Running: testConvertUnknownTimezone...")
        guard case .failure(.unknownTimezone) = TimezoneConverter.convertUTCToTarget("2025-06-15 12:00:00", targetTimezoneId: "Not/Real") else {
            fatalError("FAIL: should be .unknownTimezone")
        }
        guard case .failure(.unknownTimezone) = TimezoneConverter.convertTargetToUTC("2025-06-15 12:00:00", targetTimezoneId: "Fake/Zone") else {
            fatalError("FAIL: should be .unknownTimezone")
        }
        print("  ✓ testConvertUnknownTimezone passed")
    }

    static func testDSTSpringForwardLA() {
        print("  Running: testDSTSpringForwardLA...")
        // 2025-03-09: clocks spring forward from 2am to 3am in America/Los_Angeles.
        // UTC 10:00 = LA 02:00 during pre-DST, but on this day the valid result is 03:00
        // because 02:00-02:59 local doesn't exist.
        let result = TimezoneConverter.convertUTCToTarget("2025-03-09 10:00:00", targetTimezoneId: "America/Los_Angeles")
        guard case .success(let la) = result else {
            fatalError("FAIL: DST conversion failed")
        }
        guard la == "2025-03-09 03:00:00" else {
            fatalError("FAIL: expected '2025-03-09 03:00:00' (DST), got '\(la)'")
        }
        print("  ✓ testDSTSpringForwardLA passed")
    }

    static func testDSTFallBackLA() {
        print("  Running: testDSTFallBackLA...")
        // 2025-11-02: clocks fall back at 2:00 AM PDT → 1:00 AM PST (UTC 09:00).
        // UTC 08:30 → PDT (still -7) = 01:30
        // UTC 09:30 → PST (-8) = 01:30 (second occurrence)
        // UTC 10:00 → PST = 02:00
        let r1 = TimezoneConverter.convertUTCToTarget("2025-11-02 10:00:00", targetTimezoneId: "America/Los_Angeles")
        guard case .success(let la1) = r1 else { fatalError("FAIL: DST fall-back r1") }
        guard la1 == "2025-11-02 02:00:00" else {
            fatalError("FAIL: expected '2025-11-02 02:00:00', got '\(la1)'")
        }
        print("  ✓ testDSTFallBackLA passed")
    }

    static func testNow() {
        print("  Running: testNow...")
        guard let pair = TimezoneConverter.now(targetTimezoneId: "Asia/Tokyo") else {
            fatalError("FAIL: now() returned nil for valid tz")
        }
        guard !pair.utc.isEmpty, !pair.target.isEmpty else {
            fatalError("FAIL: now() strings should not be empty")
        }
        guard TimezoneConverter.now(targetTimezoneId: "Invalid/Zone") == nil else {
            fatalError("FAIL: now() should return nil for invalid tz")
        }
        print("  ✓ testNow passed")
    }

    static func runAll() {
        print("TimezoneConverter Unit Tests")
        print("============================")
        testParseUTCValid()
        testParseUTCInvalid()
        testParseYearOutOfRange()
        testConvertUTCToShanghai()
        testConvertTargetToUTC()
        testConvertUnknownTimezone()
        testDSTSpringForwardLA()
        testDSTFallBackLA()
        testNow()
        print("\nAll TimezoneConverter unit tests passed ✓")
    }
}
