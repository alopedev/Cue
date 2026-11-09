import Foundation
import SwiftData

extension SwiftDataLibraryStore {
    /// Nil until the first launch is completed (RF-01).
    public func settings() throws -> UserSettings? {
        let rows = try modelContext.fetch(FetchDescriptor<UserSettingsModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { _ in 0 },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.first.flatMap(UserSettings.init(model:))
    }

    public func save(_ settings: UserSettings) throws {
        let existing = try modelContext.fetch(FetchDescriptor<UserSettingsModel>())
        let now = Date()
        upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { UserSettingsModel(createdAt: now) },
            in: modelContext,
            apply: { model in model.apply(settings, updatedAt: now) }
        )
        try modelContext.save()
    }
}
