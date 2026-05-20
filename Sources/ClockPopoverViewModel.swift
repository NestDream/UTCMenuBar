import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class ClockPopoverViewModel: ObservableObject {
    @Published var currentTime: String = ""
    @Published var language: AppLanguage = .en

    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore
    private let displayOptionsProvider: () -> DisplayOptions
    private var timer: Timer?

    init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        displayOptionsProvider: @escaping () -> DisplayOptions
    ) {
        self.styleStore = styleStore
        self.languageStore = languageStore
        self.displayOptionsProvider = displayOptionsProvider
        self.language = languageStore.current

        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateTime() }
        }
        RunLoop.current.add(timer!, forMode: .common)

        styleStore.addListener { [weak self] _ in self?.updateTime() }
        languageStore.addListener { [weak self] lang in self?.language = lang }
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
