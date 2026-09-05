// VaultsView.swift
// Vault management, creation, and goal tracking

import SwiftUI

struct VaultsView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingCreateSheet = false
    @State private var vaultToDelete: Vault?
    @State private var newVaultName = ""
    @State private var newVaultType = "goal"
    @State private var newVaultTarget = ""
    
    private var totalVaulted: Float {
        networkManager.vaults.reduce(0) { $0 + $1.currentBalance }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Summary stats strip
                            summaryStatsCard
                            
                            // Vault list
                            if networkManager.isLoading && networkManager.vaults.isEmpty {
                                loadingStateView
                            } else if networkManager.vaults.isEmpty {
                                emptyStateView
                            } else {
                                vaultsListView
                            }
                            
                            if let error = networkManager.errorMessage {
                                errorMessageView(error: error)
                            }
                            
                            Spacer().frame(height: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .refreshable {
                        if let userId = networkManager.currentUser?.id {
                            await networkManager.fetchVaults(userId: userId)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateSheet) {
                createVaultSheet
            }
            .sheet(item: $vaultToDelete) { vault in
                DeleteVaultSheet(
                    vault: vault,
                    availableVaults: networkManager.vaults,
                    isPresented: Binding(
                        get: { vaultToDelete != nil },
                        set: { if !$0 { vaultToDelete = nil } }
                    ),
                    onDelete: { destination, targetVaultId in
                        Task {
                            await networkManager.deleteVault(
                                vaultId: vault.id,
                                transferDestination: destination,
                                targetVaultId: targetVaultId
                            )
                            vaultToDelete = nil
                        }
                    }
                )
            }
            .onAppear {
                Task {
                    if let userId = networkManager.currentUser?.id {
                        await networkManager.fetchVaults(userId: userId)
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Goal Vaults")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.vuTextPrimary)
                Text("Segregated savings & locked milestones")
                    .font(.subheadline)
                    .foregroundColor(.vuTextSecondary)
            }
            
            Spacer()
            
            Button(action: { showingCreateSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("New")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.vuAccent, .vuAccentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.vuAccent.opacity(0.35), radius: 6, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Summary Stats Card
    private var summaryStatsCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Locked & Saved")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.vuTextSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("₹")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.vuCyan)
                    Text(String(format: "%.2f", totalVaulted))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.vuTextPrimary)
                }
            }
            
            Spacer()
            
            Divider()
                .frame(height: 36)
                .background(Color.vuDivider)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Active Goals")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.vuTextSecondary)
                
                Text("\(networkManager.vaults.count)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.vuAccent)
            }
        }
        .padding(18)
        .vuCard()
    }
    
    // MARK: - Vaults List View
    private var vaultsListView: some View {
        VStack(spacing: 14) {
            ForEach(networkManager.vaults) { vault in
                NavigationLink(destination: VaultDetailView(vault: vault).environmentObject(networkManager)) {
                    VaultDetailCard(vault: vault)
                }
                .buttonStyle(PlainButtonStyle())
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        vaultToDelete = vault
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.vuAccent.opacity(0.12))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.vuAccent)
            }
            
            VStack(spacing: 6) {
                Text("No Vaults Created")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                Text("Lock money away for your laptop, semester trips, or emergency fund with automated roundups.")
                    .font(.subheadline)
                    .foregroundColor(.vuTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingCreateSheet = true }) {
                Text("Create Your First Vault")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.vuAccent)
                    .clipShape(Capsule())
                    .shadow(color: Color.vuAccent.opacity(0.35), radius: 6, y: 3)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .vuCard()
    }
    
    private var loadingStateView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.vuAccent)
            Text("Loading vaults...")
                .font(.caption)
                .foregroundColor(.vuTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .vuCard()
    }
    
    private func errorMessageView(error: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.vuDanger)
            Text(error)
                .font(.caption)
                .foregroundColor(.vuDanger)
            Spacer()
        }
        .padding(12)
        .background(Color.vuDanger.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Create Vault Sheet
    private var createVaultSheet: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Savings Goal")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.vuTextPrimary)
                            Text("Set up an automated target with lock protection")
                                .font(.caption)
                                .foregroundColor(.vuTextSecondary)
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Goal Name")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                TextField("e.g. MacBook Pro, Goa Trip, Gym Gear", text: $newVaultName)
                                    .padding(12)
                                    .background(Color.vuCardElevated)
                                    .cornerRadius(10)
                                    .foregroundColor(.vuTextPrimary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.vuBorder, lineWidth: 1)
                                    }
                            }
                            
                            // Type
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Vault Type")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                Picker("Type", selection: $newVaultType) {
                                    Text("Goal Vault (Personal)").tag("goal")
                                    Text("Trip Escrow (Group)").tag("trip_escrow")
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Target
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Target Amount (₹)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                HStack(spacing: 8) {
                                    Text("₹")
                                        .font(.headline)
                                        .foregroundColor(.vuCyan)
                                    
                                    TextField("e.g. 50000", text: $newVaultTarget)
                                        .keyboardType(.decimalPad)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.vuTextPrimary)
                                }
                                .padding(12)
                                .background(Color.vuCardElevated)
                                .cornerRadius(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                                }
                            }
                        }
                        .padding(18)
                        .vuCard()
                        
                        // Submit Button
                        Button(action: createVault) {
                            if networkManager.isLoading {
                                ProgressView().tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            } else {
                                Text("Create Goal Vault")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                        }
                        .buttonStyle(VUActionButtonStyle(color: .vuAccent))
                        .disabled(newVaultName.isEmpty || newVaultTarget.isEmpty || networkManager.isLoading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Create Vault")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingCreateSheet = false }
                        .foregroundColor(.vuTextSecondary)
                }
            }
        }
        .presentationDetents([.medium])
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

// MARK: - Vault Detail Card
struct VaultDetailCard: View {
    let vault: Vault
    
    var categoryIcon: (String, Color) {
        let name = vault.name.lowercased()
        if name.contains("laptop") || name.contains("mac") || name.contains("tech") {
            return ("laptopcomputer", .vuCyan)
        } else if name.contains("trip") || name.contains("travel") || name.contains("escrow") {
            return ("airplane.departure", .vuAccentPurple)
        } else if name.contains("emergency") || name.contains("rainy") {
            return ("cross.case.fill", .vuDanger)
        } else if name.contains("book") || name.contains("course") || name.contains("tuition") {
            return ("book.fill", .vuWarning)
        } else if vault.vaultType.lowercased() == "liquid" {
            return ("drop.fill", .vuCyan)
        } else {
            return ("lock.fill", .vuAccent)
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                let (icon, color) = categoryIcon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.14))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(vault.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.vuTextPrimary)
                    
                    HStack(spacing: 6) {
                        Text(vault.vaultType.capitalized)
                            .font(.caption)
                            .foregroundColor(.vuTextSecondary)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.vuTextMuted)
                        
                        Text(vault.isLocked ? "Locked 🔒" : "Unlocked 🔓")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(vault.isLocked ? .vuDanger : .vuSuccess)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(String(format: "%.2f", vault.currentBalance))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.vuTextPrimary)
                    
                    if vault.targetAmount > 0 {
                        Text("of ₹\(String(format: "%.0f", vault.targetAmount))")
                            .font(.caption2)
                            .foregroundColor(.vuTextSecondary)
                    }
                }
            }
            
            if vault.targetAmount > 0 {
                VStack(spacing: 6) {
                    ProgressBar(
                        progress: vault.progressPercentage,
                        colors: [.vuCyan, .vuAccent]
                    )
                    
                    HStack {
                        Text("\(vault.progressFormatted) achieved")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.vuSuccess)
                        
                        Spacer()
                        
                        let remaining = max(0, vault.targetAmount - vault.currentBalance)
                        Text("₹\(String(format: "%.0f", remaining)) to goal")
                            .font(.system(size: 11))
                            .foregroundColor(.vuTextSecondary)
                    }
                }
            }
        }
        .padding(16)
        .vuCard()
    }
}

// MARK: - Delete Vault Sheet
struct DeleteVaultSheet: View {
    let vault: Vault
    let availableVaults: [Vault]
    @Binding var isPresented: Bool
    var onDelete: (String?, Int?) -> Void
    
    @State private var transferChoice: String = "bank" // "bank" or "vault"
    @State private var selectedTargetVaultId: Int?
    
    var otherVaults: [Vault] {
        availableVaults.filter { $0.id != vault.id }
    }
    
    var hasBalance: Bool {
        vault.currentBalance > 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Icon
                        ZStack {
                            Circle()
                                .fill(Color.vuDanger.opacity(0.12))
                                .frame(width: 68, height: 68)
                            
                            Image(systemName: hasBalance ? "arrow.triangle.swap" : "trash.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.vuDanger)
                        }
                        .padding(.top, 12)
                        
                        VStack(spacing: 6) {
                            Text("Delete '\(vault.name)'")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.vuTextPrimary)
                            
                            if hasBalance {
                                Text("This vault contains a remaining balance of ₹\(String(format: "%.2f", vault.currentBalance)). Please select where to deposit these funds before closing.")
                                    .font(.caption)
                                    .foregroundColor(.vuTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            } else {
                                Text("This vault is currently empty and will be permanently removed.")
                                    .font(.caption)
                                    .foregroundColor(.vuTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        if hasBalance {
                            VStack(spacing: 12) {
                                // Option 1: Credit to Bank Account
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        transferChoice = "bank"
                                    }
                                }) {
                                    HStack(spacing: 14) {
                                        Image(systemName: transferChoice == "bank" ? "largecircle.fill.circle" : "circle")
                                            .font(.title3)
                                            .foregroundColor(transferChoice == "bank" ? .vuSuccess : .vuTextMuted)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(Color.vuSuccess.opacity(0.14))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "building.columns.fill")
                                                .foregroundColor(.vuSuccess)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Credit to Bank Account")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.vuTextPrimary)
                                            Text("Payout ₹\(String(format: "%.2f", vault.currentBalance)) directly to linked bank")
                                                .font(.caption2)
                                                .foregroundColor(.vuTextSecondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(14)
                                    .vuCard(fill: transferChoice == "bank" ? Color.vuSuccess.opacity(0.08) : .vuCardElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(transferChoice == "bank" ? Color.vuSuccess : Color.vuBorder, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // Option 2: Transfer to Existing Vault
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        transferChoice = "vault"
                                        if selectedTargetVaultId == nil {
                                            selectedTargetVaultId = otherVaults.first?.id
                                        }
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 14) {
                                            Image(systemName: transferChoice == "vault" ? "largecircle.fill.circle" : "circle")
                                                .font(.title3)
                                                .foregroundColor(transferChoice == "vault" ? .vuCyan : .vuTextMuted)
                                            
                                            ZStack {
                                                Circle()
                                                    .fill(Color.vuCyan.opacity(0.14))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "arrow.left.arrow.right")
                                                    .foregroundColor(.vuCyan)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Transfer to Another Vault")
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.vuTextPrimary)
                                                Text("Move ₹\(String(format: "%.2f", vault.currentBalance)) into another goal")
                                                    .font(.caption2)
                                                    .foregroundColor(.vuTextSecondary)
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        if transferChoice == "vault" && !otherVaults.isEmpty {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("Destination Vault")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.vuTextSecondary)
                                                
                                                Picker("Destination Vault", selection: Binding(
                                                    get: { selectedTargetVaultId ?? otherVaults.first?.id ?? 0 },
                                                    set: { selectedTargetVaultId = $0 }
                                                )) {
                                                    ForEach(otherVaults) { target in
                                                        Text("\(target.name) (₹\(String(format: "%.0f", target.currentBalance)))")
                                                            .tag(target.id)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                                .padding(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.vuCardInset)
                                                .cornerRadius(10)
                                            }
                                            .padding(.top, 4)
                                        }
                                    }
                                    .padding(14)
                                    .vuCard(fill: transferChoice == "vault" ? Color.vuCyan.opacity(0.08) : .vuCardElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(transferChoice == "vault" ? Color.vuCyan : Color.vuBorder, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                if hasBalance {
                                    if transferChoice == "bank" {
                                        onDelete("bank", nil)
                                    } else {
                                        let targetId = selectedTargetVaultId ?? otherVaults.first?.id
                                        onDelete("vault", targetId)
                                    }
                                } else {
                                    onDelete(nil, nil)
                                }
                                isPresented = false
                            }) {
                                Text(hasBalance ? "Transfer & Delete Vault" : "Delete Vault")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(VUActionButtonStyle(color: .vuDanger))
                            
                            Button("Cancel") {
                                isPresented = false
                            }
                            .font(.subheadline)
                            .foregroundColor(.vuTextSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Vault Closure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(.vuTextSecondary)
                }
            }
            .onAppear {
                if selectedTargetVaultId == nil {
                    selectedTargetVaultId = otherVaults.first?.id
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
