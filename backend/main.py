# main.py
import math
import hmac
import hashlib
import json
from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException, Request, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import razorpay
from pydantic import BaseModel
from typing import Optional, List

from models import Base, User, Vault, VaultType, LedgerEntry, Transaction

# Database setup
DATABASE_URL = "sqlite:///./vaultup.db"  # Switch to postgresql:// for production
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base.metadata.create_all(bind=engine)

# FastAPI app
app = FastAPI(
    title="VaultUp - Student AI Finance Controller",
    description="Autonomous goal-locked student neo-wallet with micro-roundup saving",
    version="1.0.0"
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Razorpay Configuration
RAZORPAY_KEY_ID = "rzp_test_1234567890"  # Replace with your test key
RAZORPAY_KEY_SECRET = "your_webhook_secret_key"  # Replace with your secret
RAZORPAY_WEBHOOK_SECRET = "your_webhook_secret"  # Replace with webhook secret

try:
    client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))
except Exception as e:
    print(f"Razorpay client initialization warning: {e}")

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic Models for request/response
class UserCreate(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None
    student_email: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    is_student_verified: bool
    linked_bank_account: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

class VaultCreate(BaseModel):
    name: str
    vault_type: VaultType = VaultType.GOAL
    target_amount: float = 0.0

class VaultResponse(BaseModel):
    id: int
    name: str
    vault_type: VaultType
    target_amount: float
    current_balance: float
    is_locked: bool
    last_withdrawal_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class LedgerEntryResponse(BaseModel):
    id: int
    transaction_ref: str
    amount: float
    entry_type: str
    description: Optional[str]
    timestamp: datetime

    class Config:
        from_attributes = True

class PaymentRequest(BaseModel):
    amount: float
    liquid_percentage: float = 0.70  # 70% to liquid, 30% to goal by default
    merchant_name: Optional[str] = None
    description: Optional[str] = None

class SplitDepositRequest(BaseModel):
    amount: float
    liquid_vault_id: int
    goal_vault_id: int
    split_ratio: float = 0.3  # 30% to goal vault

class LoginRequest(BaseModel):
    phone: Optional[str] = None
    email: Optional[str] = None
    identifier: Optional[str] = None

class ConnectBankRequest(BaseModel):
    account_number: str

class VaultTransactionRequest(BaseModel):
    amount: float


# ==================== USER ENDPOINTS ====================

@app.post("/api/users/register", response_model=UserResponse)
def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    existing = db.query(User).filter(
        (User.email == user_data.email) | 
        ((User.phone == user_data.phone) & (User.phone != None) & (User.phone != ""))
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="An account with this email or phone already exists. Please sign in.")
    
    new_user = User(
        name=user_data.name,
        email=user_data.email,
        phone=user_data.phone,
        student_email=user_data.student_email,
        is_student_verified=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create default Main Pocket vault
    main_pocket = Vault(
        user_id=new_user.id,
        name="Main Pocket 💰",
        vault_type=VaultType.LIQUID,
        target_amount=0.0,
        current_balance=0.0
    )
    db.add(main_pocket)
    db.commit()
    
    return new_user

@app.get("/api/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Retrieve user details"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.post("/api/users/login", response_model=UserResponse)
def login_user(login_data: LoginRequest, db: Session = Depends(get_db)):
    """Login user via phone number, email, or identifier"""
    query_val = (login_data.identifier or login_data.phone or login_data.email or "").strip()
    if not query_val:
        raise HTTPException(status_code=400, detail="Phone number or email is required to sign in")
    
    user = db.query(User).filter(
        (User.phone == query_val) | (User.email == query_val) | (User.student_email == query_val)
    ).first()
    
    if not user and query_val.isdigit():
        user = db.query(User).filter(User.id == int(query_val)).first()
        
    if not user:
        raise HTTPException(status_code=404, detail="No account found with this credential. Please check your number or sign up.")
    return user

@app.post("/api/users/{user_id}/connect-bank", response_model=UserResponse)
def connect_bank(user_id: int, bank_data: ConnectBankRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.linked_bank_account = bank_data.account_number
    db.commit()
    db.refresh(user)
    return user


# ==================== VAULT ENDPOINTS ====================

@app.post("/api/vaults/create", response_model=VaultResponse)
def create_goal_vault(
    user_id: int,
    vault_data: VaultCreate,
    db: Session = Depends(get_db)
):
    """Create a new sub-wallet (vault) for a specific goal"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    vault = Vault(
        user_id=user_id,
        name=vault_data.name,
        vault_type=vault_data.vault_type,
        target_amount=vault_data.target_amount,
        current_balance=0.0,
        is_locked=vault_data.vault_type == VaultType.GOAL
    )
    db.add(vault)
    db.commit()
    db.refresh(vault)
    return vault

@app.get("/api/users/{user_id}/vaults", response_model=List[VaultResponse])
def list_vaults(user_id: int, db: Session = Depends(get_db)):
    """Get all vaults for a user"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    vaults = db.query(Vault).filter(Vault.user_id == user_id).all()
    return vaults

@app.get("/api/vaults/{vault_id}", response_model=VaultResponse)
def get_vault(vault_id: int, db: Session = Depends(get_db)):
    """Get vault details"""
    vault = db.query(Vault).filter(Vault.id == vault_id).first()
    if not vault:
        raise HTTPException(status_code=404, detail="Vault not found")
    return vault

@app.delete("/api/vaults/{vault_id}")
def delete_vault(
    vault_id: int,
    transfer_destination: Optional[str] = None,  # 'bank' or 'vault'
    target_vault_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    vault = db.query(Vault).filter(Vault.id == vault_id).first()
    if not vault:
        raise HTTPException(status_code=404, detail="Vault not found")
    if vault.vault_type == VaultType.LIQUID:
        raise HTTPException(status_code=400, detail="The primary liquid vault cannot be deleted")
    
    balance = float(vault.current_balance or 0.0)
    user = db.query(User).filter(User.id == vault.user_id).first()
    liquid_vault = db.query(Vault).filter(
        Vault.user_id == vault.user_id,
        Vault.vault_type == VaultType.LIQUID,
        Vault.id != vault.id
    ).first()

    if balance > 0:
        if transfer_destination == "bank":
            bank_name = user.linked_bank_account if (user and user.linked_bank_account) else "Linked Bank Account"
            target_id = liquid_vault.id if liquid_vault else vault.id
            ledger = LedgerEntry(
                user_id=vault.user_id,
                transaction_ref=f"closure_{int(datetime.utcnow().timestamp())}_{vault.id}",
                from_vault_id=vault.id,
                to_vault_id=target_id,
                amount=-balance,
                entry_type="withdrawal",
                description=f"Vault '{vault.name}' closed: ₹{balance:.2f} credited to {bank_name}"
            )
            db.add(ledger)
            vault.current_balance = 0.0
            
        elif transfer_destination == "vault" and target_vault_id:
            target_vault = db.query(Vault).filter(Vault.id == target_vault_id, Vault.user_id == vault.user_id).first()
            if not target_vault:
                raise HTTPException(status_code=400, detail="Target destination vault not found")
            if target_vault.id == vault.id:
                raise HTTPException(status_code=400, detail="Cannot transfer funds into the vault being deleted")
            
            target_vault.current_balance += balance
            ledger = LedgerEntry(
                user_id=vault.user_id,
                transaction_ref=f"closure_transfer_{int(datetime.utcnow().timestamp())}_{vault.id}",
                from_vault_id=vault.id,
                to_vault_id=target_vault.id,
                amount=balance,
                entry_type="deposit",
                description=f"Transferred ₹{balance:.2f} from closed vault '{vault.name}' to '{target_vault.name}'"
            )
            db.add(ledger)
            vault.current_balance = 0.0
            
        else:
            raise HTTPException(
                status_code=400,
                detail=f"Vault has a remaining balance of ₹{balance:.2f}. Please specify transfer destination ('bank' or an existing vault)."
            )

    # Re-link ledger entries where to_vault_id or from_vault_id was this vault to preserve audit trail
    fallback_id = target_vault_id if target_vault_id else (liquid_vault.id if liquid_vault else None)
    if fallback_id:
        db.query(LedgerEntry).filter(LedgerEntry.to_vault_id == vault.id).update({"to_vault_id": fallback_id})
        db.query(LedgerEntry).filter(LedgerEntry.from_vault_id == vault.id).update({"from_vault_id": fallback_id})

    db.delete(vault)
    db.commit()
    return {"status": "success", "vault_id": vault_id}

@app.post("/api/vaults/{vault_id}/deposit", response_model=VaultResponse)
def deposit_vault(vault_id: int, req: VaultTransactionRequest, db: Session = Depends(get_db)):
    vault = db.query(Vault).filter(Vault.id == vault_id).first()
    if not vault:
        raise HTTPException(status_code=404, detail="Vault not found")
    
    vault.current_balance += req.amount
    ledger = LedgerEntry(
        user_id=vault.user_id,
        transaction_ref=f"dep_{datetime.now().timestamp()}",
        to_vault_id=vault.id,
        amount=req.amount,
        entry_type="deposit",
        description="Manual Deposit"
    )
    db.add(ledger)
    db.commit()
    db.refresh(vault)
    return vault

@app.post("/api/vaults/{vault_id}/withdraw", response_model=VaultResponse)
def withdraw_vault(vault_id: int, req: VaultTransactionRequest, db: Session = Depends(get_db)):
    vault = db.query(Vault).filter(Vault.id == vault_id).first()
    if not vault:
        raise HTTPException(status_code=404, detail="Vault not found")
    
    if vault.current_balance < req.amount:
        raise HTTPException(status_code=400, detail="Insufficient balance")

    # 12 Hour cooling period check
    if vault.last_withdrawal_at:
        time_since = datetime.utcnow() - vault.last_withdrawal_at
        if time_since < timedelta(hours=12):
            remaining = timedelta(hours=12) - time_since
            hours = int(remaining.total_seconds() // 3600)
            mins = int((remaining.total_seconds() % 3600) // 60)
            raise HTTPException(status_code=400, detail=f"Cooling period active. Try again in {hours}h {mins}m.")

    vault.current_balance -= req.amount
    vault.last_withdrawal_at = datetime.utcnow()
    
    ledger = LedgerEntry(
        user_id=vault.user_id,
        transaction_ref=f"wtd_{datetime.now().timestamp()}",
        to_vault_id=vault.id, # Using to_vault_id as the vault reference (maybe negative amount)
        amount=-req.amount,
        entry_type="withdrawal",
        description="Manual Withdrawal"
    )
    db.add(ledger)
    db.commit()
    db.refresh(vault)
    return vault

# ==================== PAYMENT & ROUNDUP LOGIC ====================

def calculate_roundup(amount: float, step: int = 10) -> float:
    """
    Calculate micro-roundup amount
    E.g., ₹83 rounds up to ₹90; delta = ₹7
    """
    ceiling = math.ceil(amount / step) * step
    delta = round(ceiling - amount, 2)
    return delta if delta > 0 else 0.0

def allocate_to_vaults(
    user_id: int,
    amount: float,
    liquid_percentage: float,
    goal_vault_id: Optional[int] = None,
    db: Session = None
) -> dict:
    """
    Allocate payment amount between liquid and goal vaults with roundup
    """
    liquid_amount = round(amount, 2)
    goal_direct = 0.0
    roundup_amount = calculate_roundup(amount, step=10)
    
    return {
        "liquid_allocation": liquid_amount,
        "goal_direct_allocation": goal_direct,
        "roundup_amount": roundup_amount,
        "total": amount + roundup_amount
    }

@app.post("/api/payments/create-order")
def create_payment_order(payment_req: PaymentRequest, user_id: int, db: Session = Depends(get_db)):
    """
    Create a Razorpay order for split payment between Liquid and Goal vaults
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Get or create liquid vault
    liquid_vault = db.query(Vault).filter(
        Vault.user_id == user_id,
        Vault.vault_type == VaultType.LIQUID
    ).first()
    
    if not liquid_vault:
        liquid_vault = db.query(Vault).filter(Vault.user_id == user_id).first()
        if not liquid_vault:
            liquid_vault = Vault(
                user_id=user_id,
                name="Main Pocket 💰",
                vault_type=VaultType.LIQUID,
                target_amount=0.0,
                current_balance=0.0
            )
            db.add(liquid_vault)
            db.commit()
            db.refresh(liquid_vault)
    
    # Calculate allocation
    allocation = allocate_to_vaults(
        user_id=user_id,
        amount=payment_req.amount,
        liquid_percentage=payment_req.liquid_percentage,
        db=db
    )
    
    # Create Razorpay order
    try:
        order_payload = {
            "amount": int((payment_req.amount + allocation["roundup_amount"]) * 100),  # In paise
            "currency": "INR",
            "payment_capture": 1,
            "notes": {
                "user_id": str(user_id),
                "liquid_vault_id": str(liquid_vault.id),
                "liquid_allocation": str(allocation["liquid_allocation"]),
                "goal_allocation": str(allocation["goal_direct_allocation"]),
                "roundup_amount": str(allocation["roundup_amount"]),
                "merchant_name": payment_req.merchant_name or "Direct Payment"
            }
        }
        
        # In test mode, you can simulate this
        # In production, use: order = client.order.create(data=order_payload)
        order = {
            "id": "order_1234567890",
            "amount": order_payload["amount"],
            "currency": order_payload["currency"]
        }
        
        goal_vault = db.query(Vault).filter(Vault.user_id == user_id, Vault.vault_type != VaultType.LIQUID).first()
        transaction_ref = f"sim_{datetime.now().timestamp()}"
        merchant_label = payment_req.merchant_name or "Direct Payment"
        liquid_vault.current_balance += allocation["liquid_allocation"]
        db.add(LedgerEntry(user_id=user_id, transaction_ref=f"{transaction_ref}_liquid", to_vault_id=liquid_vault.id, amount=allocation["liquid_allocation"], entry_type="deposit", description="Payment at " + merchant_label))
        goal_amount = allocation["roundup_amount"]
        if goal_vault and goal_amount > 0:
            goal_vault.current_balance += goal_amount
            db.add(LedgerEntry(user_id=user_id, transaction_ref=f"{transaction_ref}_goal", to_vault_id=goal_vault.id, amount=goal_amount, entry_type="roundup", description="Goal saving from " + merchant_label))
        db.add(Transaction(user_id=user_id, razorpay_payment_id=transaction_ref, razorpay_order_id=order["id"], amount=payment_req.amount, status="captured", liquid_allocation=allocation["liquid_allocation"], goal_allocation=allocation["goal_direct_allocation"], roundup_amount=allocation["roundup_amount"], merchant_name=payment_req.merchant_name, description=payment_req.description))
        db.commit()
        return {
            "order_id": order["id"],
            "amount": order["amount"],
            "currency": order["currency"],
            "allocation": allocation,
            "message": "Order created successfully. Redirect to Razorpay Checkout."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create order: {str(e)}")

@app.post("/api/payments/capture")
def capture_payment(
    razorpay_payment_id: str,
    razorpay_order_id: str,
    user_id: int,
    db: Session = Depends(get_db)
):
    """
    Capture a payment and allocate funds to vaults
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Get liquid vault
    liquid_vault = db.query(Vault).filter(
        Vault.user_id == user_id,
        Vault.vault_type == VaultType.LIQUID
    ).first()
    
    if not liquid_vault:
        raise HTTPException(status_code=400, detail="Liquid vault not found")
    
    # Create transaction record
    transaction = Transaction(
        user_id=user_id,
        razorpay_payment_id=razorpay_payment_id,
        razorpay_order_id=razorpay_order_id,
        amount=0.0,  # Should be extracted from Razorpay
        status="captured"
    )
    db.add(transaction)
    db.commit()
    
    # Create ledger entry
    ledger = LedgerEntry(
        user_id=user_id,
        transaction_ref=razorpay_payment_id,
        to_vault_id=liquid_vault.id,
        amount=0.0,
        entry_type="deposit",
        razorpay_reference=razorpay_payment_id
    )
    db.add(ledger)
    db.commit()
    
    return {
        "status": "success",
        "message": "Payment captured and allocated to vaults"
    }

# ==================== LEDGER ENDPOINTS ====================

@app.get("/api/users/{user_id}/ledger", response_model=List[LedgerEntryResponse])
def get_ledger(user_id: int, limit: int = 50, db: Session = Depends(get_db)):
    """
    Get the double-entry ledger for a user
    Shows all transactions and movements between vaults
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    entries = db.query(LedgerEntry).filter(
        LedgerEntry.user_id == user_id
    ).order_by(LedgerEntry.timestamp.desc()).limit(limit).all()
    
    return entries

@app.get("/api/vaults/{vault_id}/balance")
def get_vault_balance(vault_id: int, db: Session = Depends(get_db)):
    """Get current balance of a vault"""
    vault = db.query(Vault).filter(Vault.id == vault_id).first()
    if not vault:
        raise HTTPException(status_code=404, detail="Vault not found")
    
    return {
        "vault_id": vault_id,
        "name": vault.name,
        "current_balance": vault.current_balance,
        "target_amount": vault.target_amount,
        "progress_percentage": round((vault.current_balance / vault.target_amount * 100) if vault.target_amount > 0 else 0, 2),
        "is_locked": vault.is_locked,
        "vault_type": vault.vault_type
    }

# ==================== WEBHOOK ENDPOINT ====================

@app.post("/api/webhooks/razorpay")
async def razorpay_webhook(
    request: Request,
    x_razorpay_signature: str = Header(None),
    db: Session = Depends(get_db)
):
    """
    Handle Razorpay webhook events
    Processes: payment.captured, transfer.processed, virtual_account.credited
    """
    body = await request.body()
    
    # Verify webhook signature (in production)
    # try:
    #     client.utility.verify_webhook_signature(
    #         body.decode("utf-8"),
    #         x_razorpay_signature,
    #         RAZORPAY_WEBHOOK_SECRET
    #     )
    # except Exception:
    #     raise HTTPException(status_code=400, detail="Invalid webhook signature")
    
    payload = json.loads(body.decode("utf-8"))
    event = payload.get("event")
    
    # Handle payment.captured event
    if event == "payment.captured":
        payment = payload["payload"]["payment"]["entity"]
        amount_paid = payment["amount"] / 100.0  # Convert paise to INR
        user_notes = payment.get("notes", {})
        
        user_id = int(user_notes.get("user_id", 0))
        liquid_vault_id = int(user_notes.get("liquid_vault_id", 0))
        liquid_allocation = float(user_notes.get("liquid_allocation", 0))
        roundup_amount = float(user_notes.get("roundup_amount", 0))
        goal_allocation = float(user_notes.get("goal_allocation", 0))
        
        # Get vaults
        liquid_vault = db.query(Vault).filter(Vault.id == liquid_vault_id).first()
        if liquid_vault:
            liquid_amount = liquid_allocation or round(
                amount_paid - goal_allocation - roundup_amount, 2
            )
            liquid_vault.current_balance += liquid_amount
            
            # Record ledger entry for deposit
            ledger = LedgerEntry(
                user_id=user_id,
                transaction_ref=payment["id"],
                to_vault_id=liquid_vault.id,
                amount=liquid_amount,
                entry_type="deposit",
                description=user_notes.get("merchant_name", "Payment"),
                razorpay_reference=payment["id"]
            )
            db.add(ledger)
            
            goal_vault = db.query(Vault).filter(
                Vault.user_id == user_id,
                Vault.vault_type == VaultType.GOAL
            ).order_by(Vault.created_at.desc()).first()

            goal_amount = roundup_amount
            if goal_vault and goal_amount > 0:
                goal_vault.current_balance += goal_amount

                if goal_allocation > 0:
                    goal_ledger = LedgerEntry(
                        user_id=user_id,
                        transaction_ref=f"goal_{payment['id']}",
                        to_vault_id=goal_vault.id,
                        amount=goal_allocation,
                        entry_type="split_allocation",
                        description=f"Goal allocation from {user_notes.get('merchant_name', 'Payment')}",
                        razorpay_reference=payment["id"]
                    )
                    db.add(goal_ledger)

                if roundup_amount > 0:
                    roundup_ledger = LedgerEntry(
                        user_id=user_id,
                        transaction_ref=f"rnd_{payment['id']}",
                        to_vault_id=goal_vault.id,
                        amount=roundup_amount,
                        entry_type="roundup",
                        description=f"Micro-roundup from ₹{amount_paid}",
                        razorpay_reference=payment["id"]
                    )
                    db.add(roundup_ledger)
            
            db.commit()
    
    return {"status": "ok", "event": event}

# ==================== UTILITY ENDPOINTS ====================

@app.get("/api/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "VaultUp API", "version": "1.0.0"}

@app.get("/api/users/{user_id}/dashboard")
def get_dashboard(user_id: int, db: Session = Depends(get_db)):
    """
    Get complete dashboard with all vaults and balance summary
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    vaults = db.query(Vault).filter(Vault.user_id == user_id).all()
    
    total_balance = sum(v.current_balance for v in vaults)
    liquid_balance = sum(v.current_balance for v in vaults if v.vault_type == VaultType.LIQUID)
    goal_balance = sum(v.current_balance for v in vaults if v.vault_type == VaultType.GOAL)
    
    vault_details = []
    for vault in vaults:
        progress = round((vault.current_balance / vault.target_amount * 100) if vault.target_amount > 0 else 0, 2)
        vault_details.append({
            "id": vault.id,
            "name": vault.name,
            "type": vault.vault_type,
            "balance": vault.current_balance,
            "target": vault.target_amount,
            "progress_percentage": progress,
            "is_locked": vault.is_locked
        })
    
    return {
        "user_id": user_id,
        "user_name": user.name,
        "user_email": user.email,
        "is_student_verified": user.is_student_verified,
        "total_balance": total_balance,
        "liquid_balance": liquid_balance,
        "goal_balance": goal_balance,
        "vaults": vault_details,
        "created_at": user.created_at
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
