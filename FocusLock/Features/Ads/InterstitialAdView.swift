import SwiftUI

/// Stub interstitial ad overlay. Shows a full-screen ad simulation.
/// Replace with GADInterstitialAd presentation logic.
struct InterstitialAdView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var storeManager = StoreManager.shared
    
    @State private var countdown = 3
    @State private var canDismiss = false
    
    var body: some View {
        if storeManager.isProUser {
            // Pro users skip ads
            Color.clear.onAppear { isPresented = false }
        } else {
            adContent
        }
    }
    
    private var adContent: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Ad placeholder
                VStack(spacing: 16) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(FLColor.cyan.opacity(0.4))
                    
                    Text("Interstitial Ad")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text("This is where a full-screen ad would appear\nbetween focus sessions.")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(FLColor.cyan.opacity(0.2), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // Close button with countdown
                Button {
                    if canDismiss { isPresented = false }
                } label: {
                    Text(canDismiss ? "Close Ad ✕" : "Close in \(countdown)s")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canDismiss ? .white : .white.opacity(0.3))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(canDismiss ? FLColor.cyan.opacity(0.3) : Color.white.opacity(0.05))
                        )
                }
                .disabled(!canDismiss)
                .padding(.bottom, 40)
            }
        }
        .onAppear { startCountdown() }
    }
    
    private func startCountdown() {
        _ = AdManager.shared.showInterstitial()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                canDismiss = true
            }
        }
    }
}
