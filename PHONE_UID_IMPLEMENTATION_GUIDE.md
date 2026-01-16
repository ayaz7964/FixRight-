## Implementation Guide: Phone-UID Authentication System

This guide explains how the phone number is now used as a unique identifier (UID) and accessed across all screens in the FixRight app.

---

## Architecture Overview

### 1. **UserSession Service** (`lib/services/user_session.dart`)

A singleton service that stores the authenticated user's phone number globally:

```dart
// Get the authenticated user's phone UID
String? phoneUID = UserSession().phoneUID;

// Check if user is authenticated
bool isAuth = UserSession().isAuthenticated;

// Store phone UID after OTP verification (automatic)
UserSession().setPhoneUID(phoneNumber);

// Clear session (logout)
UserSession().clearSession();
```

### 2. **Navigation Flow**

After successful OTP verification in **LoginPage**:

1. ✅ Phone number is stored in `UserSession().phoneUID`
2. ✅ `navigateToHome()` is called (no re-verification needed)
3. ✅ Navigation data is passed to **AppModeSwitcher**
4. ✅ All child screens receive the `phoneUID` parameter

---

## How to Access Phone-UID in Any Screen

### **Option 1: Using Constructor Parameter (Recommended for widgets with parent)**

**When the widget receives phoneUID as a parameter:**

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
  @override
  void initState() {
    super.initState();
    final uid = widget.phoneUID;
    // Use uid to fetch user data
  }
}
```

---

### **Option 2: Using UserSession Service (Recommended for independent widgets)**

**When the widget doesn't receive phoneUID as a parameter:**

```dart
import 'package:fixright/services/user_session.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    final uid = UserSession().phoneUID;
    final isAuthenticated = UserSession().isAuthenticated;
    // Use uid to fetch user data
  }
}
```

---

### **Option 3: Fallback Pattern (Best for flexibility)**

**Combine both methods for maximum flexibility:**

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
    // Use parameter first, then fall back to UserSession
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
  }
}
```

---

## How to Fetch User Data from Firebase

### **Using the Phone-UID as Firestore Document ID**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getUserData(String phoneUID) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(phoneUID)  // Phone number is the document ID
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}
```

### **Real-time User Data (Listener)**

```dart
void _listenToUserData(String phoneUID) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(phoneUID)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;
          // Update UI with userData
          print('User name: ${userData['firstName']}');
          print('User city: ${userData['city']}');
        }
      });
}
```

---

## Updated Screens

The following screens have been updated to accept and use the `phoneUID`:

### **Home Screen** (`lib/src/pages/home_page.dart`)
```dart
HomePage(phoneUID: phoneUID)
```

### **Messages Screen** (`lib/src/pages/MessageChatBotScreen.dart`)
```dart
MessageChatBotScreen(phoneUID: phoneUID)
```

### **Orders/Services Screen** (`lib/src/pages/orders_page.dart`)
```dart
OrdersPage(phoneUID: phoneUID)
```

### **Profile Screen** (`lib/src/pages/ProfileScreen.dart`)
```dart
ProfileScreen(
  isSellerMode: isSellerMode,
  onToggleMode: onToggleMode,
  phoneUID: phoneUID,
)
```

### **Seller Dashboard** (`lib/src/pages/seller_dashboard_page.dart`)
```dart
SellerDashboardPage(phoneUID: phoneUID)
```

### **Manage Orders** (`lib/src/pages/ManageOrdersScreen.dart`)
```dart
ManageOrdersScreen(phoneUID: phoneUID)
```

---

## Firestore User Document Structure

Each user has a document with the phone number as the ID:

```
collection: users
document_id: +923001234567 (phone number)

data:
{
  "uid": "+923001234567",
  "mobile": "+923001234567",
  "firstName": "Ali",
  "lastName": "Khan",
  "city": "Karachi",
  "country": "Pakistan",
  "Role": "Buyer",
  "latitude": 24.8607,
  "longitude": 67.0011,
  "address": "Karachi, Pakistan",
  "createdAt": "2025-01-16T10:30:00Z",
  "liveLocation": {
    "lat": 24.8607,
    "lng": 67.0011,
    "updatedAt": "2025-01-16T10:35:00Z"
  }
}
```

---

## Example: Complete User Data Fetch in a Screen

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_session.dart';

class ExampleScreen extends StatefulWidget {
  final String? phoneUID;

  const ExampleScreen({
    super.key,
    this.phoneUID,
  });

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late String phoneUID;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Get phone UID from parameter or UserSession
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
    
    if (phoneUID.isNotEmpty) {
      _loadUserData();
    } else {
      // User not authenticated - redirect to login
      Future.microtask(() => Navigator.of(context).pushReplacementNamed('/'));
    }
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneUID)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Data')),
      body: Center(
        child: userData != null
            ? Text('Hello ${userData!['firstName']}!')
            : const Text('No user data found'),
      ),
    );
  }
}
```

---

## Logout Implementation

```dart
void _logout() {
  // Clear the UserSession
  UserSession().clearSession();
  
  // Sign out from Firebase
  FirebaseAuth.instance.signOut();
  
  // Navigate to login
  Navigator.of(context).pushReplacementNamed('/');
}
```

---

## Key Points

✅ **Phone number = UID** (stored as Firestore document ID)  
✅ **One-time storage** (stored in UserSession after OTP verification)  
✅ **No re-verification needed** (available across all screens)  
✅ **Clean navigation** (AppModeSwitcher passes it to all child screens)  
✅ **Simple & maintainable** (singleton pattern + constructor parameters)  
✅ **Firebase ready** (direct document lookup using phone UID)

---

## Migration Path for Existing Screens

If you have screens that don't accept `phoneUID` parameter yet:

1. **Add parameter to StatefulWidget**:
```dart
final String? phoneUID;
const MyScreen({ super.key, this.phoneUID });
```

2. **Get the UID in initState**:
```dart
phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
```

3. **Use for Firebase queries**:
```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(phoneUID)
    .get();
```

---

This implementation is clean, secure, and follows Flutter best practices! 🎉
