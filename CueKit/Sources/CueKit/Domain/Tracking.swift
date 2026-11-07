import Foundation

// User entities about what the user follows and has watched (PRD §4.3).

public enum SeriesStatus: Hashable, Sendable {
    case pending
    case watching
    case upToDate
    case paused
    case abandoned
    case finished
}

/// What the user keeps of one series. At most one per series (PRD §4.4).
public struct SeriesTracking: Hashable, Sendable {
    public let seriesID: SeriesID
    public let status: SeriesStatus
    public let addedAt: Date
    public let lastMarkedAt: Date?
    /// The next unmarked episode in air order. Nil when there is none.
    public let currentEpisode: EpisodeReference?

    public init(
        seriesID: SeriesID,
        status: SeriesStatus,
        addedAt: Date,
        lastMarkedAt: Date?,
        currentEpisode: EpisodeReference?
    ) {
        self.seriesID = seriesID
        self.status = status
        self.addedAt = addedAt
        self.lastMarkedAt = lastMarkedAt
        self.currentEpisode = currentEpisode
    }
}

public enum MovieStatus: Hashable, Sendable {
    case pending
    case watched
    case dismissed
}

/// What the user keeps of one movie. At most one per movie (PRD §4.4).
public struct MovieTracking: Hashable, Sendable {
    public let movieID: MovieID
    public let status: MovieStatus
    public let addedAt: Date
    public let watchedAt: Date?

    public init(movieID: MovieID, status: MovieStatus, addedAt: Date, watchedAt: Date?) {
        self.movieID = movieID
        self.status = status
        self.addedAt = addedAt
        self.watchedAt = watchedAt
    }
}

public enum MarkSource: Hashable, Sendable {
    case manual
    case trakt
    case reconciled
}

/// One episode marked as watched.
public struct EpisodeMark: Hashable, Sendable {
    public let episode: EpisodeReference
    public let markedAt: Date
    public let source: MarkSource

    public init(episode: EpisodeReference, markedAt: Date, source: MarkSource) {
        self.episode = episode
        self.markedAt = markedAt
        self.source = source
    }
}
