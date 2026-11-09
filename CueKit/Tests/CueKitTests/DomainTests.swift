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

    @Test("§4.2: a mood keeps separate criteria for series and movies")
    func moodKeepsSeparateCriteria() {
        let romance = Keyword(id: 9840, name: "romance")
        let mood = Mood(
            id: "romantic",
            displayName: "Romántica",
            seriesCriteria: .matching(genreIDs: [], keywordIDs: [romance.id]),
            movieCriteria: .matching(genreIDs: [10749], keywordIDs: [])
        )
        #expect(mood.seriesCriteria == .matching(genreIDs: [], keywordIDs: [9840]))
        #expect(mood.movieCriteria == .matching(genreIDs: [10749], keywordIDs: []))
        #expect(mood.movieCriteria != .everything)
    }
}
