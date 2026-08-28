import SwiftUI
import UTCMenuBarLib

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel2
    let onPickCustomFont: () -> Void
    let onCheckForUpdates: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Live preview pinned above the form: a miniature menu bar strip
            // showing exactly what ships, always visible while the Appearance
            // controls below change it.
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.label(.settingsLabelPreview))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                HStack {
                    Spacer()
                    Text(viewModel.previewText)
                        .font(Font(StyledTextBuilder.resolveFont(
                            family: viewModel.fontFamily,
                            weight: viewModel.fontWeight,
                            size: viewModel.fontSize,
                            customFontName: viewModel.customFontName
                        ) as CTFont))
                        .foregroundStyle(previewColor)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.bar)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(.separator, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 4)

            Form {
                Section(viewModel.label(.settingsSectionGeneral)) {
                    Toggle(viewModel.label(.settingsLaunchAtLogin), isOn: $viewModel.launchAtLogin)
                    Toggle(viewModel.label(.updateAutoCheck), isOn: $viewModel.autoCheckUpdates)
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

                Section(viewModel.label(.settingsSectionDisplay)) {
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

                Section(viewModel.label(.settingsSectionAbout)) {
                    LabeledContent(viewModel.label(.aboutVersion)) {
                        Text("\(BundleInfo.shortVersion) (\(BundleInfo.buildNumber))")
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    Button(viewModel.label(.menuCheckForUpdates)) {
                        onCheckForUpdates()
                    }
                    Link(viewModel.label(.aboutViewReleases), destination: BundleInfo.releasesURL)
                }
            }
            .formStyle(.grouped)
        }
        // One surface: the pinned preview header sits on the same background
        // as the grouped form, so there is no seam where the form begins.
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(width: 380, height: 540)
    }

    private var previewColor: Color {
        // Same resolution path as the menu bar renderer, so the preview color
        // can't drift from what actually ships.
        if let ns = StyledTextBuilder.resolveColor(option: viewModel.textColor) {
            return Color(nsColor: ns)
        }
        return .primary
    }
}
