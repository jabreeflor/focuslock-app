import SwiftUI
import Combine

/// Manages ad loading, display, and impression tracking.
/// Currently uses stub/placeholder ads. Swap in Google Mobile Ads SDK later.
@MainActor
final class AdManager: ObservableObject {
    static let shared = AdManager()
    
    // Test Ad Unit IDs (Google's official test IDs)
    enum AdUnitID {
        static let banner = "ca-app-pub-3940256099942544/2435281174"
        static let interstitial = "ca-app-pub-3940256099942544/4411468910"
        static let rewarded = "ca-app-pub-3940256099942544/1712485313"
    }
    
    @Published var isInterstitialReady = true // Stub: always ready
    @Published var isRewardedReady = true
    @Published private(set) var totalImpressions: Int = 0
    
    private init() {}
    
    /// Call once at app launch to initialize the ads SDK
    func configure() {
        // TODO: Replace with GADMobileAds.sharedInstance().start()
        print("[AdManager] Configured with stub ads")
    }
    
    /// Show an interstitial ad. Returns true if shown.
    func showInterstitial() -> Bool {
        guard !StoreManager.shared.isProUser else { return false }
        totalImpressions += 1
        print("[AdManager] Interstitial shown (stub) — total impressions: \(totalImpressions)")
        // TODO: Present GADInterstitialAd from root view controller
        return true
    }
    
    /// Show a rewarded ad. Calls completion with true if reward earned.
    func showRewarded(completion: @escaping (Bool) -> Void) {
        guard !StoreManager.shared.isProUser else {
            completion(false)
            return
        }
        totalImpressions += 1
        print("[AdManager] Rewarded ad shown (stub) — granting reward")
        // TODO: Present GADRewardedAd, call completion in delegate
        // Simulate reward after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    /// Preload the next interstitial
    func loadInterstitial() {
        // TODO: GADInterstitialAd.load(...)
        isInterstitialReady = true
    }
    
    /// Preload the next rewarded ad
    func loadRewarded() {
        // TODO: GADRewardedAd.load(...)
        isRewardedReady = true
    }
}
