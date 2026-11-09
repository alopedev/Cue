import CoreText
import Testing

@testable import DesignSystem

@Suite("Typography")
struct TypographyTests {
    @Test("The title font ships with the package and registers by its PostScript name")
    func registersTitleFont() throws {
        try CueFonts.register()
        let font = CTFontCreateWithName(CueFonts.titlePostScriptName as CFString, 20, nil)
        #expect(CTFontCopyPostScriptName(font) as String == CueFonts.titlePostScriptName)
    }

    @Test("Registering twice is harmless")
    func registersTwice() throws {
        try CueFonts.register()
        try CueFonts.register()
    }

    @Test("Every text style keeps a size of at least 12 points at the default text size")
    func noStyleBelowCaption() {
        for style in CueTextStyle.allCases {
            #expect(style.baseSize >= 12, "\(style)")
        }
    }
}

@Suite("Fixed-width digits")
struct FixedWidthDigitTests {
    @Test("Only durations use fixed-width digits")
    func onlyDurations() {
        let fixed = CueTextStyle.allCases.filter(\.usesFixedWidthDigits)
        #expect(fixed == [.minutes, .minutesLarge])
    }
}
