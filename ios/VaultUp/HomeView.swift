// HomeView.swift
// Dashboard and main home screen with luxury fintech aesthetics

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("student_name") private var studentName: String = "Abhinav Karra"
    @State private var showingTransactions = false
    @State private var showingCreateVault = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                VStack(spacing: 0) {
                    // Top Bar
                    topBarView
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            if networkManager.isLoading && networkManager.dashboard == nil {
                                loadingStateView
                            } else if let dashboard = networkManager.dashboard {
                                // Hero Fintech Card
                                heroBalanceCard(dashboard: dashboard)
                                
                                // Quick Actions
                                quickActionsBar
                                
                                // Smart Roundup Savings Banner
                                smartRoundupBanner
                                
                                // Active Vaults Section
                                activeVaultsSection(vaults: dashboard.vaults)
                                
                                // Student Status Card
                                studentVerifiedBanner(isVerified: dashboard.isStudentVerified)
                            } else {
                                emptyStateView
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
                        if let userId = networkManager.currentUser?.id ?? networkManager.dashboard?.userId {
                            await networkManager.fetchDashboard(userId: userId)
                            await networkManager.fetchVaults(userId: userId)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTransactions) {
                TransactionHistoryView()
                    .environmentObject(networkManager)
            }
            .onAppear {
                if let userId = networkManager.currentUser?.id ?? networkManager.dashboard?.userId {
                    Task {
                        await networkManager.fetchDashboard(userId: userId)
                        await networkManager.fetchVaults(userId: userId)
                    }
                }
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBarView: some View {
        HStack {
            HStack(spacing: 12) {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.vuAccent, .vuAccentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.vuAccent.opacity(0.35), radius: 6, y: 2)
                    
                    Text(initials(for: studentName))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back,")
                        .font(.caption)
                        .foregroundColor(.vuTextSecondary)
                    Text(studentName.isEmpty ? (networkManager.dashboard?.userName ?? "Student") : studentName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.vuTextPrimary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Transaction History button
            Button(action: { showingTransactions = true }) {
                ZStack {
                    Circle()
                        .fill(Color.vuCardElevated)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Circle().strokeBorder(Color.vuBorder, lineWidth: 1)
                        )
                    
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.vuAccent)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 12)
    }
    
    // MARK: - Hero Balance Card
    private func heroBalanceCard(dashboard: Dashboard) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.shield.fill")
                        .font(.subheadline)
                        .foregroundColor(.vuCyan)
                    Text("VAULTUP PLATINUM")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(1.5)
                }
                
                Spacer()
                
                Image(systemName: "wave.3.right")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Balance")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.75))
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("₹")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                    Text(String(format: "%.2f", dashboard.totalBalance))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // Split breakdown
            HStack(spacing: 12) {
                // Liquid
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.vuCyan.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "drop.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.vuCyan)
                        )
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Liquid Cash")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("₹\(String(format: "%.0f", dashboard.liquidBalance))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Goals
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.vuSuccess.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.vuSuccess)
                        )
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Locked Goals")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("₹\(String(format: "%.0f", dashboard.goalBalance))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.16, blue: 0.45),
                    Color(red: 0.12, green: 0.08, blue: 0.32),
                    Color(red: 0.08, green: 0.05, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.vuAccent.opacity(0.35), radius: 18, y: 8)
    }
    
    // MARK: - Quick Actions Bar
    private var quickActionsBar: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: PaymentView().environmentObject(networkManager)) {
                quickActionItem(icon: "qrcode.viewfinder", title: "Pay UPI", color: .vuAccent)
            }
            
            NavigationLink(destination: VaultsView().environmentObject(networkManager)) {
                quickActionItem(icon: "plus.circle.fill", title: "New Vault", color: .vuCyan)
            }
            
            Button(action: { showingTransactions = true }) {
                quickActionItem(icon: "clock.arrow.circlepath", title: "History", color: .vuWarning)
            }
            
            NavigationLink(destination: SettingsView().environmentObject(networkManager)) {
                quickActionItem(icon: "person.crop.circle.badge.checkmark", title: "Profile", color: .vuSuccess)
            }
        }
    }
    
    private func quickActionItem(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.14))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.vuTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .vuCard(fill: .vuCardElevated, radius: 16)
    }
    
    // MARK: - Smart Roundup Banner
    private var smartRoundupBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.vuCyan, .vuAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Micro-Roundup Engine")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.vuTextPrimary)
                    
                    Text("ACTIVE")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.vuSuccess.opacity(0.15))
                        .foregroundColor(.vuSuccess)
                        .clipShape(Capsule())
                }
                
                Text("Every spend rounds up to ₹10 into your goal vaults automatically.")
                    .font(.caption)
                    .foregroundColor(.vuTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(14)
        .vuCard(fill: .vuCard)
    }
    
    // MARK: - Active Vaults
    private func activeVaultsSection(vaults: [VaultSummary]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Active Vaults")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                
                Spacer()
                
                NavigationLink(destination: VaultsView().environmentObject(networkManager)) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.vuAccent)
                }
            }
            
            if vaults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "lock.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.vuTextMuted)
                    Text("No vaults active yet")
                        .font(.subheadline)
                        .foregroundColor(.vuTextSecondary)
                    NavigationLink(destination: VaultsView().environmentObject(networkManager)) {
                        Text("Create Your First Goal Vault")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.vuAccent)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .vuCard()
            } else {
                VStack(spacing: 12) {
                    ForEach(vaults) { vault in
                        ModernVaultCard(vault: vault)
                    }
                }
            }
        }
    }
    
    // MARK: - Student Verified Banner
    private func studentVerifiedBanner(isVerified: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isVerified ? "checkmark.seal.fill" : "person.badge.shield.checkmark.fill")
                .font(.title3)
                .foregroundColor(isVerified ? .vuSuccess : .vuAccent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isVerified ? "Student Account Verified 🎓" : "Student Verification Pending")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                Text(isVerified ? "Zero platform charges & double-roundup rewards enabled." : "Add your student roll number in Settings to unlock perks.")
                    .font(.caption)
                    .foregroundColor(.vuTextSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .vuCard(fill: isVerified ? Color.vuSuccess.opacity(0.08) : Color.vuAccent.opacity(0.08))
    }
    
    private var loadingStateView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.vuAccent)
            Text("Connecting to VaultUp ledger...")
                .font(.subheadline)
                .foregroundColor(.vuTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .vuCard()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Text("Ready to get started?")
                .font(.headline)
                .foregroundColor(.vuTextPrimary)
            Text("Create your first goal vault to start micro-saving.")
                .font(.caption)
                .foregroundColor(.vuTextSecondary)
            Button("Create Goal Vault") {
                showingCreateVault = true
            }
            .buttonStyle(VUActionButtonStyle(color: .vuAccent))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
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
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Modern Vault Card
struct ModernVaultCard: View {
    let vault: VaultSummary
    
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
        } else if vault.type.lowercased() == "liquid" {
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
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vault.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.vuTextPrimary)
                    
                    Text(vault.type.capitalized)
                        .font(.caption2)
                        .foregroundColor(.vuTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(String(format: "%.2f", vault.balance))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.vuTextPrimary)
                    
                    if vault.target > 0 {
                        Text("Target: ₹\(String(format: "%.0f", vault.target))")
                            .font(.caption2)
                            .foregroundColor(.vuTextSecondary)
                    }
                }
            }
            
            if vault.target > 0 {
                VStack(spacing: 6) {
                    ProgressBar(
                        progress: vault.progressPercentage,
                        colors: [.vuCyan, .vuAccent]
                    )
                    
                    HStack {
                        Text("\(String(format: "%.1f", vault.progressPercentage))% achieved")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.vuSuccess)
                        Spacer()
                        Text("₹\(String(format: "%.0f", max(0, vault.target - vault.balance))) left")
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
