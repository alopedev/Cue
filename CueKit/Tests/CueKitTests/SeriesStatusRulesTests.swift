import Testing

@testable import CueKit

@Suite("SeriesStatusRules")
struct SeriesStatusRulesTests {
    @Test("Marking the first episode of a pending series starts watching it")
    func pendingBecomesWatching() {
        let fixture = SeriesFixture(seasons: [5], aired: 5)
        let progress = fixture.progress(watching: [fixture.reference(1, 1)])
        #expect(SeriesStatusRules.statusAfterMarking(.pending, progress: progress, airing: .ended) == .watching)
    }

    @Test("RF-48: watching every aired episode of an airing series makes it up to date")
    func airingCaughtUpIsUpToDate() {
        let fixture = SeriesFixture(seasons: [4], aired: 2)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 2)])
        #expect(SeriesStatusRules.statusAfterMarking(.watching, progress: progress, airing: .airing) == .upToDate)
    }

    @Test(
        "Watching every episode of an ended or canceled series finishes it",
        arguments: [AiringStatus.ended, .canceled]
    )
    func endedCaughtUpIsFinished(airing: AiringStatus) {
        let fixture = SeriesFixture(seasons: [2], aired: 2, airingStatus: airing)
        let progress = fixture.progress(watching: fixture.references)
        #expect(SeriesStatusRules.statusAfterMarking(.watching, progress: progress, airing: airing) == .finished)
    }

    @Test("Unmarking an episode of a finished or up-to-date series goes back to watching")
    func unmarkingGoesBackToWatching() {
        let fixture = SeriesFixture(seasons: [3], aired: 3)
        let progress = fixture.progress(watching: [fixture.reference(1, 1)])
        #expect(SeriesStatusRules.statusAfterMarking(.finished, progress: progress, airing: .ended) == .watching)
        #expect(SeriesStatusRules.statusAfterMarking(.upToDate, progress: progress, airing: .airing) == .watching)
    }

    @Test("Unmarking every episode leaves the series pending")
    func unmarkingEverythingIsPending() {
        let fixture = SeriesFixture(seasons: [3], aired: 3)
        let progress = fixture.progress(watching: [])
        #expect(SeriesStatusRules.statusAfterMarking(.watching, progress: progress, airing: .ended) == .pending)
    }

    @Test("Marks never change a series the user abandoned")
    func abandonedStaysAbandoned() {
        let fixture = SeriesFixture(seasons: [3], aired: 3)
        let progress = fixture.progress(watching: [fixture.reference(1, 1)])
        #expect(SeriesStatusRules.statusAfterMarking(.abandoned, progress: progress, airing: .ended) == .abandoned)
    }

    @Test("RF-47: a new aired episode moves an up-to-date series back to watching")
    func newEpisodeWakesUpToDate() {
        let fixture = SeriesFixture(seasons: [4], aired: 3)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 2)])
        #expect(SeriesStatusRules.refreshedStatus(.upToDate, progress: progress) == .watching)
    }

    @Test("Refreshing leaves every other status as it is", arguments: [
        SeriesStatus.pending, .watching, .paused, .abandoned, .finished,
    ])
    func refreshKeepsOtherStatuses(status: SeriesStatus) {
        let fixture = SeriesFixture(seasons: [4], aired: 3)
        let progress = fixture.progress(watching: [])
        #expect(SeriesStatusRules.refreshedStatus(status, progress: progress) == status)
    }

    @Test("An up-to-date series with nothing new stays up to date")
    func upToDateWithNothingNew() {
        let fixture = SeriesFixture(seasons: [4], aired: 2)
        let progress = fixture.progress(watching: [fixture.reference(1, 1), fixture.reference(1, 2)])
        #expect(SeriesStatusRules.refreshedStatus(.upToDate, progress: progress) == .upToDate)
    }
}
