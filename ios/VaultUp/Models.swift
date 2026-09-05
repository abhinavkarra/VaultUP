// Models.swift
// Data models for API responses

import Foundation

// MARK: - User Models
struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String?
    let isStudentVerified: Bool
    let linkedBankAccount: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone
        case createdAt = "created_at"
        case isStudentVerified = "is_student_verified"
        case linkedBankAccount = "linked_bank_account"
    }
}

// MARK: - Vault Models
struct Vault: Codable, Identifiable {
    let id: Int
    let name: String
    let vaultType: String
    let targetAmount: Float
    let currentBalance: Float
    let isLocked: Bool
    let lastWithdrawalAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case vaultType = "vault_type"
        case targetAmount = "target_amount"
        case currentBalance = "current_balance"
        case isLocked = "is_locked"
        case lastWithdrawalAt = "last_withdrawal_at"
    }
    
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return Double(currentBalance / targetAmount) * 100
    }
    
    var progressFormatted: String {
        String(format: "%.1f%%", progressPercentage)
    }
}

// MARK: - Payment Models
struct PaymentOrder: Codable {
    let orderId: String
    let amount: Int
    let currency: String
    let allocation: AllocationDetails
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case amount, currency, allocation, message
    }
}

struct AllocationDetails: Codable {
    let liquidAllocation: Float
    let goalDirectAllocation: Float
    let roundupAmount: Float
    let total: Float
    
    enum CodingKeys: String, CodingKey {
        case liquidAllocation = "liquid_allocation"
        case goalDirectAllocation = "goal_direct_allocation"
        case roundupAmount = "roundup_amount"
        case total
    }
}

// MARK: - Ledger Models
struct LedgerEntry: Codable, Identifiable {
    let id: Int
    let transactionRef: String
    let amount: Float
    let entryType: String
    let description: String?
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case transactionRef = "transaction_ref"
        case amount
        case entryType = "entry_type"
        case description, timestamp
    }
}

// MARK: - Dashboard Models
struct Dashboard: Codable {
    let userId: Int
    let userName: String
    let userEmail: String
    let isStudentVerified: Bool
    let totalBalance: Float
    let liquidBalance: Float
    let goalBalance: Float
    let vaults: [VaultSummary]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userEmail = "user_email"
        case totalBalance = "total_balance"
        case liquidBalance = "liquid_balance"
        case goalBalance = "goal_balance"
        case isStudentVerified = "is_student_verified"
        case vaults
        case createdAt = "created_at"
    }
}

struct VaultSummary: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let balance: Float
    let target: Float
    let progressPercentage: Double
    let isLocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, balance, target
        case isLocked = "is_locked"
        case progressPercentage = "progress_percentage"
    }
}

// MARK: - API Request Models
struct UserRegistrationRequest: Codable {
    let name: String
    let email: String
    let phone: String?
    let studentEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case name, email, phone
        case studentEmail = "student_email"
    }
}

struct VaultCreateRequest: Codable {
    let name: String
    let vaultType: String
    let targetAmount: Float
    
    enum CodingKeys: String, CodingKey {
        case name
        case vaultType = "vault_type"
        case targetAmount = "target_amount"
    }
}

struct PaymentCreateRequest: Codable {
    let amount: Float
    let liquidPercentage: Float
    let merchantName: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case liquidPercentage = "liquid_percentage"
        case merchantName = "merchant_name"
        case description
    }
}

struct LoginRequest: Codable {
    let phone: String
}

struct ConnectBankRequest: Codable {
    let accountNumber: String
    
    enum CodingKeys: String, CodingKey {
        case accountNumber = "account_number"
    }
}

struct VaultTransactionRequest: Codable {
    let amount: Float
}

struct DeleteVaultResponse: Codable {
    let status: String
    let vaultId: Int

    enum CodingKeys: String, CodingKey {
        case status
        case vaultId = "vault_id"
    }
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let status: String
    let data: T?
    let message: String?
}

struct ErrorResponse: Codable {
    let detail: String
}
