import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?

    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    private let questions: [QuizQuestion] = [
        
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 8?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма меньше чем 3?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 7?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 8?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 9?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма меньше чем 5?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    private var shuffledQuestions: [QuizQuestion] = []
        private var currentIndex = 0
    
    func requestNextQuestion() {
           if shuffledQuestions.isEmpty {
               shuffledQuestions = questions.shuffled()
               currentIndex = 0
           }

           let question = shuffledQuestions[safe: currentIndex]
           currentIndex += 1

           if currentIndex >= shuffledQuestions.count {
               shuffledQuestions = []
           }

           delegate?.didReceiveNextQuestion(question: question)
       }
   }
