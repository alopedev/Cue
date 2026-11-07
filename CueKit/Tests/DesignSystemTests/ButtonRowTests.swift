import SwiftUI
import Testing

@testable import DesignSystem

@MainActor
@Suite("Button row")
struct ButtonRowTests {
    @Test("Buttons side by side share the width of the widest one")
    func sharesWidestWidth() throws {
        let wideWidth = try #require(render(Button("Marcar visto") {}.buttonStyle(.cuePrimary))?.width)
        let row = CueButtonRow(spacing: 12) {
            Button("Marcar visto") {}.buttonStyle(.cuePrimary)
            Button("Ahora no") {}.buttonStyle(.cueSecondary)
        }
        #expect(render(row)?.width == wideWidth * 2 + 12)
    }

    private func render(_ view: some View) -> CGImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        return renderer.cgImage
    }
}
