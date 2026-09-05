// SettingsView.swift
// Settings, Student Profile, and Theme Management

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.colorScheme) private var colorScheme
    
    // Persistent Theme
    @AppStorage("app_theme") private var appThemeRaw: String = AppTheme.dark.rawValue
    
    // Persistent Student Profile (Name, Date of Birth, Roll Number)
    @AppStorage("student_name") private var studentName: String = "Abhinav Karra"
    @AppStorage("student_roll_number") private var studentRollNumber: String = "21BCE10482"
    @AppStorage("student_dob_timestamp") private var studentDOBTimestamp: Double = 1092528000 // Aug 15, 2004
    @AppStorage("student_college") private var studentCollege: String = "Vellore Institute of Technology"
    
    @State private var showingEditProfile = false
    @State private var showingDeviceInfo = false
    @State private var showingLogoutConfirmation = false
    @State private var bankName = ""
    @State private var isConnectingBank = false
    
    private var studentDOB: Date {
        Date(timeIntervalSince1970: studentDOBTimestamp)
    }
    
    private var formattedDOB: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: studentDOB)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title Header
                        headerView
                        
                        // Student Profile Card
                        studentProfileSection
                        
                        // Theme / Appearance Switcher
                        appearanceSection
                        
                        // Bank Account Connection
                        bankAccountSection
                        
                        // Account & Session / Log Out
                        logoutSection
                        
                        // Features List
                        featuresSection
                        
                        // About & Quick Links
                        aboutSection
                        
                        // Debug & Status
                        debugSection
                        
                        Spacer()
                            .frame(height: 32)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileSheet(
                    name: $studentName,
                    rollNumber: $studentRollNumber,
                    dobTimestamp: $studentDOBTimestamp,
                    college: $studentCollege,
                    isPresented: $showingEditProfile
                )
            }
            .sheet(isPresented: $showingDeviceInfo) {
                DeviceInfoSheet(isPresented: $showingDeviceInfo)
            }
            .alert("Log Out of VaultUp?", isPresented: $showingLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    networkManager.logout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You will need to sign in again to access your vaults and balance.")
            }
            .onAppear {
                if let data = UserDefaults.standard.data(forKey: "student_profile_data"),
                   let profile = try? JSONDecoder().decode(StudentProfile.self, from: data) {
                    studentName = profile.name
                    studentRollNumber = profile.rollNumber
                    studentDOBTimestamp = profile.dateOfBirth.timeIntervalSince1970
                    studentCollege = profile.college
                } else if let user = networkManager.currentUser, user.name != "Test User" && !user.name.isEmpty {
                    studentName = user.name
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.vuTextPrimary)
            Text("Profile, appearance, and account preferences")
                .font(.subheadline)
                .foregroundColor(.vuTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }
    
    // MARK: - Student Profile Card
    private var studentProfileSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Avatar with glowing ring
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.vuAccent, .vuAccentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.vuAccent.opacity(0.4), radius: 8, y: 3)
                    
                    Text(initials(for: studentName))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.vuSuccess)
                        .background(Color.white.clipShape(Circle()))
                        .font(.system(size: 16))
                        .offset(x: 2, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(studentName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.vuTextPrimary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 6) {
                        Text("Roll:")
                            .font(.caption)
                            .foregroundColor(.vuTextSecondary)
                        Text(studentRollNumber)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(.vuCyan)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "graduationcap.fill")
                            .font(.caption2)
                            .foregroundColor(.vuSuccess)
                        Text("Verified Student")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.vuSuccess)
                    }
                }
                
                Spacer()
                
                Button(action: { showingEditProfile = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.vuAccent)
                        .clipShape(Circle())
                        .shadow(color: Color.vuAccent.opacity(0.35), radius: 5, y: 2)
                }
            }
            .padding(18)
            
            Divider()
                .background(Color.vuDivider)
            
            // Detailed Info Grid
            VStack(spacing: 12) {
                HStack {
                    Label("Date of Birth", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.vuTextSecondary)
                    Spacer()
                    Text(formattedDOB)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.vuTextPrimary)
                }
                
                HStack {
                    Label("Roll Number", systemImage: "number")
                        .font(.subheadline)
                        .foregroundColor(.vuTextSecondary)
                    Spacer()
                    Text(studentRollNumber)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.vuTextPrimary)
                }
                
                HStack {
                    Label("Institution", systemImage: "building.columns")
                        .font(.subheadline)
                        .foregroundColor(.vuTextSecondary)
                    Spacer()
                    Text(studentCollege)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.vuTextPrimary)
                        .lineLimit(1)
                }
            }
            .padding(18)
        }
        .vuCard()
    }
    
    // MARK: - Appearance Switcher
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(.headline)
                .foregroundColor(.vuTextPrimary)
            
            HStack(spacing: 10) {
                ForEach(AppTheme.allCases) { theme in
                    let isSelected = appThemeRaw == theme.rawValue
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            appThemeRaw = theme.rawValue
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: theme.icon)
                                .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .vuTextSecondary)
                            
                            Text(theme.rawValue)
                                .font(.caption)
                                .fontWeight(isSelected ? .bold : .medium)
                                .foregroundColor(isSelected ? .white : .vuTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if isSelected {
                                    LinearGradient(
                                        colors: [.vuAccent, .vuAccentPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(color: Color.vuAccent.opacity(0.35), radius: 8, y: 3)
                                } else {
                                    Color.vuCardElevated
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    isSelected ? Color.white.opacity(0.2) : Color.vuBorder,
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .vuCard(fill: .vuCard)
        }
    }
    
    // MARK: - Bank Account Section
    private var bankAccountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Banking & Funding")
                .font(.headline)
                .foregroundColor(.vuTextPrimary)
            
            VStack(alignment: .leading, spacing: 14) {
                if let linkedBank = networkManager.currentUser?.linkedBankAccount, !linkedBank.isEmpty {
                    HStack(spacing: 14) {
                        Image(systemName: "building.columns.fill")
                            .font(.title3)
                            .foregroundColor(.vuSuccess)
                            .padding(10)
                            .background(Color.vuSuccess.opacity(0.15))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(linkedBank)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.vuTextPrimary)
                            Text("Primary payment source")
                                .font(.caption)
                                .foregroundColor(.vuTextSecondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.vuSuccess)
                                .frame(width: 8, height: 8)
                            Text("Connected")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.vuSuccess)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.vuSuccess.opacity(0.12))
                        .clipShape(Capsule())
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Connect Bank for Micro-Roundups")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.vuTextPrimary)
                        
                        HStack(spacing: 10) {
                            TextField("Enter Bank (e.g. HDFC Bank)", text: $bankName)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.vuCardElevated)
                                .cornerRadius(10)
                                .foregroundColor(.vuTextPrimary)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                                }
                            
                            Button(action: {
                                guard !bankName.isEmpty else { return }
                                isConnectingBank = true
                                Task {
                                    await networkManager.connectBank(accountNumber: bankName)
                                    isConnectingBank = false
                                }
                            }) {
                                if isConnectingBank {
                                    ProgressView().tint(.white)
                                        .frame(width: 80, height: 42)
                                } else {
                                    Text("Link")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 42)
                                }
                            }
                            .background(bankName.isEmpty ? Color.gray.opacity(0.4) : Color.vuAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .disabled(bankName.isEmpty || isConnectingBank)
                        }
                    }
                }
            }
            .padding(16)
            .vuCard()
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VaultUp Capabilities")
                .font(.headline)
                .foregroundColor(.vuTextPrimary)
            
            VStack(spacing: 10) {
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Goal-Locked Vaults",
                    subtitle: "Segregated discipline-driven savings goals",
                    color: .vuAccent
                )
                
                FeatureRow(
                    icon: "arrow.triangle.merge",
                    title: "Micro-Roundup Engine",
                    subtitle: "Automatic spare change collected on every UPI spend",
                    color: .vuCyan
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Double-Entry Ledger",
                    subtitle: "Cryptographic audit consistency with zero leakage",
                    color: .vuSuccess
                )
                
                FeatureRow(
                    icon: "creditcard.and.123",
                    title: "Razorpay Sandbox",
                    subtitle: "Instant simulated UPI payments & dynamic orders",
                    color: .vuWarning
                )
                
                FeatureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Student Verification",
                    subtitle: "Institutional roll number verification and exclusive perks",
                    color: .vuAccentPurple
                )
            }
        }
    }
    
    // MARK: - About & Info
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
                .foregroundColor(.vuTextPrimary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("App Version")
                        .foregroundColor(.vuTextSecondary)
                    Spacer()
                    Text("1.2.0 (Fintech Edition)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.vuTextPrimary)
                }
                
                Divider().background(Color.vuDivider)
                
                HStack {
                    Text("Platform")
                        .foregroundColor(.vuTextSecondary)
                    Spacer()
                    Text("iOS 16+ SwiftUI")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.vuTextPrimary)
                }
                
                Divider().background(Color.vuDivider)
                
                Button(action: { showingDeviceInfo = true }) {
                    HStack {
                        Text("Device & Hardware Specs")
                            .foregroundColor(.vuTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.vuTextSecondary)
                    }
                }
                
                Divider().background(Color.vuDivider)
                
                Link(destination: URL(string: "http://localhost:8000/docs")!) {
                    HStack {
                        Label("FastAPI Interactive Docs", systemImage: "curlybraces")
                            .foregroundColor(.vuTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.vuAccent)
                    }
                }
            }
            .padding(16)
            .vuCard()
        }
    }
    
    // MARK: - Debug Status
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.vuSuccess)
                    .frame(width: 8, height: 8)
                Text("Backend Core: Connected (localhost:8000)")
                    .font(.caption)
                    .foregroundColor(.vuSuccess)
            }
            Text("Database: SQLite Double-Entry Ledger Active")
                .font(.caption2)
                .foregroundColor(.vuTextMuted)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingLogoutConfirmation = true
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.vuDanger.opacity(0.14))
                            .frame(width: 40, height: 40)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.vuDanger)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Log Out")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.vuDanger)
                        
                        if let user = networkManager.currentUser {
                            Text("Signed in as \(user.phone ?? user.email)")
                                .font(.caption2)
                                .foregroundColor(.vuTextSecondary)
                        } else {
                            Text("End current session")
                                .font(.caption2)
                                .foregroundColor(.vuTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.vuTextSecondary)
                }
                .padding(16)
                .vuCard(fill: Color.vuDanger.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.vuDanger.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Text("VaultUp v1.0 • Micro-Savings & Goal Vaults")
                .font(.caption2)
                .foregroundColor(.vuTextMuted)
                .padding(.top, 4)
        }
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var rollNumber: String
    @Binding var dobTimestamp: Double
    @Binding var college: String
    @Binding var isPresented: Bool
    
    @State private var tempName: String = ""
    @State private var tempRollNumber: String = ""
    @State private var tempDOB: Date = Date()
    @State private var tempCollege: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header note
                        VStack(spacing: 4) {
                            Text("Student Identification")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.vuTextPrimary)
                            Text("Keep your official college details updated for student perks")
                                .font(.caption)
                                .foregroundColor(.vuTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Full Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Full Name")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                TextField("Your Name", text: $tempName)
                                    .padding(12)
                                    .background(Color.vuCardElevated)
                                    .cornerRadius(10)
                                    .foregroundColor(.vuTextPrimary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.vuBorder, lineWidth: 1)
                                    }
                            }
                            
                            // Roll Number
                            VStack(alignment: .leading, spacing: 6) {
                                Text("College Roll Number / Student ID")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                TextField("e.g. 21BCE10482", text: $tempRollNumber)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(12)
                                    .background(Color.vuCardElevated)
                                    .cornerRadius(10)
                                    .foregroundColor(.vuTextPrimary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.vuBorder, lineWidth: 1)
                                    }
                            }
                            
                            // Date of Birth
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date of Birth")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                DatePicker(
                                    "Date of Birth",
                                    selection: $tempDOB,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.vuCardElevated)
                                .cornerRadius(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                                }
                            }
                            
                            // College / Institution
                            VStack(alignment: .leading, spacing: 6) {
                                Text("College / University")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.vuTextSecondary)
                                
                                TextField("Institution Name", text: $tempCollege)
                                    .padding(12)
                                    .background(Color.vuCardElevated)
                                    .cornerRadius(10)
                                    .foregroundColor(.vuTextPrimary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.vuBorder, lineWidth: 1)
                                    }
                            }
                        }
                        .padding(20)
                        .vuCard()
                        
                        // Save Button
                        Button(action: saveProfile) {
                            Text("Save Profile")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(VUActionButtonStyle(color: .vuAccent))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.vuTextSecondary)
                }
            }
            .onAppear {
                tempName = name
                tempRollNumber = rollNumber
                tempDOB = Date(timeIntervalSince1970: dobTimestamp)
                tempCollege = college
            }
        }
    }
    
    private func saveProfile() {
        name = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
        rollNumber = tempRollNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        dobTimestamp = tempDOB.timeIntervalSince1970
        college = tempCollege.trimmingCharacters(in: .whitespacesAndNewlines)
        isPresented = false
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.vuTextSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .vuCard(fill: .vuCard)
    }
}

// MARK: - Device Info Sheet
struct DeviceInfoSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                VUBackground()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        InfoRow(label: "Device Name", value: UIDevice.current.name)
                        InfoRow(label: "Hardware Model", value: UIDevice.current.model)
                        InfoRow(label: "iOS Version", value: UIDevice.current.systemVersion)
                        InfoRow(label: "Screen Scale", value: "\(Int(UIScreen.main.scale))x Retina")
                        InfoRow(label: "Resolution", value: String(format: "%.0f × %.0f pt", UIScreen.main.bounds.width, UIScreen.main.bounds.height))
                    }
                    .padding(18)
                    .vuCard()
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(VUActionButtonStyle(color: .vuAccent))
                }
                .padding(20)
            }
            .navigationTitle("Device Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.vuTextSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.vuTextPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NetworkManager())
}
