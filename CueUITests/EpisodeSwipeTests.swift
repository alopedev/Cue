import XCTest

/// Marking an episode by swiping its row, without aiming at the round check.
final class EpisodeSwipeTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-sampleLibrary", "-openTitle", "Cordillera"]
        app.launch()
    }

    @MainActor
    func testSwipingAnEpisodeMarksItAndSwipingAgainUnmarksIt() {
        // Cordillera has episode 1 watched and episode 2 next.
        let row = app.descendants(matching: .any)["episode.1.2"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 60))
        XCTAssertEqual(row.value as? String, "sin ver")

        row.swipeRight()
        XCTAssertTrue(waitForValue("visto", of: row))
        attachScreenshot("swipe-marcado")

        row.swipeRight()
        XCTAssertTrue(waitForValue("sin ver", of: row))
    }

    private func waitForValue(_ value: String, of element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }

    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
