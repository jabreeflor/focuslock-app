import SwiftUI
import SwiftData

@main
struct FocusLockApp: App {
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
