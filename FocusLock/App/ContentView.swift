import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .preferredColorScheme(.dark)
        } else {
            mainTabView
                .preferredColorScheme(.dark)
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ScheduleListView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Schedules")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(FLColor.cyan)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FocusSchedule.self, FocusSession.self, ChallengeAttempt.self])
}
