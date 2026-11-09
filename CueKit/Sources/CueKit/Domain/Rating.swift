import Foundation

/// A score from 1 to 10, the same scale as Trakt (D-08).
public struct RatingValue: Hashable, Sendable {
    public static let range = 1...10

    public let rawValue: Int

    /// Returns nil when the value is outside 1...10.
    public init?(_ rawValue: Int) {
        guard Self.range.contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

public enum RatingSource: Hashable, Sendable {
    case manual
    case trakt
}

/// The user's score for a series or a movie. At most one per title.
public struct Rating: Hashable, Sendable {
    public let title: TitleID
    public let value: RatingValue
    public let ratedAt: Date
    public let source: RatingSource

    public init(title: TitleID, value: RatingValue, ratedAt: Date, source: RatingSource) {
        self.title = title
        self.value = value
        self.ratedAt = ratedAt
        self.source = source
    }
}
