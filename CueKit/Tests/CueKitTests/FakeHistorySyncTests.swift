import Testing

@testable import CueKit

@Suite("FakeHistorySync")
struct FakeHistorySyncTests {
    let oldMark = EpisodeMark(episode: SampleData.episode(1, 1), markedAt: SampleData.reference, source: .trakt)
    let newMark = EpisodeMark(
        episode: SampleData.episode(1, 2),
        markedAt: SampleData.date(daysAfterReference: 2),
        source: .trakt
    )

    @Test("RF-52: with no date, everything in Trakt comes back")
    func fetchWithoutDateReturnsEverything() async throws {
        let history = try remoteHistory()
        let sync = FakeHistorySync(remote: history)
        #expect(try await sync.fetchChanges(since: nil) == history)
    }

    @Test("RF-54: with a date, only what changed after it comes back")
    func fetchSinceDateReturnsOnlyNewer() async throws {
        let sync = FakeHistorySync(remote: try remoteHistory())
        let changes = try await sync.fetchChanges(since: SampleData.date(daysAfterReference: 1))
        #expect(changes.episodeMarks == [newMark])
        #expect(changes.movieWatches.isEmpty)
        #expect(changes.ratings.map(\.value.rawValue) == [9])
        #expect(changes.watchlist == [.series(SampleData.severanceID)])
    }

    @Test("RF-53: sent changes are recorded in order")
    func sentChangesAreRecorded() async throws {
        let sync = FakeHistorySync()
        try await sync.send(.episodeMarked(newMark))
        try await sync.send(.movieWatched(MovieWatch(movieID: SampleData.duneID, watchedAt: SampleData.reference)))
        #expect(
            await sync.sentChanges == [
                .episodeMarked(newMark),
                .movieWatched(MovieWatch(movieID: SampleData.duneID, watchedAt: SampleData.reference)),
            ]
        )
    }

    @Test("RF-55: while failing, sends throw and are not recorded; after recovery they go through")
    func failingSendCanRecover() async throws {
        let sync = FakeHistorySync(failure: .unavailable)
        await #expect(throws: HistorySyncError.unavailable) { try await sync.send(.episodeMarked(newMark)) }
        await #expect(throws: HistorySyncError.unavailable) { try await sync.fetchChanges(since: nil) }
        #expect(await sync.sentChanges.isEmpty)

        await sync.setFailure(nil)
        try await sync.send(.episodeMarked(newMark))
        #expect(await sync.sentChanges == [.episodeMarked(newMark)])
    }

    @Test("RF-57: after disconnecting, every call throws notConnected")
    func disconnectStopsSync() async throws {
        let sync = FakeHistorySync()
        try await sync.disconnect()
        await #expect(throws: HistorySyncError.notConnected) { try await sync.fetchChanges(since: nil) }
        await #expect(throws: HistorySyncError.notConnected) { try await sync.send(.episodeMarked(newMark)) }
        await #expect(throws: HistorySyncError.notConnected) { try await sync.disconnect() }
    }

    private func remoteHistory() throws -> SyncedHistory {
        SyncedHistory(
            episodeMarks: [oldMark, newMark],
            movieWatches: [MovieWatch(movieID: SampleData.duneID, watchedAt: SampleData.reference)],
            watchlist: [.series(SampleData.severanceID)],
            ratings: [try #require(SampleData.rating(6)), try #require(SampleData.rating(9, daysAfterReference: 2))]
        )
    }
}
