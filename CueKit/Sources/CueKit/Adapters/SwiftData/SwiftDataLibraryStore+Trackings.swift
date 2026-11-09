import Foundation
import SwiftData

extension SwiftDataLibraryStore {
    public func seriesTrackings() throws -> [SeriesTracking] {
        let rows = try modelContext.fetch(FetchDescriptor<SeriesTrackingModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { $0.seriesIDRaw },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.compactMap(SeriesTracking.init(model:))
    }

    /// Replaces any tracking with the same series ID.
    public func save(_ tracking: SeriesTracking) throws {
        let existing = try modelContext.fetch(FetchDescriptor<SeriesTrackingModel>())
            .filter { $0.seriesIDRaw == tracking.seriesID.rawValue }
        let now = Date()
        upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { SeriesTrackingModel(createdAt: now) },
            in: modelContext,
            apply: { model in model.apply(tracking, updatedAt: now) }
        )
        try modelContext.save()
    }

    public func movieTrackings() throws -> [MovieTracking] {
        let rows = try modelContext.fetch(FetchDescriptor<MovieTrackingModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { $0.movieIDRaw },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.compactMap(MovieTracking.init(model:))
    }

    /// Replaces any tracking with the same movie ID.
    public func save(_ tracking: MovieTracking) throws {
        let existing = try modelContext.fetch(FetchDescriptor<MovieTrackingModel>())
            .filter { $0.movieIDRaw == tracking.movieID.rawValue }
        let now = Date()
        upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { MovieTrackingModel(createdAt: now) },
            in: modelContext,
            apply: { model in model.apply(tracking, updatedAt: now) }
        )
        try modelContext.save()
    }
}
