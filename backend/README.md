# VaultUp - Backend Setup Guide

## Overview
VaultUp is an autonomous goal-locked student neo-wallet with:
- Double-entry ledger system for perfect accounting
- Micro-roundup automatic savings
- Sub-wallet (vault) system for goal segregation
- Razorpay payment integration
- Webhook-based transaction processing

## Quick Start

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Razorpay Credentials
```bash
# Copy the example env file
cp .env.example .env

# Edit .env with your Razorpay keys
# Get your keys from: https://dashboard.razorpay.com/app/settings/api-keys
```

### 3. Initialize Database
```bash
# SQLite database will be created automatically on first run
# For PostgreSQL, create database first:
# createdb vaultup_db
```

### 4. Run the Server
```bash
# Development mode with auto-reload
uvicorn main:app --reload

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

Server will be available at: `http://localhost:8000`

### 5. View API Documentation
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

---

## API Endpoints Reference

### User Management

#### Register a new user
```bash
POST /api/users/register

{
  "name": "Abhinav Karra",
  "email": "abhinav@example.com",
  "phone": "9876543210",
  "student_email": "abhinav@college.edu"
}

Response:
{
  "id": 1,
  "name": "Abhinav Karra",
  "email": "abhinav@example.com",
  "is_student_verified": true,
  "created_at": "2024-01-15T10:30:00"
}
```

#### Get user details
```bash
GET /api/users/{user_id}
```

---

### Vault Management (Sub-Wallets)

#### Create a new vault (sub-wallet)
```bash
POST /api/vaults/create?user_id=1

{
  "name": "MacBook Air M2",
  "vault_type": "goal",
  "target_amount": 65000
}

Response:
{
  "id": 2,
  "name": "MacBook Air M2",
  "vault_type": "goal",
  "target_amount": 65000,
  "current_balance": 0,
  "is_locked": true,
  "created_at": "2024-01-15T10:31:00"
}
```

#### List all vaults for a user
```bash
GET /api/users/{user_id}/vaults

Response: Array of vaults with balance and progress
```

#### Get vault balance and progress
```bash
GET /api/vaults/{vault_id}/balance

Response:
{
  "vault_id": 2,
  "name": "MacBook Air M2",
  "current_balance": 5000,
  "target_amount": 65000,
  "progress_percentage": 7.69,
  "is_locked": true,
  "vault_type": "goal"
}
```

---

### Payment System

#### Create a payment order
```bash
POST /api/payments/create-order?user_id=1

{
  "amount": 83,
  "liquid_percentage": 0.70,
  "merchant_name": "College Canteen",
  "description": "Meal purchase"
}

Response:
{
  "order_id": "order_1234567890",
  "amount": 9000,
  "currency": "INR",
  "allocation": {
    "liquid_allocation": 58.10,
    "goal_direct_allocation": 24.90,
    "roundup_amount": 7,
    "total": 90
  },
  "message": "Order created successfully. Redirect to Razorpay Checkout."
}
```

#### Capture a payment
```bash
POST /api/payments/capture

{
  "razorpay_payment_id": "pay_1234567890",
  "razorpay_order_id": "order_1234567890",
  "user_id": 1
}

Response:
{
  "status": "success",
  "message": "Payment captured and allocated to vaults"
}
```

---

### Ledger & Transaction History

#### Get double-entry ledger
```bash
GET /api/users/{user_id}/ledger?limit=50

Response: Array of all ledger entries
[
  {
    "id": 1,
    "transaction_ref": "pay_1234567890",
    "amount": 83,
    "entry_type": "deposit",
    "description": "College Canteen",
    "timestamp": "2024-01-15T10:35:00"
  },
  {
    "id": 2,
    "transaction_ref": "rnd_pay_1234567890",
    "amount": 7,
    "entry_type": "roundup",
    "description": "Micro-roundup from ₹83",
    "timestamp": "2024-01-15T10:35:00"
  }
]
```

---

### Dashboard

#### Get complete user dashboard
```bash
GET /api/users/{user_id}/dashboard

Response:
{
  "user_id": 1,
  "user_name": "Abhinav Karra",
  "user_email": "abhinav@example.com",
  "is_student_verified": true,
  "total_balance": 25000,
  "liquid_balance": 5000,
  "goal_balance": 20000,
  "vaults": [
    {
      "id": 1,
      "name": "Liquid Pocket 💰",
      "type": "liquid",
      "balance": 5000,
      "target": 0,
      "progress_percentage": 0,
      "is_locked": false
    },
    {
      "id": 2,
      "name": "MacBook Air M2",
      "type": "goal",
      "balance": 20000,
      "target": 65000,
      "progress_percentage": 30.77,
      "is_locked": true
    }
  ],
  "created_at": "2024-01-15T10:30:00"
}
```

---

### Webhook Handler

#### Razorpay Webhook
```bash
POST /api/webhooks/razorpay

Header: x-razorpay-signature: {signature}

Handles events:
- payment.captured: Credits liquid vault + applies roundup to goal vault
- transfer.processed: Confirms split allocation
- virtual_account.credited: Tracks group escrow contributions
```

---

## Database Schema

### Users Table
- `id`: User identifier
- `name`: Full name
- `email`: Email address (unique)
- `phone`: Phone number
- `razorpay_customer_id`: Razorpay customer ID
- `is_student_verified`: Student status (for discounts)
- `student_email`: College email (.edu)
- `created_at`, `updated_at`: Timestamps

### Vaults Table
- `id`: Vault identifier
- `user_id`: Foreign key to users
- `name`: Vault name (e.g., "MacBook", "Goa Trip")
- `vault_type`: LIQUID, GOAL, or TRIP_ESCROW
- `target_amount`: Savings goal
- `current_balance`: Current balance
- `is_locked`: Cannot withdraw before target
- `cooldown_until`: Emergency withdraw cooldown

### LedgerEntry Table (Double-Entry)
- `id`: Entry identifier
- `user_id`: User who owns this transaction
- `transaction_ref`: Razorpay payment/transfer ID
- `from_vault_id`: Source vault (nullable for deposits)
- `to_vault_id`: Destination vault
- `amount`: Transaction amount
- `entry_type`: deposit, roundup, split_allocation, withdrawal
- `timestamp`: When transaction occurred

### Transaction Table
- Stores payment metadata from Razorpay
- Tracks order IDs, allocations, and status

---

## Roundup Logic

When a student makes a payment of ₹83:

1. **Roundup Calculation**: 
   - Ceiling to nearest 10: ₹90
   - Delta: ₹90 - ₹83 = ₹7

2. **Allocation** (with 70-30 split):
   - Liquid Pocket: ₹58.10 (70% of ₹83)
   - Goal Vault (direct): ₹24.90 (30% of ₹83)
   - Roundup (automatic): ₹7

3. **Ledger Entries**:
   - Entry 1: ₹83 → Liquid Pocket (deposit)
   - Entry 2: ₹7 → Goal Vault (roundup)

Total saved for goal: ₹24.90 + ₹7 = ₹31.90

---

## Testing with cURL

```bash
# Register user
curl -X POST "http://localhost:8000/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Student",
    "email": "test@example.com",
    "phone": "9876543210",
    "student_email": "test@college.edu"
  }'

# Create goal vault
curl -X POST "http://localhost:8000/api/vaults/create?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Summer Laptop",
    "vault_type": "goal",
    "target_amount": 50000
  }'

# Get dashboard
curl -X GET "http://localhost:8000/api/users/1/dashboard"

# Create payment order
curl -X POST "http://localhost:8000/api/payments/create-order?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 83,
    "liquid_percentage": 0.70,
    "merchant_name": "Canteen",
    "description": "Lunch"
  }'
```

---

## Deployment

### Local Development
```bash
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

### Docker Deployment
```bash
docker build -t vaultup-backend .
docker run -p 8000:8000 -e DATABASE_URL=postgresql://... vaultup-backend
```

### Production (with Gunicorn)
```bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
```

### Ngrok for Webhook Testing
```bash
ngrok http 8000
# Add to Razorpay: https://<ngrok-id>.ngrok.io/api/webhooks/razorpay
```

---

## Next Steps

1. ✅ Backend Payment System with Sub-Wallets (COMPLETED)
2. 🔄 Mobile React Native App Integration
3. 🔄 Student Perk/Discount Matcher (AI Controller)
4. 🔄 Group Trip Escrow Feature
5. 🔄 Synthetic 50-Transaction Batch Test
6. 🔄 Demo Video & Presentation

---

## Support

For issues or questions:
- Check API docs: http://localhost:8000/docs
- Review database schema in models.py
- Test endpoints with the provided cURL examples
