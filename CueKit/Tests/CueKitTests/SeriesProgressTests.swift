import Foundation
import Testing

@testable import CueKit

@Suite("SeriesProgress")
struct SeriesProgressTests {
    @Test("§4.4: the current episode is the first unwatched aired episode in air order")
    func currentEpisodeIsFirstUnwatched() {
        let fixture = SeriesFixture(seasons: [3, 3], aired: 5)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 3)])
        #expect(progress.currentEpisode?.id == fixture.reference(1, 2))
    }

    @Test("Counts aired and watched episodes, ignoring episodes not aired yet")
    func countsAiredEpisodes() {
        let fixture = SeriesFixture(seasons: [4, 4], aired: 6)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 2)])
        #expect(progress.airedCount == 6)
        #expect(progress.watchedAiredCount == 2)
        #expect(progress.fractionWatched == 2.0 / 6.0)
        #expect(progress.hasUnairedEpisodes)
    }

    @Test("RF-35: remaining episodes and minutes cover only the unwatched aired ones")
    func remainingEpisodesAndMinutes() {
        let fixture = SeriesFixture(seasons: [5], aired: 4, runtimeMinutes: 45)
        let progress = fixture.progress(watching: [fixture.reference(1, 1)])
        #expect(progress.remainingEpisodes.map(\.id) == [2, 3, 4].map { fixture.reference(1, $0) })
        #expect(progress.remainingMinutes == 135)
    }

    @Test("An episode with no known runtime counts as the series' average runtime")
    func unknownRuntimeUsesAverage() {
        let fixture = SeriesFixture(seasons: [3], aired: 3, runtimeMinutes: 40)
        var details = fixture.details
        let episodes = details.episodes.enumerated().map { index, episode in
            Episode(
                id: episode.id,
                title: episode.title,
                runtimeMinutes: index == 2 ? nil : 30 + index * 20,
                airDate: episode.airDate
            )
        }
        details = SeriesDetails(series: details.series, seasons: details.seasons, episodes: episodes, availability: [])
        let progress = SeriesProgress(details: details, watched: [], now: SeriesFixture.now)
        // Known runtimes 30 and 50 average 40, so the third episode counts as 40.
        #expect(progress.remainingMinutes == 120)
    }

    @Test("With no runtime known at all, the remaining time is zero")
    func noRuntimeKnown() {
        let fixture = SeriesFixture(seasons: [2], aired: 2, runtimeMinutes: nil)
        #expect(fixture.progress(watching: []).remainingMinutes == 0)
    }

    @Test("Watching every aired episode means caught up, with no current episode")
    func caughtUp() {
        let fixture = SeriesFixture(seasons: [4], aired: 2)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 2)])
        #expect(progress.isCaughtUp)
        #expect(progress.currentEpisode == nil)
        #expect(progress.remainingMinutes == 0)
    }

    @Test("A series with nothing aired yet is not caught up and has nothing to watch")
    func nothingAired() {
        let fixture = SeriesFixture(seasons: [3], aired: 0)
        let progress = fixture.progress(watching: [])
        #expect(!progress.isCaughtUp)
        #expect(progress.currentEpisode == nil)
        #expect(progress.fractionWatched == 0)
    }

    @Test("Specials (season 0) do not count towards progress")
    func specialsAreIgnored() {
        let fixture = SeriesFixture(seasons: [2], aired: 2)
        let base = fixture.details
        let special = Episode(
            id: EpisodeReference(seriesID: SeriesFixture.id, seasonNumber: 0, episodeNumber: 1),
            title: "Especial",
            runtimeMinutes: 20,
            airDate: SeriesFixture.now.addingTimeInterval(-86_400 * 30)
        )
        let details = SeriesDetails(
            series: base.series,
            seasons: base.seasons,
            episodes: [special] + base.episodes,
            availability: []
        )
        let progress = SeriesProgress(details: details, watched: [], now: SeriesFixture.now)
        #expect(progress.airedCount == 2)
        #expect(progress.currentEpisode?.id == fixture.reference(1, 1))
    }

    @Test("Every episode up to a given one, in air order, crossing seasons")
    func episodesUpTo() {
        let fixture = SeriesFixture(seasons: [2, 2], aired: 4)
        let progress = fixture.progress(watching: [])
        #expect(progress.episodes(through: fixture.reference(2, 1)).map(\.id) == [
            fixture.reference(1, 1), fixture.reference(1, 2), fixture.reference(2, 1),
        ])
        #expect(progress.episodes(through: fixture.reference(9, 9)).isEmpty)
    }

    @Test("The last episode of its season and of the series are recognised")
    func seasonAndSeriesEndings() {
        let fixture = SeriesFixture(seasons: [2, 2], aired: 4)
        let progress = fixture.progress(watching: [])
        #expect(progress.isLastOfSeason(fixture.reference(1, 2)))
        #expect(!progress.isLastOfSeason(fixture.reference(1, 1)))
        #expect(progress.isLastOfSeason(fixture.reference(2, 2)))
    }
}
