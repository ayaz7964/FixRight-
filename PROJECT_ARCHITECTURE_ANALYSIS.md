# 🏗️ FIXRIGHT PROJECT - COMPLETE ARCHITECTURE & FLOW ANALYSIS

## 📋 Executive Summary

**FixRight** is a Flutter-based service marketplace app with:
- **Phone-based Authentication** using Firebase Auth OTP
- **Location-based Services** for provider discovery
- **Real-time Presence System** for user availability tracking
- **Role-based System** (Buyer/Seller)
- **Live Location Tracking** for service providers
- **Chat & Messaging System** for client-provider communication

---

## 🎯 PROJECT STRUCTURE

```
fixright/
├── lib/
│   ├── main.dart                          # App entry point, routing setup
│   ├── firebase_options.dart              # Firebase configuration
│   ├── services/                          # Business logic & data services
│   │   ├── auth_service.dart              # Authentication logic
│   │   ├── user_session.dart              # Global user session manager
│   │   ├── user_presence_service.dart     # Online/offline status tracking
│   │   ├── user_service.dart              # User profile CRUD operations
│   │   ├── chat_service.dart              # Messaging functionality
│   │   ├── location_service.dart          # Location handling
│   │   ├── profile_service.dart           # Profile management
│   │   ├── profile_image_service.dart     # Image profile handling
│   │   ├── translation_service.dart       # Language translation
│   │   └── other services...
│   ├── src/
│   │   ├── components/
│   │   │   ├── LoginPage.dart             # Login/Phone auth UI
│   │   │   ├── SIgnupPage.dart            # Signup (currently commented)
│   │   │   ├── HomeSearchBar.dart
│   │   │   └── other components...
│   │   ├── pages/
│   │   │   ├── home_page.dart             # Main home screen
│   │   │   ├── app_mode_switcher.dart     # Role switcher (Buyer/Seller)
│   │   │   ├── ChatListScreen.dart
│   │   │   ├── ProfileScreen.dart
│   │   │   ├── SellerDirectoryScreen.dart
│   │   │   └── other pages...
│   │   ├── widgets/                       # Reusable UI components
│   │   └── models/                        # Data models
└── assets/                                 # Images, fonts, etc.
```

---

## 🔐 AUTHENTICATION FLOW (COMPLETE)

### 🎯 login_page.dart → auth_service.dart → Firebase Auth

```
┌─────────────────────────────────────────────────────────────────┐
│                     LOGIN PAGE FLOW                               │
└─────────────────────────────────────────────────────────────────┘

STEP 1: SELECT COUNTRY & ENTER PHONE NUMBER
┌─────────────────────────────────┐
│ User Selects Country (Default: PK)
│ - Uses country_picker package
│ - Gets: Country code, Phone code
│ - Example: PK = +92
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ User Enters Phone Number
│ - Validates: not empty
│ - Format: Combined with country code
│ - Example: +923001234567
└──────────────┬──────────────────┘
               │
               ▼

STEP 2: SEND OTP (_verifyPhone)
┌─────────────────────────────────────────────────────────┐
│ _verifyPhone() Method
│ ├─ Validates phone input
│ ├─ Creates full phone: '+${countryCode}${phoneNumber}'
│ └─ Calls: FirebaseAuth.verifyPhoneNumber()
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│ Firebase.verifyPhoneNumber() - 4 Callbacks:
│
│ 1️⃣  verificationCompleted (AUTO SIGN-IN)
│    └─ Rare: Signs in if SIM matches
│
│ 2️⃣  verificationFailed (ERROR HANDLING)
│    └─ Invalid phone number
│    └─ Too many requests
│    └─ Network error
│
│ 3️⃣  codeSent ✅ (SUCCESS - OTP SENT)
│    ├─ Gets: verificationId (temporary token)
│    ├─ Storage: setState → verificationId variable
│    ├─ UI: Switch to OTP entry screen (codeSent = true)
│    └─ User receives SMS with 6-digit code
│
│ 4️⃣  codeAutoRetrievalTimeout
│    └─ Called when OTP expires (auto-retrieval fails)
└──────────────┬──────────────────────────────────────────┘
               │
               ▼

STEP 3: ENTER RECEIVED OTP
┌─────────────────────────────────────────────┐
│ OTP Entry Screen (if codeSent == true)
│ ├─ Uses Pinput widget (6-digit input UI)
│ ├─ TextEditingController: _otpController
│ └─ Example: User enters: 123456
└──────────────┬──────────────────────────────┘
               │
               ▼

STEP 4: VERIFY OTP (_verifyOTP)
┌──────────────────────────────────────────────────────────┐
│ _verifyOTP() Method:
│ ├─ Validates: OTP length == 6
│ ├─ Creates credential using:
│ │  ├─ verificationId (from codeSent callback)
│ │  └─ smsCode (user's OTP input)
│ │
│ └─ Calls: PhoneAuthProvider.credential()
│    └─ Then: _auth.signInWithCredential()
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│ FIREBASE AUTH: signInWithCredential()
│ ├─ Verifies OTP with Firebase backend
│ ├─ Creates/Updates Firebase Auth user
│ ├─ Sets: FirebaseAuth.instance.currentUser
│ └─ Phone number = Firebase UID (auto-set)
└──────────────┬───────────────────────────────────────────┘
               │
               ▼

STEP 5: CHECK USER & NAVIGATE (checkUserAndNavigate)
┌──────────────────────────────────────────────────────────┐
│ checkUserAndNavigate() Method:
│
│ 1. Get Firebase currentUser
│    └─ phoneNumber = user.phoneNumber!
│
│ 2. Store globally in UserSession:
│    └─ UserSession().setPhoneUID(phoneNumber)
│
│ 3. Check if user exists in Firestore:
│    └─ Query: users collection → doc(phoneNumber)
│
│ ├─ IF USER EXISTS (Login path):
│ │  ├─ _startLiveLocationTracking(uid)
│ │  └─ Navigate to /home
│ │
│ └─ IF USER NOT EXISTS (Signup path):
│    └─ createNewUser(uid)
└──────────────┬───────────────────────────────────────────┘
               │
               ▼

STEP 6A: EXISTING USER → LOGIN
┌──────────────────────────────────────────────────────────┐
│ _startLiveLocationTracking(uid)
│ ├─ Starts continuous location updates
│ ├─ Listens to: Geolocator.getPositionStream()
│ ├─ Updates Firestore every 10m or interval:
│ │  └─ users/{uid}/liveLocation
│ └─ Runs until app closes
│
│ THEN: _navigateToHome(uid)
│ ├─ Initializes UserPresenceService
│ ├─ Sets user online in Firestore
│ ├─ Navigates to /home route
│ └─ User enters main app ✅
└──────────────────────────────────────────────────────────┘

STEP 6B: NEW USER → SIGNUP
┌──────────────────────────────────────────────────────────┐
│ createNewUser(uid)
│
│ 1. Request Location Permission
│    ├─ Geolocator.checkPermission()
│    └─ If denied: Geolocator.requestPermission()
│
│ 2. Get Current Location (if permitted)
│    ├─ Geolocator.getCurrentPosition()
│    └─ Returns: latitude, longitude
│
│ 3. Convert to Human-Readable Address
│    ├─ placemarkFromCoordinates()
│    ├─ Extract: city, country
│    └─ Fallback: "Unknown City"
│
│ 4. Create Firestore User Document
│    └─ users/{uid}.set({
│       ├─ uid: '+923001234567'
│       ├─ mobile: '+923001234567'
│       ├─ firstName: 'User'
│       ├─ lastName: 'Account'
│       ├─ city: 'Karachi'
│       ├─ country: 'Pakistan'
│       ├─ latitude, longitude
│       ├─ profileUrl: 'uploading Picture'
│       ├─ Role: 'Buyer' (default)
│       └─ createdAt: server timestamp
│    })
│
│ 5. Start Live Location Tracking
│    └─ _startLiveLocationTracking(uid)
│
│ THEN: Navigate to /home ✅
└──────────────────────────────────────────────────────────┘
```

---

## 🔑 KEY SERVICE CLASSES

### 1️⃣ AuthService (auth_service.dart)

```dart
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // 🔐 Core Methods:
  verifyPhone()              // Send OTP
  signInWithOtp()            // Verify OTP & create user
  getUserPhoneDocId()        // Get phone as document ID
  getUserProfile()           // Fetch user from Firestore
  updateUserLocation()       // Update location & address
  initializeSellerProfile()  // Create seller doc
  signOut()                  // Logout (sets offline)
}
```

**Usage in LoginPage:**
```dart
final AuthService _authService = AuthService();
// Later: Used for getting user profile data
```

### 2️⃣ UserSession (user_session.dart)

```dart
class UserSession extends ChangeNotifier {
  // Singleton pattern - single instance
  static final UserSession _instance = UserSession._internal();

  String? _phoneUID;  // Stores phone number as UID

  // Methods:
  setPhoneUID(String phone)  // Store after login
  get phoneUID               // Retrieve anytime
  get isAuthenticated        // Check if logged in
  clearSession()             // Clear on logout
}
```

**Usage Pattern:**
```dart
// In LoginPage, after OTP verification:
UserSession().setPhoneUID(user.phoneNumber!);

// In any other page/service:
String? uid = UserSession().phoneUID;
```

### 3️⃣ UserPresenceService (user_presence_service.dart)

```dart
class UserPresenceService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Methods:
  initializePresence()       // Mark user online (on login)
  updatePresence(bool)       // Update online/offline
  setOfflineBeforeLogout()   // Mark offline (on logout)
  getUserPresenceStream()    // Real-time status stream
  isUserOnlineStream()       // Is user online stream
}
```

**Firestore Collection:**
```
userPresence/
├─ +923001234567           (Document ID = Phone number)
│  ├─ isOnline: true
│  ├─ lastSeen: 2024-02-08 14:30:00
│  └─ updatedAt: 2024-02-08 14:30:00
└─ +923001234568
   └─ ...
```

### 4️⃣ UserService (user_service.dart)

```dart
class UserService {
  final FirebaseFirestore _firestore;

  // Methods:
  getUserProfile()           // Fetch user by phone
  updateUserProfile()        // Update name, address
  updateUserRole()           // Change to seller
  getUserByPhone()
  searchUsers()
  getUsersByRole()
  createUserProfile()
  getUserProfileStream()     // Real-time updates
}
```

---

## 📱 FIRESTORE DATABASE STRUCTURE

### Users Collection

```
Firestore (Database) →
├─ users (Collection)
│  └─ +923001234567 (Document ID = Phone number)
│     ├─ uid: '+923001234567'              [String]
│     ├─ mobile: '+923001234567'           [String]
│     ├─ phoneNumber: '+923001234567'      [String]
│     ├─ firstName: 'Ahmed'                [String]
│     ├─ lastName: 'Khan'                  [String]
│     ├─ city: 'Karachi'                   [String]
│     ├─ country: 'Pakistan'               [String]
│     ├─ address: 'Gulshan-e-Iqbal'        [String]
│     ├─ latitude: 24.8407°                [Number]
│     ├─ longitude: 67.0011°               [Number]
│     ├─ role: 'buyer'                     [String] - 'buyer' or 'seller'
│     ├─ profileUrl: 'https://...'         [String]
│     ├─ ProfileImage: 'uploading Picture' [String]
│     ├─ liveLocation: {                   [Map]
│     │  ├─ lat: 24.8407
│     │  ├─ lng: 67.0011
│     │  └─ updatedAt: timestamp
│     ├─ location: GeoPoint(24.8407, 67)   [GeoPoint]
│     ├─ createdAt: timestamp              [Timestamp]
│     └─ lastLocationUpdate: timestamp     [Timestamp]
│
├─ sellers (Collection - For seller-specific data)
│  └─ +923001234567 (Document ID = Phone)
│     ├─ uid: '+923001234567'
│     ├─ Available_Balance: 0
│     ├─ Jobs_Completed: 5
│     ├─ Earning: 5000
│     ├─ Total_Jobs: 10
│     ├─ Pending_Jobs: 2
│     ├─ Rating: 4.5
│     ├─ status: 'approved'  [none, submitted, approved]
│     ├─ comments: 'Great service'
│     ├─ createdAt: timestamp
│     └─ updatedAt: timestamp
│
└─ userPresence (Collection - For presence tracking)
   └─ +923001234567 (Document ID = Phone)
      ├─ isOnline: true
      ├─ lastSeen: timestamp
      └─ updatedAt: timestamp
```

---

## 🚀 COMPLETE LOGIN FLOW SEQUENCE

```
USER INTERACTION                 CODE EXECUTION                   FIRESTORE STATE
═══════════════════════════════════════════════════════════════════════════════════

1. App Opens
   └─ Shows LoginPage

2. User Sees:
   ├─ Country Picker (Default: Pakistan +92)
   ├─ Phone Input Field
   └─ "Send OTP" Button

3. User Actions:
   ├─ [Optional] Change Country
   ├─ Enter Phone: 3001234567
   └─ Click "Send OTP"
                                
                                └─ _verifyPhone() Called
                                   ├─ Validates phone input
                                   ├─ Creates: +923001234567
                                   └─ FirebaseAuth.verifyPhoneNumber()
                                      │
                                      ├─ Firebase validates
                                      └─ Sends SMS OTP
   ✅ User receives SMS
      with OTP code             └─ codeSent callback triggered
                                   ├─ Stores verificationId
                                   ├─ Sets codeSent = true
                                   └─ UI switches to OTP screen

4. UI Changes:
   └─ Shows:
      ├─ Pinput (6-digit OTP entry)
      ├─ "Verify OTP" Button
      └─ "Change Number" Button

5. User Actions:
   ├─ Enters Received OTP: 123456
   └─ Click "Verify OTP"
                                
                                └─ _verifyOTP() Called
                                   ├─ Validates OTP length = 6
                                   ├─ Creates PhoneAuthCredential
                                   └─ _auth.signInWithCredential()
                                      │
                                      └─ Firebase verifies OTP
                                         └─ Creates Auth User
                                            (phoneNumber auto-set)

6. User Authenticated! ✅
                                
                                └─ checkUserAndNavigate()
                                   ├─ Gets: currentUser.phoneNumber
                                   │  → +923001234567
                                   │
                                   ├─ Stores in UserSession:
                                   │  UserSession().setPhoneUID()
                                   │
                                   └─ Checks Firestore:
                                      users/{phoneNumber}
                                      exists?
                                      │
   ┌─────────────────────────────────┼─────────────────────────────┐
   │ EXISTS (Existing User)           │ NOT EXISTS (New User)         │
   │                                   │                              │
   │ ✅ LOGIN PATH                    │ 🆕 SIGNUP PATH               │
   ├─────────────────────────────────┼─────────────────────────────┤
   │                                   │                              │
   │ └─ _startLiveLocationTracking() │ └─ createNewUser()           │
   │    └─ Geolocator stream starts  │    ├─ Request location perm  │
   │       (updates liveLocation)    │    ├─ Get current position   │
   │                                   │    ├─ Reverse geocode       │
   │ └─ _navigateToHome()            │    ├─ Create Firestore doc   │
   │    ├─ Init UserPresenceService  │    │  └─ set({full user      │
   │    │  └─ Set isOnline: true     │    │     data, city,          │
   │    ├─ Navigate to /home         │    │     country, location})  │
   │    └─ Show HomePage   ✅         │    ├─ Start location track   │
   │                                   │    └─ _navigateToHome()     │
   │                                   │       └─ Navigate to /home ✅
   └─────────────────────────────────┴─────────────────────────────┘

7. Home Page Loads
   └─ HomePage._loadUserData()
      ├─ Gets UserSession.phoneUID
      ├─ Fetches profile from Firestore
      └─ Displays:
         ├─ User name greeting
         ├─ Location
         ├─ Profile image
         └─ Main content
```

---

## 🎛️ APP ROUTING (main.dart)

```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const LoginPage(),        // 🔐 Auth screen
    '/home': (context) => const AppModeSwitcher(), // 🏠 Main app
    '/signup': (context) => const SignupScreen(),  // 📝 Registration
  },
)
```

**Navigation Logic:**
- App starts → `/` (LoginPage)
- User not authenticated → Stays on `/`
- User authenticates → Navigates to `/home`
- User clicks signup button → Routes to `/signup`
- On logout → Returns to `/`

---

## 🌍 LOCATION SERVICES FLOW

### For **NEW USERS** (Signup)

```
createNewUser() →
├─ Check permission:
│  └─ Geolocator.checkPermission()
│
├─ If denied, request:
│  └─ Geolocator.requestPermission()
│
├─ If allowed, get position:
│  └─ Geolocator.getCurrentPosition(
│      desiredAccuracy: LocationAccuracy.high)
│     ├─ latitude: 24.8407
│     └─ longitude: 67.0011
│
├─ Convert to address:
│  └─ placemarkFromCoordinates(24.8407, 67.0011)
│     ├─ city: "Karachi"
│     └─ country: "Pakistan"
│
└─ Save to Firestore:
   users/{uid}.set({
   ├─ latitude: 24.8407
   ├─ longitude: 24.8407
   ├─ city: "Karachi"
   ├─ country: "Pakistan"
   └─ ...
   })
```

### For **LIVE LOCATION TRACKING**

```
_startLiveLocationTracking() →
├─ Geolocator.getPositionStream(
│  ├─ accuracy: LocationAccuracy.high
│  └─ distanceFilter: 10m  ← update every 10m movement
│
└─ .listen((Position position) {
   ├─ Every position update triggers:
   └─ Firestore.update({
      liveLocation: {
      ├─ lat: position.latitude
      ├─ lng: position.longitude
      └─ updatedAt: serverTimestamp()
      }
   })
   })
```

**Real-time Tracking:**
- ✅ Runs continuously after login
- ✅ Updates every 10 meters of movement
- ✅ Persists data in Firestore
- ✅ Used by other users to find nearby providers

---

## 👥 USER ROLES & PERMISSIONS

### **BUYER** (Default Role)

```
Initial Role: Buyer
├─ Can: Search services
├─ Can: Post jobs
├─ Can: Contact sellers
├─ Can: Chat with providers
└─ Location: Tracked in background
```

### **SELLER** (Upgraded Role)

```
To Become Seller:
├─ User has 'buyer' role initially
├─ Can apply to become seller
├─ Auth: initializeSellerProfile()
│  └─ Creates sellers/{uid} document
│     ├─ status: 'none' → 'submitted' → 'approved'
│     ├─ Available_Balance: 0
│     ├─ Jobs_Completed: 0
│     ├─ Earning: 0
│     ├─ Rating: 0
│     └─ ...financial fields
└─ Features: Job listings, earnings, ratings

Status Values:
├─ 'none' = Not applied
├─ 'submitted' = Application pending
└─ 'approved' = Seller verified
```

---

## 🔄 USER PRESENCE SYSTEM

### Online/Offline Tracking

```
Timeline:
═════════

1. User Logs In
   └─ checkUserAndNavigate()
      └─ _navigateToHome()
         └─ UserPresenceService.initializePresence()
            └─ Firestore: userPresence/{phoneUID}.set({
               isOnline: true,
               lastSeen: timestamp
               })

2. App in Foreground
   └─ WidgetsBindingObserver detects AppLifecycleState.resumed
      └─ updatePresence(true)
         └─ Firestore update: isOnline: true

3. App in Background
   └─ WidgetsBindingObserver detects AppLifecycleState.paused
      └─ updatePresence(false)
         └─ Firestore update: isOnline: false

4. User Logs Out
   └─ AuthService.signOut()
      └─ UserPresenceService.setOfflineBeforeLogout()
         └─ Firestore update: isOnline: false
            └─ FirebaseAuth.signOut()
```

### Real-time Status Updates

```
Any page can listen to user status:

Stream<bool> onlineStatus = UserPresenceService()
  .isUserOnlineStream(userId);

onlineStatus.listen((isOnline) {
  // Update UI: Show online/offline indicator
});
```

---

## 🎨 LOGIN PAGE UI COMPONENTS

### State Variables

```dart
final FirebaseAuth _auth = FirebaseAuth.instance;
final AuthService _authService = AuthService();
final TextEditingController _phoneController;
final TextEditingController _otpController;

bool codeSent = false;          // Toggle UI between phone & OTP screens
String verificationId = '';     // Firebase temporary token
bool isLoading = false;         // Show loading spinner

// Selected country (default Pakistan)
Country selectedCountry = Country(
  phoneCode: '92',
  countryCode: 'PK',
  name: 'Pakistan',
  // ...
);
```

### UI Sections

#### Section 1: Phone Number Entry (if !codeSent)

```
┌──────────────────────────────┐
│ Select Country               │
│ 🇵🇰 Pakistan (+92)  ▼         │
│ [Opens country picker]       │
├──────────────────────────────┤
│ Phone Number                 │
│ [TextField: 3001234567]      │
├──────────────────────────────┤
│ [Send OTP Button - Blue]     │
│ (or spinner if isLoading)    │
└──────────────────────────────┘
```

#### Section 2: OTP Entry (if codeSent)

```
┌──────────────────────────────┐
│ Enter OTP                    │
│ [1] [2] [3] [4] [5] [6]     │
│             Pinput Widget    │
├──────────────────────────────┤
│ [Verify OTP Button - Green]  │
│ (or spinner if isLoading)    │
├──────────────────────────────┤
│ [Change Number Link]         │
└──────────────────────────────┘
```

---

## 📊 DATA FLOW DIAGRAM

```
┌──────────────────────┐
│   User (Phone)       │
│  - Selects Country   │
│  - Enters Number     │
│  - Enters OTP        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────┐
│    LoginPage (UI)                │
│  - _verifyPhone()                │
│  - _verifyOTP()                  │
│  - checkUserAndNavigate()        │
└──────────┬────────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  Firebase Auth                   │
│  - verifyPhoneNumber()           │
│  - signInWithCredential()        │
│  - Creates currentUser           │
└──────────┬────────────────────────┘
           │
           ├──────────┬──────────────┐
           │          │              │
           ▼          ▼              ▼
    ┌──────────┐ ┌──────────┐  ┌──────────────┐
    │ Firebase │ │  Cloud   │  │ UserSession  │
    │   Auth   │ │Firestore │  │   (Global)   │
    │  User    │ │  users   │  │  phoneUID    │
    │          │ │   docs   │  │  isAuth      │
    └──┬───────┘ └────┬─────┘  └──────────────┘
       │              │
       └──────┬───────┘
              │
              ▼
    ┌──────────────────────┐
    │  Presence Service    │
    │  - initializePresence│
    │  - Set: isOnline:true│
    │  - userPresence doc  │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │  Location Service    │
    │  _startLiveTracking()│
    │  getPositionStream() │
    │  Updates liveLocation│
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │   Navigation         │
    │   Route to: /home    │
    │   Show: HomePage     │
    └──────────────────────┘
```

---

## ⚡ KEY FEATURES IMPLEMENTED

✅ **Phone-based Authentication**
- OTP sent to phone
- 60-second verification timeout
- Auto-verification support
- Error handling for invalid numbers

✅ **User Session Management**
- Singleton pattern
- Global access to phoneUID
- Automatic authentication state tracking

✅ **Live Location Tracking**
- Continuous position updates
- 10-meter distance filter
- Reverse geocoding for addresses
- Permission handling

✅ **Presence Tracking**
- Real-time online/offline status
- Lifecycle-aware (foreground/background)
- Graceful logout handling
- Stream-based updates

✅ **Role-based System**
- Default: Buyer
- Upgrade to: Seller
- Seller dashboard with financials
- Approval workflow

✅ **Firestore Integration**
- Users collection with phone as UID
- Sellers collection for financials
- UserPresence collection for status
- GeoPoint support for locations

---

## 🚨 ERROR HANDLING

### Phone Verification Errors

```dart
// Invalid Phone Number
code: 'invalid-phone-number'
→ Show: "Invalid phone number"

// Too Many Attempts
code: 'too-many-requests'
→ Show: "Too many attempts. Try later."

// Network Error
→ Show: "Something went wrong"
```

### OTP Verification Errors

```dart
// Wrong OTP
code: 'invalid-verification-code'
→ Show: "Invalid OTP"

// OTP Expired
code: 'session-expired'
→ Show: "Code expired. Request new OTP"
```

### Location Errors

```dart
// Permission Denied
→ Continue with "Unknown City", "Unknown Country"

// Geocoding Failed
→ Use coordinates: "24.8407, 67.0011"

// Service Disabled
→ Use default location, show warning
```

---

## 🔗 IMPORTANT CONFIG FILES

### firebase_options.dart
- Firebase project configuration
- API keys and project IDs
- Platform-specific settings (Android, iOS, Web)

### .env
- API keys
- Environment variables
- Configuration secrets

### pubspec.yaml
- Dependencies listed:
  - `firebase_auth` - Authentication
  - `cloud_firestore` - Database
  - `geolocator` - Location
  - `geocoding` - Address conversion
  - `country_picker` - Country selection
  - `pinput` - OTP input UI
  - `image_picker` - Profile images
  - etc.

---

## 📚 SUMMARY OF CRITICAL INFORMATION

| Component | Purpose | Location |
|-----------|---------|----------|
| **AuthService** | Handle Firebase auth logic | `services/auth_service.dart` |
| **UserSession** | Global user state | `services/user_session.dart` |
| **UserPresenceService** | Online/offline tracking | `services/user_presence_service.dart` |
| **LoginPage** | Phone auth UI & flow | `src/components/LoginPage.dart` |
| **HomePage** | Main app interface | `src/pages/home_page.dart` |
| **AppModeSwitcher** | Role selector | `src/pages/app_mode_switcher.dart` |
| **Firebase Auth** | Phone OTP provider | Firebase Console |
| **Firestore DB** | User profiles & data | Firebase Console |

---

## 🎯 CURRENT AUTHENTICATION FLOW (VISUAL)

```
LOGIN_PAGE.dart
│
├─→ [UI: Country Selector + Phone Input]
│   └─→ User enters: Country (PK) + Phone (3001234567)
│
├─→ _verifyPhone()
│   └─→ FirebaseAuth.verifyPhoneNumber(phoneNumber: "+923001234567")
│
├─→ Firebase OTP Service
│   └─→ Sends SMS to device
│
├─→ [UI: OTP Pinput Entry]
│   └─→ User enters: 123456
│
├─→ _verifyOTP()
│   └─→ PhoneAuthProvider.credential(verificationId, smsCode)
│   └─→ _auth.signInWithCredential(credential)
│
├─→ Firebase Verification ✅
│   └─→ Creates currentUser with phoneNumber
│
├─→ checkUserAndNavigate()
│   ├─→ Get phoneNumber from currentUser
│   ├─→ Store in UserSession (global)
│   └─→ Check if user exists in Firestore
│
├─→ IF EXISTING USER:
│   ├─→ _startLiveLocationTracking()
│   └─→ _navigateToHome() → /home
│
└─→ IF NEW USER:
    ├─→ createNewUser()
    │  ├─→ Request location permission
    │  ├─→ Get latitude, longitude
    │  ├─→ Reverse geocode to city/country
    │  └─→ Create Firestore user document
    ├─→ _startLiveLocationTracking()
    └─→ _navigateToHome() → /home
```

This flow ensures seamless authentication while capturing user location and maintaining real-time presence tracking!

