import Foundation

@testable import CueKit

/// Builds series details for the library tests: episodes in air order, one day apart.
struct SeriesFixture {
    static let now = SampleData.reference
    static let id = SeriesID(1)

    /// Episodes per season, e.g. `[3, 2]` is S1E1…S1E3, S2E1, S2E2.
    var seasons: [Int]
    /// How many episodes, counting from the first, have already aired.
    var aired: Int
    var airingStatus: AiringStatus = .airing
    var runtimeMinutes: Int? = 50

    var references: [EpisodeReference] {
        seasons.enumerated().flatMap { index, count in
            (1...count).map { EpisodeReference(seriesID: Self.id, seasonNumber: index + 1, episodeNumber: $0) }
        }
    }

    func reference(_ season: Int, _ episode: Int) -> EpisodeReference {
        EpisodeReference(seriesID: Self.id, seasonNumber: season, episodeNumber: episode)
    }

    var details: SeriesDetails {
        let episodes = references.enumerated().map { position, reference in
            let daysFromNow = Double(position - aired + 1)  // the last aired episode aired today
            return Episode(
                id: reference,
                title: "Episodio \(reference.episodeNumber)",
                runtimeMinutes: runtimeMinutes,
                airDate: Self.now.addingTimeInterval(daysFromNow * 86_400 - 3_600)
            )
        }
        let series = Series(
            id: Self.id,
            title: "Serie de prueba",
            year: 2025,
            seasonCount: seasons.count,
            airingStatus: airingStatus,
            genres: [],
            keywords: [],
            posterURL: nil
        )
        let seasonList = seasons.enumerated().map {
            Season(seriesID: Self.id, number: $0.offset + 1, episodeCount: $0.element)
        }
        return SeriesDetails(series: series, seasons: seasonList, episodes: episodes, availability: [])
    }

    func progress(watching watched: [EpisodeReference]) -> SeriesProgress {
        SeriesProgress(details: details, watched: Set(watched), now: Self.now)
    }
}
