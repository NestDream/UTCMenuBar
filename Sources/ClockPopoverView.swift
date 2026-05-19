import SwiftUI
import UTCMenuBarLib

struct ClockPopoverView: View {
    @ObservedObject var viewModel: ClockPopoverViewModel
    let onSettings: () -> Void
    let onConverter: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Arrow pointing up toward the status item
            ArrowUp()
                .fill(.ultraThinMaterial)
                .frame(width: 16, height: 8)

            VStack(spacing: 12) {
                Text(viewModel.currentTime)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                Divider()

                VStack(spacing: 4) {
                    popoverButton(
                        title: Strings.t(.menuSettings, language: viewModel.language),
                        systemImage: "gearshape",
                        shortcut: "⌘,",
                        action: onSettings
                    )
                    popoverButton(
                        title: Strings.t(.menuTimezoneConverter, language: viewModel.language),
                        systemImage: "globe",
                        shortcut: "⌘T",
                        action: onConverter
                    )

                    Divider()
                        .padding(.vertical, 4)

                    popoverButton(
                        title: Strings.t(.menuQuit, language: viewModel.language),
                        systemImage: "power",
                        shortcut: "⌘Q",
                        action: onQuit
                    )
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 260)
    }

    private func popoverButton(title: String, systemImage: String, shortcut: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 13))
                    .frame(width: 18, alignment: .center)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
                Text(shortcut)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}

/// A small triangle pointing upward, used as the popover arrow.
private struct ArrowUp: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
