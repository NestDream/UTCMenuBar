import Foundation
import UTCMenuBarLib

/// Unit tests for TimeFormatter with specific format examples from the design matrix.
/// **Validates: Requirements 1.2, 1.3, 2.2, 2.3, 3.2, 3.3**

enum TimeFormatterTests {

    /// Create a fixed date: January 15, 2024 at 14:30:25 UTC
    private static func fixedDate() -> Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.second = 25
        components.timeZone = TimeZone(identifier: "UTC")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        guard let date = calendar.date(from: components) else {
            fatalError("FAIL: Could not create fixed test date")
        }
        return date
    }

    /// Test 1: showDate=false, compactTime=false → "🌐 14:30:25 UTC"
    static func testFullTimeOnly() {
        print("  Running: showDate=false, compactTime=false...")
        let options = DisplayOptions(showDate: false, compactTime: false, compactDate: false)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 14:30:25 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    /// Test 2: showDate=false, compactTime=true → "🌐 14:30 UTC"
    static func testCompactTimeOnly() {
        print("  Running: showDate=false, compactTime=true...")
        let options = DisplayOptions(showDate: false, compactTime: true, compactDate: false)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 14:30 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    /// Test 3: showDate=true, compactTime=false, compactDate=false → "🌐 2024-01-15 14:30:25 UTC"
    static func testFullDateFullTime() {
        print("  Running: showDate=true, compactTime=false, compactDate=false...")
        let options = DisplayOptions(showDate: true, compactTime: false, compactDate: false)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 2024-01-15 14:30:25 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    /// Test 4: showDate=true, compactTime=false, compactDate=true → "🌐 01/15 14:30:25 UTC"
    static func testCompactDateFullTime() {
        print("  Running: showDate=true, compactTime=false, compactDate=true...")
        let options = DisplayOptions(showDate: true, compactTime: false, compactDate: true)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 01/15 14:30:25 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    /// Test 5: showDate=true, compactTime=true, compactDate=false → "🌐 2024-01-15 14:30 UTC"
    static func testFullDateCompactTime() {
        print("  Running: showDate=true, compactTime=true, compactDate=false...")
        let options = DisplayOptions(showDate: true, compactTime: true, compactDate: false)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 2024-01-15 14:30 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    /// Test 6: showDate=true, compactTime=true, compactDate=true → "🌐 01/15 14:30 UTC"
    static func testCompactDateCompactTime() {
        print("  Running: showDate=true, compactTime=true, compactDate=true...")
        let options = DisplayOptions(showDate: true, compactTime: true, compactDate: true)
        let result = TimeFormatter.formatDisplay(date: fixedDate(), options: options)
        let expected = "🌐 01/15 14:30 UTC"
        guard result == expected else {
            fatalError("FAIL: Expected '\(expected)', got '\(result)'")
        }
        print("  ✓ passed")
    }

    static func runAll() {
        print("TimeFormatter Unit Tests")
        print("========================")
        testFullTimeOnly()
        testCompactTimeOnly()
        testFullDateFullTime()
        testCompactDateFullTime()
        testFullDateCompactTime()
        testCompactDateCompactTime()
        print("\nAll TimeFormatter unit tests passed ✓")
    }
}
