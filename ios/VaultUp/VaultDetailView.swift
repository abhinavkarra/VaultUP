import SwiftUI

struct VaultDetailView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss
    
    let vault: Vault
    
    @State private var transactionAmount = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingDeleteSheet = false
    
    var body: some View {
        ZStack {
            VUBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Details
                    VStack(spacing: 12) {
                        Text(vault.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.vuTextPrimary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text("₹")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.vuCyan)
                            Text(String(format: "%.2f", vault.currentBalance))
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundColor(.vuTextPrimary)
                        }
                        
                        if vault.targetAmount > 0 {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Goal Target")
                                        .font(.caption)
                                        .foregroundColor(.vuTextSecondary)
                                    Spacer()
                                    Text("₹\(String(format: "%.0f", vault.targetAmount))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.vuTextPrimary)
                                }
                                
                                ProgressBar(
                                    progress: vault.progressPercentage,
                                    colors: [.vuCyan, .vuAccent]
                                )
                                
                                HStack {
                                    Text(vault.progressFormatted + " achieved")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.vuSuccess)
                                    Spacer()
                                    let remaining = max(0, vault.targetAmount - vault.currentBalance)
                                    Text("₹\(String(format: "%.0f", remaining)) remaining")
                                        .font(.system(size: 11))
                                        .foregroundColor(.vuTextSecondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(20)
                    .vuCard()
                    
                    // Transaction Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Manage Funds")
                            .font(.headline)
                            .foregroundColor(.vuTextPrimary)
                        
                        HStack(spacing: 8) {
                            Text("₹")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.vuAccent)
                            
                            TextField("Amount", text: $transactionAmount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.vuTextPrimary)
                        }
                        .padding(14)
                        .background(Color.vuCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.vuBorder, lineWidth: 1)
                        )
                        
                        HStack(spacing: 14) {
                            Button(action: {
                                handleTransaction(isDeposit: true)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.left")
                                    Text("Deposit")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(VUActionButtonStyle(color: .vuSuccess))
                            
                            Button(action: {
                                handleTransaction(isDeposit: false)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.right")
                                    Text("Withdraw")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(VUActionButtonStyle(color: .vuWarning))
                        }
                        
                        if let lastWithdrawal = vault.lastWithdrawalAt {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last withdrawal: \(lastWithdrawal)")
                                    .font(.caption2)
                                    .foregroundColor(.vuTextSecondary)
                                
                                Text("Cooldown: 12-hour cooling period applies between withdrawals.")
                                    .font(.caption2)
                                    .foregroundColor(.vuWarning)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(20)
                    .vuCard()
                    
                    // Close & Delete Vault Option
                    Button(action: { showingDeleteSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.vuDanger)
                                .font(.subheadline)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Close & Delete Vault")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.vuDanger)
                                Text(vault.currentBalance > 0 ? "Transfer ₹\(String(format: "%.2f", vault.currentBalance)) to bank or existing vault" : "Permanently remove this empty vault")
                                    .font(.caption2)
                                    .foregroundColor(.vuTextSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.vuTextSecondary)
                        }
                        .padding(16)
                        .vuCard(fill: Color.vuDanger.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.vuDanger.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle(vault.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDeleteSheet) {
            DeleteVaultSheet(
                vault: vault,
                availableVaults: networkManager.vaults,
                isPresented: $showingDeleteSheet,
                onDelete: { destination, targetVaultId in
                    Task {
                        await networkManager.deleteVault(
                            vaultId: vault.id,
                            transferDestination: destination,
                            targetVaultId: targetVaultId
                        )
                        if networkManager.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            )
        }
        .alert("Transaction Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: networkManager.errorMessage) { error in
            if let error = error {
                errorMessage = error
                showingError = true
            }
        }
    }
    
    private func handleTransaction(isDeposit: Bool) {
        guard let amount = Float(transactionAmount), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            showingError = true
            return
        }
        
        Task {
            if isDeposit {
                await networkManager.deposit(vaultId: vault.id, amount: amount)
            } else {
                await networkManager.withdraw(vaultId: vault.id, amount: amount)
            }
            
            if networkManager.errorMessage == nil {
                transactionAmount = ""
                dismiss()
            }
        }
    }
}
