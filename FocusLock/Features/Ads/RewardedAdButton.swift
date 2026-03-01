import SwiftUI

/// "Watch Ad to Skip" button for the Challenge screen.
/// Shows a rewarded ad and calls onRewardEarned when complete.
struct RewardedAdButton: View {
    let onRewardEarned: () -> Void
    @ObservedObject private var storeManager = StoreManager.shared
    @ObservedObject private var adManager = AdManager.shared
    @State private var isLoading = false
    @State private var showConfirmation = false
    
    var body: some View {
        if !storeManager.isProUser {
            Button {
                showConfirmation = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 16))
                    
                    Text("Watch Ad to Skip")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [FLColor.amber.opacity(0.3), FLColor.amber.opacity(0.15)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(FLColor.amber, lineWidth: 1.5)
                        )
                )
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .alert("Skip Challenge?", isPresented: $showConfirmation) {
                Button("Watch Ad") { watchAd() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Watch a short ad to skip this challenge and unlock your apps.")
            }
        }
    }
    
    private func watchAd() {
        isLoading = true
        adManager.showRewarded { success in
            isLoading = false
            if success {
                onRewardEarned()
            }
        }
    }
}
