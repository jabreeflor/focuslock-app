import SwiftUI

// MARK: - FocusLock Design System

enum FLColor {
    // Core gradients
    static let backgroundTop = Color(hex: "2D0A4E")
    static let backgroundBottom = Color(hex: "0A0E2A")
    
    static let cyan = Color(hex: "00E5FF")
    static let purple = Color(hex: "9C27B0")
    static let magenta = Color(hex: "E040FB")
    static let deepPurple = Color(hex: "7B1FA2")
    static let lavender = Color(hex: "CE93D8")
    static let neonGreen = Color(hex: "00E676")
    static let dangerRed = Color(hex: "F44336")
    static let darkRed = Color(hex: "B71C1C")
    static let amber = Color(hex: "FBBF24")
    
    // Surface
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.12)
    static let inputBackground = Color.white.opacity(0.05)
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    
    // Gradients
    static let ctaGradient = LinearGradient(
        colors: [cyan, purple],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let ringGradient = AngularGradient(
        colors: [cyan, .blue, purple, magenta, cyan],
        center: .center
    )
    
    static let timerTextGradient = LinearGradient(
        colors: [cyan, magenta],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(FLColor.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(FLColor.cardBorder, lineWidth: 1)
                    )
            )
    }
}

struct CTAButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Capsule()
                    .fill(FLColor.ctaGradient)
                    .shadow(color: FLColor.deepPurple.opacity(0.5), radius: 20, y: 8)
            )
            .clipShape(Capsule())
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
    
    func ctaButton() -> some View {
        modifier(CTAButton())
    }
    
    func focusLockBackground() -> some View {
        self.background(
            ZStack {
                FLColor.backgroundGradient.ignoresSafeArea()
                NetworkLinesView()
            }
        )
    }
}
