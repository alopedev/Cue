/// Where the user's data is kept. Real version: SwiftData with iCloud (docs/adr/0002).
///
/// Saving something that already exists for the same key replaces it, so there is
/// at most one tracking per series or movie and one rating per title (PRD §4.4).
public protocol LibraryStore: Sendable {
    // MARK: Trackings

    func seriesTrackings() async throws -> [SeriesTracking]
    /// Replaces any tracking with the same series ID.
    func save(_ tracking: SeriesTracking) async throws

    func movieTrackings() async throws -> [MovieTracking]
    /// Replaces any tracking with the same movie ID.
    func save(_ tracking: MovieTracking) async throws

    // MARK: Episode marks

    func episodeMarks() async throws -> [EpisodeMark]
    /// Replaces any mark for the same episode.
    func save(_ mark: EpisodeMark) async throws
    /// Removes the mark of an episode, to undo it (RF-33). Does nothing if there is none.
    func removeMark(for episode: EpisodeReference) async throws

    // MARK: Ratings

    func ratings() async throws -> [Rating]
    /// Replaces any rating for the same title.
    func save(_ rating: Rating) async throws

    // MARK: Decisions and rejections

    func decisions() async throws -> [Decision]
    /// Replaces any decision with the same ID, so proposal outcomes can be updated.
    func save(_ decision: Decision) async throws

    func rejections() async throws -> [Rejection]
    func save(_ rejection: Rejection) async throws

    // MARK: Settings

    /// Nil until the first launch is completed (RF-01).
    func settings() async throws -> UserSettings?
    func save(_ settings: UserSettings) async throws
}
