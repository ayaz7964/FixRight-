# Quick Reference: Phone-UID Authentication

## 🚀 Quick Start

### 1. Get Current User's Phone UID
```dart
import 'package:fixright/services/user_session.dart';

final phoneUID = UserSession().phoneUID;
```

### 2. Get Current User's Profile
```dart
import 'package:fixright/services/user_data_helper.dart';

final profile = await UserDataHelper.getCurrentUserProfile();
print(profile?['firstName']); // "Ali"
```

### 3. Get Specific User Info
```dart
// Get user's first name
final name = await UserDataHelper.getUserFirstName(phoneUID);

// Get user's full name
final fullName = await UserDataHelper.getUserFullName(phoneUID);

// Get user's location
final location = await UserDataHelper.getUserLocation(phoneUID);

// Check if user is seller
final isSeller = await UserDataHelper.isUserSeller(phoneUID);
```

---

## 📝 Common Tasks

### Update User Profile
```dart
await UserDataHelper.updateCurrentUserProfile({
  'firstName': 'New Name',
  'city': 'Karachi',
});
```

### Stream Real-time User Data
```dart
UserDataHelper.streamCurrentUserProfile().listen((profile) {
  if (profile != null) {
    print('User name: ${profile['firstName']}');
  }
});
```

### Check Authentication
```dart
if (UserSession().isAuthenticated) {
  final uid = UserSession().phoneUID;
  // Proceed
}
```

### Update User Role
```dart
await UserDataHelper.updateUserRole(phoneUID, 'seller');
```

### Update Live Location
```dart
await UserDataHelper.updateUserLiveLocation(phoneUID, 24.8607, 67.0011);
```

---

## 📚 Available Helper Methods

### User Session
```dart
UserSession().phoneUID              // Get phone UID
UserSession().isAuthenticated       // Check if authenticated
UserSession().setPhoneUID(phone)    // Store phone UID
UserSession().clearSession()        // Logout
```

### User Data Helper
```dart
// Get data
UserDataHelper.getCurrentPhoneUID()
UserDataHelper.getCurrentUserProfile()
UserDataHelper.getUserProfile(phoneUID)
UserDataHelper.getUserFirstName(phoneUID)
UserDataHelper.getUserFullName(phoneUID)
UserDataHelper.getUserLocation(phoneUID)
UserDataHelper.getUserRole(phoneUID)
UserDataHelper.getUserContactNumber(phoneUID)
UserDataHelper.getUserLiveLocation(phoneUID)

// Stream data
UserDataHelper.streamCurrentUserProfile()

// Update data
UserDataHelper.updateUserProfile(phoneUID, updates)
UserDataHelper.updateCurrentUserProfile(updates)
UserDataHelper.updateUserRole(phoneUID, role)
UserDataHelper.updateUserLiveLocation(phoneUID, lat, lng)

// Utility
UserDataHelper.isUserSeller(phoneUID)
UserDataHelper.searchUsersByName(query)
UserDataHelper.logout()
```

---

## 🔄 Navigation Flow

```
OTP Verification Success
        ↓
UserSession.setPhoneUID() [Automatic]
        ↓
Navigate to Home (no re-verification!)
        ↓
All screens have access to phoneUID
```

---

## 💾 Where Data is Stored

**Firestore Collection**: `users`  
**Document ID**: `+923001234567` (phone number)

```dart
// Access in code
FirebaseFirestore.instance
    .collection('users')
    .doc(phoneUID)      // phoneUID is the document ID
    .get()
```

---

## ✅ Implementation Checklist

- [ ] UserSession service created ✓
- [ ] UserDataHelper service created ✓
- [ ] LoginPage stores phoneUID ✓
- [ ] AppModeSwitcher passes phoneUID ✓
- [ ] All screens accept phoneUID parameter ✓
- [ ] Home, Messages, Orders, Profile updated ✓
- [ ] Seller screens updated ✓
- [ ] Documentation created ✓

---

## 🎯 For New Screens

Add this to any new screen:

```dart
class MyScreen extends StatefulWidget {
  final String? phoneUID;

  const MyScreen({
    super.key,
    this.phoneUID,
  });

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late String phoneUID;

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
  }

  Future<void> _loadData() async {
    final profile = await UserDataHelper.getUserProfile(phoneUID);
    // Use profile data
  }
}
```

---

## 🔐 Security Notes

✅ Phone number is stored securely in UserSession (volatile - cleared on logout)  
✅ Firestore document ID is the phone number (no sensitive data exposed)  
✅ Navigation enforces authentication check at app entry  
✅ Session is cleared when user logs out

---

## 📞 Support

For detailed information, see:
- `PHONE_UID_IMPLEMENTATION_GUIDE.md` - Complete implementation details
- `PHONE_UID_CHANGES_SUMMARY.md` - List of all changes made

---

**Last Updated**: January 16, 2026
