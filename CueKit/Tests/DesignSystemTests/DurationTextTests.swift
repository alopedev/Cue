import Testing

@testable import DesignSystem

@Suite("Duration text")
struct DurationTextTests {
    @Test(
        "Durations always carry their unit",
        arguments: [
            (0, "0 min"), (48, "48 min"), (60, "1 h"), (112, "1 h 52 min"), (912, "15 h 12 min"),
        ]
    )
    func formats(minutes: Int, expected: String) {
        #expect(DurationText.string(minutes: minutes) == expected)
    }
}
