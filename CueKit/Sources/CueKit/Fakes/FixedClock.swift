import Foundation

/// A clock stopped at a given date, for tests.
public struct FixedClock: Clock {
    public let now: Date

    public init(now: Date) {
        self.now = now
    }
}
