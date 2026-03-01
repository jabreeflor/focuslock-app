import SwiftUI

/// Stub native ad card for placement between content sections.
struct NativeAdView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        if !storeManager.isProUser {
            nativeAdCard
        }
    }
    
    private var nativeAdCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sponsored")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                    .textCase(.uppercase)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.2))
            }
            
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [FLColor.cyan.opacity(0.15), FLColor.purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundStyle(FLColor.cyan.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Boost Your Productivity")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text("Native ad content would appear here with app install or content promotion.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}
