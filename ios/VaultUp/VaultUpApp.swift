import SwiftUI

@main
struct VaultUpApp: App {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedTab = 0
    @AppStorage("app_theme") private var appThemeRaw: String = AppTheme.dark.rawValue

    private var currentTheme: AppTheme {
        AppTheme(rawValue: appThemeRaw) ?? .dark
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if networkManager.isLoggedIn && networkManager.currentUser != nil {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem { Label("Home", systemImage: "house.fill") }
                            .tag(0)
                        VaultsView()
                            .tabItem { Label("Vaults", systemImage: "lock.fill") }
                            .tag(1)
                        PaymentView()
                            .tabItem { Label("Pay", systemImage: "creditcard.fill") }
                            .tag(2)
                        SettingsView()
                            .tabItem { Label("Settings", systemImage: "gear") }
                            .tag(3)
                    }
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.96)), removal: .opacity))
                } else {
                    AuthView()
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 1.04)), removal: .opacity))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: networkManager.isLoggedIn)
            .tint(Color.vuAccent)
            .preferredColorScheme(currentTheme.colorScheme)
            .environmentObject(networkManager)
        }
    }
}
