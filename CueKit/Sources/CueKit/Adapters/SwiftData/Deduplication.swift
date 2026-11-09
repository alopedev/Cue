import Foundation

/// Collapses rows that share the same key into one, keeping the content of the row with
/// the latest `updatedAt`. Returns the survivors ordered by the earliest `createdAt` seen
/// for that key, so replacing a row never moves its place in the list (docs/adr/0002:
/// the adapter removes duplicates that arrive via sync).
func collapsingDuplicates<Row, Key: Hashable>(
    _ rows: [Row],
    key: (Row) -> Key,
    createdAt: (Row) -> Date,
    updatedAt: (Row) -> Date
) -> [Row] {
    var winnerByKey: [Key: Row] = [:]
    var latestUpdatedAtByKey: [Key: Date] = [:]
    var earliestCreatedAtByKey: [Key: Date] = [:]
    var keyOrder: [Key] = []
    var seenKeys: Set<Key> = []

    for row in rows {
        let rowKey = key(row)
        if seenKeys.insert(rowKey).inserted {
            keyOrder.append(rowKey)
        }

        let rowCreatedAt = createdAt(row)
        earliestCreatedAtByKey[rowKey] = min(rowCreatedAt, earliestCreatedAtByKey[rowKey] ?? rowCreatedAt)

        let rowUpdatedAt = updatedAt(row)
        if rowUpdatedAt >= (latestUpdatedAtByKey[rowKey] ?? .distantPast) {
            latestUpdatedAtByKey[rowKey] = rowUpdatedAt
            winnerByKey[rowKey] = row
        }
    }

    return
        keyOrder
        .sorted { (earliestCreatedAtByKey[$0] ?? .distantPast) < (earliestCreatedAtByKey[$1] ?? .distantPast) }
        .compactMap { winnerByKey[$0] }
}
