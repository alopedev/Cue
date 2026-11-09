// What CatalogProvider returns: search results and full title details.

/// One search or popular-list result.
public enum CatalogItem: Hashable, Sendable {
    case series(Series)
    case movie(Movie)
}

/// Everything the app needs about a series: data, seasons, episodes and availability.
public struct SeriesDetails: Hashable, Sendable {
    public let series: Series
    public let seasons: [Season]
    /// Episodes in air order.
    public let episodes: [Episode]
    public let availability: [Availability]

    public init(series: Series, seasons: [Season], episodes: [Episode], availability: [Availability]) {
        self.series = series
        self.seasons = seasons
        self.episodes = episodes
        self.availability = availability
    }
}

/// Everything the app needs about a movie: data and availability.
public struct MovieDetails: Hashable, Sendable {
    public let movie: Movie
    public let availability: [Availability]

    public init(movie: Movie, availability: [Availability]) {
        self.movie = movie
        self.availability = availability
    }
}
