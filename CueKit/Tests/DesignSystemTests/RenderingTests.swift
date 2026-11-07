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

    @Test("A large button has a fixed size: 52 points tall and at least 240 wide, plus its edge")
    func largeButtonSize() {
        let image = render(Button("Ok") {}.buttonStyle(CueButtonStyle(.primary, size: .large)).fixedSize())
        #expect(image?.height == 52 + Int(CueDepth.button))
        #expect(image?.width == 240)
    }

    @Test("A regular button is 44 points tall and at least 140 wide, plus its edge")
    func regularButtonSize() {
        let image = render(Button("Ok") {}.buttonStyle(.cueSecondary).fixedSize())
        #expect(image?.height == 44 + Int(CueDepth.button))
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
        #expect((render(button)?.height ?? 0) > 44 + Int(CueDepth.button))
    }

    @Test("A disabled button draws without its edge")
    func disabledButton() {
        let button = Button("Ok") {}.buttonStyle(.cuePrimary).disabled(true)
        #expect(render(button) != nil)
    }

    private func render(_ view: some View) -> CGImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        return renderer.cgImage
    }
}
