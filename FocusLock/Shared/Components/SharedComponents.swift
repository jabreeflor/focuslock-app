import SwiftUI

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: Difficulty
    var compact: Bool = false
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: compact ? 10 : 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, compact ? 8 : 12)
            .padding(.vertical, compact ? 4 : 6)
            .background(
                Capsule()
                    .fill(Color(hex: difficulty.color))
            )
    }
}

// MARK: - Mock App Icon

struct MockAppIcon: View {
    let name: String
    let color: Color
    let symbol: String
    var size: CGFloat = 52
    var isSelected: Bool = false
    var isLocked: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(color.gradient)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: size * 0.4))
                        .foregroundStyle(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(isSelected ? color : .clear, lineWidth: 2)
                        .shadow(color: isSelected ? color.opacity(0.6) : .clear, radius: 8)
                )
                .opacity(isLocked ? 0.6 : 1)
            
            if isSelected {
                Circle()
                    .fill(FLColor.neonGreen)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 4, y: 4)
            }
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .offset(x: 4, y: 4)
            }
        }
    }
}

// MARK: - App Data

struct MockApp: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let symbol: String
    
    static let all: [MockApp] = [
        MockApp(name: "Instagram", color: .init(hex: "E1306C"), symbol: "camera.fill"),
        MockApp(name: "TikTok", color: .init(hex: "1A1A2E"), symbol: "play.fill"),
        MockApp(name: "Twitter", color: .init(hex: "1DA1F2"), symbol: "at"),
        MockApp(name: "YouTube", color: .init(hex: "FF0000"), symbol: "play.rectangle.fill"),
        MockApp(name: "Reddit", color: .init(hex: "FF4500"), symbol: "bubble.left.fill"),
        MockApp(name: "Snapchat", color: .init(hex: "FFFC00"), symbol: "bolt.fill"),
    ]
}

// MARK: - Logo View

struct FocusLockLogo: View {
    var size: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(FLColor.deepPurple.opacity(0.3))
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 20)
            
            // Lock body
            ZStack {
                // Lock base
                RoundedRectangle(cornerRadius: size * 0.15, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "3A3A4A"), Color(hex: "2A2A3A")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.7, height: size * 0.55)
                    .offset(y: size * 0.15)
                
                // Lock shackle
                UnevenRoundedRectangle(
                    topLeadingRadius: size * 0.25,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: size * 0.25
                )
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "4A4A5A"), Color(hex: "3A3A4A")],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: size * 0.08
                )
                .frame(width: size * 0.4, height: size * 0.35)
                .offset(y: -size * 0.12)
                
                // Brain icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: size * 0.28, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [FLColor.magenta, FLColor.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: size * 0.15)
            }
        }
    }
}

// MARK: - Number Pad Key

struct NumPadKey: View {
    let key: String
    let action: () -> Void
    @State private var isPressed = false

    private var isConfirm: Bool { key == "✓" }
    private var isDelete: Bool { key == "⌫" }

    var body: some View {
        Button(action: {
            action()
        }) {
            Group {
                if isDelete {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22))
                } else if isConfirm {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                } else {
                    Text(key)
                        .font(.system(size: 26, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isConfirm
                        ? AnyShapeStyle(FLColor.ctaGradient)
                        : AnyShapeStyle(Color.white.opacity(0.09)))
                    .shadow(color: isConfirm ? FLColor.cyan.opacity(0.3) : .clear, radius: 8)
            )
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        ._onButtonGesture(pressing: { pressing in isPressed = pressing }, perform: {})
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 180
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            
            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [FLColor.cyan, .blue, FLColor.purple, FLColor.magenta, FLColor.cyan],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: FLColor.cyan.opacity(0.4), radius: 8)
        }
        .frame(width: size, height: size)
    }
}
