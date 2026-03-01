import SwiftUI
import StoreKit

/// Manages FocusLock Pro subscriptions via StoreKit 2
@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    enum ProductID {
        static let monthly = "com.focuslock.pro.monthly"
        static let yearly = "com.focuslock.pro.yearly"
        static let all = [monthly, yearly]
    }
    
    @Published var products: [Product] = []
    @Published var isProUser = false
    @Published var purchaseInProgress = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task { await checkEntitlements() }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductID.all)
                .sorted { $0.price < $1.price }
        } catch {
            print("[StoreManager] Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async {
        purchaseInProgress = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkEntitlements()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase pending approval"
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        purchaseInProgress = false
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }
    
    // MARK: - Entitlements
    
    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               ProductID.all.contains(transaction.productID) {
                isProUser = true
                return
            }
        }
        isProUser = false
    }
    
    // MARK: - Helpers
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? await self.checkVerified(result) {
                    await transaction.finish()
                    await self.checkEntitlements()
                }
            }
        }
    }
    
    /// Helper: formatted price strings
    var monthlyPrice: String {
        products.first { $0.id == ProductID.monthly }?.displayPrice ?? "$2.99"
    }
    
    var yearlyPrice: String {
        products.first { $0.id == ProductID.yearly }?.displayPrice ?? "$19.99"
    }
}
