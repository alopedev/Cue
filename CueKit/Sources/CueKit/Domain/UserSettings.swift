/// The user's settings (PRD §4.3). Absent until the first launch is completed.
public struct UserSettings: Hashable, Sendable {
    public let country: CountryCode
    /// The streaming providers the user says they pay for, by provider ID.
    public let subscribedProviders: Set<Int>
    public let lastWindow: TimeWindow?
    public let lastMoodID: String?
    public let isTraktConnected: Bool

    public init(
        country: CountryCode,
        subscribedProviders: Set<Int>,
        lastWindow: TimeWindow?,
        lastMoodID: String?,
        isTraktConnected: Bool
    ) {
        self.country = country
        self.subscribedProviders = subscribedProviders
        self.lastWindow = lastWindow
        self.lastMoodID = lastMoodID
        self.isTraktConnected = isTraktConnected
    }
}
