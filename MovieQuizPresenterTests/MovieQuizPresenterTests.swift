import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var lastStepModel: QuizStepViewModel?
    var lastResultModel: QuizResultsViewModel?
    var didCallShowLoadingIndicator = false
    var didCallHideLoadingIndicator = false
    var didCallShowNetworkError = false
    var receivedErrorMessage: String?
    var didCallHighlightImageBorder = false
    var receivedIsCorrectAnswer: Bool?

    func show(quiz step: QuizStepViewModel) {
        lastStepModel = step
    }

    func show(quiz result: QuizResultsViewModel) {
        lastResultModel = result
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        didCallHighlightImageBorder = true
        receivedIsCorrectAnswer = isCorrectAnswer
    }

    func showLoadingIndicator() {
        didCallShowLoadingIndicator = true
    }

    func hideLoadingIndicator() {
        didCallHideLoadingIndicator = true
    }

    func showNetworkError(message: String) {
        didCallShowNetworkError = true
        receivedErrorMessage = message
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(
            image: emptyData,
            text: "Question Text",
            correctAnswer: true
        )

        let viewModel = sut.convert(model: question)

        XCTAssertEqual(viewModel.imageData, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
