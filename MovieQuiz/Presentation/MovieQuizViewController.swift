import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private lazy var moviesLoader: MoviesLoading = MoviesLoader()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupButtonsAppearance()
        contentStackView.isHidden = true
               questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
               statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func loadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.hideLoadingIndicator()
                self?.yesButton.isEnabled = true
                self?.noButton.isEnabled = true
            }
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.hideLoadingIndicator()
                    self?.yesButton.isEnabled = true
                    self?.noButton.isEnabled = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.hideLoadingIndicator()
                self?.yesButton.isEnabled = true
                self?.noButton.isEnabled = true
    
            }
        }
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Повторить"
        ) { [weak self] in
            self?.showLoadingIndicator()
            self?.questionFactory.loadData()
        }

        alertPresenter.show(in: self, model: model)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.contentStackView.isHidden = false
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
            self.showLoadingIndicator()
            self.show(quiz: viewModel)
            self.hideLoadingIndicator()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true        }
    }

    
    // MARK: - Actions
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        let givenAnswer = sender == yesButton
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private
    
    private func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let result = QuizResultsViewModel(
                title: "Раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } 
    
    private func setupButtonsAppearance() {
        let cornerRadius: CGFloat = 15
        
        yesButton.layer.cornerRadius = cornerRadius
        noButton.layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
}
