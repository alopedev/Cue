import Foundation
import SwiftData

/// A row's key for an `EpisodeMark`: the episode it marks.
private struct EpisodeKey: Hashable {
    let seriesIDRaw: Int?
    let seasonNumber: Int?
    let episodeNumber: Int?
}

extension EpisodeMarkModel {
    fileprivate var episodeKey: EpisodeKey {
        EpisodeKey(seriesIDRaw: seriesIDRaw, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
    }
}

extension SwiftDataLibraryStore {
    public func episodeMarks() throws -> [EpisodeMark] {
        let rows = try modelContext.fetch(FetchDescriptor<EpisodeMarkModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { $0.episodeKey },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.compactMap(EpisodeMark.init(model:))
    }

    /// Replaces any mark for the same episode.
    public func save(_ mark: EpisodeMark) throws {
        let existing = try modelContext.fetch(FetchDescriptor<EpisodeMarkModel>())
            .filter { $0.episodeReference == mark.episode }
        let now = Date()
        upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { EpisodeMarkModel(createdAt: now) },
            in: modelContext,
            apply: { model in model.apply(mark, updatedAt: now) }
        )
        try modelContext.save()
    }

    /// Removes the mark of an episode, to undo it (RF-33). Does nothing if there is none.
    public func removeMark(for episode: EpisodeReference) throws {
        let existing = try modelContext.fetch(FetchDescriptor<EpisodeMarkModel>())
            .filter { $0.episodeReference == episode }
        for model in existing {
            modelContext.delete(model)
        }
        try modelContext.save()
    }
}
