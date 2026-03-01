import SwiftUI

struct ChallengeView: View {
    @Binding var isPresented: Bool
    let difficulty: Difficulty
    
    @State private var challenge: Challenge
    @State private var userAnswer = ""
    @State private var elapsedSeconds: Double = 0
    @State private var timer: Timer?
    @State private var isIncorrect = false
    @State private var isSolved = false
    @State private var challengesRemaining = 3
    
    init(isPresented: Binding<Bool>, difficulty: Difficulty) {
        self._isPresented = isPresented
        self.difficulty = difficulty
        self._challenge = State(initialValue: ChallengeEngine.shared.generate(difficulty: difficulty))
    }
    
    var body: some View {
        ZStack {
            FLColor.backgroundGradient.ignoresSafeArea()
            NetworkLinesView()
            
            if isSolved {
                solvedOverlay
            } else {
                challengeContent
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    // MARK: - Challenge Content
    
    private var challengeContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            // Header Card
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(FLColor.cyan)
                    Text("Solve to Unlock")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Text("Complete the challenge to access your app")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
                
                HStack(spacing: 12) {
                    DifficultyBadge(difficulty: difficulty)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.system(size: 12))
                        Text("\(challengesRemaining) remaining")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .glassCard(cornerRadius: 20)
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 32)
            
            // Timer Ring
            ZStack {
                ProgressRing(
                    progress: min(elapsedSeconds / 120, 1.0),
                    lineWidth: 6,
                    size: 80
                )
                
                VStack(spacing: 2) {
                    Text(formatTimer(elapsedSeconds))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("elapsed")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer().frame(height: 32)
            
            // Math Expression
            VStack(spacing: 12) {
                Text("What is")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text(challenge.displayExpression + " = ?")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(FLColor.timerTextGradient)
            }
            
            Spacer().frame(height: 32)
            
            // Answer Display
            HStack {
                Text(userAnswer.isEmpty ? "Your answer" : userAnswer)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(userAnswer.isEmpty ? .white.opacity(0.3) : .white)
                
                if !userAnswer.isEmpty {
                    Rectangle()
                        .fill(FLColor.cyan)
                        .frame(width: 2, height: 32)
                        .opacity(0.6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .glassCard()
            .padding(.horizontal, 40)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isIncorrect ? FLColor.dangerRed : .clear, lineWidth: 2)
                    .padding(.horizontal, 40)
            )
            
            if isIncorrect {
                Text("Incorrect, try again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(FLColor.dangerRed)
                    .padding(.top, 8)
            }
            
            Spacer().frame(height: 24)
            
            // Number Pad
            numberPad
            
            Spacer().frame(height: 16)
            
            // Give Up button
            Button {
                isPresented = false
            } label: {
                Text("Give Up")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer().frame(height: 32)
        }
    }
    
    // MARK: - Number Pad
    
    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach(numberRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            Group {
                                if key == "⌫" {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 20))
                                } else if key == "✓" {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                } else {
                                    Text(key)
                                        .font(.system(size: 24, weight: .semibold))
                                }
                            }
                            .foregroundStyle(key == "✓" ? .white : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(key == "✓"
                                        ? AnyShapeStyle(FLColor.ctaGradient)
                                        : AnyShapeStyle(Color.white.opacity(0.08))
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var numberRows: [[String]] {
        [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["⌫", "0", "✓"]
        ]
    }
    
    private func handleKey(_ key: String) {
        isIncorrect = false
        switch key {
        case "⌫":
            if !userAnswer.isEmpty { userAnswer.removeLast() }
        case "✓":
            submitAnswer()
        default:
            if userAnswer.count < 10 {
                userAnswer += key
            }
        }
    }
    
    private func submitAnswer() {
        if ChallengeEngine.shared.validate(answer: userAnswer, for: challenge) {
            timer?.invalidate()
            withAnimation(.spring(response: 0.4)) {
                isSolved = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isIncorrect = true
            }
            userAnswer = ""
            challengesRemaining = max(0, challengesRemaining - 1)
            challenge = ChallengeEngine.shared.generate(difficulty: difficulty)
        }
    }
    
    // MARK: - Solved Overlay
    
    private var solvedOverlay: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "lock.open.fill")
                .font(.system(size: 64))
                .foregroundStyle(FLColor.neonGreen)
                .shadow(color: FLColor.neonGreen.opacity(0.5), radius: 20)
            
            Text("Unlocked!")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Unlocked for \(difficulty.unlockDurationMinutes) minutes")
                .font(.system(size: 16))
                .foregroundStyle(FLColor.cyan)
            
            Spacer()
            
            Button {
                isPresented = false
            } label: {
                Text("Continue →")
                    .ctaButton()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helpers
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }
    
    private func formatTimer(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    ChallengeView(isPresented: .constant(true), difficulty: .easy)
}
