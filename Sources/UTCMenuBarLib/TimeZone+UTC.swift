import Foundation

extension TimeZone {
    /// The UTC time zone, resolved safely without force-unwrapping.
    /// `TimeZone(identifier: "UTC")` is guaranteed on any healthy system; the
    /// `secondsFromGMT: 0` fallback covers a corrupted timezone database so the
    /// app degrades to a correct GMT offset instead of crashing.
    public static let utc: TimeZone = TimeZone(identifier: "UTC")
        ?? TimeZone(secondsFromGMT: 0)
        ?? .gmt
}
