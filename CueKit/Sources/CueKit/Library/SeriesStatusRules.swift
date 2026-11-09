/// How a series' status follows from what the user has watched (PRD §4.4, RF-47, RF-48).
///
/// The statuses the user chooses by hand (abandoned, paused) are never changed by marks.
public enum SeriesStatusRules {
    /// The status after the user marked or unmarked episodes.
    public static func statusAfterMarking(
        _ current: SeriesStatus,
        progress: SeriesProgress,
        airing: AiringStatus
    ) -> SeriesStatus {
        switch current {
        case .abandoned, .paused:
            return current
        case .pending, .watching, .upToDate, .finished:
            guard progress.hasWatchedAnything else { return .pending }
            guard progress.isCaughtUp else { return .watching }
            return airing == .airing ? .upToDate : .finished
        }
    }

    /// The status after the catalog brought new episodes (RF-47).
    public static func refreshedStatus(_ current: SeriesStatus, progress: SeriesProgress) -> SeriesStatus {
        current == .upToDate && !progress.isCaughtUp ? .watching : current
    }
}
