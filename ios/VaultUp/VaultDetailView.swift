import SwiftUI

struct VaultDetailView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss
    
    let vault: Vault
    
    @State private var transactionAmount = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            VUBackground()
            
            VStack(spacing: 24) {
                // Header Details
                VStack(spacing: 8) {
                    Text(vault.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Current Balance: ₹\(String(format: "%.2f", vault.currentBalance))")
                        .font(.title3)
                        .foregroundColor(.cyan)
                    
                    if vault.targetAmount > 0 {
                        Text("Target: ₹\(String(format: "%.0f", vault.targetAmount))")
                            .foregroundColor(.gray)
                        
                        ProgressBar(progress: vault.progressPercentage)
                            .frame(height: 12)
                            .padding(.top, 8)
                            .padding(.horizontal)
                        
                        Text(vault.progressFormatted)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .vuCard()
                .padding(.horizontal)
                
                // Transaction Area
                VStack(spacing: 16) {
                    Text("Manage Funds")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Amount in ₹", text: $transactionAmount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            handleTransaction(isDeposit: true)
                        }) {
                            Text("Deposit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            handleTransaction(isDeposit: false)
                        }) {
                            Text("Withdraw")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    
                    if let lastWithdrawal = vault.lastWithdrawalAt {
                        Text("Last withdrawal: \(lastWithdrawal)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        
                        Text("Note: 12-hour cooling period applies between withdrawals.")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .vuCard()
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Transaction Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        // Observe network manager errors
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
                // Successfully processed
                dismiss() // Optionally go back or just refresh state
            }
        }
    }
}
