import Foundation
import SwiftData

extension SwiftDataLibraryStore {
    public func decisions() throws -> [Decision] {
        let rows = try modelContext.fetch(FetchDescriptor<DecisionModel>())
        let winners = collapsingDuplicates(
            rows,
            key: { $0.idRaw },
            createdAt: { $0.createdAt ?? .distantPast },
            updatedAt: { $0.updatedAt ?? .distantPast }
        )
        return winners.compactMap(Decision.init(model:))
    }

    /// Replaces any decision with the same ID, so proposal outcomes can be updated.
    public func save(_ decision: Decision) throws {
        let existing = try modelContext.fetch(FetchDescriptor<DecisionModel>())
            .filter { $0.idRaw == decision.id }
        let now = Date()
        try upsert(
            matching: existing,
            createdAt: { $0.createdAt ?? .distantPast },
            makeNew: { DecisionModel(createdAt: now) },
            in: modelContext,
            apply: { model in try model.apply(decision, updatedAt: now) }
        )
        try modelContext.save()
    }

    public func rejections() throws -> [Rejection] {
        let rows = try modelContext.fetch(FetchDescriptor<RejectionModel>())
        let ordered = rows.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
        return ordered.compactMap(Rejection.init(model:))
    }

    public func save(_ rejection: Rejection) throws {
        let model = RejectionModel(createdAt: Date())
        model.apply(rejection)
        modelContext.insert(model)
        try modelContext.save()
    }
}
