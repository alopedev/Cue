import SwiftUI
import Testing

@testable import DesignSystem

@Suite("Sample posters")
struct PosterDesignTests {
    private let sampleTitles = [
        "La casa del faro", "Órbita baja", "Turno de noche", "Los archivos de Marta Vidal",
        "Pan y mantequilla", "Cordillera", "Mareas", "Ciudad dormida", "El último tranvía",
        "Nebulosa once", "Domingo de lluvia", "Taller de relojes", "Cometas en agosto", "Doce tejados",
    ]

    @Test("The same title always gets the same poster, on every launch")
    func stableDesign() {
        // A known hash (FNV-1a) proves the seed does not depend on Swift's per-launch hashing.
        #expect(PosterDesign(title: "Mareas") == PosterDesign(title: "Mareas"))
        #expect(PosterDesign.seed(for: "Mareas") == fnv1a("Mareas"))
    }

    @Test("Sample titles spread over most palettes and motifs")
    func designsVary() {
        let designs = sampleTitles.map(PosterDesign.init(title:))
        #expect(Set(designs.map(\.palette)).count >= 5)
        #expect(Set(designs.map(\.motif)).count >= 5)
    }

    @Test("Poster titles are readable on every palette (4.5:1)", arguments: PosterPalette.all)
    func titleIsReadable(palette: PosterPalette) {
        #expect(palette.text.contrastRatio(with: palette.background) >= 4.5)
    }

    @Test("Shapes stand out from the poster background (1.5:1 at least)", arguments: PosterPalette.all)
    func shapesStandOut(palette: PosterPalette) {
        #expect(palette.primary.contrastRatio(with: palette.background) >= 1.5)
    }

    @MainActor
    @Test("A poster keeps the 2:3 shape of a film poster, plus its edge", arguments: PosterMotif.allCases)
    func posterShape(motif: PosterMotif) throws {
        let design = PosterDesign(palette: PosterPalette.all[0], motif: motif)
        let image = try #require(render(CuePoster(title: "Mareas", design: design).frame(width: 120)))
        #expect(image.width == 120)
        #expect(image.height == 180 + Int(CueDepth.soft))
    }

    private func fnv1a(_ text: String) -> UInt64 {
        text.unicodeScalars.reduce(0xcbf2_9ce4_8422_2325) { ($0 ^ UInt64($1.value)) &* 0x100_0000_01b3 }
    }
}
