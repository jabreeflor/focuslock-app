import Foundation
import SwiftData

enum ChallengeType: String, Codable {
    case math
    case typing
    case pattern
    case wordProblem
    case logic
}

@Model
final class ChallengeAttempt {
    var id: UUID
    var sessionId: UUID?
    var typeRaw: String
    var difficultyRaw: String
    var solved: Bool
    var gaveUp: Bool
    var timeToSolveSeconds: Double
    var attemptDate: Date
    
    var type: ChallengeType {
        get { ChallengeType(rawValue: typeRaw) ?? .math }
        set { typeRaw = newValue.rawValue }
    }
    
    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .medium }
        set { difficultyRaw = newValue.rawValue }
    }
    
    init(
        sessionId: UUID? = nil,
        type: ChallengeType = .math,
        difficulty: Difficulty = .medium,
        solved: Bool = false,
        gaveUp: Bool = false,
        timeToSolveSeconds: Double = 0
    ) {
        self.id = UUID()
        self.sessionId = sessionId
        self.typeRaw = type.rawValue
        self.difficultyRaw = difficulty.rawValue
        self.solved = solved
        self.gaveUp = gaveUp
        self.timeToSolveSeconds = timeToSolveSeconds
        self.attemptDate = Date()
    }
}
