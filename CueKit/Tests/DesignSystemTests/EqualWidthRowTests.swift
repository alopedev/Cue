import SwiftUI
import Testing

@testable import DesignSystem

@MainActor
@Suite("Equal-width row")
struct EqualWidthRowTests {
    @Test("Buttons side by side share the width of the widest one")
    func sharesWidestWidth() {
        let wide = Color.clear.frame(width: 180, height: 10)
        let narrow = Color.clear.frame(width: 100, height: 10)
        let row = CueEqualWidthRow(spacing: 12) {
            wide
            narrow
        }
        let renderer = ImageRenderer(content: row.fixedSize())
        renderer.scale = 1
        #expect(renderer.cgImage?.width == 180 + 12 + 180)
    }
}
