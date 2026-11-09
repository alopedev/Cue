import Foundation
import SwiftData

/// A row's key for a `Rating`: the title it rates.
private struct RatingKey: Hashable {
    let titleSeriesIDRaw: Int?
    let titleMovieIDRaw: Int?
}

extension RatingModel {
    fileprivate var ratingKey: RatingKey {
        RatingKey(titleSeriesIDRaw: titleSeriesIDRaw, titleMovieIDRaw: titleMovieIDRaw)
    }
}

extension SwiftDataLibraryStore {
    public func ratings() throws -> [Rating] {
        let rows = try modelContext.fetch(FetchDescriptor<RatingModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { $0.ratingKey },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.compactMap(Rating.init(model:))
    }

    /// Replaces any rating for the same title.
    public func save(_ rating: Rating) throws {
        let existing = try modelContext.fetch(FetchDescriptor<RatingModel>())
            .filter { $0.title == rating.title }
        let now = Date()
        upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { RatingModel(createdAt: now) },
            in: modelContext,
            apply: { model in model.apply(rating, updatedAt: now) }
        )
        try modelContext.save()
    }
}
