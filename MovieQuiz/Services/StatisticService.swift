import Foundation

final class StatisticService {
    
    private var storage: UserDefaults = .standard
    
    var correct: Int {
        get { storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }

    var total: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }
    
    private enum Keys: String {
            case gamesCount
            case bestGameCorrect
            case bestGameTotal
            case bestGameDate
            case totalCorrectAnswers
            case totalQuestionsAsked
        }
    }

    extension StatisticService: StatisticServiceProtocol {
        var gamesCount: Int {
            get {
                storage.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                storage.set(newValue, forKey: Keys.gamesCount.rawValue)
            }
        }
        
        var bestGame: GameResult {
            get {
                let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
                let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
                let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()

                return GameResult(correct: correct, total: total, date: date)
            }
            set {
                storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
                storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
                storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            }
        }
        
        var totalAccuracy: Double {
            guard total > 0 else { return 0 }
            return (Double(correct) / Double(total)) * 100
        }
        
        func store(correct count: Int, total amount: Int) {
            correct += count
            total += amount
            
            gamesCount += 1
            let currentGame = GameResult(correct: count, total: amount, date: Date())
            if currentGame.isBetterThan(bestGame) {
                bestGame = currentGame
            }
        }
    }
