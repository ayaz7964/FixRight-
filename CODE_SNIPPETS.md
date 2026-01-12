# FixRight: Code Snippets & Examples

## 📌 Common Implementation Patterns

### 1. Getting User's Phone Document ID (Anywhere in App)

```dart
import '../../services/auth_service.dart';

// In any widget
final authService = AuthService();
final phoneDocId = authService.getUserPhoneDocId();

if (phoneDocId != null) {
  // User is authenticated
  print('User phone (Document ID): $phoneDocId');
} else {
  // User not authenticated
  print('User not logged in');
}
```

---

### 2. Loading User Profile Data

```dart
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfileWidget extends StatefulWidget {
  @override
  State<MyProfileWidget> createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends State<MyProfileWidget> {
  final AuthService _authService = AuthService();
  
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String address = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final phoneDocId = _authService.getUserPhoneDocId();
      
      if (phoneDocId != null) {
        final userDoc = await _authService.getUserProfile(phoneDocId);
        
        if (userDoc != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          
          setState(() {
            firstName = data['firstName'] ?? '';
            lastName = data['lastName'] ?? '';
            phoneNumber = data['phoneNumber'] ?? '';
            address = data['address'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        Text('Name: $firstName $lastName'),
        Text('Phone: $phoneNumber'),
        Text('Address: $address'),
      ],
    );
  }
}
```

---

### 3. Updating User Profile

```dart
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateUserProfile({
  required String firstName,
  required String lastName,
  required String address,
}) async {
  final authService = AuthService();
  final phoneDocId = authService.getUserPhoneDocId();

  if (phoneDocId == null) {
    print('User not authenticated');
    return;
  }

  try {
    final firestore = FirebaseFirestore.instance;
    
    await firestore.collection('users').doc(phoneDocId).update({
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('Profile updated successfully');
  } catch (e) {
    print('Error updating profile: $e');
    rethrow;
  }
}
```

---

### 4. Display Location in App Bar

```dart
import '../../services/auth_service.dart';

class MyAppBar extends StatefulWidget {
  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userLocation = 'Loading...';
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final phoneDocId = _authService.getUserPhoneDocId();
      
      if (phoneDocId != null) {
        final userDoc = await _authService.getUserProfile(phoneDocId);
        
        if (userDoc != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          
          setState(() {
            userName = data['firstName'] ?? 'User';
            userLocation = data['address'] ?? 'Location unknown';
          });
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => userLocation = 'Location error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $userName'),
          Text(
            userLocation,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

---

### 5. Streaming User Data (Real-time Updates)

```dart
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveProfileWidget extends StatelessWidget {
  final UserService _userService = UserService();
  final String phoneDocId;

  LiveProfileWidget({required this.phoneDocId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getUserProfileStream(phoneDocId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User not found');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
        final address = data['address'] ?? '';

        return Column(
          children: [
            Text('Name: $firstName'),
            Text('Location: $address'),
          ],
        );
      },
    );
  }
}
```

---

### 6. Update User Location

```dart
import '../../services/auth_service.dart';

Future<void> updateUserLocationManually() async {
  final authService = AuthService();
  final phoneDocId = authService.getUserPhoneDocId();

  if (phoneDocId == null) {
    print('User not authenticated');
    return;
  }

  try {
    await authService.updateUserLocation(phoneDocId);
    print('Location updated successfully');
  } catch (e) {
    print('Error updating location: $e');
  }
}
```

---

### 7. Logout User

```dart
import '../../services/auth_service.dart';

Future<void> logoutUser(BuildContext context) async {
  final authService = AuthService();
  
  try {
    await authService.signOut();
    
    // Navigate to login
    Navigator.pushReplacementNamed(context, '/');
  } catch (e) {
    print('Error logging out: $e');
  }
}
```

---

### 8. Search Users by Name

```dart
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> searchServiceProviders(
    String searchQuery) async {
  final userService = UserService();
  
  try {
    final results = await userService.searchUsers(searchQuery);
    
    // Filter for sellers
    final sellers = results
        .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'seller')
        .toList();
    
    return sellers;
  } catch (e) {
    print('Error searching: $e');
    return [];
  }
}
```

---

### 9. Get All Sellers

```dart
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> getAllSellers() async {
  final userService = UserService();
  
  try {
    return await userService.getUsersByRole('seller');
  } catch (e) {
    print('Error fetching sellers: $e');
    return [];
  }
}
```

---

### 10. Switch User Role (Buyer ↔ Seller)

```dart
import '../../services/user_service.dart';

Future<void> switchUserRole({
  required String phoneDocId,
  required bool toSellerMode,
}) async {
  final userService = UserService();
  final newRole = toSellerMode ? 'seller' : 'buyer';

  try {
    await userService.updateUserRole(
      phoneDocId: phoneDocId,
      role: newRole,
    );

    print('Role switched to: $newRole');
  } catch (e) {
    print('Error switching role: $e');
  }
}
```

---

## 🔐 Authentication Examples

### Request Location Permission

```dart
import '../../services/auth_service.dart';

Future<void> requestLocationWithDialog() async {
  final authService = AuthService();

  try {
    await authService.requestLocationPermission(
      onDenied: () {
        print('User denied location permission');
        // Show custom dialog or message
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

---

### Phone OTP Sign-In Flow

```dart
import '../../services/auth_service.dart';

class PhoneAuthExample {
  final AuthService _authService = AuthService();
  String verificationId = '';

  // Step 1: Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _authService.verifyPhone(
        phoneNumber,
        codeSent: (verId) {
          verificationId = verId;
          print('OTP sent to $phoneNumber');
        },
        verificationFailed: (error) {
          print('Verification failed: ${error.message}');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOTP(String smsCode) async {
    try {
      final user = await _authService.signInWithOtp(
        verificationId,
        smsCode,
      );

      if (user != null) {
        print('User authenticated: ${user.phoneNumber}');
        // User is now logged in
        // Firestore document created with phone as ID
      }
    } catch (e) {
      print('OTP verification failed: $e');
    }
  }
}
```

---

## 📊 Firestore Query Examples

### Get User by Phone Number

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentSnapshot?> getUserByPhone(String phoneNumber) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(phoneNumber)
        .get();

    return doc.exists ? doc : null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

### Get All Users Created Today

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> getUsersCreatedToday() async {
  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs;
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
```

### Get Users Near Location

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> getUsersNearby({
  required double latitude,
  required double longitude,
  required double radiusInKm,
}) async {
  try {
    // Note: Firestore doesn't have native geo-distance queries
    // This is a simplified example
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .get();

    // Filter in code (or use a geohashing library)
    final nearby = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as GeoPoint?;

      if (location == null) return false;

      // Calculate distance (Haversine formula)
      // For now, just return all
      return true;
    }).toList();

    return nearby;
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
```

---

## 🎨 UI Examples

### Simple Edit Profile Dialog

```dart
void showEditDialog(BuildContext context) {
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save logic here
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
```

---

**Version:** 1.0.0  
**Last Updated:** January 8, 2026
