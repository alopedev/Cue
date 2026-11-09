import Foundation

/// The user's library held in memory, for tests and sample data.
///
/// Follows the same uniqueness rules as the real store: saving an existing key replaces it.
public actor InMemoryLibraryStore: LibraryStore {
    private var seriesTrackingList = KeyedList<SeriesID, SeriesTracking>()
    private var movieTrackingList = KeyedList<MovieID, MovieTracking>()
    private var markList = KeyedList<EpisodeReference, EpisodeMark>()
    private var ratingList = KeyedList<TitleID, Rating>()
    private var decisionList = KeyedList<UUID, Decision>()
    private var rejectionList: [Rejection] = []
    private var storedSettings: UserSettings?

    public init() {}

    public func seriesTrackings() -> [SeriesTracking] { seriesTrackingList.values }
    public func save(_ tracking: SeriesTracking) { seriesTrackingList.upsert(tracking, key: tracking.seriesID) }

    public func movieTrackings() -> [MovieTracking] { movieTrackingList.values }
    public func save(_ tracking: MovieTracking) { movieTrackingList.upsert(tracking, key: tracking.movieID) }

    public func episodeMarks() -> [EpisodeMark] { markList.values }
    public func save(_ mark: EpisodeMark) { markList.upsert(mark, key: mark.episode) }
    public func removeMark(for episode: EpisodeReference) { markList.remove(key: episode) }

    public func ratings() -> [Rating] { ratingList.values }
    public func save(_ rating: Rating) { ratingList.upsert(rating, key: rating.title) }

    public func decisions() -> [Decision] { decisionList.values }
    public func save(_ decision: Decision) { decisionList.upsert(decision, key: decision.id) }

    public func rejections() -> [Rejection] { rejectionList }
    public func save(_ rejection: Rejection) { rejectionList.append(rejection) }

    public func settings() -> UserSettings? { storedSettings }
    public func save(_ settings: UserSettings) { storedSettings = settings }
}

/// Values unique by key, kept in the order their key was first saved.
private struct KeyedList<Key: Hashable, Value> {
    private var keys: [Key] = []
    private var valuesByKey: [Key: Value] = [:]

    var values: [Value] { keys.compactMap { valuesByKey[$0] } }

    mutating func upsert(_ value: Value, key: Key) {
        if valuesByKey.updateValue(value, forKey: key) == nil {
            keys.append(key)
        }
    }

    mutating func remove(key: Key) {
        guard valuesByKey.removeValue(forKey: key) != nil else { return }
        keys.removeAll { $0 == key }
    }
}
