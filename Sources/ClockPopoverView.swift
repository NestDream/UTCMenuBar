import SwiftUI
import UTCMenuBarLib

struct ClockPopoverView: View {
    /// Single source for the popover width; PopoverController's fallback
    /// sizing reads it too, so the two can't drift.
    static let width: CGFloat = 292

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ObservedObject var viewModel: ClockPopoverViewModel
    let onSettings: () -> Void
    let onConverter: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(viewModel.timeText)
                    .font(.system(size: 42, weight: .regular))
                    .monospacedDigit()
                    .tracking(-1)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                HStack(spacing: 10) {
                    Text("UTC")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(InterfaceStyle.accent)
                    Text(viewModel.dateText)
                        .font(.system(size: 12))
                        .monospacedDigit()
                        .foregroundStyle(.primary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 22)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 20)

            VStack(spacing: 3) {
                // The panel becomes key while open, so the displayed
                // shortcuts actually work, not just decorate.
                PopoverButton(
                    title: Strings.t(.menuSettings, language: viewModel.language),
                    systemImage: "gearshape",
                    shortcut: "⌘,",
                    action: onSettings
                )
                .keyboardShortcut(",", modifiers: .command)
                PopoverButton(
                    title: Strings.t(.menuTimezoneConverter, language: viewModel.language),
                    systemImage: "globe",
                    shortcut: "⌘T",
                    action: onConverter
                )
                .keyboardShortcut("t", modifiers: .command)

                PopoverButton(
                    title: Strings.t(.menuQuit, language: viewModel.language),
                    systemImage: "power",
                    shortcut: "⌘Q",
                    isSecondary: true,
                    action: onQuit
                )
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(10)
        }
        .frame(width: Self.width)
        .background {
            let shape = RoundedRectangle(cornerRadius: InterfaceStyle.panelRadius, style: .continuous)
            if reduceTransparency {
                shape.fill(Color(nsColor: .windowBackgroundColor))
            } else {
                shape.fill(.regularMaterial)
            }
        }
    }
}

private struct PopoverButton: View {
    let title: String
    let systemImage: String
    let shortcut: String
    var isSecondary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 20, alignment: .center)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary.opacity(isSecondary ? 0.75 : 1))
                    .lineLimit(1)
                Spacer()
                Text(shortcut)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.primary.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(PopoverActionStyle())
    }
}

private struct PopoverActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ActionFeedback(isPressed: configuration.isPressed) {
            configuration.label
        }
    }
}

private struct ActionFeedback<Content: View>: View {
    let isPressed: Bool
    @ViewBuilder let content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    var body: some View {
        content()
            .background {
                RoundedRectangle(cornerRadius: InterfaceStyle.controlRadius, style: .continuous)
                    .fill(Color.primary.opacity(isPressed ? 0.11 : (isHovered ? 0.06 : 0)))
            }
            .onHover { hovering in
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.1)) {
                    isHovered = hovering
                }
            }
    }
}
