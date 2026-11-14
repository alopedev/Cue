import XCTest

/// Marking an episode by swiping its row, without aiming at the round check.
final class EpisodeSwipeTests: XCTestCase {
    private var app: XCUIApplication!

    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-sampleLibrary", "-openTitle", "Cordillera"]
        app.launch()
    }

    @MainActor
    func testSwipingAnEpisodeUnmarksItAndSwipingAgainMarksIt() {
        // Cordillera has episode 1 watched. It is the top row, clear of the undo capsule at the bottom.
        let row = app.descendants(matching: .any)["episode.1.1"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 60))
        // The sample marks land just after the sheet opens.
        XCTAssertTrue(waitForValue("visto", of: row))
        app.swipeUp()

        fullSwipeRight(row)
        XCTAssertTrue(waitForValue("sin ver", of: row))

        fullSwipeRight(row)
        XCTAssertTrue(waitForValue("visto", of: row))
        attachScreenshot("swipe-marcado")
    }

    /// A long swipe across the whole row: it runs the action without tapping the revealed button.
    @MainActor
    private func fullSwipeRight(_ element: XCUIElement) {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        let end = element.coordinate(withNormalizedOffset: CGVector(dx: 1.0, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0.1)
    }

    @MainActor
    private func waitForValue(_ value: String, of element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }

    @MainActor
    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
