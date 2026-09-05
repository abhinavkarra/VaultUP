// VaultUpApp.swift
// Main App Entry Point

import SwiftUI

@main
struct VaultUpApp: App {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedTab = 0
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
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
                .environmentObject(networkManager)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
                    .environmentObject(networkManager)
            }
        }
    }
}

