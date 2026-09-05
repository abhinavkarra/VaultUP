// PaymentView.swift
// Payment processing with micro-roundup engine and luxury fintech UI

import SwiftUI

struct PaymentView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var amount = ""
    @State private var merchantName = "Canteen"
    @State private var showingPaymentConfirmation = false
    
    let merchants = [
        ("Canteen", "fork.knife", Color.orange),
        ("Stationery", "pencil.and.ruler.fill", Color.blue),
        ("Books", "book.fill", Color.vuWarning),
        ("Transport", "bus.fill", Color.vuCyan),
        ("Coffee", "cup.and.saucer.fill", Color.brown),
        ("Movie", "film.fill", Color.purple),
        ("Dining", "takeoutbag.and.cup.and.straw.fill", Color.pink),
        ("Gym", "figure.run", Color.vuSuccess),
        ("Shopping", "bag.fill", Color.vuAccent),
        ("Other", "ellipsis.circle.fill", Color.gray)
    ]
    
    var calculatedRoundup: Float {
        guard let amountValue = Float(amount), amountValue > 0 else { return 0 }
        let ceiling = ceil(amountValue / 10) * 10
        let diff = ceiling - amountValue
        return diff == 0 ? 10.0 : diff
    }
    
    var totalAmount: Float {
        guard let amountValue = Float(amount) else { return 0 }
        return amountValue + calculatedRoundup
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
                            // Amount Input Card
                            amountInputCard
                            
                            // Preset chips
                            presetChips
                            
                            // Micro-Roundup Visualization Card
                            roundupBreakdownCard
                            
                            // Merchant Selection
                            merchantSelectionCard
                            
                            // How Roundup Works note
                            howItWorksCard
                            
                            // Process Payment Button
                            processPaymentButton
                            
                            if let error = networkManager.errorMessage {
                                errorMessageView(error: error)
                            }
                            
                            Spacer().frame(height: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPaymentConfirmation) {
                if let order = networkManager.lastPaymentOrder {
                    PaymentSuccessSheet(order: order, isPresented: $showingPaymentConfirmation)
                }
            }

        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pay & Auto-Save")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.vuTextPrimary)
                Text("Every spend rounds up to your goal vault")
                    .font(.subheadline)
                    .foregroundColor(.vuTextSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Amount Input Card
    private var amountInputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Bill Amount")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.vuSuccess)
                        .frame(width: 6, height: 6)
                    Text("Liquid Balance Available")
                        .font(.caption2)
                        .foregroundColor(.vuSuccess)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("₹")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.vuAccent)
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.vuTextPrimary)
                
                if !amount.isEmpty {
                    Button(action: { amount = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.vuTextMuted)
                            .font(.title3)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(20)
        .vuCard()
    }
    
    // MARK: - Quick Presets
    private var presetChips: some View {
        HStack(spacing: 8) {
            ForEach([50, 100, 250, 500], id: \.self) { val in
                Button(action: {
                    let current = Float(amount) ?? 0
                    amount = String(format: "%.0f", current + Float(val))
                }) {
                    Text("+₹\(val)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.vuTextPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.vuCardElevated)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.vuBorder, lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
    }
    
    // MARK: - Roundup Breakdown
    private var roundupBreakdownCard: some View {
        VStack(spacing: 12) {
            let amountVal = Float(amount) ?? 0
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spend Amount")
                        .font(.caption)
                        .foregroundColor(.vuTextSecondary)
                    Text("₹\(String(format: "%.2f", amountVal))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.vuTextPrimary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.vuTextMuted)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.vuSuccess)
                        Text("Auto-Roundup")
                            .font(.caption)
                            .foregroundColor(.vuSuccess)
                    }
                    Text("+₹\(String(format: "%.2f", calculatedRoundup))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.vuSuccess)
                }
            }
            
            Divider().background(Color.vuDivider)
            
            HStack {
                Text("Total Account Debit")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                
                Spacer()
                
                Text("₹\(String(format: "%.2f", totalAmount))")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.vuCyan)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.vuWarning)
                Text("₹\(String(format: "%.2f", calculatedRoundup)) directly compounds inside your goal vault.")
                    .font(.caption2)
                    .foregroundColor(.vuTextSecondary)
                Spacer()
            }
        }
        .padding(16)
        .vuCard(fill: .vuCardElevated)
    }
    
    // MARK: - Merchant Selector
    private var merchantSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Select Category")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                
                Spacer()
                
                Text(merchantName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuAccent)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(merchants, id: \.0) { merchant, icon, color in
                    let isSelected = merchantName == merchant
                    Button(action: { merchantName = merchant }) {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isSelected ? color : color.opacity(0.12))
                                    .frame(width: 46, height: 46)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(isSelected ? .white : color)
                            }
                            
                            Text(merchant)
                                .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .vuTextPrimary : .vuTextSecondary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .vuCard()
    }
    
    // MARK: - How It Works Note
    private var howItWorksCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title3)
                .foregroundColor(.vuAccent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Zero Friction Savings")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                Text("Transactions are authenticated with mock Razorpay test gateway and recorded into your double-entry ledger.")
                    .font(.caption2)
                    .foregroundColor(.vuTextSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .vuCard(fill: Color.vuAccent.opacity(0.08))
    }
    
    // MARK: - Process Payment Button
    private var processPaymentButton: some View {
        Button(action: processPayment) {
            HStack(spacing: 10) {
                if networkManager.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "creditcard.fill")
                        .font(.headline)
                    Text("Pay ₹\(String(format: "%.2f", totalAmount))")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(VUActionButtonStyle(color: .vuAccent))
        .disabled(amount.isEmpty || (Float(amount) ?? 0) <= 0 || networkManager.isLoading)
        .opacity((amount.isEmpty || (Float(amount) ?? 0) <= 0) ? 0.5 : 1.0)
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
    
    private func processPayment() {
        guard let amountValue = Float(amount), amountValue > 0 else { return }
        
        Task {
            await networkManager.createPaymentOrder(
                amount: amountValue,
                liquidPercentage: 1.0,
                merchantName: merchantName
            )
            
            if networkManager.errorMessage == nil {
                showingPaymentConfirmation = networkManager.lastPaymentOrder != nil
                amount = ""
            }
        }
    }
}

// MARK: - Payment Success Sheet
struct PaymentSuccessSheet: View {
    let order: PaymentOrder
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            VUBackground()
            
            VStack(spacing: 20) {
                // Success Badge
                ZStack {
                    Circle()
                        .fill(Color.vuSuccess.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.vuSuccess)
                }
                .padding(.top, 10)
                
                VStack(spacing: 4) {
                    Text("Payment Successful!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.vuTextPrimary)
                    
                    Text("Order Ref: \(order.orderId)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.vuTextSecondary)
                        .textSelection(.enabled)
                }
                
                // Ledger Allocation Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Paid to Merchant")
                            .foregroundColor(.vuTextSecondary)
                        Spacer()
                        Text("₹\(String(format: "%.2f", Float(order.amount) / 100))")
                            .font(.headline)
                            .foregroundColor(.vuTextPrimary)
                    }
                    
                    Divider().background(Color.vuDivider)
                    
                    HStack {
                        Text("Liquid Account Allocation")
                            .foregroundColor(.vuTextSecondary)
                        Spacer()
                        Text("₹\(String(format: "%.2f", order.allocation.liquidAllocation))")
                            .font(.subheadline)
                            .foregroundColor(.vuCyan)
                    }
                    
                    HStack {
                        Label("Saved into Goal Vault", systemImage: "arrow.down.right.and.arrow.up.left")
                            .foregroundColor(.vuSuccess)
                            .font(.subheadline)
                        Spacer()
                        Text("+₹\(String(format: "%.2f", order.allocation.roundupAmount))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.vuSuccess)
                    }
                    .padding(12)
                    .background(Color.vuSuccess.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(18)
                .vuCard()
                
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(VUActionButtonStyle(color: .vuAccent))
                
                Spacer()
            }
            .padding(24)
        }
        .presentationDetents([.medium])
    }
}
