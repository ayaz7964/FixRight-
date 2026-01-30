import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../services/user_data_helper.dart';
import '../../services/location_service.dart';
import '../../services/profile_service.dart';
import 'LocationMapScreen.dart';

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
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String phoneDocId;
  bool isLoading = true;
  final mobile = UserSession().phoneUID;
  final UserDataHelper _userDataHelper = UserDataHelper();

  UserDataHelper userDataHelper = UserDataHelper();

  // User profile data
  String firstName = '';
  String lastName = '';
  String address = '';
  String phoneNumber = '';
  String UserRole = 'Buyer';
  double longitude = 0;
  double latitude = 0;
  String city = '';
  String country = '';
  String fullAddress = '';

  @override
  void initState() {
    super.initState();
    // Use provided phoneUID or get from UserSession or AuthService
    phoneDocId =
        widget.phoneUID ??
        UserSession().phoneUID ??
        _authService.getUserPhoneDocId() ??
        '';
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userDoc = await _authService.getUserProfile(phoneDocId);

      if (userDoc != null) {
        final data = userDoc.data() as Map<String, dynamic>;

        final lat = (data['latitude'] ?? 0).toDouble();
        final lng = (data['longitude'] ?? 0).toDouble();

        // Load address details from coordinates using LocationService
        String loadedCity = data['city'] ?? '';
        String loadedCountry = data['country'] ?? '';
        String loadedAddress = data['address'] ?? '';

        if (lat != 0 && lng != 0) {
          try {
            final locationDetails =
                await LocationService.getAddressFromCoordinates(lat, lng);
            loadedCity = locationDetails['city'] ?? loadedCity;
            loadedCountry = locationDetails['country'] ?? loadedCountry;
            loadedAddress = LocationService.formatAddress(locationDetails);
          } catch (e) {
            print('Error getting location details: $e');
          }
        }

        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          address = loadedAddress;
          phoneNumber = data['phoneNumber'] ?? '';
          UserRole = data['Role'] ?? '';
          longitude = lng;
          latitude = lat;
          city = loadedCity;
          country = loadedCountry;
          fullAddress = loadedAddress;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  // Options for the BUYER/Client mode
  final List<Map<String, dynamic>> _buyerOptions = [
    {'icon': Icons.diamond, 'title': 'Get inspired'},
    {'icon': Icons.favorite_border, 'title': 'Saved lists'},
    {'icon': Icons.insights, 'title': 'My interests'},
    {'icon': Icons.send, 'title': 'Invite friends'},
  ];

  // Options for the SELLER/Worker mode
  final List<Map<String, dynamic>> _sellerOptions = [
    {'icon': Icons.account_balance_wallet, 'title': 'Earnings'},
    {'icon': Icons.description, 'title': 'Custom offer templates'},
    {'icon': Icons.text_snippet, 'title': 'Briefs'},
    {'icon': Icons.share, 'title': 'Share Gigs'},
  ];

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap:
          onTap ??
          () {
            debugPrint('Tapped: $title');
          },
    );
  }

  /// Edit profile screen - fully functional with data loading and image upload
  Widget _UpdateUserProfileScreen(String phoneDocId) {
    return _EditProfileScreen(phoneDocId: phoneDocId);
  }

  void _showEditProfileDialog(phoneDocId) {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final addressController = TextEditingController(text: address);
    final phoneNumberController = TextEditingController(text: mobile);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: mobile ?? '',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(
                firstNameController.text,
                lastNameController.text,
                addressController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(
    String newFirstName,
    String newLastName,
    String newAddress,
  ) async {
    try {
      await _firestore.collection('users').doc(phoneDocId).update({
        'firstName': newFirstName,
        'lastName': newLastName,
        'address': newAddress,
      });

      setState(() {
        firstName = newFirstName;
        lastName = newLastName;
        address = newAddress;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentOptions = widget.isSellerMode ? _sellerOptions : _buyerOptions;
    final primaryColor = widget.isSellerMode
        ? Colors.green.shade700
        : const Color(0xFF2B7CD3);
    final headerText = widget.isSellerMode ? 'Selling' : 'My FixRight';
    final Color optionColor = widget.isSellerMode
        ? Colors.green.shade700
        : const Color(0xFF2B7CD3);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('My Profile'), Icon(Icons.notifications)],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Container (Dynamic Color)
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Info Row (Avatar, Name, Balance)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stack for Avatar + Online Dot
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Online Status Dot
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      // User Name and Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$firstName $lastName'.trim(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Personal balance: \$0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  UserRole == 'Buyer'
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (latitude != 0 && longitude != 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'City: $city, Country: $country\n'
                                      'Coordinates: $latitude, $longitude',
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Location not available'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Became Seller',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      :
                        // Seller Mode Switch Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Seller Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: widget.isSellerMode,
                                activeThumbColor: primaryColor,
                                onChanged: (bool newValue) {
                                  widget.onToggleMode(newValue);
                                },
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),

            // 2. "My Profile" Tile (Edit Form)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 15),
            _buildProfileOption(
              icon: Icons.person,
              title: 'My Profile',
              color: optionColor,
              // onTap: () => _showEditProfileDialog(phoneDocId),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _UpdateUserProfileScreen(phoneDocId),
                ),
              ),
            ),

            // 2B. Location Info Card
            if (latitude != 0 && longitude != 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: optionColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: optionColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$city, $country',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (fullAddress.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              fullAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationMapScreen(
                                    latitude: latitude,
                                    longitude: longitude,
                                    userName: '$firstName $lastName'.trim(),
                                    userRole: UserRole.toLowerCase(),
                                    address: fullAddress,
                                    phoneUID: phoneDocId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: optionColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Dynamic Options List
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                headerText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 15),

            // Generate the list of options
            ...currentOptions.map(
              (option) => _buildProfileOption(
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                color: optionColor,
              ),
            ),

            // 4. General Settings (Visible in both modes)
            const Padding(
              padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 15),
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Preferences',
              color: Colors.grey.shade700,
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

/// Stateful edit profile screen with data loading and image upload
class _EditProfileScreen extends StatefulWidget {
  final String phoneDocId;

  const _EditProfileScreen({required this.phoneDocId});

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late ProfileService _profileService;

  late UserProfile _profile;
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _loadProfile();
  }

  /// Load profile data from Firestore
  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.fetchProfile(widget.phoneDocId);
      if (profile != null) {
        setState(() {
          _profile = profile;
          _initializeControllers(profile);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Profile not found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading profile: $e';
      });
    }
  }

  /// Initialize text controllers with profile data
  void _initializeControllers(UserProfile profile) {
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _cityController = TextEditingController(text: profile.city);
    _countryController = TextEditingController(text: profile.country);
    _addressController = TextEditingController(text: profile.address);
    _phoneController = TextEditingController(text: profile.phoneNumber);
  }

  /// Save profile changes to Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate using service
    final validationError = ProfileService.validateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      city: _cityController.text,
      country: _countryController.text,
      address: _addressController.text,
    );

    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() => isSaving = true);

    try {
      await _profileService.updateProfile(
        widget.phoneDocId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        city: _cityController.text,
        country: _countryController.text,
        address: _addressController.text,
      );

      _showSuccessSnackBar('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSaving = false);
      _showErrorSnackBar('Error saving profile: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade600),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profile.profileImageUrl != null
                    ? NetworkImage(_profile.profileImageUrl!)
                    : null,
                child: _profile.profileImageUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                    : null,
              ),
              const SizedBox(height: 32),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Country
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Phone (Read-only)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
