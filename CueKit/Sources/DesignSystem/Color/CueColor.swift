import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

extension RGBColor {
    fileprivate var color: Color { Color(.sRGB, red: red, green: green, blue: blue) }
}

extension ThemedColor {
    /// A SwiftUI color that switches with the light or dark appearance.
    public var color: Color {
        #if canImport(UIKit)
            let light = UIColor(self.light.color)
            let dark = UIColor(self.dark.color)
            return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
        #elseif canImport(AppKit)
            let light = NSColor(self.light.color)
            let dark = NSColor(self.dark.color)
            return Color(
                nsColor: NSColor(name: nil) { appearance in
                    appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
                }
            )
        #endif
    }
}

/// SwiftUI colors of the design system. Use these in views; never write a hex value in a screen.
public enum CueColor {
    public static let canvas = CuePalette.canvas.color
    public static let surface = CuePalette.surface.color
    public static let surfaceSunken = CuePalette.surfaceSunken.color
    public static let line = CuePalette.line.color
    public static let ink = CuePalette.ink.color
    public static let inkMuted = CuePalette.inkMuted.color
    public static let cue = CuePalette.cue.color
    public static let onCue = CuePalette.onCue.color
    public static let cueEdge = CuePalette.cueEdge.color
    public static let ticket = CuePalette.ticket.color
    public static let onTicket = CuePalette.onTicket.color
    public static let onTicketMuted = CuePalette.onTicketMuted.color
    public static let ticketEdge = CuePalette.ticketEdge.color
    public static let stage = CuePalette.stage.color
    public static let softEdge = CuePalette.softEdge.color
    public static let success = CuePalette.success.color
    public static let danger = CuePalette.danger.color
    public static let focus = CuePalette.focus.color
}
