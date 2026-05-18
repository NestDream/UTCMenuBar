import AppKit
import SwiftUI
import UTCMenuBarLib

@MainActor
final class ClockPopoverViewModel: ObservableObject {
    @Published var currentTime: String = ""
    @Published var language: AppLanguage = .en
    @Published var styleOptions: StyleOptions = .default
    @Published var displayOptions: DisplayOptions = .default

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
        self.styleOptions = styleStore.current
        self.displayOptions = displayOptionsProvider()

        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateTime() }
        }

        styleStore.addListener { [weak self] style in
            self?.styleOptions = style
            self?.updateTime()
        }
        languageStore.addListener { [weak self] lang in
            self?.language = lang
        }
    }

    private func updateTime() {
        displayOptions = displayOptionsProvider()
        currentTime = TimeFormatter.formatDisplay(
            date: Date(),
            options: displayOptions,
            iconPrefix: styleOptions.iconPrefix
        )
    }
}
