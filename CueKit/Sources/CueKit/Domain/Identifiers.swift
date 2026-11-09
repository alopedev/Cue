// Identifiers shared by catalog and user entities.

/// TMDB identifier of a series.
public struct SeriesID: Hashable, Sendable {
    public let rawValue: Int

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// TMDB identifier of a movie. Series and movie IDs live in separate TMDB namespaces.
public struct MovieID: Hashable, Sendable {
    public let rawValue: Int

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A series or a movie, for things that apply to both (ratings, availability).
public enum TitleID: Hashable, Sendable {
    case series(SeriesID)
    case movie(MovieID)
}

/// Points at one episode the way TMDB and Trakt do: series, season and episode number.
public struct EpisodeReference: Hashable, Sendable {
    public let seriesID: SeriesID
    public let seasonNumber: Int
    public let episodeNumber: Int

    public init(seriesID: SeriesID, seasonNumber: Int, episodeNumber: Int) {
        self.seriesID = seriesID
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
    }
}

/// Two-letter ISO 3166-1 country code, such as "ES". Availability depends on it.
public struct CountryCode: Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
