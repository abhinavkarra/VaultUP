# models.py
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Enum, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
import enum

Base = declarative_base()

class VaultType(str, enum.Enum):
    LIQUID = "liquid"
    GOAL = "goal"
    TRIP_ESCROW = "trip_escrow"

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True)
    phone = Column(String, nullable=True)
    razorpay_customer_id = Column(String, nullable=True)
    is_student_verified = Column(Boolean, default=False)
    student_email = Column(String, nullable=True)
    linked_bank_account = Column(String, nullable=True)  # Mock bank account
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    vaults = relationship("Vault", back_populates="owner", cascade="all, delete-orphan")
    ledger_entries = relationship("LedgerEntry", back_populates="user", cascade="all, delete-orphan")

class Vault(Base):
    __tablename__ = "vaults"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)  # e.g., "Liquid Cash", "MacBook Air", "Goa Trip"
    vault_type = Column(Enum(VaultType), default=VaultType.GOAL)
    target_amount = Column(Float, default=0.0)
    current_balance = Column(Float, default=0.0)
    linked_route_acc = Column(String, nullable=True)  # Razorpay linked account ID
    is_locked = Column(Boolean, default=False)  # For goal vaults: prevent withdrawal before target
    cooldown_until = Column(DateTime, nullable=True)  # When emergency withdraw becomes available
    last_withdrawal_at = Column(DateTime, nullable=True) # To enforce 12 hr cooling period
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    owner = relationship("User", back_populates="vaults")
    ledger_entries = relationship("LedgerEntry", foreign_keys="[LedgerEntry.to_vault_id]", back_populates="to_vault")

class LedgerEntry(Base):
    __tablename__ = "ledger_entries"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    transaction_ref = Column(String, unique=True, index=True)  # Razorpay payment_id / transfer_id
    from_vault_id = Column(Integer, ForeignKey("vaults.id"), nullable=True)
    to_vault_id = Column(Integer, ForeignKey("vaults.id"), nullable=False)
    amount = Column(Float, nullable=False)
    entry_type = Column(String, nullable=False)  # "deposit", "roundup", "split_allocation", "withdrawal"
    description = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    razorpay_reference = Column(String, nullable=True)  # Payment/Transfer ID from Razorpay

    user = relationship("User", back_populates="ledger_entries")
    to_vault = relationship("Vault", foreign_keys=[to_vault_id], backref="incoming_transactions")

class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    razorpay_payment_id = Column(String, unique=True, index=True)
    razorpay_order_id = Column(String, nullable=True)
    amount = Column(Float, nullable=False)
    currency = Column(String, default="INR")
    status = Column(String, default="pending")  # pending, captured, failed, refunded
    liquid_allocation = Column(Float, default=0.0)
    goal_allocation = Column(Float, default=0.0)
    roundup_amount = Column(Float, default=0.0)
    merchant_name = Column(String, nullable=True)
    description = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
