// PaymentView.swift
// Payment processing with roundup

import SwiftUI

struct PaymentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var amount = ""
    @State private var merchantName = ""
    @State private var selectedMerchant = "Canteen"
    @State private var userId = 1
    @State private var showingPaymentConfirmation = false
    @State private var lastPaymentOrder: PaymentOrder?
    
    let merchants = ["Canteen", "Stationery", "Books", "Transport", "Coffee", "Movie", "Restaurant", "Gym", "Shopping", "Other"]
    
    var calculatedRoundup: Float {
        guard let amountValue = Float(amount), amountValue > 0 else { return 0 }
        let ceiling = ceil(amountValue / 10) * 10
        return ceiling - amountValue
    }
    
    var totalAmount: Float {
        guard let amountValue = Float(amount) else { return 0 }
        return amountValue + calculatedRoundup
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.08, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pay & Save")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Make a payment and auto-save spare change")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Amount Input Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Payment Amount")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 8) {
                                    Text("₹")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.indigo)
                                    
                                    TextField("0.00", text: $amount)
                                        .font(.system(size: 28, weight: .bold))
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                            }
                            .padding(20)
                            .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // Roundup Preview
                            if let amountValue = Float(amount), amountValue > 0 {
                                VStack(spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Payment Amount")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text("₹\(String(format: "%.2f", amountValue))")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.green)
                                        Text("Auto-Roundup Savings")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                        Spacer()
                                        Text("₹\(String(format: "%.2f", calculatedRoundup))")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    .padding(12)
                                    .background(Color(red: 0.1, green: 0.2, blue: 0.1))
                                    .cornerRadius(8)
                                    
                                    Divider()
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    
                                    HStack {
                                        Text("Total to Charge")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("₹\(String(format: "%.2f", totalAmount))")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.cyan)
                                    }
                                }
                                .padding(16)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // Merchant Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Merchant")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Picker("Merchant", selection: $merchantName) {
                                    ForEach(merchants, id: \.self) { merchant in
                                        Text(merchant).tag(merchant)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(.indigo)
                            }
                            .padding(.horizontal, 20)
                            
                            // Info Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.cyan)
                                    Text("How It Works")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.cyan)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Payment amount goes to Liquid Pocket", systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Label("Roundup amount saved to Goal Vault", systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Label("Zero hallucination - math is always exact", systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(16)
                            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // Pay Button
                            Button(action: processPayment) {
                                if networkManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(16)
                                } else {
                                    HStack {
                                        Image(systemName: "creditcard.fill")
                                        Text("Process Payment")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.indigo, .blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .disabled(amount.isEmpty || merchantName.isEmpty || networkManager.isLoading)
                            .opacity((amount.isEmpty || merchantName.isEmpty) ? 0.5 : 1.0)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
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
                            }
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPaymentConfirmation) {
                if let order = lastPaymentOrder {
                    PaymentSuccessSheet(order: order, isPresented: $showingPaymentConfirmation)
                }
            }
            .onAppear {
                networkManager.setUserId(userId)
            }
        }
    }
    
    private func processPayment() {
        guard let amountValue = Float(amount), amountValue > 0 else { return }
        
        Task {
            await networkManager.createPaymentOrder(
                amount: amountValue,
                liquidPercentage: 0.70,
                merchantName: merchantName
            )
            
            if networkManager.errorMessage == nil {
                showingPaymentConfirmation = true
                amount = ""
                merchantName = ""
            }
        }
    }
}

struct PaymentSuccessSheet: View {
    let order: PaymentOrder
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                    
                    Text("Payment Successful!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Order ID: \(order.orderId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .textSelection(.enabled)
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Payment Amount")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("₹\(String(format: "%.2f", Float(order.amount) / 100))")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                    
                    HStack {
                        Text("Liquid Pocket")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("₹\(String(format: "%.2f", order.allocation.liquidAllocation))")
                            .foregroundColor(.cyan)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Goal Vault")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("₹\(String(format: "%.2f", order.allocation.goalDirectAllocation))")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Auto-Roundup")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("₹\(String(format: "%.2f", order.allocation.roundupAmount))")
                            .foregroundColor(.indigo)
                            .fontWeight(.bold)
                    }
                    .padding(12)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.22))
                    .cornerRadius(8)
                }
                .padding(16)
                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                .cornerRadius(12)
                
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.indigo)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .presentationDetents([.fraction(0.6)])
    }
}

#Preview {
    PaymentView()
}
