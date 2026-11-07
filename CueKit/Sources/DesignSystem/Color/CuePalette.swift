/// Every color of the Cue design system (v4, `tokens.json`).
public enum CuePalette {
    // Backgrounds
    /// Background of every screen.
    public static let canvas = ThemedColor(light: 0xF7_F4F2, dark: 0x16_131B)
    /// Sheets, cards and cells on top of `canvas`.
    public static let surface = ThemedColor(light: 0xFF_FFFF, dark: 0x21_1D27)
    /// Gaps: loading posters, chip groups, the secondary button.
    public static let surfaceSunken = ThemedColor(light: 0xEE_E8E5, dark: 0x2E_2935)
    /// Thin separators. Decorative: never the only border of a control.
    public static let line = ThemedColor(light: 0xE3_DCD8, dark: 0x35_2F3D)

    // Text
    public static let ink = ThemedColor(light: 0x23_1F2B, dark: 0xF4_EFF2)
    public static let inkMuted = ThemedColor(light: 0x61_5A6B, dark: 0xAD_A4B5)

    // Brand: coral, the only strong color
    /// Fill of the primary button, selected chips and the watched mark. Not a small-text color.
    public static let cue = ThemedColor(light: 0xB5_4A32, dark: 0xFF_B3A1)
    public static let onCue = ThemedColor(light: 0xFF_FFFF, dark: 0x3A_1208)
    public static let cueEdge = ThemedColor(light: 0x7E_2F1E, dark: 0xC9_806D)

    // Mint ticket, the character's blanket
    public static let ticket = ThemedColor(both: 0xBF_E6D2)
    public static let onTicket = ThemedColor(both: 0x1E_3A2E)
    public static let onTicketMuted = ThemedColor(both: 0x3E_5E50)
    public static let ticketEdge = ThemedColor(light: 0x8F_CBAF, dark: 0x6F_AF92)

    // Peach circle behind the character
    public static let stage = ThemedColor(light: 0xFF_E3D6, dark: 0xCF_A28E)

    // Edge under secondary buttons, unselected chips and posters
    public static let softEdge = ThemedColor(light: 0xE3_DCD8, dark: 0x0E_0C12)

    // Status: always next to a word or an icon, never alone
    public static let success = ThemedColor(light: 0x2F_7A57, dark: 0x7F_D8A8)
    public static let danger = ThemedColor(light: 0xB4_2318, dark: 0xFF_8A7A)
    public static let focus = ThemedColor(light: 0x1F_5FD1, dark: 0x8F_B2FF)

    /// Every text-on-background combination the design system allows.
    public static let textPairings: [TextPairing] = [
        TextPairing(name: "ink on canvas", foreground: ink, background: canvas),
        TextPairing(name: "ink on surface", foreground: ink, background: surface),
        TextPairing(name: "ink on surface-sunken", foreground: ink, background: surfaceSunken),
        TextPairing(name: "ink-muted on canvas", foreground: inkMuted, background: canvas),
        TextPairing(name: "ink-muted on surface", foreground: inkMuted, background: surface),
        TextPairing(name: "on-cue on cue", foreground: onCue, background: cue),
        TextPairing(name: "on-ticket on ticket", foreground: onTicket, background: ticket),
        TextPairing(name: "on-ticket-muted on ticket", foreground: onTicketMuted, background: ticket),
        TextPairing(name: "success on surface", foreground: success, background: surface),
        TextPairing(name: "danger on surface", foreground: danger, background: surface),
    ]
}
