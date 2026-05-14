import AppKit

/// Pure mapping between StyleOptions enum values and control selection indices,
/// extracted to make the Settings window's logic testable without an NSWindow.
public enum SettingsViewModel {

    /// Index of `value` within `T.allCases`. Returns 0 if not found
    /// (impossible for a valid CaseIterable value, but keeps the API non-optional).
    public static func selectedIndex<T: CaseIterable & Equatable>(_ value: T) -> Int {
        let cases = Array(T.allCases)
        return cases.firstIndex(of: value) ?? 0
    }

    /// Looks up the case at `index` in `T.allCases`. Returns nil when out of bounds.
    public static func value<T: CaseIterable>(at index: Int, of type: T.Type) -> T? {
        let cases = Array(T.allCases)
        guard cases.indices.contains(index) else { return nil }
        return cases[index]
    }

    /// Renders the styled string the menu bar would display, used as the live preview.
    public static func previewAttributedString(
        style: StyleOptions,
        sample: String = "🌐 14:30:25 UTC"
    ) -> NSAttributedString {
        StyledTextBuilder.buildAttributedString(text: sample, style: style)
    }
}
