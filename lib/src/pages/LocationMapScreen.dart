import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';

/// Professional location map display screen
class LocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String userName;
  final String userRole;
  final String address;
  final String phoneUID;

  const LocationMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.userName,
    required this.userRole,
    required this.address,
    required this.phoneUID,
  });

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late Future<Map<String, String>> _locationDetailsFuture;
  String googleMapsUrl = '';

  @override
  void initState() {
    super.initState();
    _locationDetailsFuture = LocationService.getAddressFromCoordinates(
      widget.latitude,
      widget.longitude,
    );
    _buildGoogleMapsUrl();
  }

  void _buildGoogleMapsUrl() {
    googleMapsUrl =
        'https://maps.google.com/?q=${widget.latitude},${widget.longitude}';
  }

  Future<void> _openGoogleMaps() async {
    try {
      await launchUrl(Uri.parse(googleMapsUrl));
    } catch (e) {
      print('Error opening Google Maps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Future<void> _openAppleMaps() async {
    try {
      final appleUrl =
          'maps://maps.apple.com/?q=${widget.latitude},${widget.longitude}';
      await launchUrl(Uri.parse(appleUrl));
    } catch (e) {
      print('Error opening Apple Maps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple Maps not available')),
      );
    }
  }

  void _copyCoordinates() {
    final coordinates = '${widget.latitude}, ${widget.longitude}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: $coordinates')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B7CD3),
        foregroundColor: Colors.white,
        title: Text('${widget.userName}\'s Location'),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _locationDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final locationDetails = snapshot.data ?? {};

          return SingleChildScrollView(
            child: Column(
              children: [
                // Map Section
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey.shade200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Static Google Maps Image
                      Image.network(
                        'https://maps.googleapis.com/maps/api/staticmap'
                        '?center=${widget.latitude},${widget.longitude}'
                        '&zoom=15'
                        '&size=600x300'
                        '&markers=color:blue%7C${widget.latitude},${widget.longitude}'
                        '&key=AIzaSyDummy123', // Replace with your API key
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 64,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${widget.latitude}, ${widget.longitude}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Location Details Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.blue.shade600,
                                child: Text(
                                  widget.userName.isNotEmpty
                                      ? widget.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.userRole == 'seller'
                                          ? 'Service Provider'
                                          : 'Client',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Address
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Address',
                            value: locationDetails['address'] ?? widget.address,
                          ),
                          const SizedBox(height: 16),

                          // City
                          _buildDetailRow(
                            icon: Icons.apartment,
                            label: 'City',
                            value: locationDetails['city'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 16),

                          // Country
                          _buildDetailRow(
                            icon: Icons.public,
                            label: 'Country',
                            value: locationDetails['country'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 16),

                          // Coordinates
                          _buildDetailRow(
                            icon: Icons.pin_drop,
                            label: 'Coordinates',
                            value: '${widget.latitude}, ${widget.longitude}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Google Maps Button
                      ElevatedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: const Icon(Icons.map),
                        label: const Text('Open in Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B7CD3),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Apple Maps Button
                      OutlinedButton.icon(
                        onPressed: _openAppleMaps,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Open in Apple Maps'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF555555),
                          side: const BorderSide(
                            color: Color(0xFF555555),
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Copy Coordinates Button
                      OutlinedButton.icon(
                        onPressed: _copyCoordinates,
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Copy Coordinates'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          side: BorderSide(
                            color: Colors.blue.shade600,
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF2B7CD3),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
