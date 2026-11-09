import Foundation
import Testing

@testable import CueKit

@Suite("FakeClock")
struct FakeClockTests {
    @Test("Starts at the given date and moves forward on demand")
    func advances() {
        let clock = FakeClock(now: SampleData.reference)
        #expect(clock.now == SampleData.reference)
        clock.advance(by: 90)
        #expect(clock.now == SampleData.reference.addingTimeInterval(90))
    }
}
