import SwiftUI
#if canImport(RevenueCat)
import RevenueCat
#endif

/// Premium paywall for FocusLock Pro subscription
/// Features modern design with clear value proposition and pricing
struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var revenueCat = RevenueCatManager.shared
    @State private var selectedPackage: Package?
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    // Animation states
    @State private var animateFeatures = false
    @State private var animatePricing = false
    
    var body: some View {
        ZStack {
            // Background
            FLColor.backgroundGradient
                .ignoresSafeArea()
            
            NetworkLinesView()
                .opacity(0.3)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Pricing
                    pricingSection
                    
                    // CTA
                    ctaSection
                    
                    // Footer
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            setupInitialState()
            startAnimations()
        }
        .sheet(isPresented: $showingTerms) {
            termsSheet
        }
        .sheet(isPresented: $showingPrivacy) {
            privacySheet
        }
        .alert("Purchase Error", isPresented: .constant(revenueCat.errorMessage != nil)) {
            Button("OK") { revenueCat.errorMessage = nil }
        } message: {
            Text(revenueCat.errorMessage ?? "")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Close button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(8)
                        .background(Circle().fill(.white.opacity(0.1)))
                }
            }
            
            // Premium badge
            PremiumBadge(size: .large)
                .scaleEffect(animateFeatures ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateFeatures)
            
            // Title
            VStack(spacing: 8) {
                Text("Unlock FocusLock Pro")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text("Supercharge your productivity with premium features")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .opacity(animateFeatures ? 1 : 0)
            .offset(y: animateFeatures ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateFeatures)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 20) {
            ForEach(premiumFeatures.indices, id: \.self) { index in
                let feature = premiumFeatures[index]
                
                FeatureRow(
                    icon: feature.icon,
                    title: feature.title,
                    description: feature.description,
                    accent: feature.accent
                )
                .opacity(animateFeatures ? 1 : 0)
                .offset(x: animateFeatures ? 0 : -30)
                .animation(
                    .easeOut(duration: 0.6)
                        .delay(0.4 + Double(index) * 0.1),
                    value: animateFeatures
                )
            }
        }
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .opacity(animatePricing ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(1.0), value: animatePricing)
            
            if let offerings = revenueCat.offerings?.current {
                VStack(spacing: 12) {
                    // Yearly Plan (Recommended)
                    if let yearly = offerings.annual {
                        PricingCard(
                            package: yearly,
                            title: "Annual",
                            subtitle: "Most Popular",
                            savings: revenueCat.yearlyMonthlySavings,
                            isSelected: selectedPackage?.identifier == yearly.identifier,
                            isRecommended: true
                        ) {
                            selectedPackage = yearly
                        }
                        .scaleEffect(animatePricing ? 1.0 : 0.9)
                        .opacity(animatePricing ? 1 : 0)
                        .animation(.spring(response: 0.8).delay(1.1), value: animatePricing)
                    }
                    
                    // Monthly Plan
                    if let monthly = offerings.monthly {
                        PricingCard(
                            package: monthly,
                            title: "Monthly",
                            subtitle: "Flexible",
                            isSelected: selectedPackage?.identifier == monthly.identifier
                        ) {
                            selectedPackage = monthly
                        }
                        .scaleEffect(animatePricing ? 1.0 : 0.9)
                        .opacity(animatePricing ? 1 : 0)
                        .animation(.spring(response: 0.8).delay(1.2), value: animatePricing)
                    }
                }
            } else {
                // Loading state
                VStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.1))
                            .frame(height: 80)
                            .shimmering()
                    }
                }
            }
        }
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: 16) {
            // Purchase button
            Button {
                guard let package = selectedPackage else { return }
                Task {
                    let success = await revenueCat.purchase(package)
                    if success {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if revenueCat.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Start Free Trial")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selectedPackage != nil ? FLColor.ctaGradient : Color.gray.opacity(0.3))
                )
                .scaleEffect(selectedPackage != nil ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: selectedPackage != nil)
            }
            .disabled(selectedPackage == nil || revenueCat.isPurchasing)
            
            // Restore button
            Button {
                Task {
                    _ = await revenueCat.restorePurchases()
                    if revenueCat.isProUser {
                        dismiss()
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(FLColor.cyan)
            }
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("3-day free trial, then \(selectedPackage?.storeProduct.localizedPriceString ?? "$2.99")/month")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Terms of Service") { showingTerms = true }
                Button("Privacy Policy") { showingPrivacy = true }
            }
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        // Auto-select yearly if available
        if selectedPackage == nil {
            selectedPackage = revenueCat.yearlyPackage ?? revenueCat.monthlyPackage
        }
    }
    
    private func startAnimations() {
        withAnimation {
            animateFeatures = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                animatePricing = true
            }
        }
    }
    
    // MARK: - Sheet Views
    
    private var termsSheet: some View {
        NavigationView {
            WebViewWrapper(url: "https://focuslock.app/terms")
                .navigationTitle("Terms of Service")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showingTerms = false }
                    }
                }
        }
    }
    
    private var privacySheet: some View {
        NavigationView {
            WebViewWrapper(url: "https://focuslock.app/privacy")
                .navigationTitle("Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showingPrivacy = false }
                    }
                }
        }
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let accent: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accent.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(accent)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pricing Card Component

private struct PricingCard: View {
    let package: Package
    let title: String
    let subtitle: String?
    let savings: String?
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    init(
        package: Package,
        title: String,
        subtitle: String? = nil,
        savings: String? = nil,
        isSelected: Bool = false,
        isRecommended: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.package = package
        self.title = title
        self.subtitle = subtitle
        self.savings = savings
        self.isSelected = isSelected
        self.isRecommended = isRecommended
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        if isRecommended {
                            Text("POPULAR")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "FFD700"))
                                )
                        }
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    if let savings = savings {
                        Text("Save \(savings)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FLColor.neonGreen)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(package.storeProduct.subscriptionPeriod?.localizedDescription ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(FLColor.cyan)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .white.opacity(0.1) : .white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? FLColor.cyan.opacity(0.5) : .white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Premium Features Data

private struct PremiumFeature {
    let icon: String
    let title: String
    let description: String
    let accent: Color
}

private let premiumFeatures: [PremiumFeature] = [
    PremiumFeature(
        icon: "megaphone.slash.fill",
        title: "Ad-Free Experience",
        description: "Remove all ads and distractions for pure focus",
        accent: FLColor.neonGreen
    ),
    PremiumFeature(
        icon: "chart.bar.fill",
        title: "Advanced Analytics",
        description: "Detailed insights and progress tracking",
        accent: FLColor.cyan
    ),
    PremiumFeature(
        icon: "brain.head.profile",
        title: "Smart Challenges",
        description: "AI-powered difficulty adjustment for optimal friction",
        accent: FLColor.purple
    ),
    PremiumFeature(
        icon: "icloud.fill",
        title: "Cloud Sync",
        description: "Sync your focus sessions across all devices",
        accent: Color.blue
    ),
    PremiumFeature(
        icon: "bell.badge.fill",
        title: "Smart Reminders",
        description: "Intelligent notifications to maintain your streaks",
        accent: FLColor.amber
    ),
    PremiumFeature(
        icon: "person.2.fill",
        title: "Focus Groups",
        description: "Join accountability groups and compete with friends",
        accent: FLColor.magenta
    )
]

// MARK: - Shimmering Effect

private struct ShimmeringViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmeringViewModifier())
    }
}

// MARK: - WebView Wrapper (Placeholder)

private struct WebViewWrapper: View {
    let url: String
    
    var body: some View {
        // TODO: Implement proper WebView for terms/privacy
        VStack {
            Text("Loading \(url)...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    PremiumPaywallView()
}