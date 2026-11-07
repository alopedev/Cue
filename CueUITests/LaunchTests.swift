import XCTest

/// Smoke test: the app launches and shows its first screen.
final class LaunchTests: XCTestCase {
    @MainActor
    func testAppLaunchesAndShowsRootScreen() {
        let app = XCUIApplication()
        app.launch()

        // Generous timeout: the first launch on a cold CI simulator is slow.
        XCTAssertTrue(app.staticTexts["root.title"].waitForExistence(timeout: 30))
    }
}
