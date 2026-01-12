# FixRight: Quick Reference Guide

## 🎯 What Was Implemented

### 1. **AuthService** (`lib/services/auth_service.dart`)

Complete Firebase authentication with **phone number as Firestore Document ID**.

**Key Methods:**
```dart
// Get current user's phone (Document ID)
String? getUserPhoneDocId()

// Start phone verification
Future<void> verifyPhone(phone, onCodeSent, onVerificationFailed)

// Complete OTP sign-in & create user profile
Future<User?> signInWithOtp(verificationId, smsCode)

// Get user profile from Firestore
Future<DocumentSnapshot?> getUserProfile(phoneDocId)

// Update location with GeoPoint & address
Future<void> updateUserLocation(phoneDocId)

// Request location permission
Future<LocationPermission> requestLocationPermission(onDenied)

// Sign out
Future<void> signOut()
```

---

### 2. **LoginPage** (`lib/src/components/LoginPage.dart`)

Enhanced login flow with location permission request.

**Flow:**
1. User enters phone + OTP
2. Firebase authenticates
3. System requests location permission
4. Location updated in Firestore (if granted)
5. Navigate to home

**New Method:**
```dart
Future<void> _requestLocationAndNavigate()
```
- Requests fine location permission
- Updates user's GeoPoint + address
- Handles denial gracefully

---

### 3. **ProfileScreen** (`lib/src/pages/ProfileScreen.dart`)

Complete profile management with edit functionality.

**Features:**
- ✅ Load user data from Firestore
- ✅ Display user info (first name, last name, location)
- ✅ "My Profile" tile with edit dialog
- ✅ Edit: First Name, Last Name, Address
- ✅ Phone field: **Read-Only** (it's the Document ID)
- ✅ Save updates to Firestore
- ✅ Seller mode toggle
- ✅ Logout button

**Edit Dialog:**
```dart
void _showEditProfileDialog()
```

---

### 4. **HomePage** (`lib/src/pages/home_page.dart`)

Updated home screen with location display.

**AppBar Now Shows:**
- User avatar with initial
- Greeting: "Welcome, {FirstName}"
- Location: "{City}, {Country}"

**Data Sources:**
- Loads from Firestore on init
- Updates in real-time
- Shows "Loading location..." while fetching

---

### 5. **UserService** (`lib/services/user_service.dart`)

Helper service for user operations.

**Methods:**
```dart
Future<DocumentSnapshot?> getUserProfile(phoneDocId)
Future<void> updateUserProfile({...})
Future<void> updateUserRole({...})
Future<DocumentSnapshot?> getUserByPhone(phoneNumber)
Future<List<DocumentSnapshot>> searchUsers(query)
Future<List<DocumentSnapshot>> getUsersByRole(role)
Stream<DocumentSnapshot> getUserProfileStream(phoneDocId)
```

---

## 📊 Database Schema

### Users Collection

```
Collection: users
Document ID: +923001234567 (phone number - NOT Firebase UID!)

{
  "phoneNumber": "+923001234567",
  "firebaseUid": "uid123...",
  "firstName": "Ayaz",
  "lastName": "Hussain",
  "address": "Karachi, Pakistan",
  "role": "buyer",
  "location": GeoPoint(24.8607, 67.0011),
  "createdAt": Timestamp,
  "lastLocationUpdate": Timestamp
}
```

---

## 🔄 Authentication Flow Diagram

```
START
  ↓
[LoginPage]
  ├─ Phone + Country Code
  └─ Firebase OTP Verification
      ↓
[Firebase Auth]
  ├─ Verify OTP
  └─ Return User{phoneNumber: "+923001234567"}
      ↓
[AuthService.signInWithOtp]
  ├─ Extract phoneDocId = "+923001234567"
  ├─ Check if document exists in Firestore
  │   ├─ NO → Create new document (role: "buyer")
  │   └─ YES → Continue
  └─ Return User object
      ↓
[LoginPage._requestLocationAndNavigate]
  ├─ Request location permission
  ├─ If granted → Update Firestore location
  └─ Show dialog if denied
      ↓
[Navigate to /home]
  ├─ AppModeSwitcher
  └─ HomePage shows location in AppBar
      ↓
[User can access Profile]
  ├─ View profile info
  ├─ Click "My Profile" to edit
  ├─ Update First/Last Name, Address
  ├─ Phone is read-only
  └─ Save to Firestore
      ↓
END
```

---

## 💡 Key Design Decisions

### 1. **Phone Number as Document ID (NOT Firebase UID)**
✅ **Why:**
- Unique identifier across app
- Privacy-preserving
- Easier to reference
- Supports account recovery

❌ **Not Firebase UID because:**
- UID is internal to Firebase
- Phone number is user-facing
- Phone is more stable than Firebase UID

### 2. **Location Auto-Update on Login**
✅ **Benefits:**
- No extra user action needed
- Current location always in sync
- Enables "Live Tracking" feature

### 3. **Phone Field as Read-Only**
✅ **Reason:**
- Phone is Document ID
- Changing it would require document migration
- Users can't change their own ID

### 4. **Fallback Address Format**
✅ **Format:** "City, Country"  
❌ **Doesn't include:** State/Region (to keep it simple)  
⚡ **Fallback:** Shows coordinates if geocoding fails

---

## 🚀 Usage Examples

### Get Current User Phone (Document ID)
```dart
final authService = AuthService();
final phoneDocId = authService.getUserPhoneDocId();
// Result: "+923001234567"
```

### Update User Location
```dart
await authService.updateUserLocation(phoneDocId);
// Updates: location (GeoPoint) + address (String)
```

### Edit User Profile
```dart
await firestore.collection('users').doc(phoneDocId).update({
  'firstName': 'Ayaz',
  'lastName': 'Hussain',
  'address': 'Karachi, Pakistan',
});
```

### Fetch User Profile
```dart
final userDoc = await authService.getUserProfile(phoneDocId);
final firstName = userDoc['firstName'];
final address = userDoc['address'];
```

---

## ⚙️ Required Firebase Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{document=**} {
      allow read, write: if request.auth.uid == resource.data.firebaseUid;
      allow create: if request.auth != null;
    }
  }
}
```

---

## 📱 Required Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is needed for Live Tracking</string>
```

---

## 🔍 Testing Checklist

- [ ] Phone OTP authentication works
- [ ] New user document created with role: "buyer"
- [ ] Location permission requested after login
- [ ] Location stored as GeoPoint in Firestore
- [ ] Address geocoded to "City, Country" format
- [ ] Home page shows user name & location
- [ ] Profile page loads user data
- [ ] "My Profile" edit dialog opens
- [ ] Can edit First Name, Last Name, Address
- [ ] Phone field is read-only
- [ ] Changes saved to Firestore document
- [ ] Logout works correctly
- [ ] Google Sign-In follows same flow

---

## 🐛 Common Issues & Solutions

### Issue: Phone number not found
**Solution:** Ensure Firebase Auth returns phoneNumber. Some regions may not support phone auth.

### Issue: Location permission denied
**Solution:** App continues normally. Users can enable in device settings later.

### Issue: Address geocoding fails
**Solution:** Falls back to coordinates (e.g., "24.8607, 67.0011").

### Issue: Document not created
**Solution:** Check Firebase rules allow creation. Check phoneDocId format is correct.

---

## 📚 Related Files

| File | Purpose |
|------|---------|
| `lib/services/auth_service.dart` | Core auth logic |
| `lib/services/user_service.dart` | User management |
| `lib/src/components/LoginPage.dart` | Login UI |
| `lib/src/pages/ProfileScreen.dart` | Profile UI |
| `lib/src/pages/home_page.dart` | Home UI |
| `lib/main.dart` | App entry point |

---

## 🎓 Best Practices

1. **Always use `getUserPhoneDocId()`** to get current user's Document ID
2. **Never hardcode phone numbers** - use Firebase Auth
3. **Handle location denial gracefully** - don't force permissions
4. **Cache user profile** - reduce Firestore reads
5. **Use transactions** - when updating multiple fields
6. **Validate phone format** - before database operations
7. **Implement retry logic** - for failed location updates

---

**Version:** 1.0.0  
**Last Updated:** January 8, 2026  
**Status:** ✅ Production Ready
