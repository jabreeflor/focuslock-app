import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var schedules: [FocusSchedule]
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    @State private var showQuickStart = false
    @State private var isSessionActive = false
    @State private var activeSchedule: FocusSchedule?
    
    // Mock data for initial display
    private var todayFocusMinutes: Int {
        let today = Calendar.current.startOfDay(for: .now)
        return sessions
            .filter { Calendar.current.startOfDay(for: $0.startTime) == today }
            .reduce(0) { $0 + $1.totalFocusSeconds } / 60
    }
    
    private var streakDays: Int {
        // Simple streak calculation
        var streak = 0
        var date = Calendar.current.startOfDay(for: .now)
        let cal = Calendar.current
        
        while true {
            let hasSession = sessions.contains {
                cal.startOfDay(for: $0.startTime) == date && $0.completed
            }
            if hasSession || (streak == 0 && date == cal.startOfDay(for: .now)) {
                if hasSession { streak += 1 }
                date = cal.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak > 0 ? streak : 1 // Minimum 1 on active use
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Focus Ring + Streak
                HStack(spacing: 20) {
                    focusRingSection
                    streakCard
                }
                .padding(.horizontal, 20)
                
                // Active Schedule Card
                if let schedule = schedules.first(where: { $0.isActive }) ?? mockSchedule {
                    scheduleCard(schedule)
                        .padding(.horizontal, 20)
                }
                
                // Start Button
                Button {
                    FLHaptic.impact(.medium)
                    isSessionActive = true
                } label: {
                    Text("Start Focus Session →")
                        .ctaButton()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .buttonStyle(ScaleButtonStyle())
                
                // Banner Ad
                BannerAdView()
                    .padding(.bottom, 16)
            }
            .padding(.top, 16)
        }
        .focusLockBackground()
        .fullScreenCover(isPresented: $isSessionActive) {
            ActiveLockView(isPresented: $isSessionActive)
        }
    }
    
    private var mockSchedule: FocusSchedule? {
        let s = FocusSchedule(
            name: "Work Focus",
            blockedAppNames: ["Instagram", "TikTok", "Twitter", "YouTube"],
            daysOfWeek: [2, 3, 4, 5, 6],
            startHour: 9, startMinute: 0,
            endHour: 17, endMinute: 0,
            difficulty: .medium
        )
        return s
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 2) {
            FocusLockLogo(size: 50)
            Text("FocusLock")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            Text("Lock in. Level up.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(FLColor.cyan)
        }
    }
    
    // MARK: - Focus Ring
    
    private var focusRingSection: some View {
        ZStack {
            ProgressRing(progress: 0.7, size: 160)
            
            VStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                
                let hours = todayFocusMinutes > 0 ? todayFocusMinutes / 60 : 2
                let mins = todayFocusMinutes > 0 ? todayFocusMinutes % 60 : 34
                Text("\(hours)h \(mins)m")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Focused Today")
                    .font(.system(size: 12))
                    .foregroundStyle(FLColor.cyan)
            }
        }
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [FLColor.cyan, FLColor.neonGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 2) {
                Text("\(streakDays)-Day")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text("Streak")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text("Keep the focus going!")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCard()
    }
    
    // MARK: - Schedule Card
    
    private func scheduleCard(_ schedule: FocusSchedule) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(schedule.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Deep focus for professional tasks and meetings.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("ACTIVE")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(FLColor.neonGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(FLColor.neonGreen, lineWidth: 2)
                )
        }
        .padding(20)
        .glassCard()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FocusSchedule.self, FocusSession.self])
}
