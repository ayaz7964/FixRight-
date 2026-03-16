// import "package:flutter/material.dart";
// import '../widgets//featured_carousel.dart';
// import "../widgets/image_carousel.dart";
// import '../components/HomeSearchBar.dart';
// import '../components/ServiceCategoryChips.dart';
// import '../components/TrustBanners.dart';
// import '../components/LocalWorkerHighlight.dart';
// import '../components/TopOffersList.dart';
// import '../../services/auth_service.dart';
// import '../../services/user_session.dart';
// import 'SellerDirectoryScreen.dart';
// import '../../services/chat_service.dart';

// class HomePage extends StatefulWidget {
//   final String? phoneUID;

//   const HomePage({super.key, this.phoneUID});
//   @override
//   State<HomePage> createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {
//   final AuthService _authService = AuthService();

//   String userFirstName = '';
//   String userLocationAddress = '';
//   bool isLoadingLocation = true;
//   String imageUrl = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       // Use provided phoneUID or get from UserSession
//       final phoneDocId =
//           widget.phoneUID ??
//           UserSession().phoneUID ??
//           _authService.getUserPhoneDocId();

//       if (phoneDocId != null) {
//         final userDoc = await _authService.getUserProfile(phoneDocId);

//         if (userDoc != null) {
//           final data = userDoc.data() as Map<String, dynamic>;
//           final firstName = data['firstName'] ?? 'User';
//           imageUrl = data['profileImage'] ?? '';

//           // Try to get location from multiple fields
//           String locationAddress = '';

//           // First try the combined "address" field (old format)
//           if (data['address'] != null &&
//               (data['address'] as String).isNotEmpty) {
//             locationAddress = data['address'];
//           }
//           // Then try city + country (new format from LoginPage)
//           else if ((data['city'] != null &&
//                   (data['city'] as String).isNotEmpty) ||
//               (data['country'] != null &&
//                   (data['country'] as String).isNotEmpty)) {
//             final city = data['city'] ?? '';
//             final country = data['country'] ?? '';
//             locationAddress =
//                 '$city${city.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country';
//           }

//           setState(() {
//             userFirstName = firstName.isNotEmpty ? firstName : 'User';
//             userLocationAddress = locationAddress.isNotEmpty
//                 ? locationAddress
//                 : 'Location not available';
//             isLoadingLocation = false;
//           });
//         } else {
//           // User document doesn't exist, show default
//           setState(() {
//             userFirstName = 'User';
//             userLocationAddress = 'Location not available';
//             isLoadingLocation = false;
//           });
//         }
//       } else {
//         // Not authenticated
//         setState(() {
//           userFirstName = 'User';
//           userLocationAddress = 'Not authenticated';
//           isLoadingLocation = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//       setState(() {
//         userFirstName = 'User';
//         userLocationAddress = 'Error loading location';
//         isLoadingLocation = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.5,
//         automaticallyImplyLeading: false,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 25,
//               backgroundImage: imageUrl.isNotEmpty
//                   ? NetworkImage(imageUrl)
//                   : null,
//               child: imageUrl.isEmpty
//                   ? Text(
//                       userFirstName.isNotEmpty
//                           ? userFirstName[0].toUpperCase()
//                           : 'U',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Welcome, $userFirstName",
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                   Text(
//                     isLoadingLocation
//                         ? 'Loading location...'
//                         : userLocationAddress,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("New Notification")),
//                 );
//               },
//               icon: const Icon(Icons.notifications),
//             ),
//             IconButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         SellerDirectoryScreen(phoneUID: widget.phoneUID),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.location_on_outlined),
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     HomeSearchBar(),
//                     ServiceCategoryChips(),
//                     ImageCarousel(),
//                     SizedBox(height: 12),
//                     FeaturedCarousel(),
//                     TrustBanners(),
//                     LocalWorkerHighlight(),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () async {
//                         await ChatService().initiateConversation(
//                           currentUserId: '+923163797857',
//                           otherUserId: '+923237964483',
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Conversation initiated"),
//                           ),
//                         );
//                       },
//                       child: Text("Initate the contact"),
//                     ),
//                     TopOffersList(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import 'SellerDirectoryScreen.dart';
// import 'JobDetailBidScreen.dart';
// import 'ClientMyJobsScreen.dart';
import '../components/LocalWorkerHighlight.dart';
import '../components/TopOffersList.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  final String? phoneUID;
  const HomePage({super.key, this.phoneUID});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String userFirstName = '';
  String userLocationAddress = '';
  String imageUrl = '';
  bool isLoading = true;
  String _searchQuery = '';
  int _selectedIndex = 0;
  bool _isSeller = false;

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Plumbing', 'emoji': '🔧'},
    {'name': 'Electrical', 'emoji': '⚡'},
    {'name': 'Cleaning', 'emoji': '🏠'},
    {'name': 'Carpentry', 'emoji': '🪚'},
    {'name': 'AC Repair', 'emoji': '❄️'},
    {'name': 'Painting', 'emoji': '🎨'},
    {'name': 'Mechanic', 'emoji': '🔩'},
    {'name': 'Roofing', 'emoji': '🏗️'},
  ];

  String? _selectedCategory;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final phoneDocId =
          widget.phoneUID ??
          UserSession().phoneUID ??
          _authService.getUserPhoneDocId();

      if (phoneDocId != null) {
        final userDoc = await _authService.getUserProfile(phoneDocId);
        if (userDoc != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final city = data['city'] ?? '';
          final country = data['country'] ?? '';
          final address = data['address'] ?? '';
          final loc = address.isNotEmpty
              ? address
              : '$city${city.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country';
          setState(() {
            userFirstName = data['firstName'] ?? 'User';
            imageUrl = data['profileImage'] ?? '';
            userLocationAddress = loc.isNotEmpty ? loc : 'Location not set';
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
    setState(() {
      userFirstName = 'User';
      userLocationAddress = 'Location not set';
      isLoading = false;
    });
  }

  Stream<QuerySnapshot> _jobsStream() {
    return FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('postedAt', descending: true)
        .limit(50)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final skills = (data['skills'] as List<dynamic>? ?? [])
          .map((s) => s.toString().toLowerCase())
          .toList();
      final status = (data['status'] ?? 'open').toString();

      if (status != 'open') return false;

      if (_selectedCategory != null) {
        final catLower = _selectedCategory!.toLowerCase();
        final matchesCat =
            title.contains(catLower) || skills.any((s) => s.contains(catLower));
        if (!matchesCat) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            title.contains(_searchQuery) ||
            skills.any((s) => s.contains(_searchQuery));
        if (!matchesSearch) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildTealHeader(context)),
          SliverToBoxAdapter(child: _buildCategoriesSection()),
          SliverToBoxAdapter(child: _buildJobsSection()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LocalWorkerHighlight(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: TopOffersList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Navigator.push(
            //   context,
            // MaterialPageRoute(builder: (_) =>
            //const ClientMyJobsScreen()),
            // );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle),
            label: _isSeller ? 'Post Service' : 'Post Job',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Services',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildTealHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), Color(0xFF00695C)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00695C),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              userFirstName.isNotEmpty
                                  ? userFirstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoading ? 'Loading...' : 'Welcome, $userFirstName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                userLocationAddress,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderIconButton(
                    icon: Icons.assignment_ind_outlined,
                    onPressed: () {},
                    //=> Navigator.push(
                    //   // context,
                    //   // MaterialPageRoute(
                    //     // builder: (_) => const ClientMyJobsScreen(),
                    //   ),
                    // ),
                  ),
                  // _buildHeaderIconButton(
                  //   icon: Icons.notifications_none_rounded,
                  //   onPressed: () {},
                  // ),
                  NotificationBell(
                    uid: widget.phoneUID ?? '', // your seller/buyer UID string
                    color: Colors.white, // icon color to match your AppBar
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsPage(uid: widget.phoneUID ?? ""),
                      ),
                    ),
                  ),
                  _buildHeaderIconButton(
                    icon: Icons.location_on_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SellerDirectoryScreen(phoneUID: widget.phoneUID),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                _greeting(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find the right worker,\nright now.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for a service...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required void Function() onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = isSelected
                        ? null
                        : cat['name'] as String;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00897B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00897B)
                            : Colors.grey.shade200,
                        width: isSelected ? 0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF00897B).withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 12 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat['emoji'] as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isNotEmpty || _selectedCategory != null
                    ? 'Search Results'
                    : 'Recent Jobs Near You',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              if (_selectedCategory != null || _searchQuery.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _selectedCategory = null);
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: _jobsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _emptyState(
                  'Firestore error:\n${snapshot.error}',
                  Icons.error_outline,
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF00897B),
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }

              final filtered = _filterDocs(snapshot.data?.docs ?? []);

              if (filtered.isEmpty) {
                return _emptyState(
                  _searchQuery.isNotEmpty
                      ? 'No jobs found for "$_searchQuery"'
                      : 'No open jobs yet.\nBe the first to post one!',
                  Icons.work_outline,
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                // ── Cards are no longer tappable from the home screen ──
                itemBuilder: (BuildContext context, int i) =>
                    _buildJobCard(filtered[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Job card: view-only, no onTap navigation ──────────────────
  Widget _buildJobCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'Untitled Job';
    final skills = List<String>.from(data['skills'] ?? []);
    final timing = data['timing'] ?? '';
    final budget = data['budget'];
    final location = data['location'] ?? '';
    final postedAt = data['postedAt'] as Timestamp?;

    String timeAgo = '';
    if (postedAt != null) {
      final diff = DateTime.now().difference(postedAt.toDate());
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    }

    // No GestureDetector / InkWell — card is display-only
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + time ago
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (timeAgo.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Skills chips
            if (skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: skills
                    .take(4)
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF00897B).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),

            // Budget / timing / location row
            Row(
              children: [
                if (budget != null && budget != 0) ...[
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.teal.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PKR ${budget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.teal.shade700,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (timing.isNotEmpty) ...[
                  Icon(Icons.schedule, size: 16, color: Colors.orange.shade600),
                  const SizedBox(width: 4),
                  Text(
                    timing,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (location.isNotEmpty) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // ── "View Only" label so users know tapping is disabled ──
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'View only',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
