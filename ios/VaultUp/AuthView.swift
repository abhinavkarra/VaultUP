// AuthView.swift
// Complete Authentication Flow: Sign In for existing users & Sign Up for new student users

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var authMode: AuthMode = .signIn
    
    // Sign In State
    @State private var loginIdentifier: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var loginError: String?
    
    // Sign Up State
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var emailAddress: String = ""
    @State private var rollNumber: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2004, month: 8, day: 15)) ?? Date()
    @State private var bankAccount: String = ""
    @State private var isRegistering: Bool = false
    @State private var registrationError: String?
    
    enum AuthMode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Create Account"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack {
            VUBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)
                    
                    // Brand Logo & Title
                    brandHeader
                    
                    // Mode Switcher
                    modeSelector
                    
                    // Form Content
                    if authMode == .signIn {
                        signInCard
                    } else {
                        signUpCard
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 22)
            }
        }
    }
    
    // MARK: - Brand Header
    private var brandHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.vuAccent, .vuAccentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.vuAccent.opacity(0.45), radius: 16, y: 6)
                
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("VaultUp")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.vuTextPrimary)
                
                Text("Smart Micro-Savings & Goal Vaults for Students")
                    .font(.subheadline)
                    .foregroundColor(.vuTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Mode Selector
    private var modeSelector: some View {
        HStack(spacing: 6) {
            ForEach(AuthMode.allCases) { mode in
                let isSelected = authMode == mode
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        authMode = mode
                        loginError = nil
                        registrationError = nil
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .vuTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if isSelected {
                                    LinearGradient(
                                        colors: [.vuAccent, .vuAccentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: Color.vuAccent.opacity(0.35), radius: 6, y: 2)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.vuCard)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.vuBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Sign In Card
    private var signInCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome Back")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                
                Text("Enter your registered phone number or email to access your vaults.")
                    .font(.caption)
                    .foregroundColor(.vuTextSecondary)
            }
            
            // Input field
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number or Email")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.vuAccent)
                        .font(.system(size: 18))
                    
                    TextField("e.g. 9876543210 or name@college.edu", text: $loginIdentifier)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 16))
                        .foregroundColor(.vuTextPrimary)
                    
                    if !loginIdentifier.isEmpty {
                        Button(action: { loginIdentifier = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.vuTextMuted)
                        }
                    }
                }
                .padding(14)
                .background(Color.vuCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                )
            }
            
            // Error banner
            if let error = loginError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.vuDanger)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.vuDanger)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.vuDanger.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Sign In Action Button
            Button(action: executeSignIn) {
                HStack(spacing: 8) {
                    if isLoggingIn {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(VUActionButtonStyle(color: .vuAccent))
            .disabled(loginIdentifier.trimmingCharacters(in: .whitespaces).isEmpty || isLoggingIn)
            
            Divider()
                .background(Color.vuDivider)
                .padding(.vertical, 4)
            
            // Quick Demo Login Chip
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Demo Sign In")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextSecondary)
                
                Button(action: {
                    loginIdentifier = "9876543210"
                    executeSignIn()
                }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.vuAccent.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Text("AK")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.vuAccent)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Abhinav Karra (Test User)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.vuTextPrimary)
                            Text("Phone: 9876543210 • 2 Goal Vaults")
                                .font(.caption2)
                                .foregroundColor(.vuTextSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundColor(.vuAccent)
                    }
                    .padding(12)
                    .background(Color.vuCardInset)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.vuAccent.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .vuCard()
    }
    
    // MARK: - Sign Up Card
    private var signUpCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Student Account")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.vuTextPrimary)
                
                Text("Join VaultUp to automate micro-roundups into dedicated goal vaults.")
                    .font(.caption)
                    .foregroundColor(.vuTextSecondary)
            }
            
            // Full Name
            formField(title: "Full Name", placeholder: "e.g. Rahul Sharma", icon: "person.fill", text: $fullName)
            
            // Phone Number
            formField(title: "Phone Number", placeholder: "e.g. 9123456780", icon: "phone.fill", text: $phoneNumber, keyboard: .phonePad)
            
            // Email
            formField(title: "College / Personal Email", placeholder: "e.g. rahul@college.edu", icon: "envelope.fill", text: $emailAddress, keyboard: .emailAddress)
            
            // Roll Number
            formField(title: "Student Roll Number", placeholder: "e.g. 22BCS1019", icon: "number", text: $rollNumber)
            
            // Date of Birth
            VStack(alignment: .leading, spacing: 8) {
                Text("Date of Birth")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.vuTextSecondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.vuAccent)
                        .font(.system(size: 18))
                    
                    DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                        .labelsHidden()
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.vuCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                )
            }
            
            // Linked Bank Account
            formField(title: "Linked Bank Name / Account", placeholder: "e.g. State Bank of India •••• 1042", icon: "building.columns.fill", text: $bankAccount)
            
            // Error banner
            if let error = registrationError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.vuDanger)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.vuDanger)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.vuDanger.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Register Action Button
            Button(action: executeSignUp) {
                HStack(spacing: 8) {
                    if isRegistering {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account & Start Saving")
                            .font(.headline)
                            .fontWeight(.bold)
                        Image(systemName: "sparkles")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(VUActionButtonStyle(color: .vuSuccess))
            .disabled(
                fullName.trimmingCharacters(in: .whitespaces).isEmpty ||
                phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty ||
                emailAddress.trimmingCharacters(in: .whitespaces).isEmpty ||
                isRegistering
            )
        }
        .padding(20)
        .vuCard()
    }
    
    // MARK: - Helper Subviews
    private func formField(title: String, placeholder: String, icon: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.vuTextSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.vuAccent)
                    .font(.system(size: 18))
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .autocapitalization(keyboard == .emailAddress ? .none : .words)
                    .font(.system(size: 16))
                    .foregroundColor(.vuTextPrimary)
            }
            .padding(14)
            .background(Color.vuCardElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.vuBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Auth Actions
    private func executeSignIn() {
        let trimmed = loginIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoggingIn = true
        loginError = nil
        
        Task {
            let success = await networkManager.login(identifier: trimmed)
            await MainActor.run {
                isLoggingIn = false
                if !success {
                    loginError = networkManager.errorMessage ?? "Sign in failed. Check your credential or sign up."
                }
            }
        }
    }
    
    private func executeSignUp() {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRoll = rollNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBank = bankAccount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty, !trimmedPhone.isEmpty, !trimmedEmail.isEmpty else { return }
        
        isRegistering = true
        registrationError = nil
        
        Task {
            let success = await networkManager.registerUser(
                name: trimmedName,
                email: trimmedEmail,
                phone: trimmedPhone,
                studentEmail: trimmedEmail,
                rollNumber: trimmedRoll,
                dob: dateOfBirth,
                bankAccount: trimmedBank.isEmpty ? "State Bank of India" : trimmedBank
            )
            
            await MainActor.run {
                isRegistering = false
                if !success {
                    registrationError = networkManager.errorMessage ?? "Registration failed. Please try again."
                }
            }
        }
    }
}
