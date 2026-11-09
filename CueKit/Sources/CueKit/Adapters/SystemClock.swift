import Foundation

/// The real clock: the device's current date and time.
public struct SystemClock: Clock {
    public init() {}

    public var now: Date { Date() }
}
