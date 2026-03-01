import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    let type: ChallengeType
    let difficulty: Difficulty
    let prompt: String
    let answer: String
    let displayExpression: String // formatted for display (e.g. "47 + 38")
    
    init(type: ChallengeType, difficulty: Difficulty, prompt: String, answer: String, displayExpression: String? = nil) {
        self.type = type
        self.difficulty = difficulty
        self.prompt = prompt
        self.answer = answer
        self.displayExpression = displayExpression ?? prompt
    }
}
