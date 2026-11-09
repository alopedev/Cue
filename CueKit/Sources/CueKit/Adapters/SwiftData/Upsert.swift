import Foundation
import SwiftData

/// Updates the existing row for a key, keeping its original `createdAt`, and deletes any
/// other row sharing that key; inserts a fresh row when there is none. This is what gives
/// every entity in `LibraryStore` its "saving an existing key replaces it" rule
/// (docs/adr/0002), down at the SwiftData level.
func upsert<Model: PersistentModel>(
    matching existingRows: [Model],
    createdAt: (Model) -> Date,
    makeNew: () -> Model,
    in context: ModelContext,
    apply: (Model) throws -> Void
) rethrows {
    if let primary = existingRows.min(by: { createdAt($0) < createdAt($1) }) {
        for duplicate in existingRows where duplicate !== primary {
            context.delete(duplicate)
        }
        try apply(primary)
    } else {
        let model = makeNew()
        context.insert(model)
        try apply(model)
    }
}
