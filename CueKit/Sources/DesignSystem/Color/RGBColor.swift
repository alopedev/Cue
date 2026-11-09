import Foundation

/// An sRGB color with components between 0 and 1.
///
/// Kept separate from SwiftUI so contrast can be checked in plain tests.
public struct RGBColor: Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Reads a 24-bit `0xRRGGBB` value.
    public init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// WCAG 2.x relative luminance.
    public var relativeLuminance: Double {
        0.2126 * Self.linear(red) + 0.7152 * Self.linear(green) + 0.0722 * Self.linear(blue)
    }

    /// WCAG 2.x contrast ratio, from 1 (none) to 21 (black on white).
    public func contrastRatio(with other: RGBColor) -> Double {
        let lighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private static func linear(_ component: Double) -> Double {
        component <= 0.040_45 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
    }
}
