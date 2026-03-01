import SwiftUI

/// Premium upsell view for FocusLock Pro subscription.
struct FocusLockProView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            FLColor.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.top, 8)
                    
                    // Hero
                    VStack(spacing: 12) {
                        PremiumBadge(size: .large)
                        
                        Text("FocusLock Pro")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Remove all ads and unlock\npremium features")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        proFeature(icon: "xmark.circle", color: FLColor.dangerRed, text: "No ads — ever")
                        proFeature(icon: "chart.bar.fill", color: FLColor.cyan, text: "Advanced analytics & insights")
                        proFeature(icon: "paintbrush.fill", color: FLColor.purple, text: "Custom themes & app icons")
                        proFeature(icon: "bell.badge.fill", color: FLColor.neonGreen, text: "Priority support")
                    }
                    .padding(20)
                    .glassCard()
                    
                    // Pricing buttons
                    VStack(spacing: 12) {
                        subscriptionButton(
                            title: "Monthly",
                            price: storeManager.monthlyPrice + "/mo",
                            isPopular: false
                        ) {
                            Task {
                                if let product = storeManager.products.first(where: { $0.id == StoreManager.ProductID.monthly }) {
                                    await storeManager.purchase(product)
                                }
                            }
                        }
                        
                        subscriptionButton(
                            title: "Yearly",
                            price: storeManager.yearlyPrice + "/yr",
                            isPopular: true,
                            savings: "Save 44%"
                        ) {
                            Task {
                                if let product = storeManager.products.first(where: { $0.id == StoreManager.ProductID.yearly }) {
                                    await storeManager.purchase(product)
                                }
                            }
                        }
                    }
                    
                    // Restore
                    Button {
                        Task { await storeManager.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(FLColor.cyan)
                    }
                    
                    if let error = storeManager.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundStyle(FLColor.dangerRed)
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .task { await storeManager.loadProducts() }
    }
    
    // MARK: - Components
    
    private func proFeature(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
        }
    }
    
    private func subscriptionButton(
        title: String,
        price: String,
        isPopular: Bool,
        savings: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if isPopular {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(FLColor.neonGreen.opacity(0.8))
                                )
                        }
                    }
                    
                    if let savings {
                        Text(savings)
                            .font(.system(size: 12))
                            .foregroundStyle(FLColor.neonGreen)
                    }
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(FLColor.cyan)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPopular ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isPopular ? FLColor.cyan : Color.white.opacity(0.1),
                                lineWidth: isPopular ? 2 : 1
                            )
                    )
            )
        }
        .disabled(storeManager.purchaseInProgress)
    }
}
