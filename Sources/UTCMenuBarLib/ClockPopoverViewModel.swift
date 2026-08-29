import Foundation
import Combine

@MainActor
public final class ClockPopoverViewModel: ObservableObject {
    /// The clock reading, HH:mm:ss (or HH:mm in compact mode) — no icon
    /// prefix, no suffix. The popover is a glance card with its own
    /// typographic hierarchy; menu-bar styling stays in the menu bar.
    @Published public var timeText: String = ""
    /// The full date, yyyy-MM-dd, always shown regardless of the menu bar's
    /// date toggle: the popover is the detail view.
    @Published public var dateText: String = ""
    @Published public var language: AppLanguage = .en

    private let languageStore: LanguageStore
    private let displayOptionsProvider: () -> DisplayOptions
    private var timer: Timer?
    private var languageToken: UUID?

    public init(
        languageStore: LanguageStore,
        displayOptionsProvider: @escaping () -> DisplayOptions
    ) {
        self.languageStore = languageStore
        self.displayOptionsProvider = displayOptionsProvider
        self.language = languageStore.current

        updateTime()

        languageToken = languageStore.addListener { [weak self] lang in self?.language = lang }
    }

    // No deinit cleanup: this view model is created once by PopoverController and
    // lives for the app's lifetime. Its timer is paused via stopTicking() whenever
    // the popover closes, so it never runs while hidden. (Swift 6 also forbids
    // touching the non-Sendable timer or calling the @MainActor store from a
    // nonisolated deinit, which only matters for objects that actually deallocate.)

    /// Whether the tick timer is currently running. Exposed for testing.
    public var isTicking: Bool { timer != nil }

    /// Begins ticking. Called when the popover becomes visible. Uses the same
    /// shared timer recipe as the status item (1s, or 60s in compact mode) so
    /// the two stay consistent, and the timer doesn't run while hidden.
    public func startTicking() {
        updateTime()
        timer?.invalidate()
        timer = TimerScheduling.makeAlignedTimer(compactTime: displayOptionsProvider().compactTime) { [weak self] in
            self?.updateTime()
        }
    }

    public func stopTicking() {
        timer?.invalidate()
        timer = nil
    }

    /// Recomputes the texts immediately from the current options. Exposed for testing.
    public func refresh() {
        updateTime()
    }

    private func updateTime() {
        let now = Date()
        timeText = TimeFormatter.formatTime(date: now, compact: displayOptionsProvider().compactTime)
        dateText = TimeFormatter.formatDate(date: now, compact: false)
    }
}
