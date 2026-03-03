import SwiftUI
#if canImport(RevenueCat)
import RevenueCat
#endif

/// Manages FocusLock Pro subscriptions via RevenueCat
/// Replaces StoreManager with server-validated purchases and advanced analytics
@MainActor
final class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()
    
    // MARK: - Product Configuration
    enum Config {
        static let apiKey = "appl_YOUR_API_KEY_HERE" // TODO: Replace with actual key
        static let monthlyProductID = "com.focuslock.pro.monthly"
        static let yearlyProductID = "com.focuslock.pro.yearly"
        static let entitlementID = "pro"
    }
    
    // MARK: - Published State
    @Published var offerings: Offerings?
    @Published var customerInfo: CustomerInfo?
    @Published var isProUser = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var monthlyPackage: Package? {
        offerings?.current?.monthly
    }
    
    var yearlyPackage: Package? {
        offerings?.current?.annual
    }
    
    var monthlyPrice: String {
        monthlyPackage?.storeProduct.localizedPriceString ?? "$2.99"
    }
    
    var yearlyPrice: String {
        yearlyPackage?.storeProduct.localizedPriceString ?? "$19.99"
    }
    
    var yearlyMonthlySavings: String? {
        guard let monthly = monthlyPackage,
              let yearly = yearlyPackage else { return nil }
        
        let monthlyAnnualPrice = monthly.storeProduct.price * 12
        let yearlySavings = monthlyAnnualPrice - yearly.storeProduct.price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearly.storeProduct.priceLocale
        
        return formatter.string(from: yearlySavings)
    }
    
    private init() {
        Task { await initialize() }
    }
    
    // MARK: - Initialization
    
    private func initialize() async {
        // Configure RevenueCat
        Purchases.logLevel = .debug // Change to .info for production
        Purchases.configure(withAPIKey: Config.apiKey)
        
        // Set up delegate for real-time updates
        Purchases.shared.delegate = self
        
        // Load initial data
        await loadOfferings()
        await refreshCustomerInfo()
    }
    
    // MARK: - Offerings
    
    func loadOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
            print("[RevenueCat] Loaded \(offerings?.all.count ?? 0) offerings")
        } catch {
            print("[RevenueCat] Failed to load offerings: \(error)")
            errorMessage = "Failed to load subscription options"
        }
    }
    
    // MARK: - Purchase Flow
    
    func purchase(_ package: Package) async -> Bool {
        guard !isPurchasing else { return false }
        
        isPurchasing = true
        errorMessage = nil
        
        do {
            let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
            await handleCustomerInfo(customerInfo)
            
            // Track successful purchase
            trackPurchaseEvent(package: package, success: true)
            
            isPurchasing = false
            return true
            
        } catch let error as ErrorCode {
            await handlePurchaseError(error)
            trackPurchaseEvent(package: package, success: false, error: error)
            isPurchasing = false
            return false
            
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isPurchasing = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await handleCustomerInfo(customerInfo)
            return isProUser
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Customer Info
    
    func refreshCustomerInfo() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await handleCustomerInfo(customerInfo)
        } catch {
            print("[RevenueCat] Failed to refresh customer info: \(error)")
        }
    }
    
    private func handleCustomerInfo(_ info: CustomerInfo) async {
        customerInfo = info
        let wasProUser = isProUser
        isProUser = info.entitlements[Config.entitlementID]?.isActive == true
        
        // Log subscription status changes
        if wasProUser != isProUser {
            print("[RevenueCat] Pro status changed: \(wasProUser) → \(isProUser)")
            if isProUser {
                trackSubscriptionActivated()
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func handlePurchaseError(_ error: ErrorCode) async {
        switch error {
        case .userCancelled:
            errorMessage = nil // Don't show error for user cancellation
        case .paymentPending:
            errorMessage = "Payment is pending approval"
        case .productNotAvailableForPurchase:
            errorMessage = "This subscription is not available"
        case .receiptAlreadyInUse:
            errorMessage = "This subscription is already active on another account"
        case .networkError:
            errorMessage = "Network error. Please check your connection"
        default:
            errorMessage = "Purchase failed. Please try again"
        }
        
        print("[RevenueCat] Purchase error: \(error.localizedDescription)")
    }
    
    // MARK: - Analytics
    
    private func trackPurchaseEvent(package: Package, success: Bool, error: Error? = nil) {
        // TODO: Integrate with your analytics service
        print("[RevenueCat] Purchase \(success ? "succeeded" : "failed") for \(package.identifier)")
    }
    
    private func trackSubscriptionActivated() {
        // TODO: Integrate with your analytics service
        print("[RevenueCat] Subscription activated")
    }
    
    // MARK: - User Identification
    
    func setUserID(_ userID: String) async {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(userID)
            await handleCustomerInfo(customerInfo)
        } catch {
            print("[RevenueCat] Failed to set user ID: \(error)")
        }
    }
    
    func logout() async {
        do {
            let customerInfo = try await Purchases.shared.logOut()
            await handleCustomerInfo(customerInfo)
        } catch {
            print("[RevenueCat] Failed to log out: \(error)")
        }
    }
}

// MARK: - PurchasesDelegate

extension RevenueCatManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            await handleCustomerInfo(customerInfo)
        }
    }
    
    func purchases(_ purchases: Purchases, readyForPromotedProduct product: StoreProduct, purchase startPurchase: @escaping StartPurchaseBlock) {
        // Handle App Store promoted purchases
        startPurchase { [weak self] (transaction, customerInfo, error, cancelled) in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let customerInfo = customerInfo {
                    await self.handleCustomerInfo(customerInfo)
                }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Legacy StoreManager Compatibility

// Backward compatibility for existing code
extension RevenueCatManager {
    /// Legacy property for backward compatibility
    var products: [StoreProduct] {
        [monthlyPackage?.storeProduct, yearlyPackage?.storeProduct].compactMap { $0 }
    }
    
    /// Legacy property for backward compatibility
    var purchaseInProgress: Bool { isPurchasing }
}