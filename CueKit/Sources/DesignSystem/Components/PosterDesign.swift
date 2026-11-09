/// Colors of a sample poster: the character's palette, never interface colors.
public struct PosterPalette: Hashable, Sendable, CustomStringConvertible {
    public let name: String
    public let background: RGBColor
    /// The big shape.
    public let primary: RGBColor
    /// The small accent.
    public let secondary: RGBColor
    public let text: RGBColor

    public var description: String { name }

    public static let all: [PosterPalette] = [
        PosterPalette(
            name: "remote",
            background: CuePalette.remote.light,
            primary: CuePalette.peach.light,
            secondary: CuePalette.blush.light,
            text: CuePalette.ink.dark
        ),
        PosterPalette(
            name: "peach",
            background: CuePalette.peach.light,
            primary: CuePalette.remote.light,
            secondary: CuePalette.ticket.light,
            text: CuePalette.remote.light
        ),
        PosterPalette(
            name: "mint",
            background: CuePalette.ticket.light,
            primary: CuePalette.onTicket.light,
            secondary: CuePalette.blush.light,
            text: CuePalette.onTicket.light
        ),
        PosterPalette(
            name: "stage",
            background: CuePalette.stage.light,
            primary: CuePalette.cue.light,
            secondary: CuePalette.remote.light,
            text: CuePalette.remote.light
        ),
        PosterPalette(
            name: "night",
            background: CuePalette.remoteEdge.light,
            primary: CuePalette.ticket.light,
            secondary: CuePalette.peach.light,
            text: CuePalette.ink.dark
        ),
        PosterPalette(
            name: "blush",
            background: CuePalette.blush.light,
            primary: CuePalette.remote.light,
            secondary: CuePalette.stage.light,
            text: CuePalette.remote.light
        ),
    ]
}

/// The drawing on a sample poster.
public enum PosterMotif: CaseIterable, Hashable, Sendable {
    case sunset
    case arcs
    case orbits
    case stripes
    case dots
    case moon
}

/// How the sample poster of a title looks. The same title always gets the same poster.
public struct PosterDesign: Hashable, Sendable {
    public let palette: PosterPalette
    public let motif: PosterMotif

    public init(palette: PosterPalette, motif: PosterMotif) {
        self.palette = palette
        self.motif = motif
    }

    public init(title: String) {
        let seed = Self.seed(for: title)
        let palettes = PosterPalette.all
        let motifs = PosterMotif.allCases
        // Different bits of the hash for each choice, so palette and motif vary independently.
        palette = palettes[Int((seed >> 3) % UInt64(palettes.count))]
        motif = motifs[Int((seed >> 12) % UInt64(motifs.count))]
    }

    /// FNV-1a hash of the title. Stable across launches, unlike Swift's `hashValue`.
    static func seed(for title: String) -> UInt64 {
        title.unicodeScalars.reduce(0xcbf2_9ce4_8422_2325) { ($0 ^ UInt64($1.value)) &* 0x100_0000_01b3 }
    }
}
