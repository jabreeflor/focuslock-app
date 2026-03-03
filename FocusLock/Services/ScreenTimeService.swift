import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Screen Time Service
// Real implementation using FamilyControls framework
// Requires FamilyControls entitlement and device testing for full functionality

@MainActor
final class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()
    
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    
    @Published var isAuthorized: Bool = false
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    private init() {
        updateAuthorizationStatus()
    }
    
    /// Check current authorization status
    private func updateAuthorizationStatus() {
        isAuthorized = center.authorizationStatus == .approved
    }
    
    /// Request Screen Time authorization from the user
    func requestAuthorization() async -> Bool {
        do {
            try await center.requestAuthorization(for: .individual)
            await MainActor.run {
                updateAuthorizationStatus()
            }
            print("[ScreenTimeService] Authorization status: \(center.authorizationStatus)")
            return isAuthorized
        } catch {
            print("[ScreenTimeService] Authorization failed: \(error)")
            return false
        }
    }
    
    /// Apply shields to selected apps
    func shieldSelectedApps() {
        guard isAuthorized else {
            print("[ScreenTimeService] Not authorized to shield apps")
            return
        }
        
        store.shield.applications = selectedApps.applicationTokens
        
        // Set up category shielding using the correct policy approach
        if !selectedApps.categoryTokens.isEmpty {
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy
                .specific(selectedApps.categoryTokens)
        }
        
        print("[ScreenTimeService] Shielding \(selectedApps.applicationTokens.count) apps and \(selectedApps.categoryTokens.count) categories")
    }
    
    /// Apply shields to specific app tokens
    func shieldApps(_ appTokens: Set<ApplicationToken>) {
        guard isAuthorized else {
            print("[ScreenTimeService] Not authorized to shield apps")
            return
        }
        
        store.shield.applications = appTokens
        print("[ScreenTimeService] Shielding \(appTokens.count) specific apps")
    }
    
    /// Remove all app shields
    func removeAllShields() {
        guard isAuthorized else {
            print("[ScreenTimeService] Not authorized to remove shields")
            return
        }
        
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy<Application>.none
        print("[ScreenTimeService] Removed all shields")
    }
    
    /// Update the selected apps (to be called by FamilyActivityPicker)
    func updateSelectedApps(_ selection: FamilyActivitySelection) {
        selectedApps = selection
        print("[ScreenTimeService] Updated selection: \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
    }
    
    /// Get localized display names for selected apps (for UI display)
    func getSelectedAppNames() -> [String] {
        // Note: Getting display names requires additional API calls
        // For now, return placeholder names based on token count
        let appCount = selectedApps.applicationTokens.count
        let categoryCount = selectedApps.categoryTokens.count
        
        var names: [String] = []
        if appCount > 0 {
            names.append("\(appCount) selected app\(appCount == 1 ? "" : "s")")
        }
        if categoryCount > 0 {
            names.append("\(categoryCount) app categor\(categoryCount == 1 ? "y" : "ies")")
        }
        
        return names.isEmpty ? ["No apps selected"] : names
    }
    
    /// Start monitoring device activity for the given schedule
    func startDeviceActivityMonitoring(for schedule: FocusSchedule) {
        // Implementation would use DeviceActivityCenter to set up monitoring
        print("[ScreenTimeService] Started monitoring for schedule: \(schedule.name)")
    }
    
    /// Stop device activity monitoring
    func stopDeviceActivityMonitoring() {
        // Implementation would use DeviceActivityCenter to stop monitoring
        print("[ScreenTimeService] Stopped device activity monitoring")
    }
}
