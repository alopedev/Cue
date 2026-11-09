import Testing

@testable import CueKit

@Suite("Domain value types")
struct DomainTests {
    @Test("D-08: a rating accepts values from 1 to 10", arguments: [1, 5, 10])
    func ratingAcceptsValuesInRange(value: Int) {
        #expect(RatingValue(value)?.rawValue == value)
    }

    @Test("D-08: a rating rejects values outside 1 to 10", arguments: [-1, 0, 11])
    func ratingRejectsValuesOutsideRange(value: Int) {
        #expect(RatingValue(value) == nil)
    }

    @Test("RF-41: the window choices are 30, 45, 60, 90 and 120 minutes")
    func windowChoices() {
        #expect(TimeWindow.choices.map(\.minutes) == [30, 45, 60, 90, 120])
    }
}
