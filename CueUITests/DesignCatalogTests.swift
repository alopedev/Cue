import XCTest

/// The debug design catalog opens with its launch argument and shows the components.
final class DesignCatalogTests: XCTestCase {
    @MainActor
    func testCatalogOpensWithLaunchArgument() {
        let app = XCUIApplication()
        app.launchArguments = ["-freshLibrary", "-designCatalog"]
        app.launch()

        XCTAssertTrue(app.buttons["Recomiéndame"].waitForExistence(timeout: 60))
    }
}
