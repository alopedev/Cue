import SwiftUI
import Testing

@testable import DesignSystem

@MainActor
@Suite("Chip")
struct ChipTests {
    @Test("A chip is at least 44 points tall, plus its 4-point edge, selected or not", arguments: [false, true])
    func chipHeight(isSelected: Bool) throws {
        let chip = CueChip("Viendo", count: 3, isSelected: isSelected) {}
        let image = try #require(render(chip))
        #expect(image.height >= 44 + Int(CueDepth.soft))
    }

    @Test("The mascot stage is a circle of the requested size")
    func mascotStage() throws {
        let image = try #require(render(MascotStage(Image(systemName: "tv"), size: .large)))
        #expect(image.width == 200)
        #expect(image.height == 200)
    }
}
