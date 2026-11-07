import Foundation
import Testing

@testable import CueKit

@Suite("Clock")
struct ClockTests {
    @Test("A fixed clock always returns the date it was given")
    func fixedClockReturnsItsDate() {
        let clock: any CueKit.Clock = FixedClock(now: SampleData.reference)
        #expect(clock.now == SampleData.reference)
        #expect(clock.now == SampleData.reference)
    }

    @Test("The system clock returns the current date")
    func systemClockReturnsCurrentDate() {
        let before = Date()
        let now = SystemClock().now
        let after = Date()
        #expect(before <= now && now <= after)
    }
}
