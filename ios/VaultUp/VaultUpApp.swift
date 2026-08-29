// VaultUpApp.swift
// Main App Entry Point

import SwiftUI

@main
struct VaultUpApp: App {
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                // Home Tab
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // Vaults Tab
                VaultsView()
                    .tabItem {
                        Label("Vaults", systemImage: "lock.fill")
                    }
                    .tag(1)
                
                // Pay Tab
                PaymentView()
                    .tabItem {
                        Label("Pay", systemImage: "creditcard.fill")
                    }
                    .tag(2)
                
                // Settings Tab
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(.indigo)
        }
    }
}

