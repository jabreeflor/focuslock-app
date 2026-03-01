import SwiftUI

struct ActiveLockView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: TimeInterval = 107 * 60 + 23 // 1:47:23
    @State private var showChallenge = false
    @State private var timer: Timer?
    
    private let blockedApps = Array(MockApp.all.prefix(4))
    
    var body: some View {
        ZStack {
            FLColor.backgroundGradient.ignoresSafeArea()
            NetworkLinesView()
            SparkleView(count: 10)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Session Title Card
                VStack(spacing: 4) {
                    Text("Work Focus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(FLColor.lavender)
                    Text("Session Active")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(FLColor.lavender)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .glassCard(cornerRadius: 20)
                
                Spacer()
                    .frame(height: 40)
                
                // Countdown Timer
                VStack(spacing: 8) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundStyle(FLColor.timerTextGradient)
                    
                    Text("remaining")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(FLColor.lavender)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Blocked Apps
                HStack(spacing: 12) {
                    ForEach(blockedApps) { app in
                        MockAppIcon(
                            name: app.name,
                            color: app.color,
                            symbol: app.symbol,
                            size: 50,
                            isLocked: true
                        )
                    }
                }
                .padding(16)
                .glassCard()
                
                Spacer()
                    .frame(height: 32)
                
                // Unlock Early Button
                Button {
                    showChallenge = true
                } label: {
                    HStack(spacing: 8) {
                        Text("Unlock Early")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(FLColor.amber)
                    }
                    .frame(width: 280, height: 50)
                    .background(
                        Capsule()
                            .fill(FLColor.darkRed.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(FLColor.dangerRed, lineWidth: 2)
                            )
                            .shadow(color: FLColor.dangerRed.opacity(0.3), radius: 8)
                    )
                }
                
                Spacer()
                
                // Motivational Quote
                Text("Stay focused. Your future self\nwill thank you.")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showChallenge) {
            ChallengeView(isPresented: $showChallenge, difficulty: .medium)
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isPresented = false
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d:%02d", h, m, s)
    }
}

#Preview {
    ActiveLockView(isPresented: .constant(true))
}
