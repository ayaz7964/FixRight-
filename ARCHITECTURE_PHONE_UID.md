# Phone-UID Architecture Diagram

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        FIXRIGHT APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    LOGIN FLOW                            │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  1. User enters phone number                             │   │
│  │  2. OTP sent to phone                                    │   │
│  │  3. User verifies OTP                                    │   │
│  │  4. Firebase validates OTP                               │   │
│  │  5. ✅ UserSession.setPhoneUID(phoneNumber)             │   │
│  │  6. Navigate to home                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              USERSESSION (SINGLETON)                     │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  ┌────────────────────────────────────────┐             │   │
│  │  │ phoneUID: "+923001234567"              │             │   │
│  │  │ isAuthenticated: true                  │             │   │
│  │  ├────────────────────────────────────────┤             │   │
│  │  │ • setPhoneUID(phoneNumber)             │             │   │
│  │  │ • clearSession()                       │             │   │
│  │  │ • notifyListeners()                    │             │   │
│  │  └────────────────────────────────────────┘             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           APP MODE SWITCHER                             │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  • Checks UserSession.isAuthenticated                   │   │
│  │  • Gets phoneUID from UserSession                       │   │
│  │  • Passes to main screens                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ↓                                    ↓                  │
│  ┌──────────────────────┐          ┌──────────────────────┐     │
│  │ CLIENT MAIN SCREEN   │          │ SELLER MAIN SCREEN   │     │
│  ├──────────────────────┤          ├──────────────────────┤     │
│  │ phoneUID: "..."      │          │ phoneUID: "..."      │     │
│  └──────────────────────┘          └──────────────────────┘     │
│           ↓                                    ↓                  │
│  ┌────┬────┬────┬────┐         ┌────┬────┬────┬────┐           │
│  │Home│Msg │Ord │Prof│         │Dash│Msg │Ord │Prof│           │
│  │    │    │    │ile │         │    │    │    │ile │           │
│  └────┴────┴────┴────┘         └────┴────┴────┴────┘           │
│   ↓    ↓    ↓    ↓              ↓    ↓    ↓    ↓               │
│  [phoneUID parameter passed to each screen]                     │
│                            ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        USERDATAHELPER UTILITY CLASS                      │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  getUserProfile(phoneUID)           → Firebase          │   │
│  │  getCurrentUserProfile()            → Firebase          │   │
│  │  streamCurrentUserProfile()         → Real-time         │   │
│  │  getUserFirstName(phoneUID)         → From Cache        │   │
│  │  updateUserProfile(phoneUID, data)  → Firebase          │   │
│  │  updateUserLiveLocation(phoneUID)   → Firebase          │   │
│  │  ... and 9+ more utility methods                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              FIREBASE FIRESTORE                          │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Collection: "users"                                     │   │
│  │  Document ID: "+923001234567" (phoneUID)                │   │
│  │  ├── uid: "+923001234567"                               │   │
│  │  ├── firstName: "Ali"                                   │   │
│  │  ├── lastName: "Khan"                                   │   │
│  │  ├── city: "Karachi"                                    │   │
│  │  ├── country: "Pakistan"                                │   │
│  │  ├── Role: "Buyer" / "Seller"                           │   │
│  │  ├── liveLocation: { lat, lng, updatedAt }             │   │
│  │  └── ... other user fields                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Access Patterns

### Pattern 1: Constructor Parameter (Primary)
```
Widget receives phoneUID as parameter
         ↓
Use in initState/build
         ↓
Access user data via UserDataHelper
```

### Pattern 2: UserSession Global (Fallback)
```
UserSession().phoneUID available globally
         ↓
Use in any method
         ↓
Access user data via UserDataHelper
```

### Pattern 3: Fallback Chain
```
widget.phoneUID 
    ↓ (if null)
UserSession().phoneUID
    ↓ (if null)
AuthService.getUserPhoneDocId()
    ↓ (if null)
default empty string (redirect to login)
```

---

## Navigation Tree

```
main.dart
└── FixRightApp
    └── MaterialApp
        ├── initialRoute: '/'
        ├── routes:
        │   ├── '/': LoginPage
        │   ├── '/home': AppModeSwitcher
        │   └── '/signup': SignupScreen
        └── navigatorObservers: [_RouteObserver]

AppModeSwitcher (checks authentication)
├── ClientMainScreen (phoneUID provided)
│   ├── HomePage (phoneUID)
│   ├── MessageChatBotScreen (phoneUID)
│   ├── OrdersPage (phoneUID)
│   └── ProfileScreen (phoneUID, isSellerMode, onToggleMode)
│
└── SellerMainScreen (phoneUID provided)
    ├── SellerDashboardPage (phoneUID)
    ├── MessageChatBotScreen (phoneUID)
    ├── ManageOrdersScreen (phoneUID)
    └── ProfileScreen (phoneUID, isSellerMode, onToggleMode)
```

---

## Class Diagram

```
┌─────────────────────────┐
│    UserSession          │
├─────────────────────────┤
│ - _phoneUID: String?    │
├─────────────────────────┤
│ + phoneUID              │
│ + isAuthenticated       │
│ + setPhoneUID()         │
│ + clearSession()        │
└─────────────────────────┘
         △
         │ (singleton)
         │
    used by all screens

┌────────────────────────────────────┐
│     UserDataHelper                 │
├────────────────────────────────────┤
│ - _firestore: FirebaseFirestore    │
├────────────────────────────────────┤
│ + getCurrentPhoneUID()              │
│ + getCurrentUserProfile()           │
│ + getUserProfile(phoneUID)          │
│ + streamCurrentUserProfile()        │
│ + updateUserProfile()               │
│ + getUserFirstName()                │
│ + isUserSeller()                    │
│ + updateUserRole()                  │
│ ... and more utility methods        │
└────────────────────────────────────┘
         △
         │ (static helper)
         │
    used by all screens to access Firebase

┌─────────────────────────────────┐
│  FirebaseFirestore Instance     │
├─────────────────────────────────┤
│  collection('users')             │
│    .doc(phoneUID)                │
│    .get()                         │
│    .set()                         │
│    .update()                      │
│    .snapshots()                   │
└─────────────────────────────────┘
```

---

## State Flow Diagram

```
┌─────────────┐
│   START     │
└──────┬──────┘
       │
       ↓
┌─────────────────────────────┐
│  App Initializes            │
│  main.dart → FixRightApp    │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│  initialRoute: '/'          │
│  → LoginPage                │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│  User enters phone number   │
│  and OTP verification       │
└──────┬──────────────────────┘
       │
       ↓ (OTP verified)
┌──────────────────────────────────────┐
│ UserSession.setPhoneUID("+923...")   │
│ [State stored in memory]             │
└──────┬───────────────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│  Navigate to '/home'        │
│  → AppModeSwitcher          │
└──────┬──────────────────────┘
       │
       ↓
┌──────────────────────────────────────┐
│  AppModeSwitcher checks:             │
│  UserSession.isAuthenticated == true │
└──────┬───────────────────────────────┘
       │ (authenticated)
       ├→ ClientMainScreen (pass phoneUID)
       │   or
       └→ SellerMainScreen (pass phoneUID)
           │
           ↓
       ┌──────────────────────────────┐
       │  Each child screen:          │
       │  - Receives phoneUID param   │
       │  - Loads user data           │
       │  - Displays content          │
       └──────────────────────────────┘
           │
           ↓ (logout)
       ┌──────────────────────────────┐
       │  UserSession.clearSession()  │
       │  Navigate to '/'             │
       │  → LoginPage                 │
       └──────────────────────────────┘
           │
           ↓
       ┌──────────────────────────────┐
       │  End of session              │
       │  [State cleared from memory] │
       └──────────────────────────────┘
```

---

## File Structure

```
lib/
├── main.dart                          [MODIFIED]
│
├── services/
│   ├── auth_service.dart              [EXISTING]
│   ├── user_session.dart              [NEW] ✨
│   ├── user_data_helper.dart          [NEW] ✨
│   └── user_service.dart              [EXISTING]
│
└── src/
    ├── components/
    │   └── LoginPage.dart             [MODIFIED]
    │
    └── pages/
        ├── app_mode_switcher.dart     [MODIFIED]
        ├── ClientMainSCreen.dart      [MODIFIED]
        ├── seller_main_screen.dart    [MODIFIED]
        ├── home_page.dart             [MODIFIED]
        ├── ProfileScreen.dart         [MODIFIED]
        ├── MessageChatBotScreen.dart  [MODIFIED]
        ├── orders_page.dart           [MODIFIED]
        ├── seller_dashboard_page.dart [MODIFIED]
        ├── ManageOrdersScreen.dart    [MODIFIED]
        └── ... other pages            [EXISTING]
```

---

## Sequence Diagram: Login to Home

```
User        LoginPage      UserSession    AppModeSwitcher    Firebase
  │             │               │                │               │
  │─ Phone   ──→│               │                │               │
  │  Number     │               │                │               │
  │             │─ OTP Send  ──────────────────────────────→    │
  │             │               │                │               │
  │─ OTP    ──→│               │                │               │
  │             │─ Verify    ──────────────────────────────→    │
  │             │               │                │    Verified   │
  │             │               │                │    ←─────────│
  │             │               │                │               │
  │             │─ setPhoneUID("+923...") ──→  │               │
  │             │               │ [stored]      │               │
  │             │               │               │               │
  │             │─ Navigate('/home')           │               │
  │             │                    ─────────→│               │
  │             │                               │               │
  │             │                    Check isAuthenticated     │
  │             │                               │               │
  │             │                               │─ phoneUID  ──│
  │             │                               │  from global  │
  │             │                               │               │
  │             │                               │─ Display Main Screen
  │             │                               │  with phoneUID
  │             │                               │               │
  │  ✅ Logged In and Ready to Use App
```

---

## Memory Model

```
┌────────────────────────────────────────┐
│         FLUTTER APP MEMORY             │
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────────┐ │
│  │    UserSession Instance          │ │
│  │  (Singleton - One instance)      │ │
│  │                                  │ │
│  │  _phoneUID = "+923001234567"     │ │
│  │  _isAuthenticated = true         │ │
│  │                                  │ │
│  │  Access from anywhere:           │ │
│  │  UserSession().phoneUID          │ │
│  │  UserSession().isAuthenticated   │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │   Widget State Memory            │ │
│  │  (Various screens/widgets)       │ │
│  │                                  │ │
│  │  HomePage:                       │ │
│  │   - widget.phoneUID = "..."      │ │
│  │   - userFirstName = "Ali"        │ │
│  │                                  │ │
│  │  ProfileScreen:                  │ │
│  │   - widget.phoneUID = "..."      │ │
│  │   - userData = {...}             │ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘
         │
         │ Firestore query
         ↓
┌────────────────────────────────────────┐
│      FIREBASE FIRESTORE (Cloud)        │
├────────────────────────────────────────┤
│                                        │
│  users/                                │
│  └── +923001234567/                    │
│      ├── firstName: "Ali"              │
│      ├── lastName: "Khan"              │
│      ├── city: "Karachi"               │
│      ├── country: "Pakistan"           │
│      ├── Role: "Buyer"                 │
│      └── ... more fields               │
│                                        │
└────────────────────────────────────────┘
```

---

## Key Design Patterns Used

1. **Singleton Pattern** - UserSession (one instance for entire app)
2. **Parameter Pattern** - phoneUID passed through widget tree
3. **Fallback Pattern** - Multiple sources for phoneUID (parameter → global → auth service)
4. **Observer Pattern** - NavigatorObserver for session management
5. **Stream Pattern** - UserDataHelper for real-time data
6. **Helper Pattern** - UserDataHelper for centralized Firebase operations

---

## Performance Considerations

```
✅ Minimal overhead
   - One singleton instance
   - No repeated database calls on init
   - Data cached in local widgets
   
✅ Efficient navigation
   - phoneUID passed as parameter (no lookup needed)
   - Direct Firestore queries (indexed by phoneUID)
   
✅ Real-time updates
   - Stream support for live data
   - Automatic UI updates on data change
   
✅ Memory efficient
   - phoneUID stored in memory (< 1KB)
   - Cleared on logout
```

---

This architecture ensures:
- ✅ Clean separation of concerns
- ✅ Easy data access from any screen
- ✅ No re-verification after login
- ✅ Scalable for future features
- ✅ Production-ready code
