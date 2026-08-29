# VaultUp - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Install Dependencies
```bash
cd /Users/abhinavkarra/VaultUP/backend
python3 -m pip install -r requirements.txt
```

### Step 2: Run the Backend
```bash
python3 main.py
# or with auto-reload for development:
python3 -m uvicorn main:app --reload
```

The API will be available at: **http://localhost:8000**

### Step 3: Explore the API
- **Swagger UI**: http://localhost:8000/docs (interactive API documentation)
- **ReDoc**: http://localhost:8000/redoc

---

## 📚 Example: Create a User and Make a Payment

### 1. Register a Student User
```bash
curl -X POST "http://localhost:8000/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Abhinav Karra",
    "email": "abhinav@example.com",
    "phone": "9876543210",
    "student_email": "abhinav@college.edu"
  }'
```

**Response:**
```json
{
  "id": 1,
  "name": "Abhinav Karra",
  "email": "abhinav@example.com",
  "is_student_verified": true,
  "created_at": "2024-01-15T10:30:00"
}
```

### 2. Create Sub-Wallets (Goal Vaults)
```bash
curl -X POST "http://localhost:8000/api/vaults/create?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Air M2",
    "vault_type": "goal",
    "target_amount": 65000
  }'
```

### 3. Create a Payment Order
```bash
curl -X POST "http://localhost:8000/api/payments/create-order?user_id=1" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 83,
    "liquid_percentage": 0.70,
    "merchant_name": "College Canteen",
    "description": "Lunch"
  }'
```

**Response Shows:**
- Order ID for payment
- Allocation breakdown (liquid vs goal)
- Roundup amount (₹7 for ₹83 payment)

### 4. View Dashboard
```bash
curl -X GET "http://localhost:8000/api/users/1/dashboard"
```

**Shows:**
- All vaults with balances
- Progress towards each goal
- Total balance across all accounts
- Student verification status

### 5. View Transaction Ledger
```bash
curl -X GET "http://localhost:8000/api/users/1/ledger?limit=50"
```

**Shows:**
- Double-entry ledger entries
- All deposits and roundups
- Perfect audit trail

---

## 🧪 Run the Full Test Suite

```bash
cd /Users/abhinavkarra/VaultUP/backend
python3 test_payment_system.py
```

This demonstrates:
- ✅ User registration
- ✅ 4 different sub-wallet types
- ✅ 10 payment simulations with auto-roundup
- ✅ Dashboard with progress tracking
- ✅ Complete ledger audit trail
- ✅ Zero-leakage accounting verification

---

## 🏗️ Project Structure

```
/Users/abhinavkarra/VaultUP/
├── backend/
│   ├── main.py                 # FastAPI backend with all endpoints
│   ├── models.py               # SQLAlchemy database models
│   ├── test_payment_system.py  # Test suite and demo script
│   ├── requirements.txt         # Python dependencies
│   ├── .env.example            # Environment variables template
│   ├── README.md               # Full API documentation
│   └── vaultup.db              # SQLite database (created automatically)
└── mobile/
    └── (React Native app - coming next)
```

---

## 💡 Key Features

### ✅ Payment System
- Razorpay integration ready
- Automatic fund allocation (70% liquid, 30% goal)
- Micro-roundup engine (spare change collection)
- Webhook processing for transaction events

### ✅ Sub-Wallets (Vaults)
- **Liquid Pocket**: Daily spendable funds
- **Goal Vaults**: Locked savings for specific targets
- **Trip Escrow**: Group savings for shared goals
- Independent balance tracking per vault

### ✅ Double-Entry Ledger
- Perfect accounting (zero-leakage)
- Every transaction has two entries:
  - Debit: Where money came from
  - Credit: Where money goes
- Immutable audit trail
- Transaction references to Razorpay

### ✅ Student Benefits
- `.edu` email automatic verification
- Discounts and perks integration ready
- Milestone-based rewards
- Emergency withdrawal controls

---

## 🔧 Configuration

Edit `.env` with your Razorpay credentials:

```bash
cp backend/.env.example backend/.env
```

Then update with:
- `RAZORPAY_KEY_ID`: From Razorpay Dashboard
- `RAZORPAY_KEY_SECRET`: From Razorpay Dashboard
- `RAZORPAY_WEBHOOK_SECRET`: From Razorpay Webhook Settings

---

## 📊 Database Schema

### Users Table
Stores student information and verification status

### Vaults Table
Stores sub-wallet information for each goal

### LedgerEntry Table
Complete transaction audit trail (immutable)

### Transaction Table
Razorpay payment metadata and allocation details

---

## 🚦 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/users/register` | Register new user |
| GET | `/api/users/{id}` | Get user details |
| POST | `/api/vaults/create` | Create sub-wallet |
| GET | `/api/users/{id}/vaults` | List all vaults |
| POST | `/api/payments/create-order` | Create payment order |
| POST | `/api/payments/capture` | Capture payment |
| GET | `/api/users/{id}/ledger` | View transaction history |
| GET | `/api/users/{id}/dashboard` | Complete dashboard |
| POST | `/api/webhooks/razorpay` | Razorpay webhook handler |

---

## 📝 Next Steps

1. ✅ **Payment System & Sub-Wallets** (COMPLETED)
   - Backend with FastAPI
   - Database schema
   - Roundup logic
   - Ledger system

2. 🔄 **Mobile App** (Next)
   - React Native frontend
   - Razorpay Checkout integration
   - Real-time dashboard

3. 🔄 **AI Features** (Coming Soon)
   - Student perk matcher
   - Discount aggregator
   - AI spending insights

4. 🔄 **Advanced Features**
   - Group trip escrow
   - Withdrawal locks
   - Milestone rewards

---

## 🐛 Troubleshooting

### Database Error?
```bash
rm backend/vaultup.db  # Delete old database
python3 backend/main.py  # Create fresh database
```

### Port 8000 Already in Use?
```bash
python3 -m uvicorn main:app --reload --port 8001
```

### Razorpay Connection Error?
Replace test credentials in `main.py` with your actual keys:
- `RAZORPAY_KEY_ID`
- `RAZORPAY_KEY_SECRET`

---

## 📞 Support

Check the full API documentation at `backend/README.md` for:
- Detailed endpoint documentation
- Request/response examples
- Database schema explanation
- Roundup logic details
