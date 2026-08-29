# VaultUp - iOS + Xcode + VS Code Integration Guide

## 🎯 Goal

Set up a **complete development environment** where you can:
- ✅ Write backend in VS Code
- ✅ Build iOS UI in Xcode with live previews
- ✅ See both running side-by-side
- ✅ Visualize the app in iOS Simulator
- ✅ Edit Swift code in VS Code and see changes in Xcode

---

## 📋 Prerequisites

- macOS 12.0 or higher
- Xcode 14.0 or higher (from App Store)
- VS Code with Swift extension
- Python 3.9+ (for backend)
- iPhone simulator (included with Xcode)

---

## 🚀 Step-by-Step Setup

### Phase 1: Prepare Backend

#### 1.1 Start the backend server
```bash
cd /Users/abhinavkarra/VaultUP/backend
python3 main.py
```

**Output**: 
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

Backend will be running on: **http://localhost:8000**

#### 1.2 Keep this terminal open!
Don't close this terminal window. Backend needs to stay running for the app to work.

---

### Phase 2: Set Up VS Code for Swift Development

#### 2.1 Install Swift Extension
1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Swift"
4. Install **Swift** (Apple's official extension)
5. Also install: **Swift Toolchain** by GriffnBass

#### 2.2 Open Entire VaultUP Workspace
```bash
code /Users/abhinavkarra/VaultUP/
```

This opens VS Code with both backend and iOS folders visible.

#### 2.3 VS Code Structure
```
VS Code Explorer:
├── VaultUP/
    ├── backend/                  ← Python backend
    │   ├── main.py
    │   ├── models.py
    │   ├── requirements.txt
    │   └── ...
    ├── ios/                       ← iOS app (Swift)
    │   └── VaultUp/
    │       ├── VaultUpApp.swift
    │       ├── Models.swift
    │       ├── NetworkManager.swift
    │       ├── HomeView.swift
    │       ├── VaultsView.swift
    │       ├── PaymentView.swift
    │       └── SettingsView.swift
    ├── mobile/
    ├── QUICKSTART.md
    └── SYSTEM_SUMMARY.md
```

---

### Phase 3: Set Up Xcode Project

#### 3.1 Create New Xcode Project
1. Open **Xcode**
2. File → New → Project
3. Select **App** (iOS)
4. Configure:
   ```
   Product Name: VaultUp
   Team: None
   Organization: Your Name
   Bundle Identifier: com.vaultup.app
   Interface: SwiftUI
   Min Deployment Target: iOS 15.0
   ```
5. Choose location: `/Users/abhinavkarra/VaultUP/ios/`
6. Click "Create"

#### 3.2 Add Swift Files to Xcode
1. In Xcode, left sidebar, right-click on "VaultUp" folder
2. Select "Add Files to 'VaultUp'..."
3. Navigate to: `/Users/abhinavkarra/VaultUP/ios/VaultUp/`
4. Select these files:
   - ✅ VaultUpApp.swift
   - ✅ Models.swift
   - ✅ NetworkManager.swift
   - ✅ HomeView.swift
   - ✅ VaultsView.swift
   - ✅ PaymentView.swift
   - ✅ SettingsView.swift

5. Check: "Copy items if needed"
6. Click "Add"

#### 3.3 Configure Info.plist
1. In Xcode, select the VaultUp project in navigator
2. Select VaultUp target
3. Go to "Info" tab
4. Add these keys:
   ```
   ✓ App Transport Security Settings
     └─ Allow Arbitrary Loads: YES
   ```

This allows the app to connect to localhost for development.

#### 3.4 Set Main Entry Point
1. Project Settings → VaultUp target
2. Build Settings tab
3. Search: "Main"
4. Set to: `VaultUpApp`

---

### Phase 4: Configure Network Connection

#### 4.1 Find Your Mac's IP Address
```bash
# In Terminal
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Output example:
```
inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
```

Note your IP: **192.168.1.100** (example)

#### 4.2 Update iOS App Network Settings
1. In Xcode, open **NetworkManager.swift**
2. Find line:
   ```swift
   private let baseURL = "http://localhost:8000/api"
   ```
3. Replace with your Mac's IP:
   ```swift
   private let baseURL = "http://192.168.1.100:8000/api"
   ```

**OR** use ngrok for automatic tunneling (see below).

#### 4.3 (Optional) Use ngrok for Tunneling
If you want to test on real device or avoid IP issues:

```bash
# In new terminal
brew install ngrok

# Start ngrok tunnel
ngrok http 8000
```

Copy the HTTPS URL (example: `https://abc123-45-67-890-12.ngrok.io`)

Then in NetworkManager.swift:
```swift
private let baseURL = "https://abc123-45-67-890-12.ngrok.io/api"
```

---

### Phase 5: Launch Everything

#### 5.1 Terminal 1: Backend Server (Already Running)
```bash
# KEEP THIS OPEN
cd /Users/abhinavkarra/VaultUP/backend
python3 main.py

# Output:
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

#### 5.2 Terminal 2: VS Code (Optional)
```bash
# For Swift syntax highlighting and editing
code /Users/abhinavkarra/VaultUP/
```

#### 5.3 Xcode: Build and Run
1. Select Simulator device: iPhone 15 Pro
2. Click "Play" button (or Cmd+R)
3. Wait for simulator to launch
4. App will open in simulator

---

### Phase 6: First App Launch

#### 6.1 When App Opens
The home screen will show:
```
VaultUp ⚡
[Enter User ID input]
[Load Dashboard button]
```

#### 6.2 Create Test User (If Needed)
```bash
# In Terminal (new tab)
curl -X POST "http://localhost:8000/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Test Student",
    "email":"student@college.edu",
    "phone":"9876543210",
    "student_email":"student@college.edu"
  }'

# Note the returned ID
```

#### 6.3 Load Dashboard in App
1. In simulator, enter the User ID (example: 1)
2. Click "Load Dashboard"
3. Dashboard appears with:
   - Total balance
   - Liquid pocket balance
   - All vaults
   - Progress bars

---

## 🎨 View Live Previews

### Canvas Preview (Most Useful)
While editing Swift in Xcode:

1. Open any View file (e.g., HomeView.swift)
2. Press **Cmd+Alt+Return**
3. Canvas appears on right side showing live preview
4. Edit code → Preview updates instantly
5. Click different devices to test layouts

### Try Different Devices
In preview:
- iPhone SE
- iPhone 14 Pro
- iPhone 15 Pro Max
- iPad Pro
- Landscape/Portrait

---

## 🔄 Edit-Build-Run Workflow

### Workflow 1: Edit in VS Code, Run in Xcode
```
1. Edit Swift file in VS Code
   └─ File saves automatically
   
2. Go to Xcode window
   └─ File auto-reloads
   
3. Press Cmd+R to build and run
   └─ Changes appear in simulator
```

### Workflow 2: Edit in Xcode Preview Canvas
```
1. Open Swift file in Xcode
   
2. Press Cmd+Alt+Return for preview
   
3. Edit in code editor
   └─ Preview updates live
   
4. Click "Play" to run on simulator
   └─ Full app testing
```

### Workflow 3: Debug in Simulator
```
1. Add breakpoint in Xcode (click line number)
   
2. Run app (Cmd+R)
   
3. When breakpoint hits, inspect variables
   
4. Step through code with Xcode debugger controls
```

---

## 📺 Side-by-Side Debugging

### Setup Windows
1. **Left Screen**: VS Code (both backend + iOS code)
2. **Right Screen**: Xcode + Simulator

```
┌─────────────────────┬─────────────────────┐
│                     │                     │
│   VS Code (Backend  │   Xcode Console     │
│   & iOS Code)       │   + Simulator       │
│                     │                     │
└─────────────────────┴─────────────────────┘
```

### Monitor API Calls
1. In VS Code, open **NetworkManager.swift**
2. Add logging:
   ```swift
   print("📡 API: \(method) \(url)")
   ```

3. In Xcode Console (Cmd+Shift+Y):
   - See all API requests
   - See responses
   - Debug any issues

---

## 🧪 Testing Workflow

### Test Flow
```
1. Make a payment in app
   ↓
2. Check Xcode console for API logs
   ↓
3. Verify roundup calculation
   ↓
4. Check backend logs for webhook
   ↓
5. Refresh dashboard to see updated balance
```

### Example: Test Payment
1. In simulator:
   - Go to **Pay** tab
   - Enter amount: 83
   - Select merchant: Canteen
   - Click "Process Payment"

2. In Xcode Console:
   - See: `📡 API: POST .../payments/create-order`
   - See response with roundup: 7

3. In VS Code Backend:
   - See webhook processing logs

4. In simulator:
   - Success screen shows: Roundup ₹7

---

## 🐛 Debugging Tips

### Xcode Debugger
```
View → Debug Area → Show Console      (Cmd+Shift+Y)
View → Debug Area → Show Variables    (Cmd+Shift+V)
```

### Breakpoints
1. Click line number in Xcode
2. Blue breakpoint appears
3. Run app, it stops at that line
4. Step through with controls

### Network Issues
If app can't reach backend:

1. **Check backend is running**:
   ```bash
   curl http://localhost:8000/api/health
   # Should return: {"status":"healthy"}
   ```

2. **Check IP address** (not 127.0.0.1):
   ```bash
   ifconfig | grep "inet "
   ```

3. **Verify NetworkManager.swift** has correct URL

4. **Try ngrok** if local IP doesn't work:
   ```bash
   ngrok http 8000
   ```

---

## 📱 Run on Real iPhone

For testing on physical device:

1. **Connect iPhone to Mac** via USB
2. **Trust this computer** on iPhone
3. In Xcode:
   - Device selector → Your iPhone
   - Click Play to build and run
4. **Allow Profile on iPhone**:
   - Settings → General → Profiles & Device Management
   - Trust your developer certificate

---

## 📊 Application Screens

### HomeView (Dashboard)
- Shows total balance
- Liquid vs Goal split
- All active vaults
- Student verification badge

### VaultsView
- List all vaults
- Create new vault (+)
- View vault details
- See progress to target

### PaymentView
- Enter payment amount
- See live roundup preview
- Select merchant
- Process payment
- View confirmation

### SettingsView
- API configuration
- Feature list
- About information
- Device info
- Links to API docs

---

## ✅ Verification Checklist

Before claiming "setup complete":

- [ ] Backend running: `python3 main.py` ✅
- [ ] Xcode project created
- [ ] Swift files added to Xcode
- [ ] Info.plist configured (Allow Arbitrary Loads)
- [ ] Network URL updated in NetworkManager.swift
- [ ] Simulator selected (iPhone 15 Pro)
- [ ] User ID: 1 available
- [ ] App builds without errors (Cmd+B)
- [ ] App runs on simulator (Cmd+R)
- [ ] Dashboard loads with balance data
- [ ] Payment screen shows roundup preview
- [ ] All tabs navigate without errors

---

## 🎯 Next Steps

1. ✅ **Backend + iOS Setup** (COMPLETE)
2. 🔄 **Test All Screens** (Next)
3. 🔄 **Add More Features** (Coming)
4. 🔄 **Optimize Performance** (Later)
5. 🔄 **Prepare for App Store** (Future)

---

## 🆘 Common Issues & Solutions

### Issue: "Cannot connect to backend"
**Solution**:
```bash
# Check backend is running
curl http://localhost:8000/api/health

# Get your Mac's IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Update NetworkManager.swift with correct IP
```

### Issue: "Build fails with Swift errors"
**Solution**:
1. Clean: Cmd+Shift+K
2. Delete DerivedData: 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
3. Rebuild: Cmd+B

### Issue: "Simulator won't open"
**Solution**:
```bash
# Restart simulator
Xcode → Simulate → Reset Contents and Settings

# Or reset in command line
xcrun simctl shutdown all
xcrun simctl erase all
```

### Issue: "Preview not showing"
**Solution**:
1. In Xcode, open View file
2. Press Cmd+Alt+Return
3. If still no preview, try:
   - Product → Scheme → Edit Scheme → Run → Console
   - Check for Swift compilation errors

---

## 📞 Support Resources

- **Xcode Help**: Help → Xcode Help (Cmd+?)
- **Apple Developer**: https://developer.apple.com/
- **SwiftUI Documentation**: https://developer.apple.com/swiftui/
- **Your Backend Docs**: http://localhost:8000/docs
- **Project Repo**: /Users/abhinavkarra/VaultUP/

---

## 🎉 Success!

Once setup is complete, you'll have:
- ✅ Backend API running on localhost:8000
- ✅ iOS app building in Xcode
- ✅ Live preview canvas in Xcode
- ✅ iOS Simulator with app running
- ✅ VS Code editing both backend and iOS code
- ✅ Full development environment ready

**All systems go! 🚀**
