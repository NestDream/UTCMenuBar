import Foundation
import UTCMenuBarLib

enum TimeFormatterPropertyTests {

    // MARK: - Helpers

    private static func randomDate() -> Date {
        let randomInterval = Double.random(in: -1_000_000_000...1_000_000_000)
        return Date(timeIntervalSince1970: randomInterval)
    }

    private static func randomDisplayOptions() -> DisplayOptions {
        return DisplayOptions(
            showDate: Bool.random(),
            compactTime: Bool.random(),
            compactDate: Bool.random()
        )
    }

    // MARK: - Property 1: showDate controls date visibility

    /// **Validates: Requirements 1.2, 1.3**
    /// For any Date and any DisplayOptions, the formatted output contains the date part
    /// if and only if showDate is true.
    static func testShowDateControlsDateVisibility() {
        print("  Running Property 1: showDate controls date visibility (100 iterations)...")
        for i in 0..<100 {
            let date = randomDate()
            let options = randomDisplayOptions()
            let output = TimeFormatter.formatDisplay(date: date, options: options)
            let datePart = TimeFormatter.formatDate(date: date, compact: options.compactDate)

            if options.showDate {
                guard output.contains(datePart) else {
                    fatalError("FAIL iteration \(i): showDate=true but output '\(output)' does not contain date '\(datePart)'")
                }
            } else {
                // When showDate is false, the date string should not appear in the output.
                // Check both compact and non-compact date formats to be thorough.
                let compactDate = TimeFormatter.formatDate(date: date, compact: true)
                let fullDate = TimeFormatter.formatDate(date: date, compact: false)
                guard !output.contains(fullDate) else {
                    fatalError("FAIL iteration \(i): showDate=false but output '\(output)' contains full date '\(fullDate)'")
                }
                guard !output.contains(compactDate) else {
                    fatalError("FAIL iteration \(i): showDate=false but output '\(output)' contains compact date '\(compactDate)'")
                }
            }
        }
        print("  ✓ Property 1 passed (100/100 iterations)")
    }

    // MARK: - Property 2: compactTime controls seconds visibility

    /// **Validates: Requirements 2.2, 2.3**
    /// For any Date and any DisplayOptions, when compactTime is true the time part
    /// matches HH:mm (no seconds); when false it matches HH:mm:ss (with seconds).
    static func testCompactTimeControlsSecondsVisibility() {
        print("  Running Property 2: compactTime controls seconds visibility (100 iterations)...")
        for i in 0..<100 {
            let date = randomDate()
            let options = randomDisplayOptions()
            let output = TimeFormatter.formatDisplay(date: date, options: options)
            let timePart = TimeFormatter.formatTime(date: date, compact: options.compactTime)

            guard output.contains(timePart) else {
                fatalError("FAIL iteration \(i): output '\(output)' does not contain expected time '\(timePart)' (compactTime=\(options.compactTime))")
            }

            if options.compactTime {
                // HH:mm format → exactly 5 chars
                guard timePart.count == 5 else {
                    fatalError("FAIL iteration \(i): compactTime=true but time '\(timePart)' is not 5 chars")
                }
            } else {
                // HH:mm:ss format → exactly 8 chars
                guard timePart.count == 8 else {
                    fatalError("FAIL iteration \(i): compactTime=false but time '\(timePart)' is not 8 chars")
                }
            }
        }
        print("  ✓ Property 2 passed (100/100 iterations)")
    }

    // MARK: - Property 3: compactDate controls date format

    /// **Validates: Requirements 3.2, 3.3**
    /// For any Date with showDate=true, when compactDate is true the date part matches
    /// MM/dd (5 chars); when false it matches yyyy-MM-dd (10 chars).
    static func testCompactDateControlsDateFormat() {
        print("  Running Property 3: compactDate controls date format (100 iterations)...")
        for i in 0..<100 {
            let date = randomDate()
            let compactDate = Bool.random()
            let options = DisplayOptions(
                showDate: true,
                compactTime: Bool.random(),
                compactDate: compactDate
            )
            let output = TimeFormatter.formatDisplay(date: date, options: options)
            let datePart = TimeFormatter.formatDate(date: date, compact: compactDate)

            guard output.contains(datePart) else {
                fatalError("FAIL iteration \(i): output '\(output)' does not contain expected date '\(datePart)' (compactDate=\(compactDate))")
            }

            if compactDate {
                // MM/dd format → exactly 5 chars
                guard datePart.count == 5 else {
                    fatalError("FAIL iteration \(i): compactDate=true but date '\(datePart)' is not 5 chars")
                }
            } else {
                // yyyy-MM-dd format → exactly 10 chars
                guard datePart.count == 10 else {
                    fatalError("FAIL iteration \(i): compactDate=false but date '\(datePart)' is not 10 chars")
                }
            }
        }
        print("  ✓ Property 3 passed (100/100 iterations)")
    }

    // MARK: - Property 5: output format structure invariant

    /// **Validates: Requirements 5.2, 5.3**
    /// For any Date and any DisplayOptions, the output always starts with "🌐 " and
    /// ends with " UTC". When showDate=true, the date part appears before the time part.
    static func testOutputFormatStructureInvariant() {
        print("  Running Property 5: output format structure invariant (100 iterations)...")
        for i in 0..<100 {
            let date = randomDate()
            let options = randomDisplayOptions()
            let output = TimeFormatter.formatDisplay(date: date, options: options)

            guard output.hasPrefix("🌐 ") else {
                fatalError("FAIL iteration \(i): output '\(output)' does not start with '🌐 '")
            }
            guard output.hasSuffix(" UTC") else {
                fatalError("FAIL iteration \(i): output '\(output)' does not end with ' UTC'")
            }

            if options.showDate {
                let datePart = TimeFormatter.formatDate(date: date, compact: options.compactDate)
                let timePart = TimeFormatter.formatTime(date: date, compact: options.compactTime)

                guard let dateRange = output.range(of: datePart),
                      let timeRange = output.range(of: timePart) else {
                    fatalError("FAIL iteration \(i): could not find date or time in output '\(output)'")
                }
                guard dateRange.lowerBound < timeRange.lowerBound else {
                    fatalError("FAIL iteration \(i): date part does not appear before time part in '\(output)'")
                }
            }
        }
        print("  ✓ Property 5 passed (100/100 iterations)")
    }

    // MARK: - Run All

    static func runAll() {
        print("TimeFormatter Property Tests")
        print("============================")
        testShowDateControlsDateVisibility()
        testCompactTimeControlsSecondsVisibility()
        testCompactDateControlsDateFormat()
        testOutputFormatStructureInvariant()
        print("\nAll TimeFormatter property tests passed ✓")
    }
}
