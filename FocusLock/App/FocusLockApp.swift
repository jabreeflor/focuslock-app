import SwiftUI
import SwiftData

@main
struct FocusLockApp: App {
    init() {
        // Initialize ads SDK
        AdManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            FocusSchedule.self,
            FocusSession.self,
            ChallengeAttempt.self
        ])
    }
}
