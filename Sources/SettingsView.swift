import SwiftUI
import UTCMenuBarLib

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel2
    let onPickCustomFont: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(viewModel.label(.settingsSectionGeneral)) {
                    Toggle(viewModel.label(.settingsLaunchAtLogin), isOn: $viewModel.launchAtLogin)
                    if viewModel.launchAtLoginRequiresApproval {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(viewModel.label(.launchAtLoginRequiresApproval))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(viewModel.label(.launchAtLoginOpenSettings)) {
                                LaunchAtLoginManager.openLoginItemsInSystemSettings()
                            }
                            .controlSize(.small)
                        }
                    }
                    if let error = viewModel.launchAtLoginError {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.octagon.fill")
                                .foregroundStyle(.red)
                            Text("\(viewModel.label(.launchAtLoginErrorTitle)): \(error)")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

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
                        // Render with the actual resolved font and color so the
                        // preview shows exactly what the menu bar will show.
                        Text(viewModel.previewText)
                            .font(Font(StyledTextBuilder.resolveFont(
                                family: viewModel.fontFamily,
                                weight: viewModel.fontWeight,
                                size: viewModel.fontSize,
                                customFontName: viewModel.customFontName
                            ) as CTFont))
                            .foregroundStyle(previewColor)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                }

                Section(viewModel.label(.settingsSectionAbout)) {
                    LabeledContent(viewModel.label(.aboutVersion)) {
                        Text("\(BundleInfo.shortVersion) (\(BundleInfo.buildNumber))")
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    Link(viewModel.label(.aboutViewReleases), destination: BundleInfo.releasesURL)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 380, height: 540)
    }

    private var previewColor: Color {
        if let ns = viewModel.textColor.nsColor { return Color(nsColor: ns) }
        return .primary
    }
}
