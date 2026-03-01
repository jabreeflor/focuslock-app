import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            FLColor.backgroundGradient.ignoresSafeArea()
            NetworkLinesView()
            SparkleView(count: 15)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                FocusLockLogo(size: 90)
                    .padding(.bottom, 16)
                
                // App Name
                Text("FocusLock")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                
                // Tagline
                Text("Lock in. Level up.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(FLColor.cyan)
                    .padding(.top, 4)
                
                Spacer()
                    .frame(height: 40)
                
                // Hero illustration
                HeroIllustration()
                    .frame(height: 200)
                
                Spacer()
                    .frame(height: 32)
                
                // Description
                Text("Minimize distractions. Maximize productivity.\nUnlock your potential and build deep focus\nhabits that stick.")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // CTA Button
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text("Get Started →")
                        .ctaButton()
                }
                .padding(.horizontal, 24)
                
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(.white.opacity(i == 0 ? 1 : 0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Hero Illustration

struct HeroIllustration: View {
    var body: some View {
        ZStack {
            // Concentric rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(FLColor.lavender.opacity(0.1 - Double(i) * 0.03), lineWidth: 1)
                    .frame(width: CGFloat(120 + i * 50), height: CGFloat(120 + i * 50))
            }
            
            // Central person silhouette (desk + laptop)
            VStack(spacing: 0) {
                // Person
                Image(systemName: "person.bust.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "2A2A5A"), Color(hex: "1A1A3A")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Desk
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "1A1A3A"))
                    .frame(width: 80, height: 6)
                    .offset(y: -4)
            }
            
            // Floating icons
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FLColor.cyan.opacity(0.7))
                .offset(x: -60, y: -50)
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FLColor.magenta.opacity(0.7))
                .offset(x: 0, y: -70)
            
            Image(systemName: "bolt.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(FLColor.cyan.opacity(0.6))
                .offset(x: 65, y: -40)
            
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(FLColor.amber.opacity(0.5))
                .offset(x: 50, y: 30)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
