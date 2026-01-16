# Screen Integration Examples

This document shows how to implement phone-UID functionality in actual screens.

---

## Example 1: Home Screen Integration

```dart
import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String? phoneUID;

  const HomePage({
    super.key,
    this.phoneUID,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String phoneUID;
  String userFirstName = 'User';
  String userLocation = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
    
    if (phoneUID.isEmpty) {
      // Redirect to login if not authenticated
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/'));
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await UserDataHelper.getUserProfile(phoneUID);
      
      if (profile != null) {
        setState(() {
          userFirstName = profile['firstName'] ?? 'User';
          userLocation = (profile['address'] ?? 
                          '${profile['city'] ?? ''}, ${profile['country'] ?? ''}')
                          .replaceAll(RegExp(r',\s*$'), '').trim();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
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
      appBar: AppBar(
        title: Text('Welcome, $userFirstName!'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User greeting card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello $userFirstName 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Your Location: $userLocation',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Your other home content here
        ],
      ),
    );
  }
}
```

---

## Example 2: Profile Screen with Edit Functionality

```dart
import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';

class ProfileScreen extends StatefulWidget {
  final bool isSellerMode;
  final ValueChanged<bool> onToggleMode;
  final String? phoneUID;

  const ProfileScreen({
    super.key,
    required this.isSellerMode,
    required this.onToggleMode,
    this.phoneUID,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String phoneUID;
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  bool isLoading = true;
  bool isSavingChanges = false;

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserDataHelper.getUserProfile(phoneUID);
      
      if (profile != null && mounted) {
        setState(() {
          _firstNameController.text = profile['firstName'] ?? '';
          _lastNameController.text = profile['lastName'] ?? '';
          _cityController.text = profile['city'] ?? '';
          _countryController.text = profile['country'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => isSavingChanges = true);

    try {
      await UserDataHelper.updateUserProfile(phoneUID, {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'city': _cityController.text,
        'country': _countryController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isSavingChanges = false);
    }
  }

  void _logout() {
    UserDataHelper.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile form
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: isSavingChanges ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: isSavingChanges
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 16),

            // Mode toggle (if applicable)
            SwitchListTile(
              title: const Text('Seller Mode'),
              value: widget.isSellerMode,
              onChanged: widget.onToggleMode,
            ),
            const SizedBox(height: 16),

            // Logout button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
```

---

## Example 3: Messages Screen with User Data

```dart
import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';

class MessageChatBotScreen extends StatefulWidget {
  final String? phoneUID;

  const MessageChatBotScreen({
    super.key,
    this.phoneUID,
  });

  @override
  State<MessageChatBotScreen> createState() => _MessageChatBotScreenState();
}

class _MessageChatBotScreenState extends State<MessageChatBotScreen> {
  late String phoneUID;
  String userName = 'User';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final fullName = await UserDataHelper.getUserFullName(phoneUID);
      setState(() {
        userName = fullName;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
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
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          // Welcome message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Hello $userName, you have no new messages'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Start a conversation!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Example 4: Seller Dashboard with Real-time Updates

```dart
import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';

class SellerDashboardPage extends StatefulWidget {
  final String? phoneUID;

  const SellerDashboardPage({
    super.key,
    this.phoneUID,
  });

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late String phoneUID;

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: UserDataHelper.streamCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          if (userData == null) {
            return const Center(child: Text('User data not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller name
                Text(
                  '${userData['firstName']} ${userData['lastName']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Contact info
                Text(
                  'Phone: ${userData['mobile']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                // Dashboard stats
                _buildStatCard(
                  title: 'Location',
                  value: '${userData['city']}, ${userData['country']}',
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Role',
                  value: userData['Role'] ?? 'Seller',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```

---

## Key Takeaways

1. ✅ Always get phoneUID from `widget.phoneUID ?? UserSession().phoneUID ?? ''`
2. ✅ Use `UserDataHelper` for all database operations
3. ✅ Stream data for real-time updates
4. ✅ Handle null/empty phoneUID (redirect to login)
5. ✅ Show loading state while fetching data
6. ✅ Handle errors gracefully with SnackBars
7. ✅ Clear session on logout

---

**Date**: January 16, 2026  
**Status**: Ready for Implementation
