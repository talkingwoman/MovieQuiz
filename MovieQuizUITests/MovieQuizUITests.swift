import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    private func waitForIndex(_ index: Int, timeout: TimeInterval = 30) {
        let indexLabel = app.staticTexts["Index"]
        let predicate = NSPredicate(format: "label == '\(index)/10'")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: indexLabel)
        wait(for: [expectation], timeout: timeout)
    }

    func testYesButton() {
        waitForIndex(1)
        let indexLabel = app.staticTexts["Index"]

        app.buttons["Yes"].tap()
        waitForIndex(2)

        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        waitForIndex(1)
        let indexLabel = app.staticTexts["Index"]

        app.buttons["No"].tap()
        waitForIndex(2)

        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testGameFinish() {
        for i in 1...10 {
            waitForIndex(i)
            app.buttons["Yes"].tap()
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }

    func testAlertDismiss() {
        for i in 1...10 {
            waitForIndex(i)
            app.buttons["Yes"].tap()
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Сыграть ещё раз"].tap()

        waitForIndex(1)
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(app.staticTexts["Index"].label, "1/10")
    }
}
