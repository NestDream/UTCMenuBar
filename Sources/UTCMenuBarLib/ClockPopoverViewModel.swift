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

    /// Begins ticking. Called when the popover becomes visible. The interval
    /// matches the menu-bar cadence (1s, or 60s in compact mode) so the popover
    /// and status item stay consistent and the timer doesn't run while hidden.
    /// A single repeating timer whose first fire lands on the next boundary —
    /// repeating fire dates are computed from the original fire date, so the
    /// per-fire tolerance never accumulates drift.
    public func startTicking() {
        updateTime()
        timer?.invalidate()
        let interval = TimerScheduling.interval(compactTime: displayOptionsProvider().compactTime)
        let delay = TimerScheduling.delayToNextBoundary(after: Date(), interval: interval)
        let tick = Timer(fire: Date().addingTimeInterval(delay), interval: interval, repeats: true) { [weak self] _ in
            // Timers added to the main run loop fire on the main thread.
            MainActor.assumeIsolated { self?.updateTime() }
        }
        tick.tolerance = TimerScheduling.tolerance(for: interval)
        timer = tick
        RunLoop.main.add(tick, forMode: .common)
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
