import Foundation

// The "Esta noche" engine's output and the user's answer to it (PRD §4.3, §6).

/// A ranking input of the engine (RF-21, RF-23). Phase 1 signals only.
public enum Signal: Hashable, Sendable, Codable {
    case daysSinceLastMarked
    case windowFit
    case imminentEnding
    case spoilerUrgency
    case timeInPending
    case ratingAffinity
    case startCost
}

/// A signal with the value and weight it had when the proposal was issued. Never recalculated.
public struct WeightedSignal: Hashable, Sendable, Codable {
    public let signal: Signal
    public let value: Double
    public let weight: Double

    public init(signal: Signal, value: Double, weight: Double) {
        self.signal = signal
        self.value = value
        self.weight = weight
    }
}

/// What is proposed: an episode of a series or a movie.
public enum ProposedItem: Hashable, Sendable, Codable {
    case episode(EpisodeReference)
    case movie(MovieID)
}

public enum ProposalOrigin: Hashable, Sendable, Codable {
    case userList
    case newForYou
}

public enum ProposalOutcome: Hashable, Sendable, Codable {
    case accepted
    case rejected
    case noResponse
}

public struct Proposal: Hashable, Sendable, Identifiable, Codable {
    public let id: UUID
    public let item: ProposedItem
    public let origin: ProposalOrigin
    /// One-sentence explanation shown with the proposal (RF-18).
    public let explanation: String
    public let signals: [WeightedSignal]
    public let outcome: ProposalOutcome

    public init(
        id: UUID,
        item: ProposedItem,
        origin: ProposalOrigin,
        explanation: String,
        signals: [WeightedSignal],
        outcome: ProposalOutcome
    ) {
        self.id = id
        self.item = item
        self.origin = origin
        self.explanation = explanation
        self.signals = signals
        self.outcome = outcome
    }
}

/// The proposals issued when the user taps the button, with the window and mood applied.
public struct Decision: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let issuedAt: Date
    public let window: TimeWindow
    public let moodID: String
    /// At most three (RF-26).
    public let proposals: [Proposal]

    public init(id: UUID, issuedAt: Date, window: TimeWindow, moodID: String, proposals: [Proposal]) {
        self.id = id
        self.issuedAt = issuedAt
        self.window = window
        self.moodID = moodID
        self.proposals = proposals
    }
}

public enum RejectionReason: Hashable, Sendable {
    case notTonight
    case tooLong
    case lostTrack
    case notInterested
}

/// The user said no to a proposal.
public struct Rejection: Hashable, Sendable {
    public let proposalID: UUID
    public let reason: RejectionReason
    public let rejectedAt: Date

    public init(proposalID: UUID, reason: RejectionReason, rejectedAt: Date) {
        self.proposalID = proposalID
        self.reason = reason
        self.rejectedAt = rejectedAt
    }
}
