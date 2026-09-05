import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @Binding var isAuthenticated: Bool
    
    @State private var phoneNumber: String = ""
    @State private var showingAuthError = false
    @State private var authErrorMessage = ""
    
    var body: some View {
        ZStack {
            VUBackground()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.indigo)
                    
                    Text("VaultUp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Secure Neo-Banking for Students")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobile Number")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("+91")
                                .foregroundColor(.gray)
                            
                            TextField("Enter 10-digit number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        Task {
                            await handleLogin()
                        }
                    }) {
                        if networkManager.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(12)
                        } else {
                            Text("Login & Authenticate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(phoneNumber.count < 10 || networkManager.isLoading)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .alert("Authentication Failed", isPresented: $showingAuthError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authErrorMessage)
        }
    }
    
    private func handleLogin() async {
        // 1. Perform Backend Login
        await networkManager.login(phone: phoneNumber)
        
        guard networkManager.currentUser != nil else {
            authErrorMessage = networkManager.errorMessage ?? "Failed to login via backend."
            showingAuthError = true
            return
        }
        
        // 2. Perform Face ID / Touch ID Authentication
        let context = LAContext()
        var error: NSError?
        
        // Check if authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access your VaultUp account"
            
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                if success {
                    DispatchQueue.main.async {
                        isAuthenticated = true
                    }
                } else {
                    authErrorMessage = "Biometrics/Passcode failed."
                    showingAuthError = true
                }
            } catch {
                authErrorMessage = error.localizedDescription
                showingAuthError = true
            }
        } else {
            // Fallback if no biometric/passcode is set up - in prod, force setup.
            // For simulator/testing, just allow it if no biometric is enrolled
            DispatchQueue.main.async {
                isAuthenticated = true
            }
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
        .environmentObject(NetworkManager())
}
