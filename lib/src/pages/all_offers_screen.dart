import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_session.dart';
import 'offer_place_order_sheet.dart';
import 'SellerDirectoryScreen.dart';   // SellerProfileSheet lives here
import 'tts_translation_service.dart';

// ═══════════════════════════════════════════════════════════════R
//  ALL OFFERS SCREEN  v4n
//
//  Data model (confirmed from Firestore screenshots):
//    sellers/{uid}/offers/{offerId}  — offer fields
//    users/{uid}                     — profileImage, city (NOT in sellers doc)
//
//  Strategy:
//    1. Stream collectionGroup('offers').where('status','active')
//    2. Extract unique sellerIds from offer docs
//    3. Batch-fetch users/{sellerId} for city + profileImage
//    4. Merge enriched data client-side
//    5. All filter/sort done client-side → no composite index needed
// ═══════════════════════════════════════════════════════════════
class AllOffersScreen extends StatefulWidget {
  final String? phoneUID;
  final String  buyerCity;
  final String? initialCategory;
  const AllOffersScreen({
    super.key,
    this.phoneUID,
    this.buyerCity = '',
    this.initialCategory,
  });
  @override
  State<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends State<AllOffersScreen> {
  static const _teal     = Color(0xFF00695C);
  static const _bg       = Color(0xFFF3F5F8);

  // ── Stream + enriched data ────────────────────────────────
  StreamSubscription<QuerySnapshot>? _offerSub;
  List<Map<String, dynamic>> _enrichedOffers = [];
  Map<String, Map<String, dynamic>> _userCache = {};
  bool _loadingOffers = true;

  // ── Filter / sort state ───────────────────────────────────
  final _searchCtrl = TextEditingController();
  String  _query    = '';
  String? _selCat;
  bool    _cityOnly = false;
  String  _sortBy   = 'rating';  // 'rating' | 'price_asc' | 'price_desc'

  static const _cats = [
    {'n': 'All',        'e': '🌟'},
    {'n': 'Plumbing',   'e': '🔧'},
    {'n': 'Electrical', 'e': '⚡'},
    {'n': 'Cleaning',   'e': '🧹'},
    {'n': 'Carpentry',  'e': '🪚'},
    {'n': 'AC Repair',  'e': '❄️'},
    {'n': 'Painting',   'e': '🎨'},
    {'n': 'Mechanic',   'e': '🔩'},
    {'n': 'Roofing',    'e': '🏗️'},
    {'n': 'Gardening',  'e': '🌿'},
    {'n': 'Welding',    'e': '🔥'},
    {'n': 'Masonry',    'e': '🧱'},
    {'n': 'Tiling',     'e': '🪟'},
  ];

  @override
  void initState() {
    super.initState();
    _selCat   = widget.initialCategory;
    _cityOnly = widget.buyerCity.isNotEmpty;
    _searchCtrl.addListener(() =>
        setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
    _listenToOffers();
  }

  @override
  void dispose() {
    _offerSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Subscribe to offers + enrich with user data ───────────
  void _listenToOffers() {
    _offerSub = FirebaseFirestore.instance
        .collectionGroup('offers')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snap) async {
      final rawOffers = snap.docs
          .map((d) => {...d.data() as Map<String, dynamic>, '_offerId': d.id})
          .toList();

      // Collect unique seller UIDs
      final sellerIds = rawOffers
          .map((o) => (o['sellerId'] as String? ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toSet();

      // Fetch users we don't have yet
      final missing = sellerIds.where((id) => !_userCache.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        await _batchFetchUsers(missing);
      }

      // Merge offer + user data
      final enriched = rawOffers.map((offer) {
        final sid   = (offer['sellerId'] as String? ?? '').trim();
        final user  = _userCache[sid] ?? {};
        // Build seller name: prefer offer's stored name, fall back to user doc
        final storedName   = (offer['sellerName'] as String? ?? '').trim();
        final userFirst    = (user['firstName']    as String? ?? '').trim();
        final userLast     = (user['lastName']     as String? ?? '').trim();
        final sellerName   = storedName.isNotEmpty
            ? storedName
            : '$userFirst $userLast'.trim();
        // profileImage comes from users collection
        final sellerImage  = (user['profileImage'] as String? ?? '').trim();
        // city comes from users collection (lowercase comparison later)
        final sellerCity   = (user['city'] as String? ?? '').trim();
        return {
          ...offer,
          'sellerName':  sellerName,
          'sellerImage': sellerImage,
          'sellerCity':  sellerCity,
        };
      }).toList();

      if (mounted) setState(() { _enrichedOffers = enriched; _loadingOffers = false; });
    }, onError: (_) {
      if (mounted) setState(() => _loadingOffers = false);
    });
  }

  Future<void> _batchFetchUsers(List<String> uids) async {
    // Firestore whereIn supports up to 30 items; chunk if needed
    const chunk = 30;
    for (int i = 0; i < uids.length; i += chunk) {
      final batch = uids.skip(i).take(chunk).toList();
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          _userCache[doc.id] = doc.data() as Map<String, dynamic>;
        }
      } catch (_) {}
    }
  }

  // ── Filter + sort ─────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    var list = List<Map<String, dynamic>>.from(_enrichedOffers);

    // City filter — case-insensitive
    if (_cityOnly && widget.buyerCity.isNotEmpty) {
      final bC = widget.buyerCity.trim().toLowerCase();
      list = list.where((o) =>
        (o['sellerCity'] as String? ?? '').toLowerCase() == bC).toList();
    }

    // Category filter
    if (_selCat != null) {
      final cat = _selCat!.toLowerCase();
      list = list.where((o) {
        final title  = (o['title']  as String? ?? '').toLowerCase();
        final skills = List<String>.from(o['skills'] ?? []).join(' ').toLowerCase();
        return title.contains(cat) || skills.contains(cat);
      }).toList();
    }

    // Search
    if (_query.isNotEmpty) {
      list = list.where((o) {
        final hay = [
          o['title']       ?? '',
          o['description'] ?? '',
          o['sellerName']  ?? '',
          o['sellerCity']  ?? '',
          ...List<String>.from(o['skills'] ?? []),
        ].join(' ').toLowerCase();
        return hay.contains(_query);
      }).toList();
    }

    // Sort
    list.sort((a, b) {
      switch (_sortBy) {
        case 'price_asc':
          return ((a['price'] ?? 0) as num).compareTo((b['price'] ?? 0) as num);
        case 'price_desc':
          return ((b['price'] ?? 0) as num).compareTo((a['price'] ?? 0) as num);
        default: // rating
          final ar = (a['rating'] ?? 0.0).toDouble();
          final br = (b['rating'] ?? 0.0).toDouble();
          return br.compareTo(ar);
      }
    });

    // Float buyer's city to top
    if (widget.buyerCity.isNotEmpty && !_cityOnly) {
      final bC = widget.buyerCity.trim().toLowerCase();
      list.sort((a, b) {
        final aLocal = (a['sellerCity'] as String? ?? '').toLowerCase() == bC ? 0 : 1;
        final bLocal = (b['sellerCity'] as String? ?? '').toLowerCase() == bC ? 0 : 1;
        return aLocal.compareTo(bLocal);
      });
    }

    return list;
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // ── Fixed header (no overlap) ──────────────────────
        _buildHeader(context),
        // ── Category chips ─────────────────────────────────
        _buildCategoryChips(),
        // ── Filter / results bar ───────────────────────────
        _buildResultsBar(),
        // ── Offers list ────────────────────────────────────
        Expanded(child: _buildBody()),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF00695C), Color(0xFF004D40)]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x44004D40), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row
          Row(children: [
            _iconBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(ctx)),
            const Spacer(),
            _iconBtn(Icons.sort_rounded, _showSortSheet),
            const SizedBox(width: 8),
            const GlobalLanguageButton(color: Colors.white),
          ]),
          const SizedBox(height: 10),
          const Text('Service Offers',
            style: TextStyle(color: Colors.white, fontSize: 24,
                fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(
            widget.buyerCity.isNotEmpty
                ? '${_enrichedOffers.length} offers available near ${widget.buyerCity}'
                : '${_enrichedOffers.length} offers available',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
          const SizedBox(height: 14),
          // Search bar
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search offers, skills, workers…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: _teal, size: 22),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                        onPressed: _searchCtrl.clear)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          // City filter pills
          if (widget.buyerCity.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(children: [
              _filterPill('All', !_cityOnly, () => setState(() => _cityOnly = false)),
              const SizedBox(width: 8),
              _filterPill('📍 ${widget.buyerCity}', _cityOnly, () => setState(() => _cityOnly = true)),
            ]),
          ],
        ]),
      )),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20)),
  );

  Widget _filterPill(String label, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.white : Colors.white.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
        color: active ? _teal : Colors.white)),
    ),
  );

  // ── Category chips ─────────────────────────────────────────
  Widget _buildCategoryChips() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: SizedBox(height: 36, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: _cats.length,
      itemBuilder: (_, i) {
        final cat      = _cats[i];
        final label    = cat['n'] as String;
        final emoji    = cat['e'] as String;
        final isAll    = label == 'All';
        final selected = isAll ? _selCat == null : _selCat == label;
        return GestureDetector(
          onTap: () => setState(() => _selCat = isAll ? null : label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? _teal : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? _teal : Colors.grey.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.grey[700])),
            ]),
          ),
        );
      },
    )),
  );

  // ── Results bar ────────────────────────────────────────────
  Widget _buildResultsBar() {
    final count = _filtered.length;
    const labels = {'rating': 'Top Rated', 'price_asc': 'Price ↑', 'price_desc': 'Price ↓'};
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(children: [
        Text('$count ${count == 1 ? 'offer' : 'offers'}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700])),
        const Spacer(),
        GestureDetector(
          onTap: _showSortSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _teal.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _teal.withOpacity(0.2))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.swap_vert_rounded, size: 14, color: _teal),
              const SizedBox(width: 4),
              Text(labels[_sortBy] ?? 'Sort',
                style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w700)),
            ])),
        ),
      ]),
    );
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loadingOffers) return _shimmer();
    final offers = _filtered;
    if (offers.isEmpty) return _emptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 32),
      itemCount: offers.length,
      itemBuilder: (_, i) => _OfferCard(
        offerData: offers[i],
        offerId: offers[i]['_offerId'] as String? ?? '',
        buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
        buyerCity: widget.buyerCity,
      ),
    );
  }

  Widget _shimmer() => ListView.builder(
    padding: const EdgeInsets.all(14), itemCount: 4,
    itemBuilder: (_, i) => Container(height: 220, margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20))));

  Widget _emptyState() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(color: _teal.withOpacity(0.07), shape: BoxShape.circle),
        child: const Icon(Icons.storefront_outlined, size: 40, color: _teal)),
      const SizedBox(height: 20),
      Text(_query.isNotEmpty ? 'No results for "$_query"'
          : _cityOnly ? 'No offers near ${widget.buyerCity}'
          : _selCat != null ? 'No "$_selCat" offers yet'
          : 'No offers yet',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87)),
      const SizedBox(height: 8),
      Text('Try a different filter or check back soon.',
        style: TextStyle(fontSize: 13, color: Colors.grey[500])),
    ]),
  ));

  void _showSortSheet() => showModalBottomSheet(
    context: context, backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
      const Text('Sort Offers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _sortTile('⭐  Top Rated',     'rating'),
      _sortTile('💰  Lowest Price',  'price_asc'),
      _sortTile('💎  Highest Price', 'price_desc'),
      const SizedBox(height: 12),
    ])));

  Widget _sortTile(String label, String val) => ListTile(
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    trailing: _sortBy == val ? const Icon(Icons.check_rounded, color: _teal) : null,
    onTap: () { setState(() => _sortBy = val); Navigator.pop(context); },
  );
}

// ══════════════════════════════════════════════════════════════
//  OFFER CARD
// ══════════════════════════════════════════════════════════════
class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  static const _teal = Color(0xFF00695C);

  const _OfferCard({required this.offerData, required this.offerId,
      required this.buyerUid, required this.buyerCity});

  @override
  Widget build(BuildContext context) {
    final title      = offerData['title']        as String? ?? 'Service Offer';
    final desc       = offerData['description']  as String? ?? '';
    final price      = (offerData['price']       ?? 0).toDouble();
    final delivery   = offerData['deliveryTime'] as String? ?? '';
    final skills     = List<String>.from(offerData['skills'] ?? []);
    final sellerName = offerData['sellerName']   as String? ?? 'Worker';
    final sellerImg  = offerData['sellerImage']  as String? ?? '';  // from users
    final sellerId   = offerData['sellerId']     as String? ?? '';
    final sellerCity = offerData['sellerCity']   as String? ?? '';  // from users
    final rating     = (offerData['rating']      ?? 0.0).toDouble();
    final orders     = (offerData['ordersCount'] ?? 0) as int;
    final imageUrl   = offerData['imageUrl']     as String? ?? '';
    final nearBuyer  = buyerCity.isNotEmpty &&
        sellerCity.trim().toLowerCase() == buyerCity.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        border: nearBuyer ? Border.all(color: _teal.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Cover image ───────────────────────────────────
        if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(children: [
              Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
                loadingBuilder: (_, child, prog) => prog == null ? child
                  : Container(height: 160, color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2)))),
              if (nearBuyer) Positioned(top: 12, right: 12, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)]),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on, size: 11, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Near You', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ]))),
            ]),
          ),

        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Seller row ───────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Tap avatar → seller profile sheet
              GestureDetector(
                onTap: () => _showProfile(context, sellerId),
                child: CircleAvatar(radius: 22, backgroundColor: _teal.withOpacity(0.1),
                  backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
                  child: sellerImg.isEmpty
                      ? Text(sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'W',
                          style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 18))
                      : null),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => _showProfile(context, sellerId),
                  child: Text(sellerName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87))),
                Row(children: [
                  Icon(Icons.star_rounded, size: 13, color: Colors.amber[600]),
                  const SizedBox(width: 2),
                  Text(rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  if (orders > 0) Text('  ·  $orders orders',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  if (sellerCity.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.location_city_outlined, size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 2),
                    Text(sellerCity, style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('PKR ${price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _teal)),
                Text('starting', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ]),
            ]),

            const Divider(height: 18, color: Color(0xFFF0F0F0)),

            // ── Title + desc ─────────────────────────────
            Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800,
                color: Colors.black87, letterSpacing: -0.2)),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.45),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 10),

            // ── Skills ───────────────────────────────────
            if (skills.isNotEmpty) Wrap(spacing: 6, runSpacing: 5,
              children: skills.take(4).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _teal.withOpacity(0.15))),
                child: Text(s, style: const TextStyle(fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
              )).toList()),
            const SizedBox(height: 12),

            // ── Footer row ───────────────────────────────
            Row(children: [
              if (delivery.isNotEmpty) ...[
                Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(delivery, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(width: 8),
              ],
              SpeakButton(text: '$title. $desc.', contentId: 'offer_$offerId'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _openSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                child: const Text('Place Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ]),
          ])),
      ]),
    );
  }

  void _openSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent,
    builder: (_) => OfferPlaceOrderSheet(
      offerData: offerData, offerId: offerId, buyerUid: buyerUid, buyerCity: buyerCity));

  void _showProfile(BuildContext ctx, String sid) {
    if (sid.isEmpty) return;
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => SellerProfileSheet(
        sellerId: sid, buyerUid: buyerUid, buyerCity: buyerCity));
  }
}