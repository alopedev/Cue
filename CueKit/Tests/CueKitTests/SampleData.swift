import Foundation

@testable import CueKit

/// Small catalog and dates shared by the tests.
enum SampleData {
    static let spain = CountryCode("ES")
    static let unitedStates = CountryCode("US")
    static let netflix = StreamingProvider(id: 8, name: "Netflix", logoURL: nil)

    static let reference = Date(timeIntervalSince1970: 1_800_000_000)

    static func date(daysAfterReference days: Double) -> Date {
        reference.addingTimeInterval(days * 86_400)
    }

    static let severanceID = SeriesID(95396)
    static let duneID = MovieID(438631)

    static let severance = Series(
        id: severanceID,
        title: "Severance",
        year: 2022,
        seasonCount: 2,
        airingStatus: .airing,
        genres: [Genre(id: 18, name: "Drama")],
        keywords: [],
        posterURL: nil
    )

    static let dune = Movie(
        id: duneID,
        title: "Dune",
        year: 2021,
        runtimeMinutes: 155,
        genres: [Genre(id: 878, name: "Science Fiction")],
        keywords: [],
        posterURL: nil
    )

    static let severanceDetails = SeriesDetails(
        series: severance,
        seasons: [Season(seriesID: severanceID, number: 1, episodeCount: 9)],
        episodes: [
            Episode(id: episode(1, 1), title: "Good News About Hell", runtimeMinutes: 57, airDate: reference)
        ],
        availability: [
            Availability(title: .series(severanceID), provider: netflix, country: spain, access: .subscription),
            Availability(title: .series(severanceID), provider: netflix, country: unitedStates, access: .subscription),
        ]
    )

    static let duneDetails = MovieDetails(
        movie: dune,
        availability: [Availability(title: .movie(duneID), provider: netflix, country: spain, access: .rent)]
    )

    static func episode(_ season: Int, _ number: Int) -> EpisodeReference {
        EpisodeReference(seriesID: severanceID, seasonNumber: season, episodeNumber: number)
    }

    static func rating(_ value: Int, daysAfterReference days: Double = 0) -> Rating? {
        RatingValue(value).map {
            Rating(title: .movie(duneID), value: $0, ratedAt: date(daysAfterReference: days), source: .manual)
        }
    }
}
