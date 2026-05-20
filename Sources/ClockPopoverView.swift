import SwiftUI
import UTCMenuBarLib

struct ClockPopoverView: View {
    @ObservedObject var viewModel: ClockPopoverViewModel
    let onSettings: () -> Void
    let onConverter: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(.ultraThinMaterial)
                .frame(width: 16, height: 8)

            VStack(spacing: 12) {
                Text(viewModel.currentTime)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                Divider()

                VStack(spacing: 2) {
                    PopoverButton(
                        title: Strings.t(.menuSettings, language: viewModel.language),
                        systemImage: "gearshape",
                        shortcut: "⌘,",
                        action: onSettings
                    )
                    PopoverButton(
                        title: Strings.t(.menuTimezoneConverter, language: viewModel.language),
                        systemImage: "globe",
                        shortcut: "⌘T",
                        action: onConverter
                    )

                    Divider()
                        .padding(.vertical, 4)

                    PopoverButton(
                        title: Strings.t(.menuQuit, language: viewModel.language),
                        systemImage: "power",
                        shortcut: "⌘Q",
                        action: onQuit
                    )
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: UnevenRoundedRectangle(
                topLeadingRadius: 4, bottomLeadingRadius: 12,
                bottomTrailingRadius: 12, topTrailingRadius: 4
            ))
        }
        .frame(width: 260)
    }
}

private struct PopoverButton: View {
    let title: String
    let systemImage: String
    let shortcut: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
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
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
