import Foundation

/// A series in the library with everything the screens need about it.
public struct SeriesEntry: Hashable, Sendable, Identifiable {
    public let details: SeriesDetails
    public let tracking: SeriesTracking
    public let progress: SeriesProgress
    /// The user's marks of this series, by episode.
    let marks: [EpisodeReference: EpisodeMark]

    public var id: SeriesID { details.series.id }

    /// The episodes the user has watched.
    public var watchedEpisodes: Set<EpisodeReference> { Set(marks.keys) }

    init(details: SeriesDetails, tracking: SeriesTracking, marks: [EpisodeReference: EpisodeMark], now: Date) {
        self.details = details
        self.tracking = tracking
        self.marks = marks
        self.progress = SeriesProgress(details: details, watched: Set(marks.keys), now: now)
    }
}

/// A movie in the library with everything the screens need about it.
public struct MovieEntry: Hashable, Sendable, Identifiable {
    public let details: MovieDetails
    public let tracking: MovieTracking

    public var id: MovieID { details.movie.id }
}

/// One title of the library: a series or a movie.
public enum LibraryEntry: Hashable, Sendable, Identifiable {
    case series(SeriesEntry)
    case movie(MovieEntry)

    public var id: TitleID {
        switch self {
        case .series(let entry): .series(entry.id)
        case .movie(let entry): .movie(entry.id)
        }
    }

    public var title: String {
        switch self {
        case .series(let entry): entry.details.series.title
        case .movie(let entry): entry.details.movie.title
        }
    }

    public var shelf: LibraryShelf {
        switch self {
        case .series(let entry): LibraryShelf(entry.tracking.status)
        case .movie(let entry): LibraryShelf(entry.tracking.status)
        }
    }

    public var seriesEntry: SeriesEntry? {
        if case .series(let entry) = self { entry } else { nil }
    }

    public var movieEntry: MovieEntry? {
        if case .movie(let entry) = self { entry } else { nil }
    }

    /// When the user last did something with this title: added it or marked it.
    var lastActivity: Date {
        switch self {
        case .series(let entry): max(entry.tracking.addedAt, entry.tracking.lastMarkedAt ?? .distantPast)
        case .movie(let entry): max(entry.tracking.addedAt, entry.tracking.watchedAt ?? .distantPast)
        }
    }
}
