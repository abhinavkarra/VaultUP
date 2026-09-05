// NetworkManager.swift
// API Communication Layer

import Foundation

class NetworkManager: ObservableObject {
    @Published var currentUser: User?
    @Published var dashboard: Dashboard?
    @Published var vaults: [Vault] = []
    @Published var ledger: [LedgerEntry] = []
    @Published var lastPaymentOrder: PaymentOrder?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://localhost:8000/api"
    private var userId: Int?

    func startDemoSession() async {
        await fetchUser(userId: 1)
        await fetchDashboard(userId: 1)
    }
    
    // MARK: - User Management
    
    func registerUser(name: String, email: String, phone: String, studentEmail: String) async {
        let endpoint = "\(baseURL)/users/register"
        
        let request = UserRegistrationRequest(
            name: name,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            studentEmail: studentEmail.isEmpty ? nil : studentEmail
        )
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.userId = user.id
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchUser(userId: Int) async {
        let endpoint = "\(baseURL)/users/\(userId)"
        self.userId = userId
        
        await performRequest(
            url: endpoint,
            method: "GET"
        ) { (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func login(phone: String) async {
        let endpoint = "\(baseURL)/users/login"
        let request = LoginRequest(phone: phone)
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.userId = user.id
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func connectBank(accountNumber: String) async {
        guard let userId = userId else { return }
        let endpoint = "\(baseURL)/users/\(userId)/connect-bank"
        let request = ConnectBankRequest(accountNumber: accountNumber)
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Dashboard
    
    func fetchDashboard(userId: Int) async {
        let endpoint = "\(baseURL)/users/\(userId)/dashboard"
        self.userId = userId
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        await performRequest(
            url: endpoint,
            method: "GET"
        ) { (result: Result<Dashboard, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let dashboard):
                    self.dashboard = dashboard
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Vault Management
    
    func createVault(name: String, vaultType: String, targetAmount: Float) async {
        guard let userId = userId else {
            errorMessage = "User not logged in"
            return
        }
        
        let endpoint = "\(baseURL)/vaults/create?user_id=\(userId)"
        
        let request = VaultCreateRequest(
            name: name,
            vaultType: vaultType,
            targetAmount: targetAmount
        )
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<Vault, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let vault):
                    self.vaults.append(vault)
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchVaults(userId: Int) async {
        let endpoint = "\(baseURL)/users/\(userId)/vaults"
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        await performRequest(
            url: endpoint,
            method: "GET"
        ) { (result: Result<[Vault], Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let vaults):
                    self.vaults = vaults
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteVault(vaultId: Int) async {
        let endpoint = "\(baseURL)/vaults/\(vaultId)"
        await performRequest(url: endpoint, method: "DELETE") { (result: Result<DeleteVaultResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.vaults.removeAll { $0.id == vaultId }
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func withdraw(vaultId: Int, amount: Float) async {
        let endpoint = "\(baseURL)/vaults/\(vaultId)/withdraw"
        let request = VaultTransactionRequest(amount: amount)
        
        DispatchQueue.main.async { self.isLoading = true }
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<Vault, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let updatedVault):
                    if let index = self.vaults.firstIndex(where: { $0.id == updatedVault.id }) {
                        self.vaults[index] = updatedVault
                    }
                    if let userId = self.userId {
                        Task { await self.fetchDashboard(userId: userId) }
                    }
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deposit(vaultId: Int, amount: Float) async {
        let endpoint = "\(baseURL)/vaults/\(vaultId)/deposit"
        let request = VaultTransactionRequest(amount: amount)
        
        DispatchQueue.main.async { self.isLoading = true }
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<Vault, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let updatedVault):
                    if let index = self.vaults.firstIndex(where: { $0.id == updatedVault.id }) {
                        self.vaults[index] = updatedVault
                    }
                    if let userId = self.userId {
                        Task { await self.fetchDashboard(userId: userId) }
                    }
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Payments
    
    func createPaymentOrder(amount: Float, liquidPercentage: Float = 1.0, merchantName: String) async {
        guard let userId = userId else {
            errorMessage = "User not logged in"
            return
        }
        
        let endpoint = "\(baseURL)/payments/create-order?user_id=\(userId)"
        
        let request = PaymentCreateRequest(
            amount: amount,
            liquidPercentage: liquidPercentage,
            merchantName: merchantName,
            description: "Payment for \(merchantName)"
        )
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        await performRequest(
            url: endpoint,
            method: "POST",
            body: request
        ) { (result: Result<PaymentOrder, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let order):
                    self.lastPaymentOrder = order
                    print("Payment order created: \(order.orderId)")
                    print("Roundup: ₹\(order.allocation.roundupAmount)")
                    self.errorMessage = nil
                    // Refresh dashboard to show updated balances
                    if let userId = self.userId {
                        Task {
                            await self.fetchDashboard(userId: userId)
                            await self.fetchVaults(userId: userId)
                        }
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Ledger
    
    func fetchLedger(userId: Int, limit: Int = 50) async {
        let endpoint = "\(baseURL)/users/\(userId)/ledger?limit=\(limit)"
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        await performRequest(
            url: endpoint,
            method: "GET"
        ) { (result: Result<[LedgerEntry], Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let ledger):
                    self.ledger = ledger
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Generic Request Method
    
    private func performRequest<T: Codable>(
        url: String,
        method: String = "GET",
        body: Encodable? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) async {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "Invalid response", code: -1)
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            case 400...599:
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NSError(domain: errorResponse.detail, code: httpResponse.statusCode)
            default:
                throw NSError(domain: "HTTP \(httpResponse.statusCode)", code: httpResponse.statusCode)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Helper Methods
    
    func setUserId(_ id: Int) {
        self.userId = id
    }
}
