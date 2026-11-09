import Testing

@testable import CueKit

@Suite("InMemoryCatalogProvider")
struct InMemoryCatalogProviderTests {
    let catalog = InMemoryCatalogProvider(
        series: [SampleData.severanceDetails],
        movies: [SampleData.duneDetails],
        popular: [SampleData.spain: [.movie(SampleData.dune)]]
    )

    @Test("Search finds series and movies by part of the title, ignoring case and accents")
    func searchMatchesPartOfTitle() async throws {
        #expect(try await catalog.search("sevérance", in: SampleData.spain) == [.series(SampleData.severance)])
        #expect(try await catalog.search("DUN", in: SampleData.spain) == [.movie(SampleData.dune)])
        #expect(try await catalog.search("zzz", in: SampleData.spain).isEmpty)
    }

    @Test("Popular returns the list given for that country")
    func popularDependsOnCountry() async throws {
        #expect(try await catalog.popular(in: SampleData.spain) == [.movie(SampleData.dune)])
        #expect(try await catalog.popular(in: SampleData.unitedStates).isEmpty)
    }

    @Test("Details only include availability in the requested country")
    func detailsFilterAvailabilityByCountry() async throws {
        let series = try await catalog.seriesDetails(for: SampleData.severanceID, in: SampleData.unitedStates)
        #expect(series.availability.map(\.country) == [SampleData.unitedStates])
        #expect(series.episodes == SampleData.severanceDetails.episodes)

        let movie = try await catalog.movieDetails(for: SampleData.duneID, in: SampleData.unitedStates)
        #expect(movie.availability.isEmpty)
    }

    @Test("Unknown titles throw notFound")
    func unknownTitlesThrowNotFound() async {
        await #expect(throws: CatalogError.notFound) {
            try await catalog.seriesDetails(for: SeriesID(1), in: SampleData.spain)
        }
        await #expect(throws: CatalogError.notFound) {
            try await catalog.movieDetails(for: MovieID(1), in: SampleData.spain)
        }
    }

    @Test("A failing catalog throws its error on every call")
    func failingCatalogThrows() async {
        let offline = InMemoryCatalogProvider(failure: .unavailable)
        await #expect(throws: CatalogError.unavailable) { try await offline.search("x", in: SampleData.spain) }
        await #expect(throws: CatalogError.unavailable) { try await offline.popular(in: SampleData.spain) }
        await #expect(throws: CatalogError.unavailable) {
            try await offline.seriesDetails(for: SampleData.severanceID, in: SampleData.spain)
        }
        await #expect(throws: CatalogError.unavailable) {
            try await offline.movieDetails(for: SampleData.duneID, in: SampleData.spain)
        }
    }
}
