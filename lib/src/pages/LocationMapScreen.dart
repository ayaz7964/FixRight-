import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

/// Professional location map display screen
class LocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String userName;
  final String userRole;
  final String address;
  final String phoneUID;
  final double? buyerLatitude;
  final double? buyerLongitude;

  const LocationMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.userName,
    required this.userRole,
    required this.address,
    required this.phoneUID,
    this.buyerLatitude,
    this.buyerLongitude,
  });

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late Future<Map<String, String>> _locationDetailsFuture;
  String googleMapsUrl = '';
  final Completer<GoogleMapController> _mapController = Completer();
  late CameraPosition _initialCamera;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _locationDetailsFuture = LocationService.getAddressFromCoordinates(
      widget.latitude,
      widget.longitude,
    );
    _buildGoogleMapsUrl();
    _initialCamera = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 15,
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('seller'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.userName),
      ),
    );
    if (widget.buyerLatitude != null && widget.buyerLongitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('buyer'),
          position: LatLng(widget.buyerLatitude!, widget.buyerLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Your location'),
        ),
      );
    }
  }

  void _buildGoogleMapsUrl() {
    if (widget.buyerLatitude != null && widget.buyerLongitude != null) {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${widget.buyerLatitude},${widget.buyerLongitude}&destination=${widget.latitude},${widget.longitude}&travelmode=driving';
    } else {
      googleMapsUrl =
          'https://maps.google.com/?q=${widget.latitude},${widget.longitude}';
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Apple Maps not available')));
    }
  }

  void _copyCoordinates() {
    final coordinates = '${widget.latitude}, ${widget.longitude}';
    final both = widget.buyerLatitude != null
        ? 'Buyer: ${widget.buyerLatitude}, ${widget.buyerLongitude}\nSeller: $coordinates'
        : 'Seller: $coordinates';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied:\n$both')));
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
                      // Embedded Google Map
                      GoogleMap(
                        initialCameraPosition: _initialCamera,
                        markers: _markers,
                        myLocationEnabled: widget.buyerLatitude != null,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
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
        Icon(icon, color: const Color(0xFF2B7CD3), size: 20),
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
