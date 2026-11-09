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

    @Test("Buttons that do not fit side by side stack instead of leaving the screen")
    func stacksWhenNarrow() throws {
        let row = CueButtonRow {
            Button("Marcar visto") {}.buttonStyle(.cuePrimary)
            Button("Ahora no") {}.buttonStyle(.cueSecondary)
        }
        let image = try #require(render(row.frame(width: 200)))
        #expect(image.width == 200)
        #expect(image.height >= 2 * 52)
    }
}
