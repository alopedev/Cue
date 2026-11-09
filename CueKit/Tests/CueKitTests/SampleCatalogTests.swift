import Foundation
import Testing

@testable import CueKit

@Suite("SampleCatalog")
struct SampleCatalogTests {
    let now = SampleData.reference

    private func allSeriesDetails() async throws -> [SeriesDetails] {
        let catalog = SampleCatalog.provider(now: now, country: SampleData.spain)
        var details: [SeriesDetails] = []
        for case .series(let series) in SampleCatalog.items(now: now) {
            details.append(try await catalog.seriesDetails(for: series.id, in: SampleData.spain))
        }
        return details
    }

    @Test("Offers series and movies, all listed as popular in the user's country")
    func offersSeriesAndMovies() async throws {
        let items = SampleCatalog.items(now: now)
        let popular = try await SampleCatalog.provider(now: now, country: SampleData.spain).popular(in: SampleData.spain)
        #expect(popular == items)
        #expect(items.filter { if case .series = $0 { true } else { false } }.count == 8)
        #expect(items.filter { if case .movie = $0 { true } else { false } }.count == 6)
    }

    @Test("Covers airing, ended and canceled series")
    func coversAiringStatuses() async throws {
        let statuses = Set(try await allSeriesDetails().map(\.series.airingStatus))
        #expect(statuses == [.airing, .ended, .canceled])
    }

    @Test("Airing series have aired episodes and episodes still to air; the others are complete")
    func airDatesFollowStatus() async throws {
        for details in try await allSeriesDetails() {
            let progress = SeriesProgress(details: details, watched: [], now: now)
            #expect(progress.airedCount > 0)
            #expect(progress.hasUnairedEpisodes == (details.series.airingStatus == .airing))
        }
    }

    @Test("Seasons match their episodes and every episode has a runtime")
    func seasonsMatchEpisodes() async throws {
        for details in try await allSeriesDetails() {
            #expect(details.seasons.reduce(0) { $0 + $1.episodeCount } == details.episodes.count)
            #expect(details.episodes.allSatisfy { ($0.runtimeMinutes ?? 0) > 0 })
        }
    }

    @Test("Every movie has its details and runtime")
    func moviesHaveDetails() async throws {
        let catalog = SampleCatalog.provider(now: now, country: SampleData.spain)
        for case .movie(let movie) in SampleCatalog.items(now: now) {
            let details = try await catalog.movieDetails(for: movie.id, in: SampleData.spain)
            #expect((details.movie.runtimeMinutes ?? 0) > 0)
        }
    }
}
