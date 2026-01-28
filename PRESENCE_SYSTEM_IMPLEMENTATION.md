# User Presence System - Complete Implementation ✅

## Overview
A comprehensive, reliable user online/offline presence system using Firebase Firestore that tracks presence across app lifecycle events.

---

## Implementation Summary

### 1. **Presence on Login / App Open** ✅

#### Flow:
```
User Opens App
  ↓
main.dart: initState() → _initializePresenceIfNeeded()
  ↓
Check if user already authenticated
  ↓
If YES: Call UserPresenceService.initializePresence()
  ↓
Set isOnline=true, lastSeen=serverTimestamp in Firestore
```

#### Code Location:
- **File**: `lib/main.dart`
- **Method**: `_initializePresenceIfNeeded()`
- **Trigger**: App startup if user already logged in

#### Implementation:
```dart
Future<void> _initializePresenceIfNeeded() async {
  if (_auth.currentUser != null && !_hasInitializedPresence) {
    _hasInitializedPresence = true;
    await _presenceService.initializePresence();
  }
}
```

**Why**: Handles case where user app is reopened without needing to login again.

---

### 2. **Presence on Successful Login** ✅

#### Flow:
```
User Enters Phone + OTP
  ↓
LoginPage: verifyPhoneNumber() succeeds
  ↓
_navigateToHome() called
  ↓
Call UserPresenceService.initializePresence()
  ↓
Set isOnline=true, lastSeen=serverTimestamp
  ↓
Navigate to /home screen
```

#### Code Location:
- **File**: `lib/src/components/LoginPage.dart`
- **Method**: `_navigateToHome(String uid)`
- **Trigger**: After successful phone verification

#### Implementation:
```dart
void _navigateToHome(String uid) async {
  setState(() => isLoading = false);
  
  // Initialize user presence after successful login
  try {
    final presenceService = UserPresenceService();
    await presenceService.initializePresence();
  } catch (e) {
    print('Error initializing presence: $e');
    // Continue navigation even if presence initialization fails
  }
  
  Navigator.pushReplacementNamed(context, '/home');
}
```

**Why**: Immediately marks user as online upon login completion.

---

### 3. **Presence on App Lifecycle Changes** ✅

#### Flow:
```
App Lifecycle State Changes
  ↓
didChangeAppLifecycleState() called
  ↓
Switch on AppLifecycleState:
  
  resumed        → isOnline = true
  paused         → isOnline = false
  inactive       → isOnline = false
  detached       → isOnline = false
  hidden         → isOnline = false
```

#### Code Location:
- **File**: `lib/main.dart`
- **Method**: `didChangeAppLifecycleState(AppLifecycleState state)`
- **Trigger**: Any app lifecycle change

#### Implementation:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);

  switch (state) {
    case AppLifecycleState.resumed:
      // App is in foreground - mark as online
      _presenceService.updatePresence(true);
      break;
    case AppLifecycleState.paused:
    case AppLifecycleState.inactive:
    case AppLifecycleState.detached:
    case AppLifecycleState.hidden:
      // App is in background or closing - mark as offline
      _presenceService.updatePresence(false);
      break;
  }
}
```

**State Details**:
- `resumed`: User returned to app (from background or lock screen)
- `paused`: User left app (home button, app switcher, notification)
- `inactive`: Brief transition state
- `detached`: App process will terminate
- `hidden`: App is hidden but not paused (rare)

---

### 4. **Presence on App Close** ✅

#### Flow:
```
User Closes App / Process Terminates
  ↓
_FixRightAppState.dispose() called
  ↓
UserPresenceService.updatePresence(false)
  ↓
Set isOnline=false, lastSeen=serverTimestamp
  ↓
Remove observer
```

#### Code Location:
- **File**: `lib/main.dart`
- **Method**: `dispose()`
- **Trigger**: App process termination

#### Implementation:
```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  // Mark user as offline when app closes
  _presenceService.updatePresence(false);
  super.dispose();
}
```

**Why**: Ensures clean offline status when app is destroyed.

---

### 5. **Presence on Logout** ✅

#### Flow:
```
User Clicks "Logout" Button
  ↓
ProfileScreen: onPressed() → authService.signOut()
  ↓
AuthService.signOut() called
  ↓
UserPresenceService.setOfflineBeforeLogout() called
  ↓
Set isOnline=false, lastSeen=serverTimestamp
  ↓
THEN sign out from Firebase Auth
  ↓
Navigate to login screen
```

#### Code Location:
- **File**: `lib/services/auth_service.dart`
- **Method**: `signOut()`
- **Trigger**: User presses logout button

#### Implementation:
```dart
/// Sign out the user
/// First marks user as offline, then signs out from Firebase
Future<void> signOut() async {
  try {
    // Mark user as offline before signing out
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

**Critical**: Presence update completes BEFORE Firebase signOut to ensure it persists.

---

## UserPresenceService Methods

### `initializePresence()` - On Login
```dart
/// Called when:
/// - User logs in successfully
/// - App starts with existing auth session
/// Updates:
/// - isOnline = true
/// - lastSeen = serverTimestamp
/// - updatedAt = Timestamp.now()
Future<void> initializePresence() async { ... }
```

### `updatePresence(bool isOnline)` - On App Lifecycle Change
```dart
/// Called when:
/// - App resumes → true
/// - App pauses → false
/// Updates:
/// - isOnline = true/false
/// - lastSeen = serverTimestamp
Future<void> updatePresence(bool isOnline) async { ... }
```

### `setOfflineBeforeLogout()` - On Logout
```dart
/// Called when:
/// - User clicks logout
/// Updates:
/// - isOnline = false
/// - lastSeen = serverTimestamp
/// Critical: Waits for Firestore update before logout completes
Future<void> setOfflineBeforeLogout() async { ... }
```

### `getUserStatusStream(String userId)` - For UI Display
```dart
/// Returns: Stream<String>
/// "Online" → when isOnline=true
/// "Last seen Xm ago" → when offline
/// "Just now" → very recently offline
/// Used in: ChatDetailScreen AppBar, chat lists
Stream<String> getUserStatusStream(String userId) { ... }
```

---

## Firestore Collection Structure

### Document Path:
```
userPresence/{phoneNumber}
```

### Document Fields:
```json
{
  "isOnline": true | false,
  "lastSeen": Timestamp,
  "updatedAt": Timestamp
}
```

### Example Documents:
```json
{
  "phoneNumber": "+923211234567",
  "isOnline": true,
  "lastSeen": 2026-01-28T14:35:22.000Z,
  "updatedAt": 2026-01-28T14:35:22.000Z
}
```

---

## Firestore Update Strategy

### Why `SetOptions(merge: true)`?
- **Prevents overwrites**: Doesn't delete other fields
- **Safe updates**: Only updates specified fields
- **No field loss**: Preserves existing data

### Code Example:
```dart
await _firestore.collection(_presenceCollection).doc(phoneUID).set({
  'isOnline': isOnline,
  'lastSeen': FieldValue.serverTimestamp(),
  'updatedAt': Timestamp.now(),
}, SetOptions(merge: true));  // ← Critical!
```

### Why `FieldValue.serverTimestamp()`?
- **Accurate**: Uses Firestore server time (not device time)
- **Consistent**: All times synchronized across all devices
- **Reliable**: Works even if device clock is wrong

---

## Real-Time UI Integration

### Display User Status in Chat
```dart
// In ChatDetailScreen AppBar
StreamBuilder<String>(
  stream: _presenceService.getUserStatusStream(widget.otherUserId),
  builder: (context, snapshot) {
    final status = snapshot.data ?? 'Offline';
    return Text(
      status,
      style: TextStyle(
        color: status == 'Online' ? Colors.green : Colors.grey,
      ),
    );
  },
)
```

### Show Status Text:
- ✅ "Online" - when user is in app
- "Last seen 5m ago" - 5 minutes offline
- "Last seen 2h ago" - 2 hours offline
- "Last seen yesterday at 14:30" - longer offline
- "Last seen 28/1/2026" - very old timestamp

---

## Event Timeline Example

### Session 1: User logs in, uses app, closes it
```
14:00 → User taps login
14:00 → Phone verification completes
14:00 → _navigateToHome() → initializePresence()
14:00 → Firestore: isOnline=true, lastSeen=14:00

14:05 → User reading chats (app active)
14:05 → App in resumed state, no presence update needed

14:10 → User minimizes app
14:10 → didChangeAppLifecycleState(paused)
14:10 → updatePresence(false)
14:10 → Firestore: isOnline=false, lastSeen=14:10
```

### Session 2: User logs back in next day
```
Next Day, 08:00 → User opens app again
08:00 → App already has auth session
08:00 → initState() → _initializePresenceIfNeeded()
08:00 → initializePresence()
08:00 → Firestore: isOnline=true, lastSeen=08:00

Chat shows: "Last seen yesterday at 14:10"
Then immediately: "Online"
```

---

## Error Handling

### Presence Update Failures
- **Non-blocking**: If Firestore update fails, app continues normally
- **User notification**: NOT shown (background sync)
- **Retry**: Firebase SDKs handle automatic retry

### Login Completion
- **Not blocked by**: Presence initialization failure
- **Result**: User still navigates to /home even if presence fails
- **Offline users**: Still get offline status if update failed

### Logout Completion
- **Presence attempted**: But doesn't block logout
- **Graceful degradation**: User still logs out if presence update fails
- **Last seen**: Remains accurate from previous presence state

---

## Performance Optimizations

### Single Initialization
```dart
bool _hasInitializedPresence = false;

// Only initialize once per app session
if (_auth.currentUser != null && !_hasInitializedPresence) {
  _hasInitializedPresence = true;
  await _presenceService.initializePresence();
}
```

### No Unnecessary Writes
```dart
// Only update when state actually changes
// (resume/pause, not every frame)
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      _presenceService.updatePresence(true);  // Once per resume
      break;
    case AppLifecycleState.paused:
      _presenceService.updatePresence(false); // Once per pause
      break;
  }
}
```

### Merge Updates
```dart
// Only update presence fields, not entire document
SetOptions(merge: true)
```

---

## Features Preserved

✅ **Chat functionality** - Unaffected by presence system
✅ **Read/unread tracking** - Still works normally
✅ **Phone calling** - Direct phone dialer still functional
✅ **Message sending** - No impact on message flow
✅ **Navigation** - All routes work as before
✅ **Authentication** - Login/logout flows intact

---

## Testing Checklist

### Login Flow
- [ ] User logs in → immediately shows "Online" in chat headers
- [ ] Check Firestore: `userPresence/{userId}` has `isOnline=true`

### App Lifecycle
- [ ] Minimize app → User shows "Last seen Xm ago" after ~5 seconds
- [ ] Restore app → User shows "Online" again
- [ ] Check Firestore: `isOnline` toggles between true/false

### Logout
- [ ] Click logout → User shows offline before leaving app
- [ ] Check Firestore: `isOnline=false, lastSeen=<current time>`

### App Restart
- [ ] Close app completely
- [ ] Reopen app → User shows "Online" immediately
- [ ] Check Firestore: `lastSeen` updated to current time

### Multiple Devices
- [ ] Login on device A → Shows "Online"
- [ ] Minimize on device A → Shows "Last seen"
- [ ] Any device can view updated presence

---

## Debugging

### Check Presence in Firestore
Navigate to Firestore Console:
```
userPresence/{phoneNumber}
- isOnline: true|false
- lastSeen: Timestamp
- updatedAt: Timestamp
```

### Check Logs
```
I/flutter (PID): Presence initialized for user: +923211234567
I/flutter (PID): Presence updated: Online for +923211234567
I/flutter (PID): Presence updated: Offline for +923211234567
I/flutter (PID): User marked offline before logout: +923211234567
```

### Troubleshooting
| Issue | Solution |
|-------|----------|
| Status shows "Offline" when app is open | Check `didChangeAppLifecycleState` is being called |
| Presence not updating on lifecycle | Ensure `WidgetsBindingObserver` is added in initState |
| "Last seen" time is wrong | Device time may be incorrect |
| Presence updates fail silently | Check Firestore rules allow `userPresence` writes |

---

## Architecture Diagram

```
LoginPage               AuthService           UserPresenceService
    |                        |                        |
    +-- signUp/Login -----> _navigateToHome()       |
    |                        |                        |
    |                        +-- initializePresence() 
    |                                                 |
    |                        +--> Firestore
    |                            (isOnline=true)
    
Main (_FixRightAppState)
    |
    +-- initState()
    |   +-- _initializePresenceIfNeeded()
    |       +-- initializePresence()
    |
    +-- didChangeAppLifecycleState()
    |   +-- resumed -----> updatePresence(true)
    |   +-- paused ------> updatePresence(false)
    |
    +-- dispose()
        +-- updatePresence(false)

ProfileScreen
    |
    +-- Logout Button
        +-- authService.signOut()
            +-- setOfflineBeforeLogout()
            +-- _auth.signOut()
```

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/services/user_presence_service.dart` | Added `initializePresence()`, `setOfflineBeforeLogout()` methods |
| `lib/main.dart` | Added `_initializePresenceIfNeeded()`, presence flag, app lifecycle handling |
| `lib/services/auth_service.dart` | Modified `signOut()` to mark offline before logout |
| `lib/src/components/LoginPage.dart` | Modified `_navigateToHome()` to initialize presence on login |

---

## Next Steps

1. ✅ Implementation complete
2. Test on real Android/iOS devices
3. Verify Firestore documents update correctly
4. Check UI displays correct status strings
5. Confirm logout properly marks user offline

---

**Status**: ✅ Complete and Ready for Testing
