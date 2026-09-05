// SettingsView.swift
// Settings and about information

import SwiftUI

struct SettingsView: View {
    @State private var appVersion = "1.0.0"
    @State private var backendURL = "http://localhost:8000"
    @State private var showingDeviceInfo = false
    @EnvironmentObject var networkManager: NetworkManager
    @State private var bankName = ""
    @State private var isConnectingBank = false
    
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
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("App configuration and about")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // API Configuration
                            VStack(alignment: .leading, spacing: 12) {
                                Text("API Configuration")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Backend URL")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    VStack {
                                        Text(backendURL)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.cyan)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(12)
                                            .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                            .cornerRadius(8)
                                        
                                        HStack(spacing: 8) {
                                            Label("Running on localhost", systemImage: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            Spacer()
                                        }
                                        .padding(.top, 8)
                                    }
                                }
                                .padding(16)
                                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // Bank Connection
                            if let user = networkManager.currentUser {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Bank Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        if let linkedBank = user.linkedBankAccount {
                                            HStack {
                                                Image(systemName: "building.columns.fill")
                                                    .foregroundColor(.green)
                                                Text(linkedBank)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text("Connected")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        } else {
                                            Text("No bank account connected")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            HStack {
                                                TextField("Enter Bank Name", text: $bankName)
                                                    .padding(12)
                                                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                                                    .cornerRadius(8)
                                                    .foregroundColor(.white)
                                                
                                                Button(action: {
                                                    if !bankName.isEmpty {
                                                        isConnectingBank = true
                                                        Task {
                                                            await networkManager.connectBank(accountNumber: bankName)
                                                            isConnectingBank = false
                                                        }
                                                    }
                                                }) {
                                                    if isConnectingBank {
                                                        ProgressView().tint(.white)
                                                    } else {
                                                        Text("Connect")
                                                            .font(.headline)
                                                    }
                                                }
                                                .frame(width: 100)
                                                .padding(12)
                                                .background(bankName.isEmpty ? Color.gray : Color.indigo)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .disabled(bankName.isEmpty || isConnectingBank)
                                            }
                                        }
                                    }
                                    .padding(16)
                                    .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Features Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Features")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    FeatureRow(
                                        icon: "lock.fill",
                                        title: "Goal-Locked Vaults",
                                        subtitle: "Segregated savings for specific targets",
                                        color: .indigo
                                    )
                                    
                                    FeatureRow(
                                        icon: "arrow.up.right.circle.fill",
                                        title: "Micro-Roundup",
                                        subtitle: "Automatic spare change collection",
                                        color: .green
                                    )
                                    
                                    FeatureRow(
                                        icon: "chart.bar.fill",
                                        title: "Double-Entry Ledger",
                                        subtitle: "Perfect accounting with zero leakage",
                                        color: .cyan
                                    )
                                    
                                    FeatureRow(
                                        icon: "creditcard.fill",
                                        title: "Razorpay Integration",
                                        subtitle: "Secure payment processing",
                                        color: .orange
                                    )
                                    
                                    FeatureRow(
                                        icon: "star.fill",
                                        title: "Student Perks",
                                        subtitle: "Verified student benefits and discounts",
                                        color: .yellow
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // About Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About VaultUp")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Version")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(appVersion)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Divider()
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    
                                    HStack {
                                        Text("Platform")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("iOS 15+")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Divider()
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    
                                    HStack {
                                        Text("Tech Stack")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("SwiftUI + Async/Await")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.cyan)
                                    }
                                    
                                    Divider()
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    
                                    Button(action: { showingDeviceInfo.toggle() }) {
                                        HStack {
                                            Text("Device Information")
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // Quick Links
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Links")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 8) {
                                    Link(destination: URL(string: "http://localhost:8000/docs")!) {
                                        HStack {
                                            Image(systemName: "book.fill")
                                                .foregroundColor(.indigo)
                                            Text("API Documentation")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12)
                                        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                        .cornerRadius(8)
                                    }
                                    
                                    Link(destination: URL(string: "http://localhost:8000/redoc")!) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                                .foregroundColor(.cyan)
                                            Text("ReDoc (Alternative Docs)")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12)
                                        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Debug Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Debug Information")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Backend Status: ✅ Connected")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    
                                    Text("Database: SQLite (localhost)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("Build: Development")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDeviceInfo) {
                DeviceInfoSheet(isPresented: $showingDeviceInfo)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
        .cornerRadius(8)
    }
}

struct DeviceInfoSheet: View {
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
            
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Device", value: UIDevice.current.name)
                        InfoRow(label: "Model", value: UIDevice.current.model)
                        InfoRow(label: "OS Version", value: UIDevice.current.systemVersion)
                        InfoRow(label: "Screen Scale", value: "\(UIScreen.main.scale)x")
                        InfoRow(label: "Screen Size", value: String(format: "%.1f × %.1f", UIScreen.main.bounds.width, UIScreen.main.bounds.height))
                    }
                    .padding(16)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.indigo)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .navigationTitle("Device Info")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.cyan)
        }
    }
}

#Preview {
    SettingsView()
}
