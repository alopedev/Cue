import Foundation

/// Two-way sync of the viewing history with Trakt (PRD §6.9, tanda B).
///
/// Connecting the account (sign-in) belongs to the adapter and the app, not to this contract.
public protocol HistorySync: Sendable {
    /// Everything that changed in Trakt since a date, or the whole history when the date is nil
    /// (RF-52, RF-54).
    func fetchChanges(since date: Date?) async throws -> SyncedHistory

    /// Sends one change made in Cue (RF-53). Retrying failed sends is the caller's job (RF-55).
    func send(_ change: OutgoingChange) async throws

    /// Disconnects the account. Local data is kept (RF-57).
    func disconnect() async throws
}

/// A movie watched, as Trakt reports it.
public struct MovieWatch: Hashable, Sendable {
    public let movieID: MovieID
    public let watchedAt: Date

    public init(movieID: MovieID, watchedAt: Date) {
        self.movieID = movieID
        self.watchedAt = watchedAt
    }
}

/// What comes from Trakt: watched episodes and movies, the watchlist and the ratings.
///
/// Marks, watches and ratings only include what changed since the requested date. The watchlist
/// has no dates in Trakt, so it is always the whole current list.
public struct SyncedHistory: Hashable, Sendable {
    public let episodeMarks: [EpisodeMark]
    public let movieWatches: [MovieWatch]
    public let watchlist: [TitleID]
    public let ratings: [Rating]

    public init(episodeMarks: [EpisodeMark], movieWatches: [MovieWatch], watchlist: [TitleID], ratings: [Rating]) {
        self.episodeMarks = episodeMarks
        self.movieWatches = movieWatches
        self.watchlist = watchlist
        self.ratings = ratings
    }

    public static let empty = SyncedHistory(episodeMarks: [], movieWatches: [], watchlist: [], ratings: [])
}

/// One change made in Cue that Trakt must receive.
public enum OutgoingChange: Hashable, Sendable {
    case episodeMarked(EpisodeMark)
    case movieWatched(MovieWatch)
    case rated(Rating)
}

public enum HistorySyncError: Error, Equatable, Sendable {
    /// There is no connected Trakt account.
    case notConnected
    /// Trakt cannot be reached right now.
    case unavailable
}
