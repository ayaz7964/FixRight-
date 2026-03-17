

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import 'SellerDirectoryScreen.dart';
import 'notification_service.dart';
import 'all_offers_screen.dart';
import 'tts_translation_service.dart';
import 'offer_place_order_sheet.dart';

class HomePage extends StatefulWidget {
  final String? phoneUID;
  const HomePage({super.key, this.phoneUID});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  String _firstName = '';
  String _location = '';
  String _city = '';
  String _imageUrl = '';
  bool _loading = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _teal = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  static const List<Map<String, dynamic>> _cats = [
    {'n': 'Plumbing', 'e': '🔧', 'c': 0xFF1565C0},
    {'n': 'Electrical', 'e': '⚡', 'c': 0xFFF57F17},
    {'n': 'Cleaning', 'e': '🧹', 'c': 0xFF2E7D32},
    {'n': 'Carpentry', 'e': '🪚', 'c': 0xFF6D4C41},
    {'n': 'AC Repair', 'e': '❄️', 'c': 0xFF0277BD},
    {'n': 'Painting', 'e': '🎨', 'c': 0xFFAD1457},
    {'n': 'Mechanic', 'e': '🔩', 'c': 0xFF37474F},
    {'n': 'Roofing', 'e': '🏗️', 'c': 0xFF4E342E},
    {'n': 'Gardening', 'e': '🌿', 'c': 0xFF388E3C},
    {'n': 'Welding', 'e': '🔥', 'c': 0xFFBF360C},
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadUser();
    TtsTranslationService().init();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final id =
          widget.phoneUID ??
          UserSession().phoneUID ??
          _authService.getUserPhoneDocId();
      if (id != null) {
        final doc = await _authService.getUserProfile(id);
        if (doc != null) {
          final d = doc.data() as Map<String, dynamic>;
          final city = d['city'] as String? ?? '';
          final country = d['country'] as String? ?? '';
          final addr = d['address'] as String? ?? '';
          final loc = addr.isNotEmpty
              ? addr
              : [city, country].where((s) => s.isNotEmpty).join(', ');
          setState(() {
            _firstName = d['firstName'] as String? ?? 'User';
            _imageUrl = d['profileImage'] as String? ?? '';
            _city = city;
            _location = loc.isNotEmpty ? loc : 'Location not set';
            _loading = false;
          });
          _fadeCtrl.forward();
          return;
        }
      }
    } catch (e) {
      debugPrint('HomePage load error: $e');
    }
    setState(() {
      _firstName = 'User';
      _loading = false;
    });
    _fadeCtrl.forward();
  }

  void _toAllOffers({String? cat}) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AllOffersScreen(
        phoneUID: widget.phoneUID,
        buyerCity: _city,
        initialCategory: cat,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildCategories()),
            if (_city.isNotEmpty) SliverToBoxAdapter(child: _buildTopWorkers()),
            SliverToBoxAdapter(child: _buildFeaturedOffers()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _tealDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x55004D40),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _loading ? '...' : 'Hi, $_firstName! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (_location.isNotEmpty &&
                            _location != 'Location not set')
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  _location,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11.5,
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
                  // Notification bell
                  NotificationBell(
                    uid: widget.phoneUID ?? '',
                    color: Colors.white,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NotificationsPage(uid: widget.phoneUID ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _headerIconBtn(
                    Icons.people_outline_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SellerDirectoryScreen(phoneUID: widget.phoneUID),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Hero text
              const Text(
                'Find trusted workers,\nfor every task.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20),

              // Search — tappable pill (navigates to AllOffersScreen)
              GestureDetector(
                onTap: () => _toAllOffers(),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search_rounded, color: _teal, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search offers, skills, workers…',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _teal,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
      ],
    ),
    child: CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white.withOpacity(0.2),
      backgroundImage: _imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null,
      child: _imageUrl.isEmpty
          ? Text(
              _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null,
    ),
  );

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );

  // ──────────────────────────────────────────────────────────
  // STATS ROW
  // ──────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      {'v': '10K+', 'l': 'Workers', 'i': Icons.people_rounded, 'c': _teal},
      {
        'v': '50+',
        'l': 'Services',
        'i': Icons.build_circle_outlined,
        'c': const Color(0xFF1565C0),
      },
      {
        'v': '4.8★',
        'l': 'Rating',
        'i': Icons.star_rounded,
        'c': const Color(0xFFF57F17),
      },
      {
        'v': '100%',
        'l': 'Secure',
        'i': Icons.verified_user_outlined,
        'c': const Color(0xFF6A1B9A),
      },
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(s['i'] as IconData, color: s['c'] as Color, size: 22),
                  const SizedBox(height: 5),
                  Text(
                    s['v'] as String,
                    style: TextStyle(
                      color: s['c'] as Color,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    s['l'] as String,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // CATEGORIES
  // ──────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _sectionHeader(
              'Browse by Category',
              'See All',
              () => _toAllOffers(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 0, right: 16),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final color = Color(cat['c'] as int);
                return GestureDetector(
                  onTap: () => _toAllOffers(cat: cat['n'] as String),
                  child: Container(
                    width: 82,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              cat['e'] as String,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['n'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  // ──────────────────────────────────────────────────────────
  // TOP WORKERS IN CITY
  // ──────────────────────────────────────────────────────────
  Widget _buildTopWorkers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _sectionHeader(
              'Top Workers in $_city',
              'View All',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SellerDirectoryScreen(phoneUID: widget.phoneUID),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sellers')
                .where('status', isEqualTo: 'approved')
                .orderBy('Rating', descending: true)
                .limit(12)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return _loadingShimmerRow();
              final all = snap.data!.docs;
              final cityL = _city.trim().toLowerCase();
              final same = all
                  .where(
                    (d) =>
                        ((d.data() as Map)['city'] as String? ?? '')
                            .trim()
                            .toLowerCase() ==
                        cityL,
                  )
                  .toList();
              final rest = all
                  .where(
                    (d) =>
                        ((d.data() as Map)['city'] as String? ?? '')
                            .trim()
                            .toLowerCase() !=
                        cityL,
                  )
                  .toList();
              final docs = [...same, ...rest].take(8).toList();
              if (docs.isEmpty) return const SizedBox();
              return SizedBox(
                height: 136,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final inCity = i < same.length;
                    return _workerChip(d, docs[i].id, inCity);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _workerChip(Map<String, dynamic> d, String id, bool sameCity) {
    final name = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
    final rating = (d['Rating'] ?? 0.0).toDouble();
    final jobs = (d['Jobs_Completed'] ?? 0) as int;
    final skills = List<String>.from(d['skills'] ?? []);
    final img = d['profileImage'] as String? ?? '';

    return Container(
      width: 122,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: sameCity
            ? Border.all(color: _teal.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _teal.withOpacity(0.1),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: _teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              if (sameCity)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: _teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 0,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            name.isEmpty ? 'Worker' : name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
              const SizedBox(width: 2),
              Text(
                '${rating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '  ·  $jobs',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              skills.take(2).join(', '),
              style: TextStyle(
                fontSize: 9.5,
                color: _teal.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // FEATURED OFFERS
  // ──────────────────────────────────────────────────────────
  Widget _buildFeaturedOffers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Top Offers For You',
            'Browse All',
            () => _toAllOffers(),
          ),
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('offers')
                .where('status', isEqualTo: 'active')
                .orderBy('rating', descending: true)
                .limit(5)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return _loadingShimmerList();
              if (snap.hasError) {
                // Index not created yet — show setup hint only in debug
                return _offersEmptyCard(
                  icon: Icons.storefront_outlined,
                  title: 'No Offers Yet',
                  subtitle:
                      'Once sellers post their service offers,\nthey will appear here.',
                );
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty)
                return _offersEmptyCard(
                  icon: Icons.storefront_outlined,
                  title: 'No Offers Yet',
                  subtitle:
                      'Sellers haven\'t posted offers yet.\nCheck back soon!',
                );
              return Column(
                children: [
                  ...docs.map(
                    (d) => _HomeOfferCard(
                      offerData: d.data() as Map<String, dynamic>,
                      offerId: d.id,
                      buyerUid: widget.phoneUID ?? '',
                      buyerCity: _city,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _seeAllBtn(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _seeAllBtn() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _toAllOffers(),
      icon: const Icon(Icons.storefront_outlined, color: _teal),
      label: const Text(
        'Browse All Offers',
        style: TextStyle(
          color: _teal,
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _teal, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _offersEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _seeAllBtn(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SHIMMER PLACEHOLDERS
  // ──────────────────────────────────────────────────────────
  Widget _loadingShimmerRow() => SizedBox(
    height: 136,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        width: 122,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );

  Widget _loadingShimmerList() => Column(
    children: List.generate(
      2,
      (_) => Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: _teal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HOME OFFER CARD — compact
// ═══════════════════════════════════════════════════════════════
class _HomeOfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  const _HomeOfferCard({
    required this.offerData,
    required this.offerId,
    required this.buyerUid,
    required this.buyerCity,
  });

  static const _teal = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final title = offerData['title'] as String? ?? 'Service Offer';
    final desc = offerData['description'] as String? ?? '';
    final price = (offerData['price'] ?? 0).toDouble();
    final delivery = offerData['deliveryTime'] as String? ?? '';
    final skills = List<String>.from(offerData['skills'] ?? []);
    final sellerName = offerData['sellerName'] as String? ?? 'Worker';
    final sellerImg = offerData['sellerImage'] as String? ?? '';
    final rating = (offerData['rating'] ?? 0.0).toDouble();
    final imageUrl = offerData['imageUrl'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 155,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: _teal.withOpacity(0.1),
                      backgroundImage: sellerImg.isNotEmpty
                          ? NetworkImage(sellerImg)
                          : null,
                      child: sellerImg.isEmpty
                          ? Text(
                              sellerName[0].toUpperCase(),
                              style: const TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$rating',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PKR ${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _teal,
                          ),
                        ),
                        Text(
                          'starting',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                if (skills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: skills
                        .take(3)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _teal.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _teal.withOpacity(0.15),
                              ),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (delivery.isNotEmpty) ...[
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        delivery,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                    ],
                    SpeakButton(
                      text: '$title. $desc. PKR ${price.toStringAsFixed(0)}.',
                      contentId: 'home_offer_$offerId',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _openSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => OfferPlaceOrderSheet(
      offerData: offerData,
      offerId: offerId,
      buyerUid: buyerUid,
      buyerCity: buyerCity,
    ),
  );
}
