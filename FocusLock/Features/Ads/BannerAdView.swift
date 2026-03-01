import SwiftUI

/// Stub banner ad view. Replace internals with GADBannerView UIViewRepresentable.
struct BannerAdView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        if !storeManager.isProUser {
            bannerContent
        }
    }
    
    private var bannerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(FLColor.cyan.opacity(0.6))
                    Text("Ad")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .textCase(.uppercase)
                }
                
                Text("FocusLock — Sponsored Content")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
    }
}

// TODO: Real implementation using UIViewRepresentable + GADBannerView
/*
struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = AdManager.AdUnitID.banner
        banner.rootViewController = UIApplication.shared.rootViewController
        banner.load(GADRequest())
        return banner
    }
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
*/
