import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ledger History")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.vuTextPrimary)
                            Text("Double-entry cryptographic ledger")
                                .font(.caption)
                                .foregroundColor(.vuTextSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.vuTextSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    if networkManager.isLoading {
                        Spacer()
                        ProgressView()
                            .tint(.vuAccent)
                        Spacer()
                    } else if networkManager.ledger.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 48))
                                .foregroundColor(.vuTextMuted)
                            Text("No Transactions Yet")
                                .font(.headline)
                                .foregroundColor(.vuTextPrimary)
                            Text("Make a payment or transfer into a vault to see transactions.")
                                .font(.caption)
                                .foregroundColor(.vuTextSecondary)
                        }
                        .padding(32)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(networkManager.ledger) { entry in
                                    TransactionRow(entry: entry)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if let userId = networkManager.currentUser?.id {
                Task {
                    await networkManager.fetchLedger(userId: userId)
                }
            }
        }
    }
}

struct TransactionRow: View {
    let entry: LedgerEntry

    var title: String {
        if entry.entryType.lowercased() == "roundup" {
            return "Goal Vault Roundup"
        }
        return entry.description ?? entry.entryType.capitalized
    }
    
    var iconName: String {
        switch entry.entryType.lowercased() {
        case "deposit": return "arrow.down.left.circle.fill"
        case "withdrawal": return "arrow.up.right.circle.fill"
        case "roundup": return "arrow.up.circle.fill"
        case "split_allocation": return "arrow.triangle.branch"
        default: return "dollarsign.circle.fill"
        }
    }
    
    var iconColor: Color {
        if entry.amount < 0 || entry.entryType == "withdrawal" {
            return .vuWarning
        }
        return .vuSuccess
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.14))
                    .frame(width: 42, height: 42)
                
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextPrimary)
                
                Text(entry.timestamp)
                    .font(.caption2)
                    .foregroundColor(.vuTextSecondary)
            }
            
            Spacer()
            
            Text("\(entry.amount > 0 ? "+" : "")₹\(String(format: "%.2f", entry.amount))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(iconColor)
        }
        .padding(14)
        .vuCard()
    }
}
