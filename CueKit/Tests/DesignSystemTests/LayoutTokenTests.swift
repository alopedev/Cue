import Testing

@testable import DesignSystem

@Suite("Spacing, radius and depth")
struct LayoutTokenTests {
    @Test("Spacing follows the 4-point scale of the design system")
    func spacingScale() {
        #expect(
            [CueSpacing.xxs, .xs, .sm, .md, .lg, .xl, .xxl] == [4, 8, 12, 16, 24, 32, 48]
        )
    }

    @Test("Radii match the design system")
    func radii() {
        #expect([CueRadius.small, CueRadius.medium, CueRadius.large] == [10, 18, 28])
    }

    @Test("An inner corner is the outer corner minus the padding between them")
    func concentricRadius() {
        #expect(CueRadius.concentric(outer: CueRadius.large, inset: CueSpacing.md) == 12)
    }

    @Test("An inner corner never goes below zero")
    func concentricRadiusFloor() {
        #expect(CueRadius.concentric(outer: 10, inset: 16) == 0)
    }
}
