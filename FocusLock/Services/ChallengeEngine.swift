import Foundation

protocol ChallengeProvider {
    var difficulty: Difficulty { get }
    func generate() -> Challenge
    func validate(answer: String, for challenge: Challenge) -> Bool
}

extension ChallengeProvider {
    func validate(answer: String, for challenge: Challenge) -> Bool {
        answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
        challenge.answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

final class ChallengeEngine {
    static let shared = ChallengeEngine()
    
    func generate(difficulty: Difficulty) -> Challenge {
        let provider = MathChallengeProvider(difficulty: difficulty)
        return provider.generate()
    }
    
    func validate(answer: String, for challenge: Challenge) -> Bool {
        let provider = MathChallengeProvider(difficulty: challenge.difficulty)
        return provider.validate(answer: answer, for: challenge)
    }
}

// MARK: - Math Challenge Provider

struct MathChallengeProvider: ChallengeProvider {
    let difficulty: Difficulty
    
    func generate() -> Challenge {
        switch difficulty {
        case .easy:
            return generateEasy()
        case .medium:
            return generateMedium()
        case .hard:
            return generateHard()
        }
    }
    
    private func generateEasy() -> Challenge {
        let ops: [(String, (Int, Int) -> Int)] = [
            ("+", { $0 + $1 }),
            ("-", { $0 - $1 }),
            ("×", { $0 * $1 })
        ]
        let (opSymbol, opFunc) = ops.randomElement()!
        
        let a: Int
        let b: Int
        
        if opSymbol == "×" {
            a = Int.random(in: 2...12)
            b = Int.random(in: 2...12)
        } else if opSymbol == "-" {
            a = Int.random(in: 20...99)
            b = Int.random(in: 1...a)
        } else {
            a = Int.random(in: 10...99)
            b = Int.random(in: 10...99)
        }
        
        let answer = opFunc(a, b)
        let expression = "\(a) \(opSymbol) \(b)"
        
        return Challenge(
            type: .math,
            difficulty: .easy,
            prompt: "What is \(expression)?",
            answer: "\(answer)",
            displayExpression: expression
        )
    }
    
    private func generateMedium() -> Challenge {
        // Two-step math
        let a = Int.random(in: 10...50)
        let b = Int.random(in: 10...50)
        let c = Int.random(in: 2...9)
        let ops = [("+", "-"), ("×", "+"), ("-", "×")].randomElement()!
        
        let answer: Int
        let expression: String
        
        switch ops {
        case ("+", "-"):
            answer = a + b - c
            expression = "\(a) + \(b) - \(c)"
        case ("×", "+"):
            let smallA = Int.random(in: 2...12)
            answer = smallA * c + b
            expression = "\(smallA) × \(c) + \(b)"
        default:
            answer = a - b * c
            let smallB = Int.random(in: 2...9)
            let smallC = Int.random(in: 2...9)
            let medAnswer = a - smallB * smallC
            return Challenge(
                type: .math,
                difficulty: .medium,
                prompt: "What is \(a) - \(smallB) × \(smallC)?",
                answer: "\(medAnswer)",
                displayExpression: "\(a) - \(smallB) × \(smallC)"
            )
        }
        
        return Challenge(
            type: .math,
            difficulty: .medium,
            prompt: "What is \(expression)?",
            answer: "\(answer)",
            displayExpression: expression
        )
    }
    
    private func generateHard() -> Challenge {
        // Multi-step with larger numbers, or equation solving
        let patterns: [() -> Challenge] = [
            {
                // Large multi-step
                let a = Int.random(in: 100...500)
                let b = Int.random(in: 10...99)
                let c = Int.random(in: 2...9)
                let d = Int.random(in: 10...50)
                let answer = a + b * c - d
                let expr = "\(a) + \(b) × \(c) - \(d)"
                return Challenge(type: .math, difficulty: .hard, prompt: "What is \(expr)?", answer: "\(answer)", displayExpression: expr)
            },
            {
                // Percentage
                let whole = Int.random(in: 50...500)
                let percent = [10, 15, 20, 25, 30].randomElement()!
                let answer = whole * percent / 100
                let expr = "\(percent)% of \(whole)"
                return Challenge(type: .math, difficulty: .hard, prompt: "What is \(expr)?", answer: "\(answer)", displayExpression: expr)
            },
            {
                // Square root (perfect squares)
                let roots = [4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225]
                let square = roots.randomElement()!
                let answer = Int(Double(square).squareRoot())
                let expr = "√\(square)"
                return Challenge(type: .math, difficulty: .hard, prompt: "What is \(expr)?", answer: "\(answer)", displayExpression: expr)
            }
        ]
        
        return patterns.randomElement()!()
    }
}
