import Foundation
import Combine

@MainActor
public final class ClockPopoverViewModel: ObservableObject {
    @Published public var currentTime: String = ""
    @Published public var language: AppLanguage = .en

    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore
    private let displayOptionsProvider: () -> DisplayOptions
    private var timer: Timer?
    private var styleToken: UUID?
    private var languageToken: UUID?

    public init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        displayOptionsProvider: @escaping () -> DisplayOptions
    ) {
        self.styleStore = styleStore
        self.languageStore = languageStore
        self.displayOptionsProvider = displayOptionsProvider
        self.language = languageStore.current

        updateTime()

        styleToken = styleStore.addListener { [weak self] _ in self?.updateTime() }
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

    /// Recomputes `currentTime` immediately from the current options. Exposed for testing.
    public func refresh() {
        updateTime()
    }

    private func updateTime() {
        let opts = displayOptionsProvider()
        currentTime = TimeFormatter.formatDisplay(
            date: Date(),
            options: opts,
            iconPrefix: styleStore.current.iconPrefix
        )
    }
}
