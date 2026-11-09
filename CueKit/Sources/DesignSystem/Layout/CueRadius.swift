import CoreGraphics

/// Corner radii of the design system. Buttons and chips are always capsules.
public enum CueRadius {
    /// 10 pt. Posters in the library grid and compact tickets.
    public static let small: CGFloat = 10
    /// 18 pt.
    public static let medium: CGFloat = 18
    /// 28 pt. Cards and sheets.
    public static let large: CGFloat = 28

    /// Radius of a shape nested inside another, so both corners share one center (RNF-11).
    public static func concentric(outer: CGFloat, inset: CGFloat) -> CGFloat {
        max(outer - inset, 0)
    }
}

/// Height of the solid edge under raised pieces. Depth is an edge, never a blurred shadow.
public enum CueDepth {
    /// Primary button (`depth-cue`).
    public static let button: CGFloat = 6
    /// Ticket (`depth-ticket`).
    public static let card: CGFloat = 8
    /// Secondary button, plain card, posters and unselected chips (`depth-soft`).
    public static let soft: CGFloat = 4
}
