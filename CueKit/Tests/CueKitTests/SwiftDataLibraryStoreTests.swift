import Foundation
import SwiftData
import Testing

@testable import CueKit

/// Behaviour specific to the SwiftData adapter: persisting to a real file, and
/// collapsing duplicate rows that can arrive through CloudKit sync (docs/adr/0002).
/// The rules every `LibraryStore` shares are checked in `LibraryStoreContractTests`.
@Suite("SwiftDataLibraryStore")
struct SwiftDataLibraryStoreTests {
    @Test("A tracking saved on disk is there after reopening the store")
    func persistsAcrossInstances() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "Library.store")

        let tracking = SeriesTracking(
            seriesID: SampleData.severanceID,
            status: .watching,
            addedAt: SampleData.reference,
            lastMarkedAt: nil,
            currentEpisode: SampleData.episode(1, 1)
        )

        let firstInstance = try SwiftDataLibraryStore(url: storeURL)
        try await firstInstance.save(tracking)

        let secondInstance = try SwiftDataLibraryStore(url: storeURL)
        #expect(try await secondInstance.seriesTrackings() == [tracking])
    }

    @Test("A duplicate series tracking row that arrives via sync collapses to the newest")
    func collapsesDuplicateSeriesTrackings() async throws {
        let store = try SwiftDataLibraryStore(inMemory: true)
        let older = seriesTracking(.pending)
        let newer = seriesTracking(.watching)

        try await store.insertRowDirectly(older, createdAt: SampleData.reference, updatedAt: SampleData.reference)
        try await store.insertRowDirectly(
            newer,
            createdAt: SampleData.date(daysAfterReference: 1),
            updatedAt: SampleData.date(daysAfterReference: 1)
        )

        #expect(try await store.seriesTrackings() == [newer])
    }

    @Test("A duplicate episode mark row that arrives via sync collapses to the newest")
    func collapsesDuplicateEpisodeMarks() async throws {
        let store = try SwiftDataLibraryStore(inMemory: true)
        let manual = EpisodeMark(episode: SampleData.episode(1, 1), markedAt: SampleData.reference, source: .manual)
        let fromTrakt = EpisodeMark(
            episode: SampleData.episode(1, 1),
            markedAt: SampleData.date(daysAfterReference: 1),
            source: .trakt
        )

        try await store.insertRowDirectly(manual, createdAt: SampleData.reference, updatedAt: SampleData.reference)
        try await store.insertRowDirectly(
            fromTrakt,
            createdAt: SampleData.date(daysAfterReference: 1),
            updatedAt: SampleData.date(daysAfterReference: 1)
        )

        #expect(try await store.episodeMarks() == [fromTrakt])
    }

    @Test("A duplicate rating row that arrives via sync collapses to the newest")
    func collapsesDuplicateRatings() async throws {
        let store = try SwiftDataLibraryStore(inMemory: true)
        let first = try #require(SampleData.rating(6))
        let second = try #require(SampleData.rating(9, daysAfterReference: 1))

        try await store.insertRowDirectly(first, createdAt: SampleData.reference, updatedAt: SampleData.reference)
        try await store.insertRowDirectly(
            second,
            createdAt: SampleData.date(daysAfterReference: 1),
            updatedAt: SampleData.date(daysAfterReference: 1)
        )

        #expect(try await store.ratings() == [second])
    }

    @Test("A duplicate decision row that arrives via sync collapses to the newest")
    func collapsesDuplicateDecisions() async throws {
        let store = try SwiftDataLibraryStore(inMemory: true)
        let id = UUID()
        let issued = decision(id: id, outcome: .noResponse)
        let answered = decision(id: id, outcome: .accepted)

        try await store.insertRowDirectly(issued, createdAt: SampleData.reference, updatedAt: SampleData.reference)
        try await store.insertRowDirectly(
            answered,
            createdAt: SampleData.date(daysAfterReference: 1),
            updatedAt: SampleData.date(daysAfterReference: 1)
        )

        #expect(try await store.decisions() == [answered])
    }

    @Test("A duplicate settings row that arrives via sync collapses to the newest")
    func collapsesDuplicateSettings() async throws {
        let store = try SwiftDataLibraryStore(inMemory: true)
        let first = UserSettings(
            country: SampleData.spain,
            subscribedProviders: [8],
            lastWindow: nil,
            lastMoodID: nil,
            isTraktConnected: false
        )
        let second = UserSettings(
            country: SampleData.unitedStates,
            subscribedProviders: [8, 9],
            lastWindow: TimeWindow(minutes: 60),
            lastMoodID: "laugh",
            isTraktConnected: true
        )

        try await store.insertRowDirectly(first, createdAt: SampleData.reference, updatedAt: SampleData.reference)
        try await store.insertRowDirectly(
            second,
            createdAt: SampleData.date(daysAfterReference: 1),
            updatedAt: SampleData.date(daysAfterReference: 1)
        )

        #expect(try await store.settings() == second)
    }

    private func seriesTracking(_ status: SeriesStatus) -> SeriesTracking {
        SeriesTracking(
            seriesID: SampleData.severanceID,
            status: status,
            addedAt: SampleData.reference,
            lastMarkedAt: nil,
            currentEpisode: SampleData.episode(1, 1)
        )
    }

    private func decision(id: UUID, outcome: ProposalOutcome) -> Decision {
        let proposal = Proposal(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            item: .movie(SampleData.duneID),
            origin: .userList,
            explanation: "Cabe justo en tu tiempo.",
            signals: [WeightedSignal(signal: .windowFit, value: 1, weight: 1)],
            outcome: outcome
        )
        return Decision(
            id: id,
            issuedAt: SampleData.reference,
            window: TimeWindow(minutes: 120),
            moodID: "any",
            proposals: [proposal]
        )
    }
}
