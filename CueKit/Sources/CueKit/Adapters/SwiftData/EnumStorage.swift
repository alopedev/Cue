// Stable string encodings for the enums stored directly as SwiftData attributes
// (docs/adr/0002). Changing a case's string breaks data already saved on a device,
// so these strings are independent of the case names.

extension SeriesStatus {
    var storageValue: String {
        switch self {
        case .pending: "pending"
        case .watching: "watching"
        case .upToDate: "upToDate"
        case .paused: "paused"
        case .abandoned: "abandoned"
        case .finished: "finished"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "pending": self = .pending
        case "watching": self = .watching
        case "upToDate": self = .upToDate
        case "paused": self = .paused
        case "abandoned": self = .abandoned
        case "finished": self = .finished
        default: return nil
        }
    }
}

extension MovieStatus {
    var storageValue: String {
        switch self {
        case .pending: "pending"
        case .watched: "watched"
        case .dismissed: "dismissed"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "pending": self = .pending
        case "watched": self = .watched
        case "dismissed": self = .dismissed
        default: return nil
        }
    }
}

extension MarkSource {
    var storageValue: String {
        switch self {
        case .manual: "manual"
        case .trakt: "trakt"
        case .reconciled: "reconciled"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "manual": self = .manual
        case "trakt": self = .trakt
        case "reconciled": self = .reconciled
        default: return nil
        }
    }
}

extension RatingSource {
    var storageValue: String {
        switch self {
        case .manual: "manual"
        case .trakt: "trakt"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "manual": self = .manual
        case "trakt": self = .trakt
        default: return nil
        }
    }
}

extension RejectionReason {
    var storageValue: String {
        switch self {
        case .notTonight: "notTonight"
        case .tooLong: "tooLong"
        case .lostTrack: "lostTrack"
        case .notInterested: "notInterested"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "notTonight": self = .notTonight
        case "tooLong": self = .tooLong
        case "lostTrack": self = .lostTrack
        case "notInterested": self = .notInterested
        default: return nil
        }
    }
}
