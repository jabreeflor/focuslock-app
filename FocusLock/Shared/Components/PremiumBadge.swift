import SwiftUI

/// Shows a "PRO" badge when the user has an active subscription.
struct PremiumBadge: View {
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 9
            case .medium: return 11
            case .large: return 16
            }
        }
        
        var paddingH: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 16
            }
        }
        
        var paddingV: CGFloat {
            switch self {
            case .small: return 3
            case .medium: return 5
            case .large: return 8
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 14
            }
        }
    }
    
    var size: BadgeSize = .small
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        if storeManager.isProUser || size == .large {
            badge
        }
    }
    
    private var badge: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: size.iconSize))
            Text("PRO")
                .font(.system(size: size.fontSize, weight: .black))
        }
        .foregroundStyle(
            LinearGradient(
                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.horizontal, size.paddingH)
        .padding(.vertical, size.paddingV)
        .background(
            Capsule()
                .fill(Color(hex: "FFD700").opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "FFD700").opacity(0.4), lineWidth: 1)
                )
        )
    }
}
