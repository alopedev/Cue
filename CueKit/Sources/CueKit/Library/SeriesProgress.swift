import Foundation

/// How far the user is in a series: what has aired, what they watched and what is left (RF-35).
///
/// Specials (season 0) are left out: they are optional and do not mark the user's position.
public struct SeriesProgress: Hashable, Sendable {
    /// Regular episodes in air order, aired or not.
    public let episodes: [Episode]
    public let airedCount: Int
    public let watchedAiredCount: Int
    /// Aired episodes the user has not watched, in air order.
    public let remainingEpisodes: [Episode]
    public let hasUnairedEpisodes: Bool
    private let airedEpisodes: Set<EpisodeReference>
    /// Minutes needed to watch every remaining episode. Unknown runtimes count as the average.
    public let remainingMinutes: Int

    public init(details: SeriesDetails, watched: Set<EpisodeReference>, now: Date) {
        let regular = details.episodes.filter { $0.id.seasonNumber > 0 }
        let aired = regular.filter { Self.hasAired($0, by: now) }
        let remaining = aired.filter { !watched.contains($0.id) }
        episodes = regular
        airedCount = aired.count
        watchedAiredCount = aired.count - remaining.count
        remainingEpisodes = remaining
        hasUnairedEpisodes = aired.count < regular.count
        airedEpisodes = Set(aired.map(\.id))
        remainingMinutes = Self.minutes(of: remaining, averageOf: regular)
    }

    /// The next episode to watch: the first unwatched aired one (PRD §4.4).
    public var currentEpisode: Episode? { remainingEpisodes.first }

    /// The user has watched every aired episode.
    public var isCaughtUp: Bool { airedCount > 0 && remainingEpisodes.isEmpty }

    public var hasWatchedAnything: Bool { watchedAiredCount > 0 }

    /// Watched share of the aired episodes, from 0 to 1.
    public var fractionWatched: Double {
        airedCount == 0 ? 0 : Double(watchedAiredCount) / Double(airedCount)
    }

    /// Every episode from the first one up to the given one, in air order. Empty if it is unknown.
    public func episodes(through reference: EpisodeReference) -> [Episode] {
        guard let index = episodes.firstIndex(where: { $0.id == reference }) else { return [] }
        return Array(episodes[...index])
    }

    /// The episode had aired when this progress was computed.
    public func hasAired(_ reference: EpisodeReference) -> Bool {
        airedEpisodes.contains(reference)
    }

    /// The episode closes its season.
    public func isLastOfSeason(_ reference: EpisodeReference) -> Bool {
        episodes.last { $0.id.seasonNumber == reference.seasonNumber }?.id == reference
    }

    private static func hasAired(_ episode: Episode, by now: Date) -> Bool {
        guard let airDate = episode.airDate else { return false }
        return airDate <= now
    }

    private static func minutes(of remaining: [Episode], averageOf all: [Episode]) -> Int {
        let known = all.compactMap(\.runtimeMinutes)
        guard !known.isEmpty else { return 0 }
        let average = known.reduce(0, +) / known.count
        return remaining.reduce(0) { $0 + ($1.runtimeMinutes ?? average) }
    }
}
