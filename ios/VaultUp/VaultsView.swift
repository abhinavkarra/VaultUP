// VaultsView.swift
// Vault management and creation

import SwiftUI

struct VaultsView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var showingCreateSheet = false
    @State private var newVaultName = ""
    @State private var newVaultType = "goal"
    @State private var newVaultTarget = ""
    @State private var userId = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                VStack {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Vaults")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                showingCreateSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.indigo)
                            }
                        }
                        Text("Manage your goal-locked savings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if networkManager.vaults.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "lock.open")
                                        .font(.system(size: 40))
                                        .foregroundColor(.indigo)
                                    Text("No Vaults Yet")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Create your first goal vault to start saving")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: { showingCreateSheet = true }) {
                                        Text("Create Vault")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(12)
                                            .background(Color.indigo)
                                            .cornerRadius(8)
                                    }
                                    .padding(.top, 8)
                                }
                                .padding(24)
                                .vuCard(radius: 16)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(networkManager.vaults) { vault in
                                        VaultDetailCard(vault: vault)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            
                            if let error = networkManager.errorMessage {
                                VStack {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text(error)
                                            .font(.subheadline)
                                            .foregroundColor(.orange)
                                        Spacer()
                                    }
                                }
                                .padding(12)
                                .vuCard(fill: .orange.opacity(0.18), radius: 12)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                NavigationStack {
                    ZStack {
                        VUBackground()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Create New Vault")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vault Name")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                TextField("e.g., MacBook Air", text: $newVaultName)
                                    .padding(12)
                                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vault Type")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Picker("Type", selection: $newVaultType) {
                                    Text("Goal Vault").tag("goal")
                                    Text("Trip Escrow").tag("trip_escrow")
                                }
                                .pickerStyle(.segmented)
                                .tint(.indigo)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target Amount (₹)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                TextField("e.g., 65000", text: $newVaultTarget)
                                    .keyboardType(.decimalPad)
                                    .padding(12)
                                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: { showingCreateSheet = false }) {
                                    Text("Cancel")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    createVault()
                                }) {
                                    if networkManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(12)
                                    } else {
                                        Text("Create")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(12)
                                            .background(Color.indigo)
                                            .cornerRadius(8)
                                    }
                                }
                                .disabled(newVaultName.isEmpty || newVaultTarget.isEmpty || networkManager.isLoading)
                            }
                            
                            Spacer()
                        }
                        .padding(24)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
            }
            .onAppear {
                Task {
                    await networkManager.fetchVaults(userId: userId)
                }
            }
        }
    }
    
    private func createVault() {
        guard let targetAmount = Float(newVaultTarget) else { return }
        
        Task {
            await networkManager.createVault(
                name: newVaultName,
                vaultType: newVaultType,
                targetAmount: targetAmount
            )
            
            if networkManager.errorMessage == nil {
                newVaultName = ""
                newVaultTarget = ""
                newVaultType = "goal"
                showingCreateSheet = false
            }
        }
    }
}

struct VaultDetailCard: View {
    let vault: Vault
    
    var vaultEmoji: String {
        switch vault.vaultType.lowercased() {
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(vaultEmoji) \(vault.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(vault.vaultType.capitalized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: vault.isLocked ? "lock.fill" : "lock.open.fill")
                    .foregroundColor(vault.isLocked ? .red : .green)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Balance")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("₹\(String(format: "%.2f", vault.currentBalance))")
                        .font(.headline)
                        .foregroundColor(.cyan)
                }
                
                if vault.targetAmount > 0 {
                    HStack {
                        Text("Target")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("₹\(String(format: "%.0f", vault.targetAmount))")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Progress")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(vault.progressFormatted)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    ProgressBar(progress: vault.progressPercentage, colors: [.green, .cyan])
                }
            }
        }
        .padding(16)
        .vuCard(radius: 16)
    }
}

#Preview {
    VaultsView()
}
