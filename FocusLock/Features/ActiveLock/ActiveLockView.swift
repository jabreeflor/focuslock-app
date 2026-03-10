import SwiftUI

struct ActiveLockView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: TimeInterval = 107 * 60 + 23
    @State private var showChallenge = false
    @State private var showInterstitial = false
    @State private var timer: Timer?
    @State private var pulseApps = false
    @State private var timerGlow = false

    private let blockedApps = Array(MockApp.all.prefix(4))

    var body: some View {
        ZStack {
            FLColor.backgroundGradient.ignoresSafeArea()
            NetworkLinesView()
            SparkleView(count: 10)

            VStack(spacing: 0) {
                Spacer().frame(height: 48)

                // Session title
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

                Spacer().frame(height: 36)

                // Countdown timer
                VStack(spacing: 6) {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 58, weight: .bold, design: .monospaced))
                        .foregroundStyle(FLColor.timerTextGradient)
                        .shadow(color: FLColor.cyan.opacity(timerGlow ? 0.6 : 0.2), radius: timerGlow ? 24 : 8)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: timerGlow)

                    Text("remaining")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(FLColor.lavender)
                }

                Spacer().frame(height: 36)

                // Blocked apps — subtle pulse to reinforce locked state
                HStack(spacing: 14) {
                    ForEach(blockedApps) { app in
                        MockAppIcon(
                            name: app.name,
                            color: app.color,
                            symbol: app.symbol,
                            size: 52,
                            isLocked: true
                        )
                        .scaleEffect(pulseApps ? 1.0 : 0.96)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(blockedApps.firstIndex(where: { $0.id == app.id }) ?? 0) * 0.2),
                            value: pulseApps
                        )
                    }
                }
                .padding(18)
                .glassCard()

                Spacer()

                // Motivational quote
                Text("Stay focused. Your future self\nwill thank you.")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 20)

                // Unlock Early button
                Button {
                    FLHaptic.impact(.heavy)
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(FLColor.darkRed.opacity(0.3))
                            .overlay(Capsule().stroke(FLColor.dangerRed, lineWidth: 2))
                            .shadow(color: FLColor.dangerRed.opacity(0.25), radius: 12)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showChallenge) {
            ChallengeView(isPresented: $showChallenge, difficulty: .medium)
        }
        .fullScreenCover(isPresented: $showInterstitial) {
            InterstitialAdView(isPresented: $showInterstitial)
        }
        .onAppear {
            startTimer()
            timerGlow = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { pulseApps = true }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                FLHaptic.success()
                showInterstitial = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    isPresented = false
                }
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }
}

#Preview {
    ActiveLockView(isPresented: .constant(true))
}
