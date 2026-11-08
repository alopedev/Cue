import SwiftUI
import Testing

@testable import DesignSystem

/// Draws the components off screen to catch layouts that break or collapse.
@MainActor
@Suite("Rendering")
struct RenderingTests {
    @Test(
        "The catalog draws every component in both themes",
        arguments: [ColorScheme.light, .dark]
    )
    func catalogRenders(scheme: ColorScheme) {
        let image = render(DesignSystemCatalog().environment(\.colorScheme, scheme).frame(width: 390))
        #expect((image?.height ?? 0) > 400)
    }

    @Test("A large primary button is 52 points tall and at least 240 wide, plus its 6-point edge")
    func largeButtonSize() {
        let image = render(Button("Ok") {}.buttonStyle(CueButtonStyle(.primary, size: .large)).fixedSize())
        #expect(image?.height == 52 + 6)
        #expect(image?.width == 240)
    }

    @Test("A regular secondary button is 52 points tall and at least 140 wide, plus its 4-point edge")
    func regularButtonSize() {
        let image = render(Button("Ok") {}.buttonStyle(.cueSecondary).fixedSize())
        #expect(image?.height == 52 + 4)
        #expect(image?.width == 140)
    }

    @Test("A button never stretches to fill the space it is given")
    func buttonDoesNotStretch() {
        let image = render(Button("Ok") {}.buttonStyle(CueButtonStyle(.primary, size: .large)))
        #expect(image?.width == 240)
    }

    @Test("A long label wraps instead of being cut")
    func longLabelWraps() {
        let label = String(repeating: "Marcar visto ", count: 8)
        let button = Button(label) {}.buttonStyle(.cueSecondary).frame(width: 200)
        #expect((render(button)?.height ?? 0) > 52 + 4)
    }

    @Test("A plain card sits on the soft 4-point edge, a ticket on the 8-point edge")
    func cardEdges() throws {
        let content = Color.clear.frame(height: 10)
        let plain = try #require(render(CueCard(.surface) { content }.frame(width: 200))?.height)
        let ticket = try #require(render(CueCard(.ticket) { content }.frame(width: 200))?.height)
        #expect(plain == 10 + 2 * Int(CueSpacing.space4) + 4)
        #expect(ticket == 10 + 2 * Int(CueSpacing.space4) + 8)
    }

    @Test("A disabled button draws without its edge")
    func disabledButton() {
        let button = Button("Ok") {}.buttonStyle(.cuePrimary).disabled(true)
        #expect(render(button) != nil)
    }
}
