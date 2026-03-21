


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import 'SellerDirectoryScreen.dart';
import 'notification_service.dart';
import 'all_offers_screen.dart';
import 'offer_place_order_sheet.dart';
import 'tts_translation_service.dart';

class HomePage extends StatefulWidget {
  final String? phoneUID;
  const HomePage({super.key, this.phoneUID});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  String _firstName = '';
  String _location  = '';
  String _city      = '';
  String _imageUrl  = '';
  String _myUid     = '';
  bool   _loading   = true;

  List<Map<String, dynamic>> _topWorkers = [];
  final Map<String, Map<String, dynamic>> _userCache = {};

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  static const List<Map<String, dynamic>> _cats = [
    {'n': 'Plumbing',   'e': '🔧', 'c': 0xFF1565C0},
    {'n': 'Electrical', 'e': '⚡', 'c': 0xFFF57F17},
    {'n': 'Cleaning',   'e': '🧹', 'c': 0xFF2E7D32},
    {'n': 'Carpentry',  'e': '🪚', 'c': 0xFF6D4C41},
    {'n': 'AC Repair',  'e': '❄️', 'c': 0xFF0277BD},
    {'n': 'Painting',   'e': '🎨', 'c': 0xFFAD1457},
    {'n': 'Mechanic',   'e': '🔩', 'c': 0xFF37474F},
    {'n': 'Roofing',    'e': '🏗️', 'c': 0xFF4E342E},
    {'n': 'Gardening',  'e': '🌿', 'c': 0xFF388E3C},
    {'n': 'Welding',    'e': '🔥', 'c': 0xFFBF360C},
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
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    TtsTranslationService().init();
    _loadUser();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _loadUser() async {
    try {
      final id = widget.phoneUID ?? UserSession().phoneUID ?? _authService.getUserPhoneDocId();
      if (id != null) {
        final doc = await _authService.getUserProfile(id);
        if (doc != null) {
          final d    = doc.data() as Map<String, dynamic>;
          final city = d['city']    as String? ?? '';
          final cty  = d['country'] as String? ?? '';
          final addr = d['address'] as String? ?? '';
          final loc  = addr.isNotEmpty ? addr : [city, cty].where((s) => s.isNotEmpty).join(', ');
          _myUid = id.trim();
          setState(() {
            _firstName = d['firstName'] as String? ?? 'User';
            _imageUrl  = d['profileImage'] as String? ?? '';
            _city      = city;
            _location  = loc.isNotEmpty ? loc : 'Location not set';
            _loading   = false;
          });
          _fadeCtrl.forward();
          _loadTopWorkers();
          return;
        }
      }
    } catch (e) { debugPrint('loadUser: $e'); }
    setState(() { _firstName = 'User'; _loading = false; });
    _fadeCtrl.forward();
    _loadTopWorkers();
  }

  Future<void> _loadTopWorkers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sellers').where('status', isEqualTo: 'approved').limit(40).get();
      if (snap.docs.isEmpty) return;
      final uids    = snap.docs.map((d) => d.id).toList();
      final missing = uids.where((id) => !_userCache.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        for (int i = 0; i < missing.length; i += 30) {
          final chunk = missing.skip(i).take(30).toList();
          try {
            final us = await FirebaseFirestore.instance.collection('users')
                .where(FieldPath.documentId, whereIn: chunk).get();
            for (final ud in us.docs) _userCache[ud.id] = ud.data() as Map<String, dynamic>;
          } catch (_) {}
        }
      }
      var workers = snap.docs.map((doc) {
        final sd = doc.data() as Map<String, dynamic>;
        final ud = _userCache[doc.id] ?? {};
        return {
          ...sd, '_uid': doc.id,
          'profileImage': (ud['profileImage'] as String? ?? '').trim(),
          'city':         (ud['city']         as String? ?? '').trim(),
          'firstName': (ud['firstName'] ?? sd['firstName'] ?? '').toString().trim(),
          'lastName':  (ud['lastName']  ?? sd['lastName']  ?? '').toString().trim(),
        };
      }).toList();
      workers = workers.where((w) => (w['_uid'] as String? ?? '').trim() != _myUid).toList();
      final cL = _city.trim().toLowerCase();
      workers.sort((a, b) {
        final aCity = (a['city'] as String? ?? '').toLowerCase() == cL ? 0 : 1;
        final bCity = (b['city'] as String? ?? '').toLowerCase() == cL ? 0 : 1;
        if (aCity != bCity) return aCity.compareTo(bCity);
        return ((b['Rating'] ?? 0.0).toDouble()).compareTo((a['Rating'] ?? 0.0).toDouble());
      });
      if (mounted) setState(() => _topWorkers = workers.take(10).toList());
    } catch (e) { debugPrint('loadWorkers: $e'); }
  }

  void _toAllOffers({String? cat}) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => AllOffersScreen(
          phoneUID: widget.phoneUID, buyerCity: _city, initialCategory: cat)));

  void _toDirectory() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => SellerDirectoryScreen(
          phoneUID: widget.phoneUID, buyerCity: _city)));

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
            if (_topWorkers.isNotEmpty)
              SliverToBoxAdapter(child: _buildTopWorkers()),
            SliverToBoxAdapter(child: _buildFeaturedOffers()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_teal, _tealDark]),
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      boxShadow: [BoxShadow(color: Color(0x55004D40), blurRadius: 20, offset: Offset(0, 8))]),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _buildAvatar(), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting(), style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500)),
            Text(_loading ? '…' : 'Hi, $_firstName! 👋',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            if (_location.isNotEmpty && _location != 'Location not set')
              Row(children: [
                const Icon(Icons.location_on, size: 12, color: Colors.white60), const SizedBox(width: 3),
                Expanded(child: Text(_location, style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
          ])),
          NotificationBell(uid: widget.phoneUID ?? '', color: Colors.white,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NotificationsPage(uid: widget.phoneUID ?? '')))),
          const SizedBox(width: 6),
          _iconBtn(Icons.people_outline_rounded, _toDirectory),
        ]),
        const SizedBox(height: 22),
        const Text('Find trusted workers,\nfor every task.',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900,
                height: 1.25, letterSpacing: -0.5)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _toAllOffers(),
          child: Container(height: 52,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 5))]),
            child: Row(children: [
              const SizedBox(width: 16),
              Icon(Icons.search_rounded, color: _teal, size: 24), const SizedBox(width: 10),
              Expanded(child: Text('Search offers, skills, workers…',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500))),
              Container(margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(24)),
                  child: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      ]),
    )),
  );

  Widget _buildAvatar() => Container(
    decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
    child: CircleAvatar(radius: 26, backgroundColor: Colors.white.withOpacity(0.2),
      backgroundImage: _imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null,
      child: _imageUrl.isEmpty ? Text(_firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)) : null),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22)));

  Widget _buildStatsRow() {
    final stats = [
      {'v': '10K+', 'l': 'Workers',  'i': Icons.people_rounded,         'c': _teal},
      {'v': '50+',  'l': 'Services', 'i': Icons.build_circle_outlined,  'c': const Color(0xFF1565C0)},
      {'v': '4.8★', 'l': 'Rating',   'i': Icons.star_rounded,           'c': const Color(0xFFF57F17)},
      {'v': '100%', 'l': 'Secure',   'i': Icons.verified_user_outlined, 'c': const Color(0xFF6A1B9A)},
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(children: stats.asMap().entries.map((e) {
        final s = e.value;
        return Expanded(child: Container(
          margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: [
            Icon(s['i'] as IconData, color: s['c'] as Color, size: 22),
            const SizedBox(height: 5),
            Text(s['v'] as String, style: TextStyle(color: s['c'] as Color, fontSize: 13.5, fontWeight: FontWeight.w900)),
            Text(s['l'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ));
      }).toList()),
    );
  }

  Widget _buildCategories() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 26, 0, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(right: 16),
          child: _sectionHeader('Browse by Category', 'See All', () => _toAllOffers())),
      const SizedBox(height: 14),
      SizedBox(height: 100, child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(right: 16),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final cat   = _cats[i];
          final color = Color(cat['c'] as int);
          return GestureDetector(
            onTap: () => _toAllOffers(cat: cat['n'] as String),
            child: Container(width: 82, margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(cat['e'] as String, style: const TextStyle(fontSize: 26)))),
                const SizedBox(height: 8),
                Text(cat['n'] as String,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                    textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      )),
    ]),
  );

  Widget _buildTopWorkers() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(right: 16),
          child: _sectionHeader(
              _city.isNotEmpty ? 'Top Workers in $_city' : 'Top Workers', 'View All', _toDirectory)),
      const SizedBox(height: 14),
      SizedBox(height: 146, child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(right: 16),
        itemCount: _topWorkers.length,
        itemBuilder: (ctx, i) => _WorkerChip(
          worker: _topWorkers[i],
          buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
          buyerCity: _city),
      )),
    ]),
  );

  Widget _buildFeaturedOffers() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _sectionHeader(
        _city.isNotEmpty ? 'Top Offers Near You' : 'Top Offers For You',
        'View All', () => _toAllOffers(),
      ),
      const SizedBox(height: 4),
      Text(
        _city.isNotEmpty ? 'Best service offers in $_city' : 'Handpicked offers from top workers',
        style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 16),
      _OffersSection(
        city: _city,
        buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
        onViewAll: () => _toAllOffers(),
      ),
    ]),
  );

  Widget _sectionHeader(String title, String action, VoidCallback onTap) =>
      Row(children: [
        Expanded(child: Text(title, style: const TextStyle(
            fontSize: 18.5, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.3))),
        GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: _teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(action, style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)))),
      ]);
}

// ═══════════════════════════════════════════════════════════════
//  OFFERS SECTION  —  isolated StatefulWidget
//  Its setState never propagates to the parent CustomScrollView.
//  RULE: zero Material buttons (ElevatedButton / OutlinedButton /
//        TextButton) anywhere in this tree — they all force w=Infinity.
// ═══════════════════════════════════════════════════════════════
class _OffersSection extends StatefulWidget {
  final String city, buyerUid;
  final VoidCallback onViewAll;
  const _OffersSection({required this.city, required this.buyerUid, required this.onViewAll});
  @override
  State<_OffersSection> createState() => _OffersSectionState();
}

class _OffersSectionState extends State<_OffersSection> {
  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  final Map<String, Map<String, dynamic>> _cache = {};
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _listen(); }

  void _listen() {
    FirebaseFirestore.instance
        .collectionGroup('offers')
        .limit(20)
        .snapshots()
        .listen((snap) async {
      if (snap.docs.isEmpty) {
        if (mounted) setState(() { _offers = []; _loading = false; });
        return;
      }
      final raw = snap.docs
          .map((d) => {...d.data() as Map<String, dynamic>, '_offerId': d.id})
          .toList();
      final sids = raw
          .map((o) => (o['sellerId'] as String? ?? '').trim())
          .where((id) => id.isNotEmpty).toSet();
      final missing = sids.where((id) => !_cache.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        for (int i = 0; i < missing.length; i += 30) {
          final chunk = missing.skip(i).take(30).toList();
          try {
            final us = await FirebaseFirestore.instance.collection('users')
                .where(FieldPath.documentId, whereIn: chunk).get();
            for (final ud in us.docs) _cache[ud.id] = ud.data() as Map<String, dynamic>;
          } catch (_) {}
        }
      }
      final enriched = raw.map((o) {
        final sid  = (o['sellerId'] as String? ?? '').trim();
        final user = _cache[sid] ?? {};
        final sn   = (o['sellerName'] as String? ?? '').trim();
        final uf   = (user['firstName'] as String? ?? '').trim();
        final ul   = (user['lastName']  as String? ?? '').trim();
        return {
          ...o,
          'sellerName':  sn.isNotEmpty ? sn : '$uf $ul'.trim(),
          'sellerImage': (o['sellerImage'] as String? ?? '').isNotEmpty
              ? o['sellerImage'] : (user['profileImage'] as String? ?? ''),
          'sellerCity':  (user['city'] as String? ?? '').trim(),
        };
      }).toList();
      // Filter out offers posted by the current user (seller == buyer)
      final filtered = enriched.where((o) =>
          (o['sellerId'] as String? ?? '').trim() != widget.buyerUid.trim()).toList();

      final cL = widget.city.trim().toLowerCase();
      filtered.sort((a, b) {
        final aC = (a['sellerCity'] as String? ?? '').toLowerCase() == cL ? 0 : 1;
        final bC = (b['sellerCity'] as String? ?? '').toLowerCase() == cL ? 0 : 1;
        if (aC != bC) return aC.compareTo(bC);
        return ((a['price'] ?? 0) as num).compareTo((b['price'] ?? 0) as num);
      });
      if (mounted) setState(() { _offers = filtered.take(5).toList(); _loading = false; });
    }, onError: (_) { if (mounted) setState(() => _loading = false); });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(children: [_shimmer(), const SizedBox(height: 12), _shimmer()]);
    }
    if (_offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
        child: Column(children: [
          Icon(Icons.storefront_outlined, size: 46, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text('No Offers Yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text('Check back soon!', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ..._offers.map((o) => _OfferCard(
        offerData: o,
        offerId:   o['_offerId'] as String? ?? '',
        buyerUid:  widget.buyerUid,
        buyerCity: widget.city,
      )),
      const SizedBox(height: 8),
      // Browse All — GestureDetector+Container, NEVER OutlinedButton
      GestureDetector(
        onTap: widget.onViewAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _teal, width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.storefront_outlined, color: _teal, size: 18),
            SizedBox(width: 8),
            Text('Browse All Offers',
                style: TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
      ),
      const SizedBox(height: 4),
    ]);
  }

  Widget _shimmer() => Container(height: 150,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)));
}

// ═══════════════════════════════════════════════════════════════
//  WORKER CHIP
// ═══════════════════════════════════════════════════════════════
class _WorkerChip extends StatelessWidget {
  final Map<String, dynamic> worker;
  final String buyerUid, buyerCity;
  static const _teal = Color(0xFF00695C);
  const _WorkerChip({required this.worker, required this.buyerUid, required this.buyerCity});

  @override
  Widget build(BuildContext context) {
    final uid      = worker['_uid']            as String? ?? '';
    final first    = worker['firstName']       as String? ?? '';
    final last     = worker['lastName']        as String? ?? '';
    final name     = '$first $last'.trim();
    final img      = worker['profileImage']    as String? ?? '';
    final city     = worker['city']            as String? ?? '';
    final rating   = (worker['Rating']         ?? 0.0).toDouble();
    final jobs     = (worker['Jobs_Completed'] ?? 0) as int;
    final skills   = List<String>.from(worker['skills'] ?? []);
    final sameCity = city.trim().toLowerCase() == buyerCity.trim().toLowerCase() && buyerCity.isNotEmpty;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => SellerProfileSheet(
            sellerId: uid, preloadedSellerDoc: worker, buyerUid: buyerUid, buyerCity: buyerCity)),
      child: Container(
        width: 122, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: sameCity ? Border.all(color: _teal.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Stack(alignment: Alignment.topRight, children: [
            CircleAvatar(radius: 28, backgroundColor: _teal.withOpacity(0.1),
              backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
              child: img.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'W',
                  style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 22)) : null),
            if (sameCity) Container(width: 16, height: 16,
              decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 1.5)]),
              child: const Icon(Icons.location_on, size: 10, color: Colors.white)),
          ]),
          const SizedBox(height: 7),
          Text(name.isEmpty ? 'Worker' : name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.star_rounded, size: 11, color: Colors.amber[600]), const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
            Text('  $jobs', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ]),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(skills.take(2).join(', '),
                style: TextStyle(fontSize: 9.5, color: _teal.withOpacity(0.8), fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  OFFER CARD — identical pattern to AllOffersScreen._OfferCard
//  which works with zero crashes.
//  Key rules enforced:
//  ✅ GestureDetector+Container for Place Order (not ElevatedButton)
//  ✅ Row for skills (not Wrap)
//  ✅ plain Text for description (not TranslatedText)
//  ✅ Expanded(delivery) so Spacer is always in a bounded Row
// ═══════════════════════════════════════════════════════════════
class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;

  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  const _OfferCard({
    required this.offerData,
    required this.offerId,
    required this.buyerUid,
    required this.buyerCity,
  });

  @override
  Widget build(BuildContext context) {
    final title      = (offerData['title']        as String? ?? 'Service Offer').trim();
    final desc       = (offerData['description']  as String? ?? '').trim();
    final price      = (offerData['price']        as num?    ?? 0).toDouble();
    final delivery   = (offerData['deliveryTime'] as String? ?? '').trim();
    final skills     = (offerData['skills'] is List)
        ? List<String>.from(offerData['skills'] as List) : <String>[];
    final sellerName = (offerData['sellerName']   as String? ?? '').trim();
    final sellerImg  = (offerData['sellerImage']  as String? ?? '').trim();
    final sellerId   = (offerData['sellerId']     as String? ?? '').trim();
    final sellerCity = (offerData['sellerCity']   as String? ?? '').trim();
    final rating     = (offerData['rating']       as num?    ?? 0.0).toDouble();
    final orders     = (offerData['ordersCount']  as int?    ?? 0);
    final imageUrl   = (offerData['imageUrl']     as String? ?? '').trim();
    final nearBuyer  = buyerCity.isNotEmpty &&
        sellerCity.trim().toLowerCase() == buyerCity.trim().toLowerCase();
    final displayName = sellerName.isNotEmpty ? sellerName : 'Worker';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: nearBuyer ? Border.all(color: _teal.withOpacity(0.35), width: 1.8) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        if (imageUrl.isNotEmpty)
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(imageUrl, height: 155, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            Positioned(top: 10, right: 10, child: _priceBadge(price)),
            if (nearBuyer) Positioned(top: 10, left: 10, child: _nearBadge()),
          ])
        else
          Container(
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_teal.withOpacity(0.85), _tealDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, height: 1.3))),
              const SizedBox(width: 10),
              _priceBadge(price, light: false),
            ]),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              GestureDetector(
                onTap: () {
                  if (sellerId.isNotEmpty) showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => SellerProfileSheet(sellerId: sellerId, buyerUid: buyerUid, buyerCity: buyerCity));
                },
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(color: _teal.withOpacity(0.25), width: 2)),
                  child: CircleAvatar(
                    radius: 20, backgroundColor: _teal.withOpacity(0.1),
                    backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
                    child: sellerImg.isEmpty
                        ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'W',
                            style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 15))
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
                Row(children: [
                  if (sellerCity.isNotEmpty) ...[
                    Icon(Icons.location_on, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Flexible(child: Text(sellerCity, style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                  ],
                  if (nearBuyer) _nearBadge(small: true),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (rating > 0) Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star_rounded, size: 13, color: Colors.amber[600]),
                  const SizedBox(width: 2),
                  Text(rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[700])),
                ]),
                if (orders > 0) Text('$orders orders',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ]),
            ]),

            const SizedBox(height: 10),

            if (imageUrl.isNotEmpty) ...[
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800,
                      color: Colors.black87, height: 1.3)),
              const SizedBox(height: 6),
            ],

            if (desc.isNotEmpty)
              Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4)),

            const SizedBox(height: 8),

            // skills — Row, never Wrap
            if (skills.isNotEmpty)
              Row(children: skills.take(3).map((s) => Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _teal.withOpacity(0.18)),
                ),
                child: Text(s, style: const TextStyle(
                    fontSize: 10.5, color: _teal, fontWeight: FontWeight.w600)),
              )).toList()),

            const SizedBox(height: 12),

            Row(children: [
              if (delivery.isNotEmpty) Expanded(
                child: Row(children: [
                  Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Flexible(child: Text(delivery, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                ]),
              ) else const Spacer(),

              // Place Order — GestureDetector+Container, NEVER ElevatedButton
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context, isScrollControlled: true,
                  useSafeArea: true, backgroundColor: Colors.transparent,
                  builder: (_) => OfferPlaceOrderSheet(
                    offerData: offerData, offerId: offerId,
                    buyerUid: buyerUid, buyerCity: buyerCity)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_teal, _tealDark]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('Place Order', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _priceBadge(double price, {bool light = true}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: light ? Colors.white : _teal.withOpacity(0.85),
      borderRadius: BorderRadius.circular(11),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 5)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
      Text('PKR ${price.toStringAsFixed(0)}', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w900, color: light ? _tealDark : Colors.white)),
      Text('starting', style: TextStyle(fontSize: 9, color: light ? Colors.grey[500] : Colors.white70)),
    ]),
  );

  Widget _nearBadge({bool small = false}) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 6 : 9, vertical: small ? 2 : 4),
    decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.near_me_rounded, size: small ? 9 : 11, color: Colors.white),
      const SizedBox(width: 3),
      Text('Near You', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: small ? 9 : 10)),
    ]),
  );
}