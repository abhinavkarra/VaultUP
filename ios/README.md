# VaultUp iOS App Setup Guide

## 🎯 Overview

The iOS app is a native **SwiftUI** application that connects to your FastAPI backend. It provides:
- Real-time dashboard with vault balances
- Payment processing with auto-roundup
- Vault management (create, view, track progress)
- Settings and device information

---

## 📁 Project Structure

```
ios/
└── VaultUp/
    ├── VaultUpApp.swift          # Main app entry point (tab navigation)
    ├── Models.swift              # All data structures
    ├── NetworkManager.swift      # API communication layer
    ├── HomeView.swift            # Dashboard screen
    ├── VaultsView.swift          # Vault management screen
    ├── PaymentView.swift         # Payment processing screen
    └── SettingsView.swift        # Settings & about screen
```

---

## 🚀 Quick Setup in Xcode

### Step 1: Create Xcode Project

1. Open **Xcode**
2. File → New → Project
3. Choose **App** (iOS)
4. Configure:
   - **Product Name**: VaultUp
   - **Team**: None (can add later)
   - **Organization**: Your name
   - **Bundle Identifier**: com.yourdomain.vaultup
   - **Interface**: SwiftUI
   - **Minimum Deployment Target**: iOS 15.0

### Step 2: Add Swift Files to Xcode

1. In Xcode's Project Navigator, right-click "VaultUp" folder
2. Select "Add Files to VaultUp..."
3. Navigate to `/Users/abhinavkarra/VaultUP/ios/VaultUp/`
4. Select all `.swift` files:
   - VaultUpApp.swift
   - Models.swift
   - NetworkManager.swift
   - HomeView.swift
   - VaultsView.swift
   - PaymentView.swift
   - SettingsView.swift

5. Check "Copy items if needed"
6. Click "Add"

### Step 3: Set Main App File

1. In Xcode, select project → VaultUp target → Build Settings
2. Search for "Main"
3. Under **Xcode Build Settings**:
   - Set **Main** to `VaultUpApp`

### Step 4: Configure App Delegate

In the project settings:
1. Select **VaultUp target**
2. Go to **Info** tab
3. Ensure these keys exist:
   ```
   App Transport Security Settings
   └─ Allow Arbitrary Loads: YES (for localhost development)
   ```

---

## 🔧 VS Code Integration

### Option 1: Edit Swift Files in VS Code

While Xcode is open, you can edit Swift files in VS Code:

1. **Install Swift Extensions in VS Code**:
   - Install "Swift" by Apple (official extension)
   - Install "Swift Toolchain" configuration

2. **Open folder in VS Code**:
   ```bash
   code /Users/abhinavkarra/VaultUP/ios/VaultUp/
   ```

3. **Edit files in VS Code**, they auto-sync to Xcode
4. **Build in Xcode** to see changes

### Option 2: Workspace Setup (Recommended)

1. **In VS Code**, open the entire VaultUP workspace:
   ```bash
   code /Users/abhinavkarra/VaultUP/
   ```

2. **Create workspace structure**:
   - `/backend/` - FastAPI server
   - `/ios/` - iOS app
   - Both accessible in one VS Code window

3. **Use VS Code terminal** for backend, Xcode for iOS UI building

---

## 📱 Run on iOS Simulator

### Method 1: Using Xcode (Recommended)

1. **Start the backend first**:
   ```bash
   cd /Users/abhinavkarra/VaultUP/backend
   python3 main.py
   ```
   Backend will run on: `http://localhost:8000`

2. **Open Xcode project**:
   ```bash
   cd /Users/abhinavkarra/VaultUP/ios
   open VaultUp.xcodeproj
   ```

3. **Select Simulator**:
   - Click device selector at top of Xcode
   - Choose "iPhone 15 Pro" or similar
   - Click "Run" button (or Cmd+R)

4. **Select User ID**: 
   - App will ask for User ID
   - Enter: `1` (the user created by test suite)
   - Click "Load Dashboard"

### Method 2: Using Command Line

```bash
# Build and run on simulator
xcodebuild -scheme VaultUp -configuration Debug -derivedDataPath build -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Or just open Xcode
open /Users/abhinavkarra/VaultUP/ios/VaultUp.xcodeproj
```

---

## 🧪 Testing the App

### 1. Test User Registration
```bash
# In Terminal
curl -X POST "http://localhost:8000/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'

# Note the returned user ID
```

Then in app, enter that ID to load dashboard.

### 2. Test Payments
1. Go to **Pay** tab
2. Enter amount: `83`
3. Select merchant: `Canteen`
4. Click "Process Payment"
5. See roundup calculation: ₹7
6. Payment success confirmation appears

### 3. Test Vault Creation
1. Go to **Vaults** tab
2. Click **+** button
3. Create vault:
   - Name: "Summer Laptop"
   - Type: Goal
   - Target: 50000
4. Click "Create"
5. Vault appears in list with 0% progress

### 4. View Dashboard
1. Go to **Home** tab
2. See:
   - Total balance
   - Liquid vs Goal split
   - All active vaults
   - Progress bars
   - Student verification badge

---

## 🌐 Network Configuration

### For Local Development

The app connects to: `http://localhost:8000/api`

**Important**: iOS Simulator needs to reach `localhost` on your Mac:

1. **Simulator uses your Mac's IP**, not `127.0.0.1`
2. **Get your Mac's IP**:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   Example: `192.168.1.100`

3. **Option A**: Update NetworkManager.swift
   ```swift
   private let baseURL = "http://192.168.1.100:8000/api"
   ```

4. **Option B**: Use ngrok for public URL
   ```bash
   # In new terminal
   ngrok http 8000
   
   # Update NetworkManager.swift with ngrok URL
   private let baseURL = "https://xxxx-xx-xxx-xxx-xx.ngrok.io/api"
   ```

### For Device Testing

For physical iPhone:
1. Connect iPhone to same Wi-Fi as Mac
2. Use Mac's IP address (not localhost)
3. Ensure backend accepts connections from network

---

## 🎨 Preview Canvas

View UI in real-time with SwiftUI Previews:

1. **Open any View file** in Xcode
2. Press **Cmd+Alt+Return** to show Preview
3. Canvas shows live preview of that screen
4. Edit in code, preview updates instantly

### Preview Devices

Click device selector in preview to test:
- iPhone SE
- iPhone 14 Pro
- iPhone 15 Pro Max
- iPad
- Landscape/Portrait modes

---

## 📊 Key Screens

### HomeView (Dashboard)
```
- Total Balance: ₹X,XXX
- Liquid: ₹X,XXX | Goals: ₹X,XXX
- Vault Cards with progress bars
- Student Verification badge
```

### VaultsView (Management)
```
- Create new vault button (+)
- List of all vaults
- Vault details: name, balance, target, progress
- Lock/Unlock status
```

### PaymentView (Pay)
```
- Amount input (₹)
- Real-time roundup preview
- Merchant selection
- Process payment button
- Success confirmation
```

### SettingsView
```
- API configuration
- Features list
- About section
- Device information
- Quick links to API docs
```

---

## 🔌 API Integration

The app communicates with your backend via:

**NetworkManager.swift** handles:
- User registration & login
- Vault CRUD operations
- Payment processing
- Ledger retrieval
- Dashboard data

All requests are:
- ✅ Async/Await pattern
- ✅ Error handled
- ✅ JSON encoded
- ✅ Published to @ObservedObject

Example:
```swift
// HomeView requests dashboard
Task {
    await networkManager.fetchDashboard(userId: 1)
}
```

---

## 🛠️ Debugging

### Xcode Console
- Click **View** → **Debug Area** → **Show Console**
- See network requests and responses
- Print statements appear here

### Network Logging
To see API calls:
```swift
// In NetworkManager.swift, add to performRequest():
print("API Call: \(method) \(url)")
print("Request: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
```

### Simulator Tools
- **Xcode Debug Gauge**: CPU, memory, disk
- **Xcode Debug Navigator**: Step through code
- **View Hierarchy Debugger**: Inspect UI layers

---

## ✅ Checklist Before First Run

- [ ] Backend running: `python3 main.py`
- [ ] Swift files added to Xcode
- [ ] iOS 15.0+ selected as min deployment
- [ ] Simulator selected (iPhone 15 Pro)
- [ ] Allow Arbitrary Loads enabled in Info.plist
- [ ] User ID: 1 (from test suite)
- [ ] Network reachability configured

---

## 📱 Run Configurations

### Development (Simulator)
```
Target: VaultUp
Device: iPhone 15 Pro Simulator
Destination: iOS Simulator
Scheme: VaultUp
```

### Device (Physical iPhone)
```
Target: VaultUp
Device: Your iPhone
Destination: Any iPhone
Code Sign: Personal Team
```

### Production
```
Target: VaultUp
Device: Generic iOS Device
Scheme: VaultUp (Release)
Code Sign: Distribution Certificate
```

---

## 🔐 Security Notes

- ✅ Uses HTTPS in production (update URL)
- ✅ Validates all API responses
- ✅ No hardcoded credentials
- ✅ Uses URLSession (secure by default)
- ⚠️ Dev: Allow Arbitrary Loads enabled (disable in production)

---

## 📝 Next Steps

1. **Complete Xcode Setup** (above)
2. **Run Backend**: `python3 backend/main.py`
3. **Build in Xcode**: Cmd+B
4. **Run on Simulator**: Cmd+R
5. **Test all screens** with sample data
6. **View API docs**: http://localhost:8000/docs

---

## 🆘 Troubleshooting

### "Cannot connect to backend"
**Solution**: Update baseURL in NetworkManager.swift to your Mac's IP
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### "Build Failed"
**Solution**: 
1. Clean build: Cmd+Shift+K
2. Delete derived data: Xcode → Settings → Locations
3. Rebuild: Cmd+B

### "Simulator won't start"
**Solution**:
1. Xcode → Settings → Locations → Command Line Tools
2. Simulate → Reset Contents and Settings
3. Try different device (iPhone 14 Pro)

### Swift compilation errors
**Solution**:
1. Check file encoding: UTF-8
2. Verify all @State/@Published syntax
3. Xcode → Build → Clean Build Folder

---

## 📞 Support

Check documentation:
- Full Backend API: `/backend/README.md`
- Architecture: `/SYSTEM_SUMMARY.md`
- QuickStart: `/QUICKSTART.md`

View API Docs live at: `http://localhost:8000/docs`
