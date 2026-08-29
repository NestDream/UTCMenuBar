import SwiftUI
import UTCMenuBarLib

/// The one accent in the app: the cyan of the icon's prime meridian.
/// Appearance-adaptive — the icon's bright cyan reads well on dark material
/// but falls below small-text contrast on light, so light mode deepens it.
let meridianAccent = Color(nsColor: NSColor(name: nil) { appearance in
    let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    return isDark
        ? NSColor(srgbRed: 0x53 / 255.0, green: 0xC7 / 255.0, blue: 0xF0 / 255.0, alpha: 1)
        : NSColor(srgbRed: 0x08 / 255.0, green: 0x6F / 255.0, blue: 0x98 / 255.0, alpha: 1)
})

struct ClockPopoverView: View {
    /// Single source for the popover width; PopoverController's fallback
    /// sizing reads it too, so the two can't drift.
    static let width: CGFloat = 280

    @ObservedObject var viewModel: ClockPopoverViewModel
    let onSettings: () -> Void
    let onConverter: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // Hero: the reading itself, then its frame of reference.
            VStack(spacing: 7) {
                Text(viewModel.timeText)
                    .font(.system(size: 38, weight: .medium))
                    .monospacedDigit()
                    .tracking(-0.5)  // large text wants slightly negative tracking
                    .foregroundStyle(.primary)
                HStack(spacing: 8) {
                    Text("UTC")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(meridianAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(meridianAccent.opacity(0.16)))
                    Text(viewModel.dateText)
                        .font(.system(size: 13))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)

            Divider()

            VStack(spacing: 2) {
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

                Divider()
                    .padding(.vertical, 4)

                PopoverButton(
                    title: Strings.t(.menuQuit, language: viewModel.language),
                    systemImage: "power",
                    shortcut: "⌘Q",
                    action: onQuit
                )
                .keyboardShortcut("q", modifiers: .command)
            }
        }
        .padding(14)
        .frame(width: Self.width)
        // A plain rounded panel below the menu bar, the way system menu bar
        // extras present — no fake arrow nub.
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
