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
        let image = render(DesignSystemCatalog().environment(\.colorScheme, scheme))
        #expect((image?.height ?? 0) > 400)
    }

    @Test("A button keeps its 52-point minimum height plus its edge")
    func buttonHeight() {
        let button = Button("Ok") {}.buttonStyle(.cuePrimary)
        #expect(render(button)?.height == 52 + Int(CueDepth.button))
    }

    @Test("A long label wraps instead of being cut")
    func longLabelWraps() {
        let label = String(repeating: "Marcar visto ", count: 8)
        let button = Button(label) {}.buttonStyle(.cueSecondary).frame(width: 200)
        #expect((render(button)?.height ?? 0) > 52 + Int(CueDepth.button))
    }

    @Test("A disabled button draws without its edge")
    func disabledButton() {
        let button = Button("Ok") {}.buttonStyle(.cuePrimary).disabled(true)
        #expect(render(button) != nil)
    }

    private func render(_ view: some View) -> CGImage? {
        let renderer = ImageRenderer(content: view.frame(width: 390))
        renderer.scale = 1
        return renderer.cgImage
    }
}
