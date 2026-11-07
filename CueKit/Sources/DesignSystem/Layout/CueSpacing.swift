import CoreGraphics

/// Spacing scale of the design system (`space-1` … `space-12`).
public enum CueSpacing {
    /// 4 pt. Between lines of one block (show and episode).
    public static let xxs: CGFloat = 4
    /// 8 pt. Between chips; between an icon and its text.
    public static let xs: CGFloat = 8
    /// 12 pt. Between buttons; vertical padding of rows.
    public static let sm: CGFloat = 12
    /// 16 pt. Side margin of a screen and padding of a card.
    public static let md: CGFloat = 16
    /// 24 pt. Between blocks of a screen.
    public static let lg: CGFloat = 24
    /// 32 pt. Before a title and in empty states.
    public static let xl: CGFloat = 32
    /// 48 pt. Air around the character in empty states.
    public static let xxl: CGFloat = 48
}
