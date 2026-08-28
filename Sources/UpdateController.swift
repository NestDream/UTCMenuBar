import AppKit
import UTCMenuBarLib

/// Drives the in-app update flow: query GitHub's latest release, prompt,
/// download, validate, swap the bundle, and relaunch. All decisions
/// (version comparison, asset choice, throttling) live in UTCMenuBarLib's
/// UpdateChecker; this class owns only networking, files, and UI.
///
/// The app deliberately does not declare LSFileQuarantineEnabled, so its own
/// downloads carry no quarantine flag: after the one manual first install,
/// updates never re-trigger Gatekeeper.
@MainActor
final class UpdateController {

    enum UpdateError: Error {
        case badResponse
        case noUsableRelease
        case unpackFailed
        case validationFailed
        case cannotReplace
        case replaceFailed(underlying: Error)
    }

    private let languageStore: LanguageStore
    private let defaults: UserDefaults
    private var isBusy = false
    private var progressPanel: NSPanel?

    init(languageStore: LanguageStore, defaults: UserDefaults = .standard) {
        self.languageStore = languageStore
        self.defaults = defaults
    }

    private var lang: AppLanguage { languageStore.current }

    func checkForUpdates(userInitiated: Bool) {
        guard !isBusy else { return }
        Task { await performCheck(userInitiated: userInitiated) }
    }

    private func performCheck(userInitiated: Bool) async {
        var prefs = UpdatePreferences.load(from: defaults)
        prefs.lastCheckAt = Date()
        prefs.save(to: defaults)

        do {
            var request = URLRequest(url: UpdateChecker.latestReleaseAPI)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw UpdateError.badResponse
            }
            guard let latest = UpdateChecker.parseLatestRelease(json: data) else {
                throw UpdateError.noUsableRelease
            }
            // Skipping a version only silences automatic checks.
            let skipped = userInitiated ? nil : prefs.skippedTag
            guard let update = UpdateChecker.availableUpdate(
                currentVersion: BundleInfo.shortVersion,
                latest: latest,
                skippedTag: skipped
            ) else {
                if userInitiated { showUpToDate() }
                return
            }
            presentUpdatePrompt(update)
        } catch {
            if userInitiated { showFailure(error) }
        }
    }

    // MARK: - Prompts

    private func presentUpdatePrompt(_ update: UpdateInfo) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = Strings.t(.updateAvailableTitle, language: lang)
        alert.informativeText = Strings.formatUpdateAvailable(
            newVersion: update.version.description,
            currentVersion: BundleInfo.shortVersion,
            language: lang
        )
        alert.addButton(withTitle: Strings.t(.updateInstall, language: lang))
        alert.addButton(withTitle: Strings.t(.updateViewRelease, language: lang))
        alert.addButton(withTitle: Strings.t(.updateLater, language: lang))
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = Strings.t(.updateSkipVersion, language: lang)

        let choice = alert.runModal()
        if alert.suppressionButton?.state == .on {
            var prefs = UpdatePreferences.load(from: defaults)
            prefs.skippedTag = update.tagName
            prefs.save(to: defaults)
        }
        switch choice {
        case .alertFirstButtonReturn:
            downloadAndInstall(update)
        case .alertSecondButtonReturn:
            NSWorkspace.shared.open(update.releasePageURL)
        default:
            break
        }
    }

    private func showUpToDate() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = Strings.t(.updateUpToDateTitle, language: lang)
        alert.informativeText = Strings.formatUpToDate(currentVersion: BundleInfo.shortVersion, language: lang)
        alert.runModal()
    }

    private func showFailure(_ error: Error) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = Strings.t(.updateFailedTitle, language: lang)
        if case UpdateError.cannotReplace = error {
            alert.informativeText = Strings.t(.updateCannotReplace, language: lang)
        } else {
            alert.informativeText = String(describing: error)
        }
        alert.addButton(withTitle: Strings.t(.updateViewRelease, language: lang))
        alert.addButton(withTitle: Strings.t(.commonOK, language: lang))
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(UpdateChecker.releasesPageURL)
        }
    }

    // MARK: - Download and install

    private func downloadAndInstall(_ update: UpdateInfo) {
        isBusy = true
        showProgress()
        Task {
            do {
                let newApp = try await fetchAndValidate(update)
                try replaceAndRelaunch(with: newApp)
            } catch {
                hideProgress()
                isBusy = false
                showFailure(error)
            }
        }
    }

    private func fetchAndValidate(_ update: UpdateInfo) async throws -> URL {
        let (tmp, response) = try await URLSession.shared.download(from: update.assetURL)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UpdateError.badResponse
        }

        let fm = FileManager.default
        let workDir = fm.temporaryDirectory.appendingPathComponent(
            "UTCMenuBarUpdate-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: workDir, withIntermediateDirectories: true)
        let zipURL = workDir.appendingPathComponent(update.assetName)
        try fm.moveItem(at: tmp, to: zipURL)

        let unzipDir = workDir.appendingPathComponent("unzipped", isDirectory: true)
        try fm.createDirectory(at: unzipDir, withIntermediateDirectories: true)
        try await runDitto(zip: zipURL, destination: unzipDir)

        let apps = try fm.contentsOfDirectory(at: unzipDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "app" }
        guard apps.count == 1, let newApp = apps.first else {
            throw UpdateError.unpackFailed
        }
        // The new bundle must be this app at exactly the offered version.
        guard let bundle = Bundle(url: newApp),
              bundle.bundleIdentifier == Bundle.main.bundleIdentifier,
              (bundle.infoDictionary?["CFBundleShortVersionString"] as? String) == update.version.description
        else {
            throw UpdateError.validationFailed
        }
        return newApp
    }

    private func runDitto(zip: URL, destination: URL) async throws {
        let ok: Bool = try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            process.arguments = ["-x", "-k", zip.path, destination.path]
            process.terminationHandler = { proc in
                continuation.resume(returning: proc.terminationStatus == 0)
            }
            do {
                try process.run()
            } catch {
                // run() threw, so the termination handler will never fire.
                continuation.resume(throwing: error)
            }
        }
        guard ok else { throw UpdateError.unpackFailed }
    }

    private func replaceAndRelaunch(with newApp: URL) throws {
        let destination = Bundle.main.bundleURL
        let fm = FileManager.default
        // A quarantined app launched from ~/Downloads runs from a read-only
        // translocation mount; replacing that copy is impossible and the real
        // bundle is elsewhere. Same for install locations we cannot write.
        guard !destination.path.contains("/AppTranslocation/"),
              destination.pathExtension == "app",
              fm.isWritableFile(atPath: destination.deletingLastPathComponent().path)
        else {
            throw UpdateError.cannotReplace
        }

        // Old bundle goes to the Trash (recoverable), new one takes its place.
        try fm.trashItem(at: destination, resultingItemURL: nil)
        do {
            try fm.moveItem(at: newApp, to: destination)
        } catch {
            // Temp dir may sit on another volume; fall back to copying.
            do {
                try fm.copyItem(at: newApp, to: destination)
            } catch {
                throw UpdateError.replaceFailed(underlying: error)
            }
        }

        // Spawn the new instance, then quit. `-n` forces a fresh instance even
        // though this (old) one is still running for a moment.
        let relaunch = Process()
        relaunch.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        relaunch.arguments = ["-n", destination.path]
        try? relaunch.run()
        NSApp.terminate(nil)
    }

    // MARK: - Progress panel

    private func showProgress() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 64),
            styleMask: [.titled],
            backing: .buffered, defer: false)
        panel.title = "UTCMenuBar"
        panel.isReleasedWhenClosed = false

        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.startAnimation(nil)
        let label = NSTextField(labelWithString: Strings.t(.updateDownloading, language: lang))
        let stack = NSStackView(views: [spinner, label])
        stack.orientation = .horizontal
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        panel.contentView = stack

        panel.center()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        progressPanel = panel
    }

    private func hideProgress() {
        progressPanel?.orderOut(nil)
        progressPanel = nil
    }
}
