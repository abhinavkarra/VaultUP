import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VUBackground()
            
            VStack {
                // Header
                HStack {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                if networkManager.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                } else if networkManager.ledger.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Transactions Yet")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(networkManager.ledger) { entry in
                                TransactionRow(entry: entry)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
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
            return .orange
        }
        return .green
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(entry.timestamp) // Should be formatted in a real app
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(entry.amount > 0 ? "+" : "")₹\(String(format: "%.2f", entry.amount))")
                .font(.headline)
                .foregroundColor(iconColor)
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.25))
        .cornerRadius(12)
    }
}
