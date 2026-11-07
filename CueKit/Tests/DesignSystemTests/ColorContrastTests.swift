import Testing

@testable import DesignSystem

@Suite("Color contrast")
struct ColorContrastTests {
    @Test("Reads a hex value into its red, green and blue parts")
    func readsHex() {
        let color = RGBColor(hex: 0xB5_4A32)
        #expect(color == RGBColor(red: 0xB5 / 255, green: 0x4A / 255, blue: 0x32 / 255))
    }

    @Test("Black on white has the maximum WCAG contrast of 21:1")
    func blackOnWhite() {
        let ratio = RGBColor(hex: 0x00_0000).contrastRatio(with: RGBColor(hex: 0xFF_FFFF))
        #expect(abs(ratio - 21) < 0.001)
    }

    @Test("Contrast is the same in both directions")
    func symmetric() {
        let coral = CuePalette.cue.light
        let white = CuePalette.onCue.light
        #expect(coral.contrastRatio(with: white) == white.contrastRatio(with: coral))
    }

    @Test(
        "Every text pairing reaches 4.5:1 in light and dark",
        arguments: CuePalette.textPairings
    )
    func textPairingIsReadable(pairing: TextPairing) {
        for theme in Theme.allCases {
            let ratio = pairing.foreground.value(in: theme)
                .contrastRatio(with: pairing.background.value(in: theme))
            #expect(ratio >= 4.5, "\(pairing.name) in \(theme): \(ratio)")
        }
    }

    // The ring is drawn outside the piece, on the screen background, never on the ticket.
    @Test("The focus ring stands out from the screen backgrounds (3:1 for non-text)")
    func focusRingIsVisible() {
        for theme in Theme.allCases {
            for background in [CuePalette.canvas, CuePalette.surface] {
                let ratio = CuePalette.focus.value(in: theme).contrastRatio(with: background.value(in: theme))
                #expect(ratio >= 3, "focus in \(theme): \(ratio)")
            }
        }
    }
}
