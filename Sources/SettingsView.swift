import SwiftUI
import UTCMenuBarLib

enum SettingsPane: CaseIterable {
    case general, appearance, about

    var titleKey: StringKey {
        switch self {
        case .general: .settingsSectionGeneral
        case .appearance: .menuAppearance
        case .about: .settingsSectionAbout
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel2
    let onPickCustomFont: () -> Void
    let onCheckForUpdates: () -> Void
    @State private var pane: SettingsPane

    init(
        viewModel: SettingsViewModel2,
        onPickCustomFont: @escaping () -> Void,
        onCheckForUpdates: @escaping () -> Void,
        initialPane: SettingsPane = .general
    ) {
        self.viewModel = viewModel
        self.onPickCustomFont = onPickCustomFont
        self.onCheckForUpdates = onCheckForUpdates
        _pane = State(initialValue: initialPane)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker(viewModel.label(.settingsWindowTitle), selection: $pane) {
                ForEach(SettingsPane.allCases, id: \.self) { item in
                    Text(viewModel.label(item.titleKey)).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(20)

            if pane != .about {
                preview
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }

            switch pane {
            case .general:
                generalForm
            case .appearance:
                appearanceForm
            case .about:
                about
            }
        }
        .tint(InterfaceStyle.accent)
        .frame(width: InterfaceStyle.settingsSize.width, height: InterfaceStyle.settingsSize.height)
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.label(.settingsLabelPreview))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            Text(AttributedString(StyledTextBuilder.buildAttributedString(
                text: viewModel.previewText,
                style: viewModel.currentStyle
            )))
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 12)
            .background(Color.primary.opacity(0.045),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var generalForm: some View {
        Form {
            Section(viewModel.label(.settingsSectionGeneral)) {
                Toggle(viewModel.label(.settingsLaunchAtLogin), isOn: $viewModel.launchAtLogin)
                Toggle(viewModel.label(.updateAutoCheck), isOn: $viewModel.autoCheckUpdates)
                if viewModel.launchAtLoginRequiresApproval {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(viewModel.label(.launchAtLoginRequiresApproval),
                              systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(viewModel.label(.launchAtLoginOpenSettings)) {
                            LaunchAtLoginManager.openLoginItemsInSystemSettings()
                        }
                        .controlSize(.small)
                    }
                }
                if let error = viewModel.launchAtLoginError {
                    Label("\(viewModel.label(.launchAtLoginErrorTitle)): \(error)",
                          systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Section(viewModel.label(.settingsSectionDisplay)) {
                Toggle(viewModel.label(.menuShowDate), isOn: $viewModel.showDate)
                Toggle(viewModel.label(.menuCompactTime), isOn: $viewModel.compactTime)
                Toggle(viewModel.label(.menuCompactDate), isOn: $viewModel.compactDate)
                    .disabled(!viewModel.showDate)
            }

            Section {
                Picker(viewModel.label(.settingsLabelLanguage), selection: $viewModel.appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Text(language.nativeName).tag(language)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var appearanceForm: some View {
        Form {
            Section(viewModel.label(.menuAppearance)) {
                Picker(viewModel.label(.settingsLabelFont), selection: $viewModel.fontFamily) {
                    ForEach(FontFamily.allCases, id: \.self) { family in
                        if family == .custom && !viewModel.customFontName.isEmpty {
                            Text(Strings.formatCustomFont(
                                name: viewModel.customFontName, language: viewModel.language
                            )).tag(family)
                        } else {
                            Text(family.displayName(for: viewModel.language)).tag(family)
                        }
                    }
                }
                .onChange(of: viewModel.fontFamily) { newValue in
                    if newValue == .custom { onPickCustomFont() }
                }

                Picker(viewModel.label(.settingsLabelWeight), selection: $viewModel.fontWeight) {
                    ForEach(FontWeight.allCases, id: \.self) { weight in
                        Text(weight.displayName(for: viewModel.language)).tag(weight)
                    }
                }

                Picker(viewModel.label(.settingsLabelSize), selection: $viewModel.fontSize) {
                    ForEach(FontSize.allCases, id: \.self) { size in
                        Text(size.displayName(for: viewModel.language)).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Picker(viewModel.label(.settingsLabelColor), selection: $viewModel.textColor) {
                    ForEach(TextColorOption.allCases, id: \.self) { color in
                        Text(color.displayName(for: viewModel.language)).tag(color)
                    }
                }
                Picker(viewModel.label(.settingsLabelIcon), selection: $viewModel.iconPrefix) {
                    ForEach(IconPrefix.allCases, id: \.self) { icon in
                        Text(icon.displayName(for: viewModel.language)).tag(icon)
                    }
                }
                Picker(viewModel.label(.settingsLabelDecorator), selection: $viewModel.decorator) {
                    ForEach(Decorator.allCases, id: \.self) { decorator in
                        Text(decorator.displayName(for: viewModel.language)).tag(decorator)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var about: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)
                .accessibilityHidden(true)
            Text("UTCMenuBar")
                .font(.system(size: 22, weight: .semibold))
            Text("\(viewModel.label(.aboutVersion)) \(BundleInfo.shortVersion) (\(BundleInfo.buildNumber))")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            Button(viewModel.label(.menuCheckForUpdates), action: onCheckForUpdates)
                .controlSize(.large)
                .padding(.top, 16)
            Link(viewModel.label(.aboutViewReleases), destination: BundleInfo.releasesURL)
                .font(.system(size: 12))
            Spacer()
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
