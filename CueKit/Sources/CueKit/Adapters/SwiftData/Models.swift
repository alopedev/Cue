import Foundation
import SwiftData

// SwiftData rows behind `SwiftDataLibraryStore`. Internal to the adapter: the contract
// only exchanges `Domain` value types (docs/adr/0002). Every attribute is optional, with
// no unique constraints, so the models stay CloudKit-compatible.
//
// `createdAt` is set once, when a row is first inserted, and never changes afterwards:
// it is what keeps a tracking, mark, rating or decision in the place it was first saved
// even after later saves replace its content. `updatedAt` changes on every save, and is
// what `collapsingDuplicates` uses to pick the newest content when duplicate rows arrive
// through sync.

@Model
final class SeriesTrackingModel {
    var seriesIDRaw: Int?
    var statusRawValue: String?
    var addedAt: Date?
    var lastMarkedAt: Date?
    var currentEpisodeSeriesIDRaw: Int?
    var currentEpisodeSeasonNumber: Int?
    var currentEpisodeNumber: Int?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension SeriesTrackingModel {
    var currentEpisodeReference: EpisodeReference? {
        guard let seriesIDRaw = currentEpisodeSeriesIDRaw,
            let seasonNumber = currentEpisodeSeasonNumber,
            let episodeNumber = currentEpisodeNumber
        else { return nil }
        return EpisodeReference(
            seriesID: SeriesID(seriesIDRaw),
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber
        )
    }

    func apply(_ tracking: SeriesTracking, updatedAt: Date) {
        seriesIDRaw = tracking.seriesID.rawValue
        statusRawValue = tracking.status.storageValue
        addedAt = tracking.addedAt
        lastMarkedAt = tracking.lastMarkedAt
        currentEpisodeSeriesIDRaw = tracking.currentEpisode?.seriesID.rawValue
        currentEpisodeSeasonNumber = tracking.currentEpisode?.seasonNumber
        currentEpisodeNumber = tracking.currentEpisode?.episodeNumber
        self.updatedAt = updatedAt
    }
}

extension SeriesTracking {
    init?(model: SeriesTrackingModel) {
        guard let seriesIDRaw = model.seriesIDRaw,
            let statusRawValue = model.statusRawValue,
            let status = SeriesStatus(storageValue: statusRawValue),
            let addedAt = model.addedAt
        else { return nil }
        self.init(
            seriesID: SeriesID(seriesIDRaw),
            status: status,
            addedAt: addedAt,
            lastMarkedAt: model.lastMarkedAt,
            currentEpisode: model.currentEpisodeReference
        )
    }
}

@Model
final class MovieTrackingModel {
    var movieIDRaw: Int?
    var statusRawValue: String?
    var addedAt: Date?
    var watchedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension MovieTrackingModel {
    func apply(_ tracking: MovieTracking, updatedAt: Date) {
        movieIDRaw = tracking.movieID.rawValue
        statusRawValue = tracking.status.storageValue
        addedAt = tracking.addedAt
        watchedAt = tracking.watchedAt
        self.updatedAt = updatedAt
    }
}

extension MovieTracking {
    init?(model: MovieTrackingModel) {
        guard let movieIDRaw = model.movieIDRaw,
            let statusRawValue = model.statusRawValue,
            let status = MovieStatus(storageValue: statusRawValue),
            let addedAt = model.addedAt
        else { return nil }
        self.init(movieID: MovieID(movieIDRaw), status: status, addedAt: addedAt, watchedAt: model.watchedAt)
    }
}

@Model
final class EpisodeMarkModel {
    var seriesIDRaw: Int?
    var seasonNumber: Int?
    var episodeNumber: Int?
    var markedAt: Date?
    var sourceRawValue: String?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension EpisodeMarkModel {
    var episodeReference: EpisodeReference? {
        guard let seriesIDRaw = seriesIDRaw, let seasonNumber = seasonNumber, let episodeNumber = episodeNumber
        else { return nil }
        return EpisodeReference(
            seriesID: SeriesID(seriesIDRaw),
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber
        )
    }

    func apply(_ mark: EpisodeMark, updatedAt: Date) {
        seriesIDRaw = mark.episode.seriesID.rawValue
        seasonNumber = mark.episode.seasonNumber
        episodeNumber = mark.episode.episodeNumber
        markedAt = mark.markedAt
        sourceRawValue = mark.source.storageValue
        self.updatedAt = updatedAt
    }
}

extension EpisodeMark {
    init?(model: EpisodeMarkModel) {
        guard let episode = model.episodeReference,
            let markedAt = model.markedAt,
            let sourceRawValue = model.sourceRawValue,
            let source = MarkSource(storageValue: sourceRawValue)
        else { return nil }
        self.init(episode: episode, markedAt: markedAt, source: source)
    }
}

@Model
final class RatingModel {
    var titleSeriesIDRaw: Int?
    var titleMovieIDRaw: Int?
    var value: Int?
    var ratedAt: Date?
    var sourceRawValue: String?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension RatingModel {
    var title: TitleID? {
        if let titleSeriesIDRaw = titleSeriesIDRaw {
            return .series(SeriesID(titleSeriesIDRaw))
        }
        if let titleMovieIDRaw = titleMovieIDRaw {
            return .movie(MovieID(titleMovieIDRaw))
        }
        return nil
    }

    func apply(_ rating: Rating, updatedAt: Date) {
        switch rating.title {
        case .series(let seriesID):
            titleSeriesIDRaw = seriesID.rawValue
            titleMovieIDRaw = nil
        case .movie(let movieID):
            titleMovieIDRaw = movieID.rawValue
            titleSeriesIDRaw = nil
        }
        value = rating.value.rawValue
        ratedAt = rating.ratedAt
        sourceRawValue = rating.source.storageValue
        self.updatedAt = updatedAt
    }
}

extension Rating {
    init?(model: RatingModel) {
        guard let title = model.title,
            let rawValue = model.value,
            let value = RatingValue(rawValue),
            let ratedAt = model.ratedAt,
            let sourceRawValue = model.sourceRawValue,
            let source = RatingSource(storageValue: sourceRawValue)
        else { return nil }
        self.init(title: title, value: value, ratedAt: ratedAt, source: source)
    }
}

@Model
final class DecisionModel {
    var idRaw: UUID?
    var issuedAt: Date?
    var windowMinutes: Int?
    var moodID: String?
    /// `[Proposal]`, JSON-encoded (ADR 0002 allows this for nested value types).
    var proposalsData: Data?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension DecisionModel {
    func apply(_ decision: Decision, updatedAt: Date) throws {
        idRaw = decision.id
        issuedAt = decision.issuedAt
        windowMinutes = decision.window.minutes
        moodID = decision.moodID
        proposalsData = try JSONEncoder().encode(decision.proposals)
        self.updatedAt = updatedAt
    }
}

extension Decision {
    init?(model: DecisionModel) {
        guard let id = model.idRaw,
            let issuedAt = model.issuedAt,
            let windowMinutes = model.windowMinutes,
            let moodID = model.moodID,
            let proposalsData = model.proposalsData,
            let proposals = try? JSONDecoder().decode([Proposal].self, from: proposalsData)
        else { return nil }
        self.init(
            id: id,
            issuedAt: issuedAt,
            window: TimeWindow(minutes: windowMinutes),
            moodID: moodID,
            proposals: proposals
        )
    }
}

/// Rejections have no uniqueness key (PRD §4.4 does not limit them): rows are only
/// ordered by `createdAt`, never collapsed.
@Model
final class RejectionModel {
    var proposalIDRaw: UUID?
    var reasonRawValue: String?
    var rejectedAt: Date?
    var createdAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension RejectionModel {
    func apply(_ rejection: Rejection) {
        proposalIDRaw = rejection.proposalID
        reasonRawValue = rejection.reason.storageValue
        rejectedAt = rejection.rejectedAt
    }
}

extension Rejection {
    init?(model: RejectionModel) {
        guard let proposalID = model.proposalIDRaw,
            let reasonRawValue = model.reasonRawValue,
            let reason = RejectionReason(storageValue: reasonRawValue),
            let rejectedAt = model.rejectedAt
        else { return nil }
        self.init(proposalID: proposalID, reason: reason, rejectedAt: rejectedAt)
    }
}

/// At most one row in practice; `apply` replaces the whole thing, like the contract
/// requires for every other kind of row.
@Model
final class UserSettingsModel {
    var countryRaw: String?
    var subscribedProviders: [Int]?
    var lastWindowMinutes: Int?
    var lastMoodID: String?
    var isTraktConnected: Bool?
    var createdAt: Date?
    var updatedAt: Date?

    init(createdAt: Date) {
        self.createdAt = createdAt
    }
}

extension UserSettingsModel {
    func apply(_ settings: UserSettings, updatedAt: Date) {
        countryRaw = settings.country.rawValue
        subscribedProviders = Array(settings.subscribedProviders)
        lastWindowMinutes = settings.lastWindow?.minutes
        lastMoodID = settings.lastMoodID
        isTraktConnected = settings.isTraktConnected
        self.updatedAt = updatedAt
    }
}

extension UserSettings {
    init?(model: UserSettingsModel) {
        guard let countryRaw = model.countryRaw else { return nil }
        self.init(
            country: CountryCode(countryRaw),
            subscribedProviders: Set(model.subscribedProviders ?? []),
            lastWindow: model.lastWindowMinutes.map(TimeWindow.init(minutes:)),
            lastMoodID: model.lastMoodID,
            isTraktConnected: model.isTraktConnected ?? false
        )
    }
}
