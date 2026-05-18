import SwiftUI
import UTCMenuBarLib

struct ClockPopoverView: View {
    @ObservedObject var viewModel: ClockPopoverViewModel
    let onSettings: () -> Void
    let onConverter: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Large UTC time display
            Text(viewModel.currentTime)
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            Divider()

            // Action buttons
            VStack(spacing: 8) {
                popoverButton(
                    title: Strings.t(.menuSettings, language: viewModel.language),
                    systemImage: "gearshape",
                    shortcut: "\u{2318},",
                    action: onSettings
                )
                popoverButton(
                    title: Strings.t(.menuTimezoneConverter, language: viewModel.language),
                    systemImage: "globe",
                    shortcut: "\u{2318}T",
                    action: onConverter
                )
                popoverButton(
                    title: Strings.t(.menuQuit, language: viewModel.language),
                    systemImage: "power",
                    shortcut: "\u{2318}Q",
                    action: onQuit
                )
            }
        }
        .padding(16)
        .frame(width: 280)
        .modifier(GlassBackgroundModifier())
    }

    private func popoverButton(title: String, systemImage: String, shortcut: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 20)
                Text(title)
                Spacer()
                Text(shortcut)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

/// Applies Liquid Glass effect on macOS 26+, falls back to ultraThinMaterial on older systems.
private struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.glassEffect(.regular.interactive())
        } else {
            content.background(.ultraThinMaterial)
        }
    }
}
