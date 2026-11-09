import Foundation

/// A catalog held in memory, for tests and sample data. Never touches the network.
public struct InMemoryCatalogProvider: CatalogProvider {
    private let series: [SeriesID: SeriesDetails]
    private let movies: [MovieID: MovieDetails]
    private let popularByCountry: [CountryCode: [CatalogItem]]
    private let failure: CatalogError?

    /// When `failure` is set, every call throws it (for example, to simulate no connection).
    public init(
        series: [SeriesDetails] = [],
        movies: [MovieDetails] = [],
        popular: [CountryCode: [CatalogItem]] = [:],
        failure: CatalogError? = nil
    ) {
        self.series = Dictionary(series.map { ($0.series.id, $0) }, uniquingKeysWith: { _, last in last })
        self.movies = Dictionary(movies.map { ($0.movie.id, $0) }, uniquingKeysWith: { _, last in last })
        self.popularByCountry = popular
        self.failure = failure
    }

    public func search(_ query: String, in country: CountryCode) async throws -> [CatalogItem] {
        try throwIfFailing()
        let seriesItems = series.values.map(\.series).filter { matches($0.title, query) }
        let movieItems = movies.values.map(\.movie).filter { matches($0.title, query) }
        // Sorted by title so results do not depend on dictionary order.
        return seriesItems.sorted { $0.title < $1.title }.map(CatalogItem.series)
            + movieItems.sorted { $0.title < $1.title }.map(CatalogItem.movie)
    }

    public func popular(in country: CountryCode) async throws -> [CatalogItem] {
        try throwIfFailing()
        return popularByCountry[country] ?? []
    }

    public func seriesDetails(for id: SeriesID, in country: CountryCode) async throws -> SeriesDetails {
        try throwIfFailing()
        guard let details = series[id] else { throw CatalogError.notFound }
        return SeriesDetails(
            series: details.series,
            seasons: details.seasons,
            episodes: details.episodes,
            availability: details.availability.filter { $0.country == country }
        )
    }

    public func movieDetails(for id: MovieID, in country: CountryCode) async throws -> MovieDetails {
        try throwIfFailing()
        guard let details = movies[id] else { throw CatalogError.notFound }
        return MovieDetails(movie: details.movie, availability: details.availability.filter { $0.country == country })
    }

    private func throwIfFailing() throws {
        if let failure { throw failure }
    }

    private func matches(_ title: String, _ query: String) -> Bool {
        title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
