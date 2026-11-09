import Foundation

/// A Trakt stand-in held in memory, for tests. Records what Cue sends.
public actor FakeHistorySync: HistorySync {
    private let remote: SyncedHistory
    private var failure: HistorySyncError?
    private var isConnected = true

    /// Changes received through `send`, in order.
    public private(set) var sentChanges: [OutgoingChange] = []

    /// `remote` is what Trakt holds. When `failure` is set, every call throws it until `setFailure(nil)`.
    public init(remote: SyncedHistory = .empty, failure: HistorySyncError? = nil) {
        self.remote = remote
        self.failure = failure
    }

    public func setFailure(_ failure: HistorySyncError?) {
        self.failure = failure
    }

    public func fetchChanges(since date: Date?) throws -> SyncedHistory {
        try throwIfUnavailable()
        guard let date else { return remote }
        return SyncedHistory(
            episodeMarks: remote.episodeMarks.filter { $0.markedAt > date },
            movieWatches: remote.movieWatches.filter { $0.watchedAt > date },
            watchlist: remote.watchlist,
            ratings: remote.ratings.filter { $0.ratedAt > date }
        )
    }

    public func send(_ change: OutgoingChange) throws {
        try throwIfUnavailable()
        sentChanges.append(change)
    }

    public func disconnect() throws {
        try throwIfUnavailable()
        isConnected = false
    }

    private func throwIfUnavailable() throws {
        guard isConnected else { throw HistorySyncError.notConnected }
        if let failure { throw failure }
    }
}
