import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonsAppearance()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        
        let questionFactory = QuestionFactory()
                questionFactory.delegate = self
                self.questionFactory = questionFactory
                
                questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.yesButton.isEnabled = true
            self?.noButton.isEnabled = true
        }
    }
    private func showError(message: String) {
            
            let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Принял") { }
            
            alertPresenter.show(in: self, model: model)
        }
        
        // MARK: - Actions

        @IBAction func answerButtonTapped(_ sender: UIButton) {
            let givenAnswer = sender == yesButton
            guard let currentQuestion = currentQuestion else { return }
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }

        // MARK: - Private

        private func showAnswerResult(isCorrect: Bool) {
            yesButton.isEnabled = false
            noButton.isEnabled = false

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
            QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
        }
    
        private func setupButtonsAppearance() {
            let cornerRadius: CGFloat = 15
            yesButton.layer.cornerRadius = cornerRadius
            noButton.layer.cornerRadius = cornerRadius
            imageView.layer.cornerRadius = cornerRadius
        }

        private func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory.requestNextQuestion()
        }
    }
