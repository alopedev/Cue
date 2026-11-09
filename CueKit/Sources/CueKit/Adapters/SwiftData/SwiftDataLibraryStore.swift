import Foundation
import SwiftData

/// The real `LibraryStore` (docs/adr/0002): SwiftData, with CloudKit left off for now.
///
/// A `@ModelActor`, so every access to its `ModelContext` is serialized and safe to call
/// from any task. Its `@Model` rows are private to this adapter; `LibraryStore` only
/// exchanges `Domain` value types.
@ModelActor
public actor SwiftDataLibraryStore: LibraryStore {
    /// Stores on disk. `url` is the store file's location; when nil, SwiftData's own
    /// default location is used.
    public init(url: URL? = nil) throws {
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: Self.schema, url: url, cloudKitDatabase: .none)
        } else {
            configuration = ModelConfiguration(schema: Self.schema, cloudKitDatabase: .none)
        }
        let container = try ModelContainer(for: Self.schema, configurations: configuration)
        self.init(modelContainer: container)
    }

    /// Keeps nothing on disk: for tests and previews.
    public init(inMemory: Bool) throws {
        let configuration = ModelConfiguration(
            schema: Self.schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: Self.schema, configurations: configuration)
        self.init(modelContainer: container)
    }

    static var schema: Schema {
        Schema([
            SeriesTrackingModel.self,
            MovieTrackingModel.self,
            EpisodeMarkModel.self,
            RatingModel.self,
            DecisionModel.self,
            RejectionModel.self,
            UserSettingsModel.self,
        ])
    }
}
