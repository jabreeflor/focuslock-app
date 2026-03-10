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
    @State private var shakeOffset: CGFloat = 0
    
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
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                challengeContent
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isSolved)
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
            .offset(x: shakeOffset)

            if isIncorrect {
                Text("Incorrect, try again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(FLColor.dangerRed)
                    .padding(.top, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer().frame(height: 20)

            // Number Pad
            numberPad

            Spacer().frame(minHeight: 12)

            // Watch Ad to Skip
            RewardedAdButton {
                timer?.invalidate()
                FLHaptic.success()
                withAnimation(.spring(response: 0.4)) {
                    isSolved = true
                }
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 10)

            // Give Up button
            Button {
                FLHaptic.impact(.light)
                isPresented = false
            } label: {
                Text("Give Up")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
    }
    
    // MARK: - Number Pad

    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach(numberRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        NumPadKey(key: key) { handleKey(key) }
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
        withAnimation(.easeOut(duration: 0.1)) { isIncorrect = false }
        switch key {
        case "⌫":
            if !userAnswer.isEmpty {
                FLHaptic.selection()
                userAnswer.removeLast()
            }
        case "✓":
            submitAnswer()
        default:
            if userAnswer.count < 10 {
                FLHaptic.selection()
                userAnswer += key
            }
        }
    }
    
    private func submitAnswer() {
        if ChallengeEngine.shared.validate(answer: userAnswer, for: challenge) {
            timer?.invalidate()
            FLHaptic.success()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isSolved = true
            }
        } else {
            FLHaptic.error()
            withAnimation(.easeInOut(duration: 0.12).repeatCount(4, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeOffset = 0
            }
            withAnimation { isIncorrect = true }
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
