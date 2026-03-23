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

    func testYesButton() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstLabel = indexLabel.label

        app.buttons["Yes"].tap()
        sleep(3)

        XCTAssertNotEqual(indexLabel.label, firstLabel)
    }

    func testNoButton() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstLabel = indexLabel.label

        app.buttons["No"].tap()
        sleep(3)

        XCTAssertNotEqual(indexLabel.label, firstLabel)
    }

    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons["Сыграть ещё раз"].tap()
        sleep(2)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
