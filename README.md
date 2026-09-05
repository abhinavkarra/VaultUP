# VaultUP

VaultUP is a student-focused finance app that turns everyday payments into organized, goal-based savings. It combines a smart payment flow, automatic spare-change roundups, and locked savings vaults so students can build toward goals without managing every small transfer manually.

> **Project status:** Working prototype with a FastAPI backend and a native SwiftUI iOS client. Razorpay integration is prepared for further development.

## What It Does

- **Smart payments:** Create payment orders with configurable liquid-fund and goal-savings allocation.
- **Automatic roundups:** A payment such as INR 83 can round up to INR 90, moving the INR 7 difference into savings.
- **Goal vaults:** Separate money into liquid spending, personal goals, or group trip escrow.
- **Transparent accounting:** Track allocations through a double-entry ledger and transaction history.
- **Student-first onboarding:** Register students and verify eligible college email addresses.
- **Progress visibility:** View balances, savings targets, and vault progress from the dashboard.

## Architecture

```text
SwiftUI iOS app  <----HTTP/JSON---->  FastAPI backend  <---->  SQLite / PostgreSQL
       |                                  |
   Dashboard,                         Payments,
   vaults, payments                    vaults, ledger,
   and settings                        Razorpay webhooks
```

### Repository Layout

| Path | Purpose |
| --- | --- |
| [`backend/`](backend/) | FastAPI API, SQLAlchemy models, payment logic, ledger, and tests |
| [`ios/`](ios/) | Native SwiftUI iOS app and Xcode project |
| [`flutter_experiment/`](flutter_experiment/) | Flutter exploration project and generated iOS project |
| [`QUICKSTART.md`](QUICKSTART.md) | Backend quick start and API examples |
| [`backend/README.md`](backend/README.md) | Detailed API documentation |
| [`iOS_XCODE_SETUP.md`](iOS_XCODE_SETUP.md) | Xcode and Simulator setup |
| [`SYSTEM_SUMMARY.md`](SYSTEM_SUMMARY.md) | Feature and architecture summary |

## Run the Backend

```bash
cd backend
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m uvicorn main:app --reload
```

Once running, open:

- API: <http://localhost:8000>
- Swagger documentation: <http://localhost:8000/docs>
- ReDoc: <http://localhost:8000/redoc>

Run the payment-system demonstration with:

```bash
cd backend
.venv/bin/python test_payment_system.py
```

## Run the iOS App

1. Open [`ios/VaultUp.xcodeproj`](ios/VaultUp.xcodeproj) in Xcode.
2. Select an iPhone Simulator.
3. Start the backend locally.
4. Build and run with `Cmd+R`.

The iOS client includes a dashboard, vault management, payment creation, transaction information, and settings screens. See [`iOS_XCODE_SETUP.md`](iOS_XCODE_SETUP.md) for network configuration and Simulator details.

## Example Flow

1. Register a student user.
2. Create a goal vault, such as a laptop or trip fund.
3. Create a payment order for an everyday purchase.
4. Apply the payment allocation and roundup.
5. Review the updated dashboard and ledger.

## Important Note

This repository is an educational prototype. Before handling real money, it needs production authentication, secure secret management, payment-provider verification, database migrations, stronger authorization, observability, and a complete deployment setup.

## License

No license has been selected for this project yet.
