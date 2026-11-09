import XCTest

/// Block 1's main path: add titles, mark, undo and finish a movie (issue #8).
final class LibraryFlowTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-freshLibrary"]
        app.launch()
    }

    @MainActor
    func testAddMarkUndoAndFinishMovie() {
        // 1. Empty library with the character and a way to start.
        let emptyAdd = app.buttons["library.emptyAdd"]
        XCTAssertTrue(emptyAdd.waitForExistence(timeout: 60))
        snapshot("1-biblioteca-vacia")

        // 2. Add a series and a movie.
        emptyAdd.tap()
        let series = app.buttons["add.Cordillera"]
        XCTAssertTrue(series.waitForExistence(timeout: 10))
        series.tap()
        // The movies sit below the series: scroll until the movie shows up.
        let movie = app.buttons["add.Domingo de lluvia"]
        for _ in 0..<4 where !movie.isHittable { app.swipeUp() }
        movie.tap()
        snapshot("2-anadir-titulos")
        app.buttons["add.done"].tap()

        // They land on «Pendientes».
        let seriesTile = app.buttons["tile.Cordillera"]
        XCTAssertTrue(seriesTile.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shelf.pending"].isSelected)
        snapshot("3-pendientes")

        // 3. Mark the first episode: the undo capsule appears; undo it.
        seriesTile.tap()
        let markNext = app.buttons["detail.markNext"]
        XCTAssertTrue(markNext.waitForExistence(timeout: 10))
        markNext.tap()
        let undo = app.buttons["undo.button"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        snapshot("4-ficha-deshacer")
        undo.tap()
        XCTAssertTrue(app.staticTexts["Pendiente"].waitForExistence(timeout: 5))

        // Mark it again and close: the series moves to «Viendo».
        markNext.tap()
        app.buttons["detail.close"].tap()
        XCTAssertTrue(app.buttons["shelf.watching"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["library.catchUp"].exists || app.staticTexts["Para ponerte al día"].exists)

        finishMovie()
    }

    /// Marks the movie watched: the celebration shows and the movie moves to «Vistas».
    @MainActor
    private func finishMovie() {
        app.buttons["shelf.pending"].tap()
        app.buttons["tile.Domingo de lluvia"].tap()
        let markMovie = app.buttons["detail.markMovie"]
        XCTAssertTrue(markMovie.waitForExistence(timeout: 10))
        markMovie.tap()
        let keepGoing = app.buttons["celebration.continue"]
        XCTAssertTrue(keepGoing.waitForExistence(timeout: 5))
        snapshot("5-celebracion")
        keepGoing.tap()
        app.buttons["detail.close"].tap()

        XCTAssertTrue(app.buttons["shelf.finished"].waitForExistence(timeout: 5))
        app.buttons["shelf.watching"].tap()
        snapshot("6-viendo")
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
