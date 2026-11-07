import Foundation

// Catalog entities (PRD §4.1). They come from TMDB and the app only reads them.

/// A TMDB genre. Series and movies use different genre lists.
public struct Genre: Hashable, Sendable, Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

/// A TMDB keyword, finer than a genre. Some moods use keywords for series.
public struct Keyword: Hashable, Sendable, Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public enum AiringStatus: Hashable, Sendable {
    case airing
    case ended
    case canceled
}

public struct Series: Hashable, Sendable, Identifiable {
    public let id: SeriesID
    public let title: String
    public let year: Int?
    public let seasonCount: Int
    public let airingStatus: AiringStatus
    public let genres: [Genre]
    public let keywords: [Keyword]
    public let posterURL: URL?

    public init(
        id: SeriesID,
        title: String,
        year: Int?,
        seasonCount: Int,
        airingStatus: AiringStatus,
        genres: [Genre],
        keywords: [Keyword],
        posterURL: URL?
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.seasonCount = seasonCount
        self.airingStatus = airingStatus
        self.genres = genres
        self.keywords = keywords
        self.posterURL = posterURL
    }
}

public struct Season: Hashable, Sendable {
    public let seriesID: SeriesID
    public let number: Int
    public let episodeCount: Int

    public init(seriesID: SeriesID, number: Int, episodeCount: Int) {
        self.seriesID = seriesID
        self.number = number
        self.episodeCount = episodeCount
    }
}

public struct Episode: Hashable, Sendable, Identifiable {
    public let id: EpisodeReference
    public let title: String
    /// Nil when TMDB does not know the runtime yet.
    public let runtimeMinutes: Int?
    /// Nil when the episode has no announced air date yet.
    public let airDate: Date?

    public init(id: EpisodeReference, title: String, runtimeMinutes: Int?, airDate: Date?) {
        self.id = id
        self.title = title
        self.runtimeMinutes = runtimeMinutes
        self.airDate = airDate
    }
}

public struct Movie: Hashable, Sendable, Identifiable {
    public let id: MovieID
    public let title: String
    public let year: Int?
    /// Nil when TMDB does not know the runtime yet.
    public let runtimeMinutes: Int?
    public let genres: [Genre]
    public let keywords: [Keyword]
    public let posterURL: URL?

    public init(
        id: MovieID,
        title: String,
        year: Int?,
        runtimeMinutes: Int?,
        genres: [Genre],
        keywords: [Keyword],
        posterURL: URL?
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.runtimeMinutes = runtimeMinutes
        self.genres = genres
        self.keywords = keywords
        self.posterURL = posterURL
    }
}

/// A streaming service, such as Netflix.
public struct StreamingProvider: Hashable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let logoURL: URL?

    public init(id: Int, name: String, logoURL: URL?) {
        self.id = id
        self.name = name
        self.logoURL = logoURL
    }
}

public enum AccessType: Hashable, Sendable {
    case subscription
    case rent
    case buy
}

/// Where a title can be watched in a country, and how.
public struct Availability: Hashable, Sendable {
    public let title: TitleID
    public let provider: StreamingProvider
    public let country: CountryCode
    public let access: AccessType

    public init(title: TitleID, provider: StreamingProvider, country: CountryCode, access: AccessType) {
        self.title = title
        self.provider = provider
        self.country = country
        self.access = access
    }
}
