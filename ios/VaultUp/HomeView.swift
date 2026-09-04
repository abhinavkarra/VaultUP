import SwiftUI

struct HomeView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var userIdText = "1"

    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        if let dashboard = networkManager.dashboard {
                            dashboardContent(dashboard)
                        } else {
                            loginCard
                        }
                        if let error = networkManager.errorMessage {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .vuCard(fill: .vuDanger, radius: 14)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.vuCardInset).frame(width: 52, height: 52)
                Image(systemName: "person.fill").font(.title2).foregroundColor(.cyan)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(networkManager.dashboard?.userName ?? "Welcome back")
                    .font(.title3.weight(.bold)).foregroundColor(.white)
                if networkManager.dashboard?.isStudentVerified == true {
                    Label("Student Verified", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold)).foregroundColor(.mint)
                }
            }
            Spacer()
            Image(systemName: "bell")
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(Color.vuCard)
                .clipShape(Circle())
        }
    }

    private func dashboardContent(_ dashboard: Dashboard) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your money, with a plan.")
                .font(.title.weight(.bold)).foregroundColor(.white)
            Text("A quiet view of what is available and what is growing.")
                .font(.subheadline).foregroundColor(.white.opacity(0.62))
            liquidBalanceCard(dashboard)
            HStack {
                Text("Active Goal Vault").font(.headline.weight(.bold)).foregroundColor(.white)
                Spacer()
                Text("See all").font(.subheadline.weight(.semibold)).foregroundColor(.cyan)
            }
            if let goal = dashboard.vaults.first(where: { $0.type.lowercased() == "goal" }) {
                goalCard(goal)
            } else {
                emptyGoalCard
            }
            Text("Quick Actions").font(.headline.weight(.bold)).foregroundColor(.white)
            HStack(spacing: 12) {
                QuickAction(title: "Add Cash", symbol: "wallet.pass.fill", color: .cyan)
                QuickAction(title: "Analytics", symbol: "chart.line.uptrend.xyaxis", color: .indigo)
                QuickAction(title: "Split Bill", symbol: "person.2.fill", color: .green)
                QuickAction(title: "Perks", symbol: "tag.fill", color: .orange)
            }
            Text("Recent Roundups").font(.headline.weight(.bold)).foregroundColor(.white)
            roundupCard
        }
    }

    private func liquidBalanceCard(_ dashboard: Dashboard) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("VaultUp Lite (Sub-Wallet)").font(.subheadline.weight(.semibold)).foregroundColor(.white.opacity(0.8))
                Spacer()
                Image(systemName: "bolt.fill").foregroundColor(.yellow)
            }
            Text("₹\(String(format: "%.2f", dashboard.liquidBalance))")
                .font(.system(size: 38, weight: .bold, design: .rounded)).foregroundColor(.white)
            
            VStack(spacing: 6) {
                ProgressBar(progress: min(Double(dashboard.liquidBalance) / 5000.0 * 100, 100), colors: [.yellow, .orange])
                HStack {
                    Text("Auto-refills from bank").font(.caption).foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("Limit: ₹5,000").font(.caption.weight(.medium)).foregroundColor(.white.opacity(0.7))
                }
            }
            
            HStack(spacing: 12) {
                ActionTile(title: "Scan & Pay", symbol: "qrcode.viewfinder", fill: .cyan)
                ActionTile(title: "Add to Lite", symbol: "plus.circle.fill", fill: .indigo)
            }
        }
        .padding(22).vuCard(fill: .vuCardElevated, radius: 24)
    }

    private func goalCard(_ goal: VaultSummary) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Active Goal Vault").font(.subheadline.weight(.semibold)).foregroundColor(.cyan)
                Spacer()
                Label("Locked", systemImage: "lock.fill")
                    .font(.caption.weight(.bold)).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Color.white.opacity(0.14)).clipShape(Capsule())
            }
            HStack(spacing: 18) {
                ZStack {
                    Circle().stroke(Color.black.opacity(0.5), lineWidth: 12)
                    Circle().trim(from: 0, to: min(max(goal.progressPercentage / 100, 0), 1))
                        .stroke(Color.cyan, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(String(format: "%.0f%%", goal.progressPercentage)).font(.headline.weight(.bold)).foregroundColor(.white)
                }.frame(width: 92, height: 92)
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.name).font(.title3.weight(.bold)).foregroundColor(.white)
                    Text("₹\(String(format: "%.2f", goal.balance))").font(.title2.weight(.bold)).foregroundColor(.white)
                    Text("of ₹\(String(format: "%.0f", goal.target))").font(.subheadline).foregroundColor(.white.opacity(0.6))
                }
            }
            Label("Micro-roundups active", systemImage: "sparkles")
                .font(.caption.weight(.semibold)).foregroundColor(.mint)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.2)).clipShape(Capsule())
        }
        .padding(22)
        .background(LinearGradient(colors: [.indigo.opacity(0.82), .cyan.opacity(0.42)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Color.white.opacity(0.14), lineWidth: 1) }
        .shadow(color: .indigo.opacity(0.28), radius: 16, y: 8)
    }

    private var emptyGoalCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.open").font(.title).foregroundColor(.cyan)
            Text("Create a goal to start saving").font(.subheadline.weight(.semibold)).foregroundColor(.white)
        }.frame(maxWidth: .infinity).padding(28).vuCard(radius: 20)
    }

    private var roundupCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "cart.fill").foregroundColor(.orange).frame(width: 48, height: 48).background(Color.orange.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("Canteen Burger").font(.subheadline.weight(.bold)).foregroundColor(.white)
                Text("Micro-roundup saved automatically").font(.caption).foregroundColor(.white.opacity(0.58))
            }
            Spacer()
            Text("+₹7").font(.subheadline.weight(.bold)).foregroundColor(.mint)
        }.padding(14).vuCard(radius: 16)
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "wallet.pass.fill").font(.system(size: 42)).foregroundColor(.cyan)
            Text("Open your wallet").font(.title2.weight(.bold)).foregroundColor(.white)
            Text("Enter your User ID to see your spending and goals.").font(.subheadline).foregroundColor(.white.opacity(0.62))
            TextField("User ID", text: $userIdText).keyboardType(.numberPad).padding(14).background(Color.vuCardInset).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).foregroundColor(.white)
            Button("Load Dashboard") {
                guard let id = Int(userIdText) else { return }
                Task { await networkManager.fetchDashboard(userId: id) }
            }.font(.headline).frame(maxWidth: .infinity).padding(15).buttonStyle(VUActionButtonStyle(color: .indigo))
        }.padding(22).vuCard(radius: 20)
    }
}

struct ActionTile: View {
    let title: String
    let symbol: String
    let fill: Color
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
            Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
        }.foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 14).background(fill).clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

struct QuickAction: View {
    let title: String
    let symbol: String
    let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol).font(.title3).foregroundColor(color).frame(width: 56, height: 56).background(Color.vuCard).clipShape(Circle())
            Text(title).font(.caption.weight(.medium)).foregroundColor(.white.opacity(0.78)).lineLimit(1).minimumScaleFactor(0.8)
        }.frame(maxWidth: .infinity)
    }
}

struct VaultCard: View {
    let vault: VaultSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text(vault.name).font(.subheadline.weight(.semibold)).foregroundColor(.white); Spacer(); Text("\(String(format: "%.1f", vault.progressPercentage))%").font(.caption.weight(.bold)).foregroundColor(.cyan) }
            Text("₹\(String(format: "%.2f", vault.balance))").font(.title3.weight(.bold)).foregroundColor(.white)
            if vault.target > 0 { ProgressBar(progress: vault.progressPercentage) }
        }.padding(16).vuCard(radius: 16)
    }
}

#Preview { HomeView() }
