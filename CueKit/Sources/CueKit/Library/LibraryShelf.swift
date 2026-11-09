/// The groups of the library grid (RF-34). Each one gathers series and movie statuses.
public enum LibraryShelf: CaseIterable, Hashable, Sendable {
    /// The default group.
    case watching
    case pending
    case upToDate
    case paused
    /// Finished series and watched movies.
    case finished
    /// Abandoned series and dismissed movies.
    case dropped

    public init(_ status: SeriesStatus) {
        switch status {
        case .watching: self = .watching
        case .pending: self = .pending
        case .upToDate: self = .upToDate
        case .paused: self = .paused
        case .finished: self = .finished
        case .abandoned: self = .dropped
        }
    }

    public init(_ status: MovieStatus) {
        switch status {
        case .pending: self = .pending
        case .watched: self = .finished
        case .dismissed: self = .dropped
        }
    }
}
