# FixRight Authentication, Location & Profile Implementation Guide

## 📋 Overview

This document details the complete implementation of Authentication, Location Services, and Profile Management for the FixRight Flutter app using Firebase and the specific database architecture with **phone number as Document ID**.

---

## 🔐 1. Authentication System

### Database Strategy (CRITICAL)

**Rule:** Do NOT use Firebase UID as Document ID.  
**Instead:** Use **formatted phone number** (e.g., `+923001234567`) as the unique Document ID in the `users` collection.

### Database Schema

```
Firestore Collection: users
Document ID: +923001234567 (formatted phone number)

{
  "phoneNumber": "+923001234567",        // Unique phone (also Document ID)
  "firebaseUid": "uid_from_firebase",    // Firebase UID for reference
  "firstName": "Ayaz",                   // Editable
  "lastName": "Hussain",                 // Editable
  "address": "Karachi, Pakistan",        // Editable, human-readable
  "role": "buyer",                       // Default: "buyer" | Alternative: "seller"
  "createdAt": "2024-01-08T10:00:00Z",  // Timestamp
  "location": {                          // GeoPoint
    "latitude": 24.8607,
    "longitude": 67.0011
  },
  "lastLocationUpdate": "2024-01-08T10:05:00Z"
}
```

### Authentication Flow

#### 1. **Phone OTP Authentication**
```
User enters phone → System adds country code → Firebase verifies OTP
    ↓
Firebase returns User object with phoneNumber field
    ↓
Extract formatted phoneNumber (e.g., "+923001234567")
    ↓
Check if document exists in Firestore with ID = phoneNumber
    ↓
If NO → Create new document with default role: "buyer"
If YES → Log user in
    ↓
Request location permissions
    ↓
Update user's location (GeoPoint + human-readable address)
    ↓
Navigate to AppModeSwitcher/Home
```

#### 2. **Google Sign-In Authentication**
- Similar flow, but Google provides different data
- Still extracts phoneNumber from Firebase Auth
- Same Firestore logic applies

### AuthService Implementation

**File:** `lib/services/auth_service.dart`

**Key Methods:**

1. **`verifyPhone(phone, onCodeSent, onVerificationFailed)`**
   - Initiates phone verification
   - Sends OTP to user's phone

2. **`signInWithOtp(verificationId, smsCode)`**
   - Completes OTP verification
   - Creates user document if not exists (role: "buyer")
   - Returns Firebase User object

3. **`getUserPhoneDocId()`**
   - Returns the current user's formatted phone number
   - Used as Document ID throughout the app

4. **`getUserProfile(phoneDocId)`**
   - Retrieves user data from Firestore using phone as ID
   - Returns DocumentSnapshot with user profile

5. **`updateUserLocation(phoneDocId)`**
   - Requests location permission with explanation
   - Gets current position
   - Converts coordinates to human-readable address using geocoding
   - Updates Firestore with GeoPoint and address

6. **`requestLocationPermission(onDenied)`**
   - Shows permission request dialog
   - Executes callback if permanently denied

### LoginPage Integration

**File:** `lib/src/components/LoginPage.dart`

**Key Changes:**
- Imports AuthService for proper database logic
- After successful OTP/Google sign-in, calls `_requestLocationAndNavigate()`
- Location request explains: "Location access is needed for Live Tracking"
- Gracefully handles location denial (user can enable later in settings)

---

## 📍 2. Location Services

### Location Permissions

**Dialog Message:**  
"Location access is needed for Live Tracking. You can enable it in settings."

### Workflow

1. **After Login:**
   - Request fine location permission
   - If granted: Update user's location in Firestore
   - If denied: Allow user to continue (can enable later)

2. **Location Data Stored:**
   - `location` (GeoPoint): Latitude & Longitude coordinates
   - `address` (String): Human-readable address (City, Country)
   - `lastLocationUpdate` (Timestamp): When location was last updated

3. **Address Resolution:**
   - Uses `geocoding` package
   - Converts GeoPoint coordinates to "City, Country" format
   - Fallback: Uses coordinates if geocoding fails

### Home Screen AppBar

**File:** `lib/src/pages/home_page.dart`

**Display:**
```
Avatar | "Welcome, FirstName"
       | "City, Country" (human-readable location)
```

**Features:**
- Loads user's first name from Firestore
- Displays current location (address)
- Updates on screen load
- Tapping location icon shows full address

---

## 👤 3. Profile Management

### Profile Screen Features

**File:** `lib/src/pages/ProfileScreen.dart`

#### "My Profile" Tile
- **Location:** Above "My FixRight" section, under "Account"
- **Action:** Opens edit dialog when tapped
- **Icon:** `Icons.person`

#### Edit Profile Dialog

**Fields:**
1. **First Name** - Text input, editable
2. **Last Name** - Text input, editable
3. **Address** - Text area (3 lines), editable
4. **Phone Number** - **Disabled/Read-Only** (it's the Document ID)

**Save Button:**
- Validates input
- Updates Firestore document (ID = phone number)
- Shows success message
- Closes dialog

### Firestore Updates

When saving profile:
```dart
await _firestore.collection('users').doc(phoneDocId).update({
  'firstName': newFirstName,
  'lastName': newLastName,
  'address': newAddress,
  // phoneNumber field is NOT updated (it's the Document ID)
});
```

### Profile Data Loading

- Loads on ProfileScreen initialization
- Retrieves data using `authService.getUserProfile(phoneDocId)`
- Displays user's initials in avatar if image unavailable
- Shows "Loading..." while fetching data

---

## 🔧 4. Implementation Files

### Core Services

#### `lib/services/auth_service.dart`
- Complete Firebase authentication logic
- Phone number as Document ID handling
- Location update functionality
- User profile CRUD operations

#### `lib/services/user_service.dart`
- User profile management
- Search functionality
- Role management
- Stream support for real-time updates

### UI Components

#### `lib/src/components/LoginPage.dart`
- Phone OTP + Google Sign-In UI
- Location permission request
- Error handling
- Navigation to home

#### `lib/src/pages/ProfileScreen.dart`
- User profile display
- Edit profile functionality
- Role switching (Buyer/Seller)
- Logout button

#### `lib/src/pages/home_page.dart`
- Home screen with user greeting
- Location display in AppBar
- Dynamic user data loading

---

## 📦 Dependencies Used

```yaml
firebase_core: ^4.2.0       # Firebase initialization
firebase_auth: ^6.1.1       # Phone OTP authentication
cloud_firestore: ^6.0.3     # Database with phone as ID
geolocator: ^10.1.0         # Location permissions & coordinates
geocoding: ^3.0.0           # Geocode coordinates to addresses
google_sign_in: ^6.1.5      # Google authentication
```

---

## ⚙️ Configuration Requirements

### Firebase Setup

1. Enable Phone Authentication in Firebase Console
2. Enable Google Sign-In
3. Create `users` collection (auto-created on first write)
4. Set Firestore security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{document=**} {
      // Users can read/write their own document
      allow read, write: if request.auth.uid == resource.data.firebaseUid;
      // Allow creation of new user documents
      allow create: if request.auth != null;
    }
  }
}
```

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Permissions (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is needed for Live Tracking</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Location access is needed for Live Tracking</string>
```

---

## 🔄 Complete User Journey

```
1. App Startup
   ↓
2. LoginPage displayed
   ↓
3. User enters phone + country code
   ↓
4. Firebase sends OTP → User enters OTP
   ↓
5. Phone verified → Firebase returns User with phoneNumber
   ↓
6. Extract: phoneDocId = user.phoneNumber (e.g., "+923001234567")
   ↓
7. Check Firestore: Does user document exist?
   ├─ NO → Create document with default role: "buyer"
   └─ YES → Continue
   ↓
8. Request location permission with dialog
   ├─ Granted → Update user's location in Firestore
   └─ Denied → Allow to continue (can enable later)
   ↓
9. Navigate to AppModeSwitcher/Home
   ↓
10. Home Screen shows:
    - User's first name in greeting
    - Current location (City, Country)
    ↓
11. User can access Profile tab to:
    - View profile info
    - Click "My Profile" to edit
    - Update First Name, Last Name, Address
    - Phone number is read-only (it's the Document ID)
    - Save changes to Firestore
```

---

## 🐛 Error Handling

### Location Permission Denied
- Show SnackBar: "Location access is needed for Live Tracking. You can enable it in settings."
- Allow user to continue app
- Location can be enabled later via system settings

### Firestore Operations
- All operations wrapped in try-catch
- Error messages logged to console
- User-friendly error messages in UI

### Phone Verification Failed
- Show error message from Firebase
- Allow user to retry
- Clear OTP form

---

## 📝 Notes

1. **Phone Number Format:** Firebase returns phone in format `+{countryCode}{number}`. This is used as Document ID.

2. **Security:** Each user can only edit their own document. Firebase UID is stored for reference but not used as Document ID.

3. **Location:** Updated whenever user logs in. Can be updated manually by changing address in profile.

4. **Role Change:** Initially set to "buyer". Users can switch to "seller" mode via toggle in Profile screen.

5. **Offline Support:** Consider adding Firestore offline persistence for better UX.

---

## 🚀 Future Enhancements

1. Real-time location tracking
2. Distance-based service recommendations
3. Seller ratings based on phone number
4. Automated address validation
5. Multiple address support
6. Profile verification system
7. Two-factor authentication

---

**Last Updated:** January 8, 2026  
**Version:** 1.0.0
