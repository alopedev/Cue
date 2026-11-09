import Foundation
import Synchronization

/// A clock that only moves when a test moves it, to check time limits such as the 10-second undo.
public final class FakeClock: Clock {
    private let current: Mutex<Date>

    public init(now: Date) {
        current = Mutex(now)
    }

    public var now: Date { current.withLock { $0 } }

    public func advance(by seconds: TimeInterval) {
        current.withLock { $0 = $0.addingTimeInterval(seconds) }
    }
}
