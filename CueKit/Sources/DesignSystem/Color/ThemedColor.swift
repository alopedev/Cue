/// Light or dark appearance. Cue follows the iPhone setting.
public enum Theme: CaseIterable, Sendable {
    case light
    case dark
}

/// A color with one value per theme.
public struct ThemedColor: Equatable, Sendable {
    public let light: RGBColor
    public let dark: RGBColor

    public init(light: UInt32, dark: UInt32) {
        self.light = RGBColor(hex: light)
        self.dark = RGBColor(hex: dark)
    }

    /// The same value in both themes.
    public init(both hex: UInt32) {
        self.init(light: hex, dark: hex)
    }

    public func value(in theme: Theme) -> RGBColor {
        switch theme {
        case .light: light
        case .dark: dark
        }
    }
}

/// A text color and the background it is used on, which must stay readable.
public struct TextPairing: Sendable, CustomStringConvertible {
    public let name: String
    public let foreground: ThemedColor
    public let background: ThemedColor

    public var description: String { name }
}
