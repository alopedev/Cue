import Foundation
import Testing

@testable import CueKit

/// A library wired to in-memory fakes, with one airing series, one ended series and a movie.
@MainActor
private struct LibraryHarness {
    static let airing = SeriesFixture(seasons: [3, 3], aired: 4)
    static let ended = SeriesFixture(seasons: [2], aired: 2, airingStatus: .ended, id: SeriesID(2))
    static let movie = SampleData.duneDetails

    let store = InMemoryLibraryStore()
    let clock = FakeClock(now: SeriesFixture.now)
    let model: LibraryModel

    init() {
        let catalog = InMemoryCatalogProvider(
            series: [Self.airing.details, Self.ended.details],
            movies: [Self.movie]
        )
        model = LibraryModel(store: store, catalog: catalog, clock: clock, country: SampleData.spain)
    }

    var airingItem: CatalogItem { .series(Self.airing.details.series) }
    var endedItem: CatalogItem { .series(Self.ended.details.series) }
    var movieItem: CatalogItem { .movie(Self.movie.movie) }

    func series(_ id: SeriesID) -> SeriesEntry? {
        model.entries.compactMap(\.seriesEntry).first { $0.id == id }
    }

    func movie() -> MovieEntry? {
        model.entries.compactMap(\.movieEntry).first
    }

    /// A second model reading the same store, as after closing and opening the app.
    func reopened() async -> LibraryModel {
        let catalog = InMemoryCatalogProvider(
            series: [Self.airing.details, Self.ended.details],
            movies: [Self.movie]
        )
        let model = LibraryModel(store: store, catalog: catalog, clock: clock, country: SampleData.spain)
        await model.load()
        return model
    }
}

@MainActor
@Suite("LibraryModel")
struct LibraryModelTests {
    @Test("A new library is empty once loaded")
    func startsEmpty() async {
        let harness = LibraryHarness()
        await harness.model.load()
        #expect(harness.model.isLoaded)
        #expect(harness.model.entries.isEmpty)
    }

    @Test("RF-49: added series and movies enter the library as pending")
    func addingMakesPending() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.add(harness.movieItem)

        #expect(harness.model.entries(on: .pending).count == 2)
        #expect(harness.model.contains(harness.airingItem))
        #expect(harness.model.contains(harness.movieItem))
        #expect(harness.series(SeriesFixture.id)?.tracking.addedAt == SeriesFixture.now)
    }

    @Test("Adding a title already in the library keeps it as it is")
    func addingTwiceKeepsOne() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markNextEpisode(of: SeriesFixture.id)
        await harness.model.add(harness.airingItem)

        #expect(harness.model.entries.count == 1)
        #expect(harness.series(SeriesFixture.id)?.tracking.status == .watching)
    }

    @Test("RF-30: marking the next episode moves a pending series to watching")
    func markNextEpisode() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markNextEpisode(of: SeriesFixture.id)

        let entry = try #require(harness.series(SeriesFixture.id))
        #expect(entry.tracking.status == .watching)
        #expect(entry.tracking.lastMarkedAt == SeriesFixture.now)
        #expect(entry.tracking.currentEpisode == LibraryHarness.airing.reference(1, 2))
        #expect(entry.progress.watchedAiredCount == 1)
        #expect(await harness.store.episodeMarks().map(\.episode) == [LibraryHarness.airing.reference(1, 1)])
        #expect(await harness.store.episodeMarks().first?.source == .manual)
    }

    @Test("Marking through an episode marks every earlier one too")
    func markThrough() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markThrough(LibraryHarness.airing.reference(2, 1))

        let entry = try #require(harness.series(SeriesFixture.id))
        #expect(entry.progress.watchedAiredCount == 4)
        #expect(entry.tracking.status == .upToDate)
    }

    @Test("RF-48: marking the last aired episode of an airing series makes it up to date")
    func upToDateAfterLastAired() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        for _ in 1...4 { await harness.model.markNextEpisode(of: SeriesFixture.id) }

        #expect(harness.series(SeriesFixture.id)?.tracking.status == .upToDate)
        #expect(harness.model.entries(on: .upToDate).count == 1)
    }

    @Test("Toggling a watched episode unmarks it")
    func toggleUnmarks() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.endedItem)
        let first = LibraryHarness.ended.reference(1, 1)
        await harness.model.toggle(first)
        await harness.model.toggle(first)

        let entry = try #require(harness.series(SeriesID(2)))
        #expect(entry.progress.watchedAiredCount == 0)
        #expect(entry.tracking.status == .pending)
        #expect(await harness.store.episodeMarks().isEmpty)
    }

    @Test("Finishing an ended series finishes it and celebrates")
    func finishingSeriesCelebrates() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.endedItem)
        await harness.model.markThrough(LibraryHarness.ended.reference(1, 2))

        #expect(harness.series(SeriesID(2))?.tracking.status == .finished)
        #expect(harness.model.celebration == Celebration(kind: .seriesFinished, title: "Serie de prueba"))
        harness.model.dismissCelebration()
        #expect(harness.model.celebration == nil)
    }

    @Test("Watching the last episode of a season celebrates the season")
    func finishingSeasonCelebrates() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        for _ in 1...2 { await harness.model.markNextEpisode(of: SeriesFixture.id) }
        #expect(harness.model.celebration == nil)
        await harness.model.markNextEpisode(of: SeriesFixture.id)

        #expect(harness.model.celebration == Celebration(kind: .seasonFinished(1), title: "Serie de prueba"))
    }

    @Test("RF-30: marking a movie watched moves it to finished and celebrates")
    func markMovieWatched() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.movieItem)
        await harness.model.markWatched(SampleData.duneID)

        let entry = try #require(harness.movie())
        #expect(entry.tracking.status == .watched)
        #expect(entry.tracking.watchedAt == SeriesFixture.now)
        #expect(harness.model.entries(on: .finished).count == 1)
        #expect(harness.model.celebration == Celebration(kind: .movieWatched, title: "Dune"))
    }

    @Test("RF-33: undo within 10 seconds restores the marks and the status")
    func undoWithinWindow() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markThrough(LibraryHarness.airing.reference(1, 2))
        #expect(
            harness.model.pendingUndo?.marked == [
                LibraryHarness.airing.reference(1, 1), LibraryHarness.airing.reference(1, 2),
            ]
        )

        harness.clock.advance(by: 9.9)
        #expect(harness.model.canUndo)
        await harness.model.undo()

        let entry = try #require(harness.series(SeriesFixture.id))
        #expect(entry.tracking.status == .pending)
        #expect(entry.progress.watchedAiredCount == 0)
        #expect(await harness.store.episodeMarks().isEmpty)
        #expect(harness.model.pendingUndo == nil)
    }

    @Test("RF-33: after 10 seconds the mark can no longer be undone")
    func undoExpires() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.movieItem)
        await harness.model.markWatched(SampleData.duneID)

        harness.clock.advance(by: 10)
        #expect(!harness.model.canUndo)
        await harness.model.undo()
        #expect(harness.movie()?.tracking.status == .watched)
    }

    @Test("Undoing a movie mark makes it pending again")
    func undoMovie() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.movieItem)
        await harness.model.markWatched(SampleData.duneID)
        await harness.model.undo()

        #expect(harness.movie()?.tracking.status == .pending)
        #expect(harness.movie()?.tracking.watchedAt == nil)
        #expect(harness.model.celebration == nil)
    }

    @Test("Undoing an unmark puts the episode back")
    func undoUnmark() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.endedItem)
        let first = LibraryHarness.ended.reference(1, 1)
        await harness.model.toggle(first)
        await harness.model.toggle(first)
        await harness.model.undo()

        #expect(harness.series(SeriesID(2))?.progress.watchedAiredCount == 1)
        #expect(harness.series(SeriesID(2))?.tracking.status == .watching)
    }

    @Test("A new mark replaces the previous undo")
    func newMarkReplacesUndo() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markNextEpisode(of: SeriesFixture.id)
        await harness.model.markNextEpisode(of: SeriesFixture.id)
        await harness.model.undo()

        #expect(harness.series(SeriesFixture.id)?.progress.watchedAiredCount == 1)
    }

    @Test("RF-37: the catch-up time adds the remaining minutes of every series being watched")
    func catchUpMinutes() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.add(harness.endedItem)
        await harness.model.markNextEpisode(of: SeriesFixture.id)  // 3 aired left × 50
        #expect(harness.model.catchUpMinutes == 150)

        await harness.model.markNextEpisode(of: SeriesID(2))  // 1 left × 50
        #expect(harness.model.catchUpMinutes == 200)
    }

    @Test("Shelves group statuses: dismissed and abandoned titles are dropped")
    func shelvesGroupStatuses() {
        #expect(LibraryShelf(SeriesStatus.finished) == .finished)
        #expect(LibraryShelf(MovieStatus.watched) == .finished)
        #expect(LibraryShelf(SeriesStatus.abandoned) == .dropped)
        #expect(LibraryShelf(MovieStatus.dismissed) == .dropped)
        #expect(LibraryShelf(SeriesStatus.paused) == .paused)
        #expect(LibraryShelf(MovieStatus.pending) == .pending)
        #expect(LibraryShelf(SeriesStatus.upToDate) == .upToDate)
        #expect(LibraryShelf.allCases.first == .watching)
    }

    @Test("Entries on a shelf come newest first")
    func shelfOrder() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        harness.clock.advance(by: 60)
        await harness.model.add(harness.movieItem)

        #expect(harness.model.entries(on: .pending).map(\.title) == ["Dune", "Serie de prueba"])
    }

    @Test("Everything is still there after closing and opening the app")
    func persistsAcrossLaunches() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.add(harness.movieItem)
        await harness.model.markNextEpisode(of: SeriesFixture.id)
        await harness.model.markWatched(SampleData.duneID)

        let reopened = await harness.reopened()
        #expect(reopened.entries(on: .watching).map(\.title) == ["Serie de prueba"])
        #expect(reopened.entries(on: .finished).map(\.title) == ["Dune"])
        #expect(reopened.pendingUndo == nil)
    }

    @Test("RF-47: on opening, an up-to-date series with a new aired episode is watching again")
    func newEpisodeOnOpening() async throws {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.add(harness.airingItem)
        await harness.model.markThrough(LibraryHarness.airing.reference(2, 1))
        #expect(harness.series(SeriesFixture.id)?.tracking.status == .upToDate)

        harness.clock.advance(by: 86_400)  // the next episode airs
        let reopened = await harness.reopened()
        let entry = try #require(reopened.entries(on: .watching).first?.seriesEntry)
        #expect(entry.tracking.currentEpisode == LibraryHarness.airing.reference(2, 2))
        #expect(await harness.store.seriesTrackings().first?.status == .watching)
    }

    @Test("A title the catalog no longer knows is left out and reported")
    func missingCatalogTitle() async {
        let store = InMemoryLibraryStore()
        await store.save(
            SeriesTracking(
                seriesID: SeriesID(99),
                status: .watching,
                addedAt: SeriesFixture.now,
                lastMarkedAt: nil,
                currentEpisode: nil
            )
        )
        let model = LibraryModel(
            store: store,
            catalog: InMemoryCatalogProvider(),
            clock: FakeClock(now: SeriesFixture.now),
            country: SampleData.spain
        )
        await model.load()
        #expect(model.entries.isEmpty)
        #expect(model.hasLoadingProblem)
    }

    @Test("Marking a title that is not in the library does nothing")
    func markingUnknownTitle() async {
        let harness = LibraryHarness()
        await harness.model.load()
        await harness.model.markNextEpisode(of: SeriesFixture.id)
        await harness.model.markWatched(SampleData.duneID)
        await harness.model.toggle(LibraryHarness.airing.reference(1, 1))
        #expect(harness.model.entries.isEmpty)
        #expect(harness.model.pendingUndo == nil)
    }
}
