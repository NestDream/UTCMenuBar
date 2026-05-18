import Foundation

public enum TimezoneConverter {

    public enum ConversionError: Error, Equatable, Sendable {
        case invalidFormat
        case unknownTimezone
        case yearOutOfRange
    }

    public static let formatPattern = "yyyy-MM-dd HH:mm:ss"

    public static func parseUTC(_ string: String) -> Result<Date, ConversionError> {
        parse(string, timeZone: TimeZone(identifier: "UTC")!)
    }

    public static func parseInTimezone(_ string: String, timezone: TimeZone) -> Result<Date, ConversionError> {
        parse(string, timeZone: timezone)
    }

    public static func format(date: Date, in timezone: TimeZone) -> String {
        let formatter = posixFormatter()
        formatter.timeZone = timezone
        return formatter.string(from: date)
    }

    public static func convertUTCToTarget(_ utcString: String, targetTimezoneId: String) -> Result<String, ConversionError> {
        guard let tz = TimeZone(identifier: targetTimezoneId) else {
            return .failure(.unknownTimezone)
        }
        switch parseUTC(utcString) {
        case .success(let date):
            return .success(format(date: date, in: tz))
        case .failure(let err):
            return .failure(err)
        }
    }

    public static func convertTargetToUTC(_ targetString: String, targetTimezoneId: String) -> Result<String, ConversionError> {
        guard let tz = TimeZone(identifier: targetTimezoneId) else {
            return .failure(.unknownTimezone)
        }
        switch parseInTimezone(targetString, timezone: tz) {
        case .success(let date):
            return .success(format(date: date, in: TimeZone(identifier: "UTC")!))
        case .failure(let err):
            return .failure(err)
        }
    }

    public static func now(targetTimezoneId: String) -> (utc: String, target: String)? {
        guard let tz = TimeZone(identifier: targetTimezoneId) else { return nil }
        let date = Date()
        return (
            utc: format(date: date, in: TimeZone(identifier: "UTC")!),
            target: format(date: date, in: tz)
        )
    }

    private static func parse(_ string: String, timeZone: TimeZone) -> Result<Date, ConversionError> {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.invalidFormat) }

        let formatter = posixFormatter()
        formatter.timeZone = timeZone

        guard let date = formatter.date(from: trimmed) else {
            return .failure(.invalidFormat)
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let year = calendar.component(.year, from: date)
        guard (1900...2100).contains(year) else {
            return .failure(.yearOutOfRange)
        }

        return .success(date)
    }

    private static func posixFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = formatPattern
        return f
    }
}
