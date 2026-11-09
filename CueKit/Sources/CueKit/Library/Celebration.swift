/// The one big celebration of the app: finishing a season, a series or a movie (RNF-02).
public struct Celebration: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        /// The season with this number.
        case seasonFinished(Int)
        case seriesFinished
        case movieWatched
    }

    public let kind: Kind
    /// Name of the series or movie.
    public let title: String

    public init(kind: Kind, title: String) {
        self.kind = kind
        self.title = title
    }
}
