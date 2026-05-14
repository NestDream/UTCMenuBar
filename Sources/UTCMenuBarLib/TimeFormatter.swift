import Foundation

public enum TimeFormatter {

    /// Format the time portion of a date.
    /// - compact=false → "HH:mm:ss"
    /// - compact=true  → "HH:mm"
    public static func formatTime(date: Date, compact: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = compact ? "HH:mm" : "HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /// Format the date portion of a date.
    /// - compact=false → "yyyy-MM-dd"
    /// - compact=true  → "MM/dd"
    public static func formatDate(date: Date, compact: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = compact ? "MM/dd" : "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    /// Format the full menu bar display string.
    /// Always starts with "🌐 " and ends with " UTC".
    /// When showDate=true: "🌐 {date} {time} UTC"
    /// When showDate=false: "🌐 {time} UTC"
    public static func formatDisplay(date: Date, options: DisplayOptions) -> String {
        let timePart = formatTime(date: date, compact: options.compactTime)
        if options.showDate {
            let datePart = formatDate(date: date, compact: options.compactDate)
            return "🌐 \(datePart) \(timePart) UTC"
        } else {
            return "🌐 \(timePart) UTC"
        }
    }
}
