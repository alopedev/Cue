/// Where series and movies come from. Real version: TMDB.
///
/// Every call can fail (no connection, unknown title). Offline reads of titles
/// already downloaded are the adapter's job, not the caller's (RF-20).
public protocol CatalogProvider: Sendable {
    /// Series and movies whose title matches the query.
    func search(_ query: String, in country: CountryCode) async throws -> [CatalogItem]

    /// Popular series and movies in a country, for the first-launch grid (RF-09).
    func popular(in country: CountryCode) async throws -> [CatalogItem]

    /// Full details of a series, with its availability in the country.
    func seriesDetails(for id: SeriesID, in country: CountryCode) async throws -> SeriesDetails

    /// Full details of a movie, with its availability in the country.
    func movieDetails(for id: MovieID, in country: CountryCode) async throws -> MovieDetails
}

public enum CatalogError: Error, Equatable, Sendable {
    /// The catalog has no title with that ID.
    case notFound
    /// The catalog cannot be reached right now.
    case unavailable
}
