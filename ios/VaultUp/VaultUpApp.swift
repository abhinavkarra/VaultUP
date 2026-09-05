import SwiftUI

@main
struct VaultUpApp: App {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
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
            .tint(.indigo)
            .environmentObject(networkManager)
            .task {
                await networkManager.startDemoSession()
            }
        }
    }
}
