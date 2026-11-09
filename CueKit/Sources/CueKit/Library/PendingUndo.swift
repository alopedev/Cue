import Foundation

/// The last marking change, which the user can undo for 10 seconds (RF-33).
public struct PendingUndo: Hashable, Sendable {
    enum PreviousTracking: Hashable, Sendable {
        case series(SeriesTracking)
        case movie(MovieTracking)
    }

    /// Episodes the change marked.
    public let marked: [EpisodeReference]
    /// Episodes the change unmarked, with the marks they had.
    let removedMarks: [EpisodeMark]
    let previousTracking: PreviousTracking
    /// Name of the series or movie, for the message.
    public let title: String
    public let expiresAt: Date

    /// Episodes the change unmarked.
    public var unmarked: [EpisodeReference] { removedMarks.map(\.episode) }

    /// The change was marking a movie as watched.
    public var isMovie: Bool {
        if case .movie = previousTracking { true } else { false }
    }
}
