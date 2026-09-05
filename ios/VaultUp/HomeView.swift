// HomeView.swift
// Dashboard and main home screen

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @State private var showingTransactions = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.08, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("VaultUp ⚡")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if let dashboard = networkManager.dashboard {
                                    Text(dashboard.userName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            
                            if networkManager.dashboard != nil {
                                Button(action: { showingTransactions = true }) {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .foregroundColor(.indigo)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if networkManager.dashboard == nil {
                                VStack(spacing: 16) {
                                    ProgressView("Loading your VaultUp account...")
                                        .tint(.white)
                                        .foregroundColor(.white)
                                }
                                .padding(24)
                            } else if let dashboard = networkManager.dashboard {
                                // Dashboard Content
                                
                                // Total Balance Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Total Balance")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "banknote")
                                            .foregroundColor(.indigo)
                                    }
                                    
                                    Text("₹\(String(format: "%.2f", dashboard.totalBalance))")
                                        .font(.system(size: 32, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Liquid")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("₹\(String(format: "%.0f", dashboard.liquidBalance))")
                                                .font(.headline)
                                                .foregroundColor(.cyan)
                                        }
                                        
                                        Divider()
                                            .frame(height: 30)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Goals")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("₹\(String(format: "%.0f", dashboard.goalBalance))")
                                                .font(.headline)
                                                .foregroundColor(.green)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(20)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                
                                // Vaults Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Active Vaults")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                    
                                    if dashboard.vaults.isEmpty {
                                        Text("No vaults yet. Create one in the Vaults tab!")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 20)
                                    } else {
                                        VStack(spacing: 12) {
                                            ForEach(dashboard.vaults) { vault in
                                                VaultCard(vault: vault)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Student Status
                                if dashboard.isStudentVerified {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.green)
                                            Text("Student Verified")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                    }
                                    .padding(16)
                                    .background(Color(red: 0.1, green: 0.2, blue: 0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                }
                            }
                            
                            if let error = networkManager.errorMessage {
                                VStack {
                                    HStack {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.red)
                                        Text(error)
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                        Spacer()
                                    }
                                }
                                .padding(12)
                                .background(Color(red: 0.25, green: 0.1, blue: 0.1))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTransactions) {
                TransactionHistoryView()
                    .environmentObject(networkManager)
            }
        }
    }
}

struct VaultCard: View {
    let vault: VaultSummary
    
    var vaultEmoji: String {
        switch vault.type.lowercased() {
        case "liquid":
            return "💰"
        case "goal":
            return "🔒"
        case "trip_escrow":
            return "👥"
        default:
            return "🏦"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(vaultEmoji) \(vault.name)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if vault.target > 0 {
                    Text("\(String(format: "%.1f", vault.progressPercentage))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
            }
            
            Text("₹\(String(format: "%.2f", vault.balance))")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            if vault.target > 0 {
                VStack(spacing: 6) {
                    HStack {
                        Text("Target: ₹\(String(format: "%.0f", vault.target))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(red: 0.2, green: 0.2, blue: 0.3))
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.cyan, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (vault.progressPercentage / 100))
                        }
                        .cornerRadius(4)
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
        .cornerRadius(10)
    }
}

#Preview {
    HomeView()
}
