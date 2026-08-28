import Foundation
import Combine

/// Backing model for the SwiftUI Settings form. Bridges the three stores and the
/// launch-at-login control, with an `isSyncing` flag so store→VM syncs don't
/// re-trigger VM→store writes (which would recurse / clobber state).
///
/// Lives in the library (not the app target) so its binding logic is unit-testable
/// with in-memory stores and a fake `LoginItemControlling`.
@MainActor
public final class SettingsViewModel2: ObservableObject {
    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore
    private let loginItem: LoginItemControlling
    private let onDisplayOptionsChanged: (DisplayOptions) -> Void
    private let displayDefaults: UserDefaults
    private var isSyncing = false
    private var styleToken: UUID?
    private var languageToken: UUID?

    @Published public var showDate: Bool {
        didSet { guard !isSyncing else { return }; saveDisplayOptions() }
    }
    @Published public var compactTime: Bool {
        didSet { guard !isSyncing else { return }; saveDisplayOptions() }
    }
    @Published public var compactDate: Bool {
        didSet { guard !isSyncing, showDate else { return }; saveDisplayOptions() }
    }
    @Published public var fontFamily: FontFamily {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.fontFamily = fontFamily } }
    }
    @Published public var fontWeight: FontWeight {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.fontWeight = fontWeight } }
    }
    @Published public var fontSize: FontSize {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.fontSize = fontSize } }
    }
    @Published public var textColor: TextColorOption {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.textColor = textColor } }
    }
    @Published public var iconPrefix: IconPrefix {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.iconPrefix = iconPrefix } }
    }
    @Published public var decorator: Decorator {
        didSet { guard !isSyncing else { return }; styleStore.update { $0.decorator = decorator } }
    }
    @Published public var appLanguage: AppLanguage {
        didSet { guard !isSyncing else { return }; languageStore.update(appLanguage) }
    }
    @Published public var customFontName: String = ""
    @Published public var language: AppLanguage = .en
    @Published public var previewText: String = ""

    @Published public var launchAtLogin: Bool {
        didSet {
            guard !isSyncing else { return }
            do {
                try loginItem.setEnabled(launchAtLogin)
                launchAtLoginError = nil
            } catch {
                launchAtLoginError = error.localizedDescription
                isSyncing = true
                launchAtLogin = loginItem.isEnabled
                isSyncing = false
            }
            launchAtLoginRequiresApproval = loginItem.requiresApproval
        }
    }
    @Published public var launchAtLoginRequiresApproval: Bool = false
    @Published public var launchAtLoginError: String?

    public init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        loginItem: LoginItemControlling,
        displayOptions: DisplayOptions,
        displayDefaults: UserDefaults = .standard,
        onDisplayOptionsChanged: @escaping (DisplayOptions) -> Void
    ) {
        self.styleStore = styleStore
        self.languageStore = languageStore
        self.loginItem = loginItem
        self.displayDefaults = displayDefaults
        self.onDisplayOptionsChanged = onDisplayOptionsChanged

        self.showDate = displayOptions.showDate
        self.compactTime = displayOptions.compactTime
        self.compactDate = displayOptions.compactDate

        let style = styleStore.current
        self.fontFamily = style.fontFamily
        self.fontWeight = style.fontWeight
        self.fontSize = style.fontSize
        self.textColor = style.textColor
        self.iconPrefix = style.iconPrefix
        self.decorator = style.decorator
        self.customFontName = style.customFontName

        self.appLanguage = languageStore.current
        self.language = languageStore.current

        self.launchAtLogin = loginItem.isEnabled
        self.launchAtLoginRequiresApproval = loginItem.requiresApproval

        updatePreview()

        styleToken = styleStore.addListener { [weak self] style in
            guard let self else { return }
            self.isSyncing = true
            self.fontFamily = style.fontFamily
            self.fontWeight = style.fontWeight
            self.fontSize = style.fontSize
            self.textColor = style.textColor
            self.iconPrefix = style.iconPrefix
            self.decorator = style.decorator
            self.customFontName = style.customFontName
            self.isSyncing = false
            self.updatePreview()
        }
        languageToken = languageStore.addListener { [weak self] lang in
            guard let self else { return }
            self.isSyncing = true
            self.language = lang
            self.appLanguage = lang
            self.isSyncing = false
        }
    }

    // Listener tokens are retained so the store API supports removal/testing;
    // this view model lives for the app's lifetime (the Settings window is
    // created once and reused), so no nonisolated-deinit cleanup is needed.

    public func label(_ key: StringKey) -> String {
        Strings.t(key, language: language)
    }

    public func updateDisplayOptions(_ opts: DisplayOptions) {
        isSyncing = true
        showDate = opts.showDate
        compactTime = opts.compactTime
        compactDate = opts.compactDate
        isSyncing = false
        updatePreview()
    }

    public func refreshLaunchAtLogin() {
        let actual = loginItem.isEnabled
        if launchAtLogin != actual {
            isSyncing = true
            launchAtLogin = actual
            isSyncing = false
        }
        launchAtLoginRequiresApproval = loginItem.requiresApproval
    }

    private func saveDisplayOptions() {
        let opts = DisplayOptions(showDate: showDate, compactTime: compactTime, compactDate: compactDate)
        opts.save(to: displayDefaults)
        onDisplayOptionsChanged(opts)
        updatePreview()
    }

    private func updatePreview() {
        let opts = DisplayOptions(showDate: showDate, compactTime: compactTime, compactDate: compactDate)
        let text = TimeFormatter.formatDisplay(date: Date(), options: opts, iconPrefix: iconPrefix)
        // Mirror the menu bar exactly, decorator included — a preview that
        // renders something other than what ships erodes trust in the control.
        previewText = decorator.prefix + text + decorator.suffix
    }
}
