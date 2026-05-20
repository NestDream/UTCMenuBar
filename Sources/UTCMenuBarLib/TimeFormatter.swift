import Foundation

public enum TimeFormatter {

    private static let utcZone = TimeZone(identifier: "UTC")!

    private static let fullTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.timeZone = utcZone
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let compactTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = utcZone
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = utcZone
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let compactDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        f.timeZone = utcZone
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    public static func formatTime(date: Date, compact: Bool) -> String {
        (compact ? compactTimeFormatter : fullTimeFormatter).string(from: date)
    }

    public static func formatDate(date: Date, compact: Bool) -> String {
        (compact ? compactDateFormatter : fullDateFormatter).string(from: date)
    }

    public static func formatDisplay(
        date: Date,
        options: DisplayOptions,
        iconPrefix: IconPrefix = .globe
    ) -> String {
        let timePart = formatTime(date: date, compact: options.compactTime)
        let prefix = iconPrefix.prefix
        if options.showDate {
            let datePart = formatDate(date: date, compact: options.compactDate)
            return "\(prefix)\(datePart) \(timePart) UTC"
        } else {
            return "\(prefix)\(timePart) UTC"
        }
    }
}
