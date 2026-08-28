import Foundation

/// A strict `major.minor.patch` version. Anything else (missing segments,
/// suffixes like `0.0.0-dev`, non-numeric parts) fails to parse, which is what
/// keeps development builds out of the update flow.
public struct AppVersion: Comparable, Equatable, Sendable, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Accepts "1.2.0" and "v1.2.0"; returns nil for everything else.
    public static func parse(_ string: String) -> AppVersion? {
        var s = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("v") { s.removeFirst() }
        let parts = s.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        // Int.init rejects empty strings and any non-digit suffix ("0-dev").
        guard let major = Int(parts[0]), let minor = Int(parts[1]), let patch = Int(parts[2]),
              major >= 0, minor >= 0, patch >= 0 else { return nil }
        return AppVersion(major: major, minor: minor, patch: patch)
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }

    public var description: String { "\(major).\(minor).\(patch)" }
}

/// What an update prompt needs to know about the latest release.
public struct UpdateInfo: Equatable, Sendable {
    public let version: AppVersion
    public let tagName: String
    public let assetURL: URL
    public let assetName: String
    public let releasePageURL: URL

    public init(version: AppVersion, tagName: String, assetURL: URL, assetName: String, releasePageURL: URL) {
        self.version = version
        self.tagName = tagName
        self.assetURL = assetURL
        self.assetName = assetName
        self.releasePageURL = releasePageURL
    }
}

/// Pure update-check logic: GitHub release JSON parsing, version-availability
/// decisions, and auto-check throttling. Networking stays in the app target.
public enum UpdateChecker {

    /// The fixed HTTPS endpoint for the latest (non-draft, non-prerelease) release.
    public static let latestReleaseAPI = URL(string: "https://api.github.com/repos/NestDream/UTCMenuBar/releases/latest")!
    public static let releasesPageURL = URL(string: "https://github.com/NestDream/UTCMenuBar/releases")!

    private struct GitHubRelease: Decodable {
        struct Asset: Decodable {
            let name: String
            let browser_download_url: URL
        }
        let tag_name: String
        let html_url: URL
        let draft: Bool
        let prerelease: Bool
        let assets: [Asset]
    }

    /// Parses the GitHub "latest release" JSON into an UpdateInfo.
    /// Returns nil for drafts, prereleases, unparsable tags, or releases
    /// without a usable zip asset.
    public static func parseLatestRelease(json: Data) -> UpdateInfo? {
        guard let release = try? JSONDecoder().decode(GitHubRelease.self, from: json) else { return nil }
        guard !release.draft, !release.prerelease else { return nil }
        guard let version = AppVersion.parse(release.tag_name) else { return nil }
        let zips = release.assets.filter { $0.name.hasSuffix(".zip") }
        let asset = zips.first { $0.name.hasPrefix("UTCMenuBar-") } ?? zips.first
        guard let asset else { return nil }
        return UpdateInfo(
            version: version,
            tagName: release.tag_name,
            assetURL: asset.browser_download_url,
            assetName: asset.name,
            releasePageURL: release.html_url
        )
    }

    /// Decides whether `latest` should be offered to a build reporting
    /// `currentVersion`. Development builds (unparsable versions) and
    /// releases the user chose to skip get nil. Pass `skippedTag: nil` for
    /// user-initiated checks so skipping only silences the automatic ones.
    public static func availableUpdate(
        currentVersion: String,
        latest: UpdateInfo,
        skippedTag: String? = nil
    ) -> UpdateInfo? {
        guard let current = AppVersion.parse(currentVersion) else { return nil }
        guard latest.version > current else { return nil }
        if let skippedTag, skippedTag == latest.tagName { return nil }
        return latest
    }

    /// Auto-check throttle: enabled, and never checked or at least
    /// `minimumInterval` (24h by default) since the last check.
    public static func shouldAutoCheck(
        now: Date,
        preferences: UpdatePreferences,
        minimumInterval: TimeInterval = 86_400
    ) -> Bool {
        guard preferences.autoCheck else { return false }
        guard let last = preferences.lastCheckAt else { return true }
        return now.timeIntervalSince(last) >= minimumInterval
    }
}
