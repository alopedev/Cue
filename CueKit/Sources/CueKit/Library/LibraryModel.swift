import Foundation
import Observation

/// The user's library as the screens see it: what they follow, grouped by status, and the
/// actions on it (add, mark, undo). Every change is saved through `LibraryStore` at once.
@MainActor
@Observable
public final class LibraryModel {
    /// How long a marking change can be undone (RF-33).
    public static let undoWindow: TimeInterval = 10

    public private(set) var entries: [LibraryEntry] = []
    public private(set) var isLoaded = false
    /// Some titles could not be read from the store or the catalog.
    public private(set) var hasLoadingProblem = false
    /// The last change could not be saved.
    public private(set) var hasSavingProblem = false
    public private(set) var pendingUndo: PendingUndo?
    public private(set) var celebration: Celebration?

    @ObservationIgnored private var addsInProgress: Set<TitleID> = []
    @ObservationIgnored private let store: any LibraryStore
    @ObservationIgnored private let catalog: any CatalogProvider
    @ObservationIgnored private let clock: any Clock
    @ObservationIgnored private let country: CountryCode

    public init(store: any LibraryStore, catalog: any CatalogProvider, clock: any Clock, country: CountryCode) {
        self.store = store
        self.catalog = catalog
        self.clock = clock
        self.country = country
    }

    // MARK: Reading

    /// Titles on a shelf, the most recently added or marked first.
    public func entries(on shelf: LibraryShelf) -> [LibraryEntry] {
        entries.filter { $0.shelf == shelf }.sorted { $0.lastActivity > $1.lastActivity }
    }

    public func contains(_ item: CatalogItem) -> Bool {
        index(of: item.titleID) != nil
    }

    /// Minutes needed to catch up with every series being watched (RF-37).
    public var catchUpMinutes: Int {
        entries.compactMap(\.seriesEntry)
            .filter { $0.tracking.status == .watching }
            .reduce(0) { $0 + $1.progress.remainingMinutes }
    }

    /// The last change can still be undone.
    public var canUndo: Bool {
        guard let pendingUndo else { return false }
        return clock.now < pendingUndo.expiresAt
    }

    // MARK: Loading

    /// Reads the library from the store and the titles' details from the catalog.
    public func load() async {
        do {
            let marks = Dictionary(grouping: try await store.episodeMarks(), by: \.episode.seriesID)
            var loaded: [LibraryEntry] = []
            for tracking in try await store.seriesTrackings() {
                let seriesMarks = marks[tracking.seriesID] ?? []
                if let entry = await loadSeries(tracking, marks: seriesMarks) { loaded.append(.series(entry)) }
            }
            for tracking in try await store.movieTrackings() {
                if let entry = await loadMovie(tracking) { loaded.append(.movie(entry)) }
            }
            entries = loaded
        } catch {
            hasLoadingProblem = true
        }
        isLoaded = true
    }

    private func loadSeries(_ tracking: SeriesTracking, marks: [EpisodeMark]) async -> SeriesEntry? {
        guard let details = try? await catalog.seriesDetails(for: tracking.seriesID, in: country) else {
            hasLoadingProblem = true
            return nil
        }
        let markRecords = Dictionary(marks.map { ($0.episode, $0) }, uniquingKeysWith: { first, _ in first })
        let entry = SeriesEntry(details: details, tracking: tracking, marks: markRecords, now: clock.now)
        // A new episode may have aired since the last time (RF-47).
        let status = SeriesStatusRules.refreshedStatus(tracking.status, progress: entry.progress)
        let current = entry.progress.currentEpisode?.id
        guard status != tracking.status || current != tracking.currentEpisode else { return entry }
        let refreshed = tracking.with(status: status, currentEpisode: current)
        // Show the refreshed status only if it was saved, so the next launch shows the same.
        guard (try? await store.save(refreshed)) != nil else { return entry }
        return SeriesEntry(details: details, tracking: refreshed, marks: markRecords, now: clock.now)
    }

    private func loadMovie(_ tracking: MovieTracking) async -> MovieEntry? {
        guard let details = try? await catalog.movieDetails(for: tracking.movieID, in: country) else {
            hasLoadingProblem = true
            return nil
        }
        return MovieEntry(details: details, tracking: tracking)
    }

    // MARK: Adding

    /// Adds a series or movie as pending (RF-49). Does nothing if it is already in the library.
    public func add(_ item: CatalogItem) async {
        // A second tap while the first one is still saving must not add the title twice.
        guard !contains(item), !addsInProgress.contains(item.titleID) else { return }
        addsInProgress.insert(item.titleID)
        defer { addsInProgress.remove(item.titleID) }
        await saving {
            switch item {
            case .series(let series):
                let details = try await catalog.seriesDetails(for: series.id, in: country)
                let tracking = SeriesTracking(
                    seriesID: series.id,
                    status: .pending,
                    addedAt: clock.now,
                    lastMarkedAt: nil,
                    currentEpisode: nil
                )
                try await store.save(tracking)
                entries.append(.series(SeriesEntry(details: details, tracking: tracking, marks: [:], now: clock.now)))
            case .movie(let movie):
                let details = try await catalog.movieDetails(for: movie.id, in: country)
                let tracking = MovieTracking(movieID: movie.id, status: .pending, addedAt: clock.now, watchedAt: nil)
                try await store.save(tracking)
                entries.append(.movie(MovieEntry(details: details, tracking: tracking)))
            }
        }
    }

    // MARK: Marking series

    /// Marks the current episode of a series as watched (RF-30).
    public func markNextEpisode(of seriesID: SeriesID) async {
        guard let entry = seriesEntry(seriesID), let next = entry.progress.currentEpisode else { return }
        await changeMarks(of: entry, marking: [next.id], unmarking: [])
    }

    /// Marks an episode, or unmarks it if it was already watched.
    public func toggle(_ episode: EpisodeReference) async {
        guard let entry = seriesEntry(episode.seriesID) else { return }
        if entry.marks[episode] == nil {
            await changeMarks(of: entry, marking: [episode], unmarking: [])
        } else {
            await changeMarks(of: entry, marking: [], unmarking: [episode])
        }
    }

    /// Marks an episode and every episode before it.
    public func markThrough(_ episode: EpisodeReference) async {
        guard let entry = seriesEntry(episode.seriesID) else { return }
        let episodes = entry.progress.episodes(through: episode).map(\.id)
        await changeMarks(of: entry, marking: episodes, unmarking: [])
    }

    private func changeMarks(
        of entry: SeriesEntry,
        marking toMark: [EpisodeReference],
        unmarking toUnmark: [EpisodeReference]
    ) async {
        let now = clock.now
        let newMarks = toMark.filter { entry.marks[$0] == nil }.map {
            EpisodeMark(episode: $0, markedAt: now, source: .manual)
        }
        let removedMarks = toUnmark.compactMap { entry.marks[$0] }
        guard !newMarks.isEmpty || !removedMarks.isEmpty else { return }

        var marks = entry.marks
        newMarks.forEach { marks[$0.episode] = $0 }
        removedMarks.forEach { marks[$0.episode] = nil }
        let progress = SeriesProgress(details: entry.details, watched: Set(marks.keys), now: now)
        let status = SeriesStatusRules.statusAfterMarking(
            entry.tracking.status,
            progress: progress,
            airing: entry.details.series.airingStatus
        )
        let tracking = SeriesTracking(
            seriesID: entry.id,
            status: status,
            addedAt: entry.tracking.addedAt,
            lastMarkedAt: newMarks.isEmpty ? entry.tracking.lastMarkedAt : now,
            currentEpisode: progress.currentEpisode?.id
        )
        let updated = SeriesEntry(details: entry.details, tracking: tracking, marks: marks, now: now)

        await saving {
            for mark in newMarks { try await store.save(mark) }
            for mark in removedMarks { try await store.removeMark(for: mark.episode) }
            try await store.save(tracking)
            replace(.series(updated))
            pendingUndo = PendingUndo(
                marked: newMarks.map(\.episode),
                removedMarks: removedMarks,
                previousTracking: .series(entry.tracking),
                title: entry.details.series.title,
                expiresAt: now.addingTimeInterval(Self.undoWindow)
            )
            celebration = Self.celebration(before: entry, after: updated, newlyMarked: newMarks.map(\.episode))
        }
    }

    private static func celebration(
        before: SeriesEntry,
        after: SeriesEntry,
        newlyMarked: [EpisodeReference]
    ) -> Celebration? {
        let title = after.details.series.title
        if after.tracking.status == .finished, before.tracking.status != .finished {
            return Celebration(kind: .seriesFinished, title: title)
        }
        let watched = after.watchedEpisodes
        let finishedSeason = newlyMarked.last { episode in
            after.progress.isLastOfSeason(episode)
                && after.progress.episodes.filter { $0.id.seasonNumber == episode.seasonNumber }
                    .allSatisfy { watched.contains($0.id) }
        }
        return finishedSeason.map { Celebration(kind: .seasonFinished($0.seasonNumber), title: title) }
    }

    // MARK: Marking movies

    /// Marks a movie as watched (RF-30). Does nothing if it already is.
    public func markWatched(_ movieID: MovieID) async {
        guard let entry = movieEntry(movieID), entry.tracking.status != .watched else { return }
        let now = clock.now
        let tracking = MovieTracking(
            movieID: movieID,
            status: .watched,
            addedAt: entry.tracking.addedAt,
            watchedAt: now
        )
        await saving {
            try await store.save(tracking)
            replace(.movie(MovieEntry(details: entry.details, tracking: tracking)))
            pendingUndo = PendingUndo(
                marked: [],
                removedMarks: [],
                previousTracking: .movie(entry.tracking),
                title: entry.details.movie.title,
                expiresAt: now.addingTimeInterval(Self.undoWindow)
            )
            celebration = Celebration(kind: .movieWatched, title: entry.details.movie.title)
        }
    }

    // MARK: Undo and celebration

    /// Reverts the last marking change, if it happened less than 10 seconds ago (RF-33).
    public func undo() async {
        guard canUndo, let undo = pendingUndo else { return }
        pendingUndo = nil
        celebration = nil
        await saving {
            switch undo.previousTracking {
            case .series(let previous):
                guard let entry = seriesEntry(previous.seriesID) else { return }
                var marks = entry.marks
                for episode in undo.marked {
                    try await store.removeMark(for: episode)
                    marks[episode] = nil
                }
                for mark in undo.removedMarks {
                    try await store.save(mark)
                    marks[mark.episode] = mark
                }
                try await store.save(previous)
                replace(.series(SeriesEntry(details: entry.details, tracking: previous, marks: marks, now: clock.now)))
            case .movie(let previous):
                guard let entry = movieEntry(previous.movieID) else { return }
                try await store.save(previous)
                replace(.movie(MovieEntry(details: entry.details, tracking: previous)))
            }
        }
    }

    public func dismissCelebration() {
        celebration = nil
    }

    // MARK: Helpers

    private func saving(_ change: () async throws -> Void) async {
        do {
            try await change()
            hasSavingProblem = false
        } catch {
            hasSavingProblem = true
        }
    }

    private func index(of id: TitleID) -> Int? {
        entries.firstIndex { $0.id == id }
    }

    private func replace(_ entry: LibraryEntry) {
        guard let index = index(of: entry.id) else { return }
        entries[index] = entry
    }

    private func seriesEntry(_ id: SeriesID) -> SeriesEntry? {
        index(of: .series(id)).flatMap { entries[$0].seriesEntry }
    }

    private func movieEntry(_ id: MovieID) -> MovieEntry? {
        index(of: .movie(id)).flatMap { entries[$0].movieEntry }
    }
}

extension CatalogItem {
    public var titleID: TitleID {
        switch self {
        case .series(let series): .series(series.id)
        case .movie(let movie): .movie(movie.id)
        }
    }
}

extension SeriesTracking {
    func with(status: SeriesStatus, currentEpisode: EpisodeReference?) -> SeriesTracking {
        SeriesTracking(
            seriesID: seriesID,
            status: status,
            addedAt: addedAt,
            lastMarkedAt: lastMarkedAt,
            currentEpisode: currentEpisode
        )
    }
}
