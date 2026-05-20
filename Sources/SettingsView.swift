import SwiftUI
import UTCMenuBarLib

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel2
    let onPickCustomFont: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Toggle(viewModel.label(.menuShowDate), isOn: $viewModel.showDate)
                    Toggle(viewModel.label(.menuCompactTime), isOn: $viewModel.compactTime)
                    Toggle(viewModel.label(.menuCompactDate), isOn: $viewModel.compactDate)
                        .disabled(!viewModel.showDate)
                }

                Section(viewModel.label(.menuAppearance)) {
                    Picker(viewModel.label(.settingsLabelFont), selection: $viewModel.fontFamily) {
                        ForEach(FontFamily.allCases, id: \.self) { family in
                            if family == .custom && !viewModel.customFontName.isEmpty {
                                Text(Strings.formatCustomFont(name: viewModel.customFontName, language: viewModel.language))
                                    .tag(family)
                            } else {
                                Text(family.displayName(for: viewModel.language))
                                    .tag(family)
                            }
                        }
                    }
                    .onChange(of: viewModel.fontFamily) { newValue in
                        if newValue == .custom {
                            onPickCustomFont()
                        }
                    }

                    Picker(viewModel.label(.settingsLabelWeight), selection: $viewModel.fontWeight) {
                        ForEach(FontWeight.allCases, id: \.self) { w in
                            Text(w.displayName(for: viewModel.language)).tag(w)
                        }
                    }

                    Picker(viewModel.label(.settingsLabelSize), selection: $viewModel.fontSize) {
                        ForEach(FontSize.allCases, id: \.self) { s in
                            Text(s.displayName(for: viewModel.language)).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker(viewModel.label(.settingsLabelColor), selection: $viewModel.textColor) {
                        ForEach(TextColorOption.allCases, id: \.self) { c in
                            Text(c.displayName(for: viewModel.language)).tag(c)
                        }
                    }

                    Picker(viewModel.label(.settingsLabelIcon), selection: $viewModel.iconPrefix) {
                        ForEach(IconPrefix.allCases, id: \.self) { p in
                            Text(p.displayName(for: viewModel.language)).tag(p)
                        }
                    }

                    Picker(viewModel.label(.settingsLabelDecorator), selection: $viewModel.decorator) {
                        ForEach(Decorator.allCases, id: \.self) { d in
                            Text(d.displayName(for: viewModel.language)).tag(d)
                        }
                    }
                }

                Section(viewModel.label(.settingsLabelLanguage)) {
                    Picker(viewModel.label(.settingsLabelLanguage), selection: $viewModel.appLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.nativeName).tag(lang)
                        }
                    }
                    .labelsHidden()
                }

                Section(viewModel.label(.settingsLabelPreview)) {
                    HStack {
                        Spacer()
                        Text(viewModel.previewText)
                            .font(.system(size: 18, design: .monospaced))
                            .padding(.vertical, 8)
                        Spacer()
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 380, height: 480)
    }
}

@MainActor
final class SettingsViewModel2: ObservableObject {
    private let styleStore: StyleOptionsStore
    private let languageStore: LanguageStore
    private let onDisplayOptionsChanged: (DisplayOptions) -> Void

    @Published var showDate: Bool {
        didSet { saveDisplayOptions() }
    }
    @Published var compactTime: Bool {
        didSet { saveDisplayOptions() }
    }
    @Published var compactDate: Bool {
        didSet { saveDisplayOptions() }
    }
    @Published var fontFamily: FontFamily {
        didSet { if fontFamily != .custom { styleStore.update { $0.fontFamily = fontFamily } } }
    }
    @Published var fontWeight: FontWeight {
        didSet { styleStore.update { $0.fontWeight = fontWeight } }
    }
    @Published var fontSize: FontSize {
        didSet { styleStore.update { $0.fontSize = fontSize } }
    }
    @Published var textColor: TextColorOption {
        didSet { styleStore.update { $0.textColor = textColor } }
    }
    @Published var iconPrefix: IconPrefix {
        didSet { styleStore.update { $0.iconPrefix = iconPrefix } }
    }
    @Published var decorator: Decorator {
        didSet { styleStore.update { $0.decorator = decorator } }
    }
    @Published var appLanguage: AppLanguage {
        didSet { languageStore.update(appLanguage) }
    }
    @Published var customFontName: String = ""
    @Published var language: AppLanguage = .en
    @Published var previewText: String = ""

    init(
        styleStore: StyleOptionsStore,
        languageStore: LanguageStore,
        displayOptions: DisplayOptions,
        onDisplayOptionsChanged: @escaping (DisplayOptions) -> Void
    ) {
        self.styleStore = styleStore
        self.languageStore = languageStore
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

        updatePreview()

        styleStore.addListener { [weak self] style in
            guard let self else { return }
            self.fontFamily = style.fontFamily
            self.fontWeight = style.fontWeight
            self.fontSize = style.fontSize
            self.textColor = style.textColor
            self.iconPrefix = style.iconPrefix
            self.decorator = style.decorator
            self.customFontName = style.customFontName
            self.updatePreview()
        }
        languageStore.addListener { [weak self] lang in
            self?.language = lang
            self?.appLanguage = lang
        }
    }

    func label(_ key: StringKey) -> String {
        Strings.t(key, language: language)
    }

    func updateDisplayOptions(_ opts: DisplayOptions) {
        showDate = opts.showDate
        compactTime = opts.compactTime
        compactDate = opts.compactDate
    }

    private func saveDisplayOptions() {
        let opts = DisplayOptions(showDate: showDate, compactTime: compactTime, compactDate: compactDate)
        opts.save()
        onDisplayOptionsChanged(opts)
        updatePreview()
    }

    private func updatePreview() {
        let opts = DisplayOptions(showDate: showDate, compactTime: compactTime, compactDate: compactDate)
        previewText = TimeFormatter.formatDisplay(date: Date(), options: opts, iconPrefix: iconPrefix)
    }
}
