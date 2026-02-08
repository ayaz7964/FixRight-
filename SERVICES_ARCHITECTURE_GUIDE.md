# 🔧 SERVICES ARCHITECTURE - DEEP DIVE

## 📌 Overview

The **Services** layer handles all business logic and data operations. Each service is responsible for specific functionality:

```
┌─────────────────────────────────────────────────────────────┐
│                   SERVICES LAYER                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │ AuthService      │  │ UserSession      │               │
│  │ (Firebase Auth)  │  │ (Global State)   │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │ UserPresence     │  │ UserService      │               │
│  │ (Online Status)  │  │ (Profile CRUD)   │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │ LocationService  │  │ ChatService      │               │
│  │ (Geo Tracking)   │  │ (Messaging)      │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │ ImageService     │  │ ProfileService   │               │
│  │ (Cloudinary API) │  │ (Profile Data)   │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 AuthService (auth_service.dart)

### Purpose
Centralized authentication logic using Firebase Auth.

### Key Methods

#### 1. `verifyPhone()`

```dart
Future<void> verifyPhone(
  String phone, {
  required CodeSentCallback codeSent,
  required VerificationFailedCallback verificationFailed,
}) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phone,  // e.g., "+923001234567"
    verificationCompleted: (credential) async {
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (e) => verificationFailed(e),
    codeSent: (verificationId, _) => codeSent(verificationId),
    codeAutoRetrievalTimeout: (id) {},
    timeout: const Duration(seconds: 60),
  );
}
```

**Callbacks:**
- `CodeSentCallback`: Called when OTP is sent successfully
- `VerificationFailedCallback`: Called on verification errors

#### 2. `signInWithOtp()`

```dart
Future<User?> signInWithOtp(String verificationId, String smsCode) async {
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,   // From codeSent callback
    smsCode: smsCode,                 // User's 6-digit OTP
  );

  final userCredential = await _auth.signInWithCredential(credential);
  final user = userCredential.user;

  if (user != null && user.phoneNumber != null) {
    final phoneDocId = user.phoneNumber!;  // e.g., "+923001234567"

    // Check if user profile exists
    final userDoc = await _firestore.collection('users').doc(phoneDocId).get();

    if (!userDoc.exists) {
      // Create new user profile
      await _createUserProfile(phoneDocId, user);
    }
  }

  return user;
}
```

**Flow:**
1. Creates PhoneAuthProvider credential
2. Signs in to Firebase
3. Gets phone number from authenticated user
4. Checks if user profile exists in Firestore
5. Creates profile if new user
6. Returns User object

#### 3. `_createUserProfile()`

```dart
Future<void> _createUserProfile(String phoneDocId, User firebaseUser) async {
  await _firestore.collection('users').doc(phoneDocId).set({
    'phoneNumber': phoneDocId,
    'firebaseUid': firebaseUser.uid,
    'firstName': '',
    'ProfileImage': 'uploading Picture',
    'lastName': '',
    'address': '',
    'role': 'buyer',  // Default role
    'createdAt': FieldValue.serverTimestamp(),
    'location': null,  // GeoPoint for later
  }, SetOptions(merge: true));
}
```

#### 4. `updateUserLocation()`

```dart
Future<void> updateUserLocation(String phoneDocId) async {
  try {
    // Check and request permission
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocode to get address
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String addressString = '';
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final city = place.locality ?? '';
      final country = place.country ?? '';
      addressString = [city, country].where((s) => s.isNotEmpty).join(', ');
    }

    // Update Firestore
    await _firestore.collection('users').doc(phoneDocId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'address': addressString,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error updating location: $e');
    rethrow;
  }
}
```

#### 5. `initializeSellerProfile()`

```dart
Future<void> initializeSellerProfile(String uid) async {
  try {
    await _firestore.collection('sellers').doc(uid).set({
      'uid': uid,
      'Available_Balance': 0,
      'Jobs_Completed': 0,
      'Earning': 0,
      'Total_Jobs': 0,
      'Pending_Jobs': 0,
      'Deposit': 0,
      'withdrawal': 0,
      'Rating': 0,
      'status': 'none',  // 'none' | 'submitted' | 'approved'
      'comments': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } catch (e) {
    print('Error initializing seller profile: $e');
    rethrow;
  }
}
```

#### 6. `signOut()`

```dart
Future<void> signOut() async {
  try {
    // Mark user as offline before logging out
    final presenceService = UserPresenceService();
    await presenceService.setOfflineBeforeLogout();
  } catch (e) {
    print('Error updating presence on logout: $e');
    // Continue with logout even if presence update fails
  }

  // Sign out from Firebase Auth
  await _auth.signOut();
}
```

### Helper Methods

```dart
String? getUserPhoneDocId() {
  final user = _auth.currentUser;
  if (user?.phoneNumber != null) {
    return user!.phoneNumber;  // e.g., "+923001234567"
  }
  return null;
}

Future<bool> userProfileExists(String phoneDocId) async {
  try {
    final doc = await _firestore.collection('users').doc(phoneDocId).get();
    return doc.exists;
  } catch (e) {
    print('Error checking user profile: $e');
    return false;
  }
}

Future<DocumentSnapshot?> getUserProfile(String phoneDocId) async {
  try {
    final doc = await _firestore.collection('users').doc(phoneDocId).get();
    return doc.exists ? doc : null;
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
}
```

---

## 👤 UserSession (user_session.dart)

### Purpose
Global state management for authenticated user's phone ID (UID).

### Architecture: Singleton Pattern

```dart
class UserSession extends ChangeNotifier {
  // Single instance throughout app lifetime
  static final UserSession _instance = UserSession._internal();

  String? _phoneUID;  // Stores user's phone number

  // Private constructor - prevents instantiation
  UserSession._internal();

  // Factory constructor - returns singleton instance
  factory UserSession() {
    return _instance;
  }
```

### Why Singleton?

✅ **Single Source of Truth** - Only one phoneUID in entire app
✅ **Global Access** - Access from ANY page without passing parameters
✅ **Memory Efficient** - Single instance throughout app lifetime
✅ **State Consistency** - All pages see same state

### Methods

```dart
// Store phone UID after login
void setPhoneUID(String phoneNumber) {
  _phoneUID = phoneNumber;
  notifyListeners();  // Notify all listeners of change
}

// Get current user's phone UID
String? get phoneUID => _phoneUID;

// Check if user is authenticated
bool get isAuthenticated => _phoneUID != null;

// Clear session on logout
void clearSession() {
  _phoneUID = null;
  notifyListeners();
}
```

### Usage Examples

**In LoginPage (after OTP verification):**
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null && user.phoneNumber != null) {
  UserSession().setPhoneUID(user.phoneNumber!);
  // Now accessible everywhere!
}
```

**In HomePage (any other page):**
```dart
@override
void initState() {
  super.initState();
  final phoneUID = UserSession().phoneUID;
  if (phoneUID != null) {
    // Fetch user profile
    _loadUserData(phoneUID);
  }
}
```

**Check if authenticated:**
```dart
if (UserSession().isAuthenticated) {
  // User is logged in
}
```

---

## 🟢 UserPresenceService (user_presence_service.dart)

### Purpose
Real-time online/offline status tracking across app lifecycle.

### Firestore Collection

```
userPresence/
├─ +923001234567 (Document ID = Phone number)
│  ├─ isOnline: true
│  ├─ lastSeen: Timestamp(2024-02-08T14:30:00)
│  └─ updatedAt: Timestamp(2024-02-08T14:30:00)
└─ +923001234568
   └─ ... (other users)
```

### Key Methods

#### 1. `initializePresence()`

```dart
Future<void> initializePresence() async {
  try {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final phoneUID = currentUser.phoneNumber;
    if (phoneUID == null || phoneUID.isEmpty) return;

    // Create presence document with online status
    await _firestore
        .collection(_presenceCollection)
        .doc(phoneUID)
        .set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));

    print('Presence initialized for user: $phoneUID');
  } catch (e) {
    print('Error initializing presence: $e');
  }
}
```

**Called When:**
- User successfully logs in
- User navigates to home page

#### 2. `updatePresence(bool isOnline)`

```dart
Future<void> updatePresence(bool isOnline) async {
  try {
    final currentUser = _auth.currentUser;
    final phoneUID = currentUser?.phoneNumber;

    if (phoneUID == null || phoneUID.isEmpty) return;

    // Update presence document
    await _firestore
        .collection(_presenceCollection)
        .doc(phoneUID)
        .set({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));

    print('Presence updated: ${isOnline ? "Online" : "Offline"}');
  } catch (e) {
    print('Error updating presence: $e');
    // Silently fail - don't crash app
  }
}
```

**Called When:**
- App resumes (foreground) → updatePresence(true)
- App pauses (background) → updatePresence(false)
- App resumes from background → updatePresence(true)

#### 3. `setOfflineBeforeLogout()`

```dart
Future<void> setOfflineBeforeLogout() async {
  try {
    final currentUser = _auth.currentUser;
    final phoneUID = currentUser?.phoneNumber;

    if (phoneUID == null || phoneUID.isEmpty) return;

    // Set offline with current timestamp
    await _firestore
        .collection(_presenceCollection)
        .doc(phoneUID)
        .update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });

    print('User marked offline before logout: $phoneUID');
  } catch (e) {
    print('Error setting offline: $e');
    // Don't block logout even if presence update fails
  }
}
```

**Called When:**
- User clicks logout button
- Before calling FirebaseAuth.signOut()

#### 4. Stream Methods

```dart
// Get real-time presence of specific user
Stream<Map<String, dynamic>?> getUserPresenceStream(String userId) {
  return _firestore
      .collection(_presenceCollection)
      .doc(userId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        return snapshot.data();
      });
}

// Is user online stream (boolean)
Stream<bool> isUserOnlineStream(String userId) {
  return getUserPresenceStream(userId)
      .map((data) => data?['isOnline'] ?? false);
}
```

**Usage in UI:**
```dart
// Listen to user's online status
UserPresenceService()
  .isUserOnlineStream(userId)
  .listen((isOnline) {
    setState(() {
      userStatus = isOnline ? 'Online' : 'Offline';
    });
  });
```

### Integration with main.dart

```dart
class _FixRightAppState extends State<FixRightApp> with WidgetsBindingObserver {
  final UserPresenceService _presenceService = UserPresenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize if already logged in
    _initializePresenceIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // 🟢 App in foreground
        _presenceService.updatePresence(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // 🔴 App in background or closing
        _presenceService.updatePresence(false);
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceService.updatePresence(false);  // Mark offline
    super.dispose();
  }
}
```

**WidgetsBindingObserver tracks:**
- `resumed` = App in foreground → Online
- `paused` = App minimized → Offline
- `inactive` = Transitioning states → Offline
- `detached` = App closing → Offline
- `hidden` = Hidden but running → Offline

---

## 👥 UserService (user_service.dart)

### Purpose
Fetch and manage user profile data from Firestore.

### Methods

#### 1. `getUserProfile(String phoneDocId)`

```dart
Future<DocumentSnapshot?> getUserProfile(String phoneDocId) async {
  try {
    final doc = await _firestore
        .collection('users')
        .doc(phoneDocId)
        .get();
    return doc.exists ? doc : null;
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
}
```

**Used in:**
- HomePage to load user greeting & location
- ProfileScreen to display user data
- Any page needing user info

#### 2. `updateUserProfile()`

```dart
Future<void> updateUserProfile({
  required String phoneDocId,
  required String firstName,
  required String lastName,
  required String address,
}) async {
  try {
    await _firestore
        .collection('users')
        .doc(phoneDocId)
        .update({
          'firstName': firstName,
          'lastName': lastName,
          'address': address,
        });
  } catch (e) {
    print('Error updating profile: $e');
    rethrow;
  }
}
```

#### 3. `updateUserRole()`

```dart
Future<void> updateUserRole({
  required String phoneDocId,
  required String role,  // 'buyer' or 'seller'
}) async {
  try {
    await _firestore
        .collection('users')
        .doc(phoneDocId)
        .update({'role': role});
  } catch (e) {
    print('Error updating role: $e');
    rethrow;
  }
}
```

#### 4. `searchUsers(String query)`

```dart
Future<List<DocumentSnapshot>> searchUsers(String query) async {
  try {
    final results = await _firestore
        .collection('users')
        .where(
          'firstName',
          isGreaterThanOrEqualTo: query,
          isLessThan: '${query}z',
        )
        .limit(10)
        .get();
    return results.docs;
  } catch (e) {
    print('Error searching users: $e');
    return [];
  }
}
```

#### 5. `getUsersByRole(String role)`

```dart
Future<List<DocumentSnapshot>> getUsersByRole(String role) async {
  try {
    final results = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .limit(50)
        .get();
    return results.docs;
  } catch (e) {
    print('Error fetching users by role: $e');
    return [];
  }
}
```

#### 6. `getUserProfileStream(String phoneDocId)` - Real-time

```dart
Stream<DocumentSnapshot> getUserProfileStream(String phoneDocId) {
  return _firestore
      .collection('users')
      .doc(phoneDocId)
      .snapshots();  // Real-time updates
}
```

**Usage:**
```dart
UserService()
  .getUserProfileStream(phoneUID)
  .listen((snapshot) {
    final userData = snapshot.data() as Map<String, dynamic>;
    setState(() {
      firstName = userData['firstName'];
      location = userData['address'];
    });
  });
```

---

## 📍 LocationService (location_service.dart)

### Purpose
Manage location permissions, tracking, and geocoding.

### Key Operations

```dart
// Get current position
Future<Position> getCurrentPosition()

// Get position stream (continuous tracking)
Stream<Position> getPositionStream()

// Check/request permissions
Future<LocationPermission> checkPermission()
Future<LocationPermission> requestPermission()

// Convert coordinates to address
Future<String> getAddressFromCoordinates(lat, lng)

// Get city and country
Future<Map<String, String>> getCityCountry(lat, lng)
```

---

## 💬 ChatService (chat_service.dart)

### Purpose
Handle real-time messaging between users.

### Firestore Structure

```
messages/
├─ chatRooms/
│  └─ {conversationId}/
│     ├─ messages/ (subcollection)
│     │  ├─ {messageId}
│     │  │  ├─ senderId: "+923001234567"
│     │  │  ├─ receiverId: "+923001234568"
│     │  │  ├─ message: "Hello!"
│     │  │  ├─ timestamp: Timestamp
│     │  │  ├─ isRead: false
│     │  │  └─ ...
│     │  └─ ...
│     ├─ lastMessage: "Hello!"
│     ├─ lastMessageTime: Timestamp
│     └─ participants: [phoneUID1, phoneUID2]
```

---

## 🖼️ ImageService & ProfileImageService

### Purpose
Upload images to Cloudinary and store references in Firestore.

### Key Methods

```dart
// Upload image to Cloudinary
Future<String?> uploadToCloudinary(File image)

// Delete image from Cloudinary
Future<void> deleteFromCloudinary(String imageUrl)

// Update profile image in Firestore
Future<void> updateProfileImage(String phoneUID, String imageUrl)
```

---

## 🎯 SERVICE USAGE PATTERNS

### Pattern 1: Dependency Injection

```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final phoneUID = UserSession().phoneUID;
    final profile = await _userService.getUserProfile(phoneUID!);
    // Use profile data
  }
}
```

### Pattern 2: Stream Listening

```dart
UserPresenceService()
  .isUserOnlineStream(userId)
  .listen((isOnline) {
    setState(() {
      userStatus = isOnline ? 'Online' : 'Offline';
    });
  });
```

### Pattern 3: Error Handling

```dart
try {
  await _authService.updateUserLocation(phoneUID);
} on FirebaseException catch (e) {
  print('Firebase error: ${e.message}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.message}')),
  );
} catch (e) {
  print('Unexpected error: $e');
}
```

---

## 📊 SERVICE INTERACTION DIAGRAM

```
            LoginPage
            │
      ┌─────┴────────┐
      │              │
      ▼              ▼
  AuthService    FirebaseAuth
      │              │
      └──────┬───────┘
             │
         Creates User
             │
             ▼
        UserSession
        (Store phoneUID)
             │
      ┌──────┴──────────┐
      │                 │
      ▼                 ▼
UserPresenceService  LocationService
(Set online)         (Get location)
      │
      └──→ Firestore
           (Update)
             │
             ▼
        HomePage
             │
      ┌──────┴──────────┐
      │                 │
      ▼                 ▼
  UserService      UserPresenceService
  (Get profile)    (Listen to status)
      │                 │
      └──────┬──────────┘
             │
             ▼
          Firestore
         (Read/Write)
```

---

## ✅ CHECKLIST: UNDERSTANDING SERVICES

✅ AuthService handles Firebase Auth + phone OTP
✅ UserSession stores phone UID globally
✅ UserPresenceService tracks online/offline status
✅ UserService manages profile CRUD operations
✅ LocationService handles geolocation
✅ ChatService handles messaging
✅ ImageService handles image uploads
✅ All services use Firestore as data backend
✅ Services are stateless and reusable
✅ Services handle errors gracefully

