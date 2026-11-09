// Configuration entities (PRD §4.2), defined by the app.

/// Which TMDB genres or keywords a mood accepts, for one kind of title.
public enum MoodCriteria: Hashable, Sendable {
    /// Accepts every title ("Me da igual").
    case everything
    /// Accepts titles with any of these genres or keywords.
    case matching(genreIDs: Set<Int>, keywordIDs: Set<Int>)
}

/// What the user feels like watching. Groups TMDB genres separately for series and movies.
public struct Mood: Hashable, Sendable, Identifiable {
    /// Stable identifier, such as "laugh". Saved as the last chosen mood.
    public let id: String
    /// Name shown in the app, in Spanish, such as "Reír".
    public let displayName: String
    public let seriesCriteria: MoodCriteria
    public let movieCriteria: MoodCriteria

    public init(id: String, displayName: String, seriesCriteria: MoodCriteria, movieCriteria: MoodCriteria) {
        self.id = id
        self.displayName = displayName
        self.seriesCriteria = seriesCriteria
        self.movieCriteria = movieCriteria
    }
}

/// Minutes the user has available for this session (PRD §11, RF-41).
public struct TimeWindow: Hashable, Sendable {
    public let minutes: Int

    public init(minutes: Int) {
        self.minutes = minutes
    }

    /// The choices offered on the "Esta noche" screen (RF-41).
    public static let choices: [TimeWindow] = [30, 45, 60, 90, 120].map { TimeWindow(minutes: $0) }
}
