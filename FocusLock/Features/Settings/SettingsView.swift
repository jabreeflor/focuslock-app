import SwiftUI

struct SettingsView: View {
    @State private var defaultDifficulty: Difficulty = .medium
    @State private var notificationsEnabled = true
    @State private var strictMode = false
    @State private var sessionStartNotif = true
    @State private var sessionEndNotif = true
    @State private var weeklySummary = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Customize your experience")
                        .font(.system(size: 14))
                        .foregroundStyle(FLColor.cyan)
                }
                .padding(.top, 16)
                
                // Profile Section
                profileSection
                
                // Notifications
                notificationSection
                
                // Difficulty
                difficultySection
                
                // Strict Mode
                strictModeSection
                
                // Blocked Apps
                blockedAppsSection
                
                // About
                aboutSection
                
                // Sign Out
                Button {
                    hasCompletedOnboarding = false
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(FLColor.dangerRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard()
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .focusLockBackground()
    }
    
    // MARK: - Profile
    
    private var profileSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [FLColor.cyan, FLColor.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text("JF")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Jabree Flor")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Premium Member")
                    .font(.system(size: 13))
                    .foregroundStyle(FLColor.cyan)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Notifications
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Notifications")
            
            VStack(spacing: 0) {
                settingsToggle("Session Start", icon: "bell.fill", iconColor: FLColor.cyan, isOn: $sessionStartNotif)
                Divider().background(Color.white.opacity(0.1))
                settingsToggle("Session End", icon: "bell.badge.fill", iconColor: FLColor.neonGreen, isOn: $sessionEndNotif)
                Divider().background(Color.white.opacity(0.1))
                settingsToggle("Weekly Summary", icon: "chart.bar.fill", iconColor: FLColor.purple, isOn: $weeklySummary)
            }
            .glassCard()
        }
    }
    
    // MARK: - Difficulty
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Default Difficulty")
            
            HStack(spacing: 0) {
                ForEach(Difficulty.allCases, id: \.self) { level in
                    Text(level.rawValue)
                        .font(.system(size: 14, weight: defaultDifficulty == level ? .bold : .regular))
                        .foregroundStyle(defaultDifficulty == level ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(defaultDifficulty == level ? Color(hex: level.color).opacity(0.3) : .clear)
                        )
                        .onTapGesture {
                            withAnimation { defaultDifficulty = level }
                        }
                }
            }
            .padding(4)
            .glassCard(cornerRadius: 12)
        }
    }
    
    // MARK: - Strict Mode
    
    private var strictModeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            settingsToggle(
                "Strict Mode",
                icon: "exclamationmark.shield.fill",
                iconColor: FLColor.dangerRed,
                isOn: $strictMode,
                subtitle: "Challenges get harder with each consecutive unlock attempt"
            )
            .glassCard()
        }
    }
    
    // MARK: - Blocked Apps
    
    private var blockedAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Blocked Apps")
            
            HStack {
                HStack(spacing: -8) {
                    ForEach(Array(MockApp.all.prefix(4).enumerated()), id: \.offset) { _, app in
                        Circle()
                            .fill(app.color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: app.symbol)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            )
                            .overlay(
                                Circle().stroke(Color(hex: "0A0E2A"), lineWidth: 2)
                            )
                    }
                }
                
                Text("\(MockApp.all.count) apps")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.leading, 12)
                
                Spacer()
                
                Text("Manage")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(FLColor.cyan)
            }
            .padding(16)
            .glassCard()
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("About")
            
            VStack(spacing: 0) {
                settingsRow("Version", value: "1.0.0")
                Divider().background(Color.white.opacity(0.1))
                settingsRow("Screen Time", value: "Authorized", valueColor: FLColor.neonGreen)
                Divider().background(Color.white.opacity(0.1))
                settingsRow("Support", trailing: true)
                Divider().background(Color.white.opacity(0.1))
                settingsRow("Privacy Policy", trailing: true)
            }
            .glassCard()
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.bottom, 8)
    }
    
    private func settingsToggle(_ title: String, icon: String, iconColor: Color, isOn: Binding<Bool>, subtitle: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(FLColor.cyan)
                .labelsHidden()
        }
        .padding(16)
    }
    
    private func settingsRow(_ title: String, value: String? = nil, valueColor: Color = .white.opacity(0.5), trailing: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            if let value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundStyle(valueColor)
            }
            
            if trailing {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(16)
    }
}

#Preview {
    SettingsView()
}
