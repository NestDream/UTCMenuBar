import AppKit
import SwiftUI

/// Shared native colors and dimensions for the app's three utility surfaces.
@MainActor
enum InterfaceStyle {
    static let accentColor = NSColor(name: nil) { appearance in
        let dark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return dark
            ? NSColor(srgbRed: 0x53 / 255.0, green: 0xC7 / 255.0, blue: 0xF0 / 255.0, alpha: 1)
            : NSColor(srgbRed: 0x08 / 255.0, green: 0x6F / 255.0, blue: 0x98 / 255.0, alpha: 1)
    }
    static let accent = Color(nsColor: accentColor)
    static let panelRadius: CGFloat = 16
    static let controlRadius: CGFloat = 8
    static let settingsSize = NSSize(width: 440, height: 560)
    static let converterSize = NSSize(width: 460, height: 332)
}
