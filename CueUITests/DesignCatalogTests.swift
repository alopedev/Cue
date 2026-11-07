import XCTest

/// The debug design catalog opens from the root screen and shows the components.
final class DesignCatalogTests: XCTestCase {
    @MainActor
    func testCatalogOpensFromRootScreen() {
        let app = XCUIApplication()
        app.launch()

        let link = app.buttons["root.designCatalog"]
        XCTAssertTrue(link.waitForExistence(timeout: 30))
        link.tap()

        XCTAssertTrue(app.buttons["Recomiéndame"].waitForExistence(timeout: 10))
    }
}
