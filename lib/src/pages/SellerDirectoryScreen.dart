import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';
import 'LocationMapScreen.dart';

/// Screen to browse sellers near the buyer's location
class SellerDirectoryScreen extends StatefulWidget {
  final String? phoneUID;

  const SellerDirectoryScreen({
    super.key,
    this.phoneUID,
  });

  @override
  State<SellerDirectoryScreen> createState() => _SellerDirectoryScreenState();
}

class _SellerDirectoryScreenState extends State<SellerDirectoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String phoneUID;

  List<Map<String, dynamic>> sellers = [];
  bool isLoading = true;
  String? loadingError;
  double? buyerLat;
  double? buyerLng;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    phoneUID = widget.phoneUID ?? UserSession().phoneUID ?? '';
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Try to get buyer's location
      try {
        final locationData = await LocationService.getCurrentLocation();
        if (locationData != null) {
          setState(() {
            buyerLat = locationData['latitude'];
            buyerLng = locationData['longitude'];
          });
        }
      } catch (e) {
        print('Could not get current location: $e');
        // Continue without buyer location
      }

      // Fetch sellers
      await _fetchSellers();
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        isLoading = false;
        loadingError = 'Error loading sellers: $e';
      });
    }
  }

  Future<void> _fetchSellers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('Role', isEqualTo: 'Seller')
          .get();

      final sellersList = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final firstName = data['firstName'] ?? 'Unknown';
        final lastName = data['lastName'] ?? '';
        final latitude = (data['latitude'] ?? 0).toDouble();
        final longitude = (data['longitude'] ?? 0).toDouble();
        final city = data['city'] ?? 'Unknown City';
        final country = data['country'] ?? 'Unknown Country';

        // Calculate distance if coordinates are available
        double distance = 999999;
        if (buyerLat != null &&
            buyerLng != null &&
            latitude != 0 &&
            longitude != 0) {
          try {
            distance = await LocationService.calculateDistance(
              buyerLat!,
              buyerLng!,
              latitude,
              longitude,
            );
          } catch (e) {
            print('Error calculating distance: $e');
          }
        }

        sellersList.add({
          'uid': doc.id,
          'firstName': firstName,
          'lastName': lastName,
          'city': city,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
          'distance': distance,
          'address': data['address'] ?? '$city, $country',
        });
      }

      // Sort by distance
      sellersList.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        sellers = sellersList;
        isLoading = false;
        loadingError = sellersList.isEmpty ? 'No sellers found nearby' : null;
      });
    } catch (e) {
      print('Error fetching sellers: $e');
      setState(() {
        isLoading = false;
        loadingError = 'Error fetching sellers: $e';
      });
    }
  }

  List<Map<String, dynamic>> get filteredSellers {
    if (searchQuery.isEmpty) return sellers;

    return sellers
        .where((seller) =>
            seller['firstName']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            seller['lastName']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            seller['city']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Sellers'),
        backgroundColor: const Color(0xFF2B7CD3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading nearby sellers...'),
                ],
              ),
            )
          : loadingError != null && sellers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loadingError!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            loadingError = null;
                          });
                          _initializeData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B7CD3),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search sellers by name or city...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => searchQuery = ''),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Seller list
                    if (filteredSellers.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No sellers found nearby'
                                    : 'No results for "$searchQuery"',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredSellers.length,
                          itemBuilder: (context, index) {
                            final seller = filteredSellers[index];
                            return _buildSellerCard(seller);
                          },
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildSellerCard(Map<String, dynamic> seller) {
    final firstName = seller['firstName'] ?? 'Unknown';
    final lastName = seller['lastName'] ?? '';
    final city = seller['city'] ?? 'Unknown';
    final distance = seller['distance'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and name
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade600,
                  child: Text(
                    firstName.isNotEmpty
                        ? firstName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName'.trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        city,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Distance and location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  distance < 1
                      ? '${(distance * 1000).toStringAsFixed(0)} m away'
                      : distance >= 999999
                          ? 'Distance unknown'
                          : '${distance.toStringAsFixed(2)} km away',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationMapScreen(
                            latitude: seller['latitude'],
                            longitude: seller['longitude'],
                            userName: '$firstName $lastName'.trim(),
                            userRole: 'seller',
                            address: seller['address'],
                            phoneUID: seller['uid'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('View Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement contact seller
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
