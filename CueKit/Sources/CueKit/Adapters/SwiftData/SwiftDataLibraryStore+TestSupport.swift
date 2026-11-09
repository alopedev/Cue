import Foundation
import SwiftData

// Test-only inserts that bypass `save`, to simulate a row arriving through CloudKit sync
// alongside one already saved (docs/adr/0002). Internal: reached by `CueKitTests` through
// `@testable import`, never part of the public `LibraryStore` surface.

extension SwiftDataLibraryStore {
    func insertRowDirectly(_ tracking: SeriesTracking, createdAt: Date, updatedAt: Date) throws {
        let model = SeriesTrackingModel(createdAt: createdAt)
        model.apply(tracking, updatedAt: updatedAt)
        modelContext.insert(model)
        try modelContext.save()
    }

    func insertRowDirectly(_ mark: EpisodeMark, createdAt: Date, updatedAt: Date) throws {
        let model = EpisodeMarkModel(createdAt: createdAt)
        model.apply(mark, updatedAt: updatedAt)
        modelContext.insert(model)
        try modelContext.save()
    }

    func insertRowDirectly(_ rating: Rating, createdAt: Date, updatedAt: Date) throws {
        let model = RatingModel(createdAt: createdAt)
        model.apply(rating, updatedAt: updatedAt)
        modelContext.insert(model)
        try modelContext.save()
    }

    func insertRowDirectly(_ decision: Decision, createdAt: Date, updatedAt: Date) throws {
        let model = DecisionModel(createdAt: createdAt)
        try model.apply(decision, updatedAt: updatedAt)
        modelContext.insert(model)
        try modelContext.save()
    }

    func insertRowDirectly(_ settings: UserSettings, createdAt: Date, updatedAt: Date) throws {
        let model = UserSettingsModel(createdAt: createdAt)
        model.apply(settings, updatedAt: updatedAt)
        modelContext.insert(model)
        try modelContext.save()
    }
}
