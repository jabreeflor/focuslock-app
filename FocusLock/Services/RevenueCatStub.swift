import SwiftUI

// MARK: - RevenueCat Stub Types
// These stub types allow the app to compile without RevenueCat SDK
// Replace with actual RevenueCat imports once SDK is added

#if !canImport(RevenueCat)

// Stub types that mirror RevenueCat SDK interfaces
struct CustomerInfo {
    let entitlements: [String: MockEntitlement] = ["pro": MockEntitlement(isActive: false)]
}

struct MockEntitlement {
    let isActive: Bool
}

struct Offerings {
    let current: MockOffering?
    let all: [String: MockOffering] = [:]
    
    init() {
        self.current = MockOffering()
    }
}

struct MockOffering {
    let monthly: Package?
    let annual: Package?
    
    init() {
        self.monthly = Package(
            identifier: "com.focuslock.pro.monthly",
            storeProduct: MockStoreProduct(
                localizedPriceString: "$2.99",
                price: NSDecimalNumber(value: 2.99),
                subscriptionPeriod: MockSubscriptionPeriod()
            )
        )
        self.annual = Package(
            identifier: "com.focuslock.pro.yearly", 
            storeProduct: MockStoreProduct(
                localizedPriceString: "$19.99",
                price: NSDecimalNumber(value: 19.99),
                subscriptionPeriod: MockSubscriptionPeriod()
            )
        )
    }
}

struct Package: Identifiable {
    let id = UUID()
    let identifier: String
    let storeProduct: MockStoreProduct
}

struct MockStoreProduct {
    let localizedPriceString: String
    let price: NSDecimalNumber
    let subscriptionPeriod: MockSubscriptionPeriod?
    let priceLocale: Locale = .current
}

struct MockSubscriptionPeriod {
    func localizedDescription() -> String {
        return "per month"
    }
}

enum MockErrorCode: Error {
    case userCancelled
    case paymentPending
    case productNotAvailableForPurchase
    case receiptAlreadyInUse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .userCancelled: return "User cancelled"
        case .paymentPending: return "Payment pending"
        case .productNotAvailableForPurchase: return "Product not available"
        case .receiptAlreadyInUse: return "Receipt already in use"
        case .networkError: return "Network error"
        }
    }
}

// Mock Purchases class
class MockPurchases {
    static let shared = MockPurchases()
    static var logLevel: String = ""
    
    weak var delegate: PurchasesDelegate?
    
    static func configure(withAPIKey: String) {
        print("[RevenueCat Stub] Configured with API key: \(withAPIKey)")
    }
    
    func offerings() async throws -> Offerings {
        try await Task.sleep(for: .milliseconds(500)) // Simulate network delay
        return Offerings()
    }
    
    func purchase(package: Package) async throws -> (String, CustomerInfo, Bool) {
        print("[RevenueCat Stub] Purchasing package: \(package.identifier)")
        try await Task.sleep(for: .milliseconds(1000)) // Simulate purchase delay
        
        // Simulate successful purchase
        let customerInfo = CustomerInfo()
        return ("transaction", customerInfo, false)
    }
    
    func restorePurchases() async throws -> CustomerInfo {
        print("[RevenueCat Stub] Restoring purchases")
        try await Task.sleep(for: .milliseconds(500))
        return CustomerInfo()
    }
    
    func customerInfo() async throws -> CustomerInfo {
        return CustomerInfo()
    }
    
    func logIn(_ userID: String) async throws -> (CustomerInfo, Bool) {
        print("[RevenueCat Stub] Logging in user: \(userID)")
        return (CustomerInfo(), true)
    }
    
    func logOut() async throws -> CustomerInfo {
        print("[RevenueCat Stub] Logging out")
        return CustomerInfo()
    }
}

protocol PurchasesDelegate: AnyObject {
    func purchases(_ purchases: MockPurchases, receivedUpdated customerInfo: CustomerInfo)
}

// Make the stub types available globally
typealias Purchases = MockPurchases
typealias ErrorCode = MockErrorCode

#endif