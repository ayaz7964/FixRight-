import "package:flutter/material.dart";
import '../widgets//featured_carousel.dart';
import "../widgets/image_carousel.dart";
import '../components/HomeSearchBar.dart';
import '../components/ServiceCategoryChips.dart';
import '../components/TrustBanners.dart';
import '../components/LocalWorkerHighlight.dart';
import '../components/TopOffersList.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';

class HomePage extends StatefulWidget {
  final String? phoneUID;

  const HomePage({super.key, this.phoneUID});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  String userFirstName = '';
  String userLocationAddress = '';
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Use provided phoneUID or get from UserSession
      final phoneDocId =
          widget.phoneUID ??
          UserSession().phoneUID ??
          _authService.getUserPhoneDocId();

      if (phoneDocId != null) {
        final userDoc = await _authService.getUserProfile(phoneDocId);

        if (userDoc != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final firstName = data['firstName'] ?? 'User';

          // Try to get location from multiple fields
          String locationAddress = '';

          // First try the combined "address" field (old format)
          if (data['address'] != null &&
              (data['address'] as String).isNotEmpty) {
            locationAddress = data['address'];
          }
          // Then try city + country (new format from LoginPage)
          else if ((data['city'] != null &&
                  (data['city'] as String).isNotEmpty) ||
              (data['country'] != null &&
                  (data['country'] as String).isNotEmpty)) {
            final city = data['city'] ?? '';
            final country = data['country'] ?? '';
            locationAddress =
                '$city${city.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country';
          }

          setState(() {
            userFirstName = firstName.isNotEmpty ? firstName : 'User';
            userLocationAddress = locationAddress.isNotEmpty
                ? locationAddress
                : 'Location not available';
            isLoadingLocation = false;
          });
        } else {
          // User document doesn't exist, show default
          setState(() {
            userFirstName = 'User';
            userLocationAddress = 'Location not available';
            isLoadingLocation = false;
          });
        }
      } else {
        // Not authenticated
        setState(() {
          userFirstName = 'User';
          userLocationAddress = 'Not authenticated';
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userFirstName = 'User';
        userLocationAddress = 'Error loading location';
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Text(
                userFirstName.isNotEmpty ? userFirstName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $userFirstName",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    isLoadingLocation
                        ? 'Loading location...'
                        : userLocationAddress,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New Notification")),
                );
              },
              icon: const Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Location: $userLocationAddress")),
                );
              },
              icon: const Icon(Icons.location_on_outlined),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HomeSearchBar(),
                    ServiceCategoryChips(),
                    ImageCarousel(),
                    SizedBox(height: 12),
                    FeaturedCarousel(),
                    TrustBanners(),
                    LocalWorkerHighlight(),
                    TopOffersList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
