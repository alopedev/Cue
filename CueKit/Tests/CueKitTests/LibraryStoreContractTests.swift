import Foundation
import Testing

@testable import CueKit

/// Which `LibraryStore` to build for a contract test run.
enum LibraryStoreKind: String, CaseIterable, CustomStringConvertible {
    case inMemory
    case swiftData

    var description: String { rawValue }

    func makeStore() throws -> any LibraryStore {
        switch self {
        case .inMemory: return InMemoryLibraryStore()
        case .swiftData: return try SwiftDataLibraryStore(inMemory: true)
        }
    }
}

/// Behaviour every `LibraryStore` must have (docs/adr/0002), checked against both the
/// in-memory fake and the real SwiftData adapter so neither one drifts from the rules.
@Suite("LibraryStore contract")
struct LibraryStoreContractTests {
    @Test("§4.4: saving the same series twice keeps one tracking, the latest", arguments: LibraryStoreKind.allCases)
    func seriesTrackingIsUnique(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let first = seriesTracking(.pending)
        let second = seriesTracking(.watching)
        try await store.save(first)
        try await store.save(second)
        #expect(try await store.seriesTrackings() == [second])
    }

    @Test("§4.4: saving the same movie twice keeps one tracking, the latest", arguments: LibraryStoreKind.allCases)
    func movieTrackingIsUnique(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let pending = MovieTracking(
            movieID: SampleData.duneID,
            status: .pending,
            addedAt: SampleData.reference,
            watchedAt: nil
        )
        let watched = MovieTracking(
            movieID: SampleData.duneID,
            status: .watched,
            addedAt: SampleData.reference,
            watchedAt: SampleData.date(daysAfterReference: 1)
        )
        try await store.save(pending)
        try await store.save(watched)
        #expect(try await store.movieTrackings() == [watched])
    }

    @Test("Trackings come back in the order they were first saved", arguments: LibraryStoreKind.allCases)
    func trackingsKeepInsertionOrder(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let other = SeriesTracking(
            seriesID: SeriesID(1),
            status: .watching,
            addedAt: SampleData.reference,
            lastMarkedAt: nil,
            currentEpisode: nil
        )
        try await store.save(seriesTracking(.pending))
        try await store.save(other)
        try await store.save(seriesTracking(.watching))
        #expect(try await store.seriesTrackings().map(\.seriesID) == [SampleData.severanceID, SeriesID(1)])
    }

    @Test("RF-33: a mark can be saved and removed to undo it", arguments: LibraryStoreKind.allCases)
    func markCanBeUndone(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let mark = EpisodeMark(episode: SampleData.episode(1, 1), markedAt: SampleData.reference, source: .manual)
        try await store.save(mark)
        #expect(try await store.episodeMarks() == [mark])

        try await store.removeMark(for: SampleData.episode(1, 1))
        #expect(try await store.episodeMarks().isEmpty)

        try await store.removeMark(for: SampleData.episode(1, 1))
        #expect(try await store.episodeMarks().isEmpty)
    }

    @Test("Marking the same episode twice keeps one mark", arguments: LibraryStoreKind.allCases)
    func markIsUniquePerEpisode(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let manual = EpisodeMark(episode: SampleData.episode(1, 1), markedAt: SampleData.reference, source: .manual)
        let fromTrakt = EpisodeMark(episode: SampleData.episode(1, 1), markedAt: SampleData.reference, source: .trakt)
        try await store.save(manual)
        try await store.save(fromTrakt)
        #expect(try await store.episodeMarks() == [fromTrakt])
    }

    @Test("A title keeps one rating, the latest", arguments: LibraryStoreKind.allCases)
    func ratingIsUniquePerTitle(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let first = try #require(SampleData.rating(6))
        let second = try #require(SampleData.rating(9, daysAfterReference: 1))
        try await store.save(first)
        try await store.save(second)
        #expect(try await store.ratings() == [second])
    }

    @Test("Saving a decision again updates its proposal outcomes", arguments: LibraryStoreKind.allCases)
    func decisionIsReplacedByID(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let issued = decision(outcome: .noResponse)
        let answered = decision(id: issued.id, outcome: .accepted)
        try await store.save(issued)
        try await store.save(answered)
        #expect(try await store.decisions() == [answered])
    }

    @Test("Rejections are kept in order", arguments: LibraryStoreKind.allCases)
    func rejectionsAreAppended(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        let first = Rejection(proposalID: UUID(), reason: .notTonight, rejectedAt: SampleData.reference)
        let second = Rejection(proposalID: UUID(), reason: .tooLong, rejectedAt: SampleData.reference)
        try await store.save(first)
        try await store.save(second)
        #expect(try await store.rejections() == [first, second])
    }

    @Test("RF-01: settings are nil until saved", arguments: LibraryStoreKind.allCases)
    func settingsStartEmpty(kind: LibraryStoreKind) async throws {
        let store = try kind.makeStore()
        #expect(try await store.settings() == nil)

        let settings = UserSettings(
            country: SampleData.spain,
            subscribedProviders: [8],
            lastWindow: nil,
            lastMoodID: nil,
            isTraktConnected: false
        )
        try await store.save(settings)
        #expect(try await store.settings() == settings)
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

    private func decision(id: UUID = UUID(), outcome: ProposalOutcome) -> Decision {
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
