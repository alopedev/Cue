import XCTest

/// Smoke test: the app launches and shows the library.
final class LaunchTests: XCTestCase {
    @MainActor
    func testAppLaunchesAndShowsLibrary() {
        let app = XCUIApplication()
        app.launchArguments = ["-freshLibrary"]
        app.launch()

        // Generous timeout: the first launch on a cold CI simulator is slow.
        XCTAssertTrue(app.staticTexts["library.title"].waitForExistence(timeout: 60))
    }
}
