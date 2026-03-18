import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_session.dart';
import 'offer_place_order_sheet.dart';
import 'SellerDirectoryScreen.dart';
import 'tts_translation_service.dart';

// ══════════════════════════════════════════════════════════════
//  ALL OFFERS SCREEN  —  v4 (layout rewrite)
//
//  WHY previous versions kept crashing:
//  ┌─ PreferredSize child never gets bounded width from Scaffold
//  │  → Column(crossAxisAlignment.start) passes UNBOUNDED width
//  │  → TextField receives infinite width → crash cascade
//
//  FIX: Remove PreferredSize entirely.
//  Use a real AppBar for chrome (back/sort/lang).
//  Move search + pills into the body Column — always bounded. ✅
//
//  NEW LOGIC:
//  • Hide buyer's OWN offers (sellerId == phoneUID)
//    so a seller-buyer can't place an order on their own listing.
// ══════════════════════════════════════════════════════════════
class AllOffersScreen extends StatefulWidget {
  final String? phoneUID;
  final String buyerCity;
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
  static const _teal = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  StreamSubscription<QuerySnapshot>? _sub;
  List<Map<String, dynamic>> _allOffers = [];
  final Map<String, String> _cityCache = {};
  bool _loading = true;

  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _cat;
  bool _nearMe = false;
  String _sort = 'rating';

  static const _cats = [
    'All',
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'AC Repair',
    'Painting',
    'Mechanic',
    'Roofing',
    'Gardening',
    'Welding',
    'Masonry',
    'Tiling',
  ];
  static const _catEmoji = {
    'All': '🌟',
    'Plumbing': '🔧',
    'Electrical': '⚡',
    'Cleaning': '🧹',
    'Carpentry': '🪚',
    'AC Repair': '❄️',
    'Painting': '🎨',
    'Mechanic': '🔩',
    'Roofing': '🏗️',
    'Gardening': '🌿',
    'Welding': '🔥',
    'Masonry': '🧱',
    'Tiling': '🪟',
  };

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cat = widget.initialCategory;
    _nearMe = widget.buyerCity.isNotEmpty;
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Firestore ─────────────────────────────────────────────────
  void _subscribe() {
    _sub = FirebaseFirestore.instance
        .collectionGroup('offers')
        .snapshots()
        .listen(
          _onData,
          onError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        );
  }

  Future<void> _onData(QuerySnapshot snap) async {
    final buyerUid = (widget.phoneUID ?? UserSession().phoneUID ?? '').trim();

    final docs = snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      final sid = (data['sellerId'] as String?)?.trim().isNotEmpty == true
          ? (data['sellerId'] as String).trim()
          : (d.reference.parent.parent?.id ?? '');
      return <String, dynamic>{...data, '_docId': d.id, 'sellerId': sid};
    }).toList();

    // ── Filter: hide buyer's OWN offers ─────────────────────────────
    //    Only exclude offers where seller == buyer (self-listings)
    final active = docs.where((o) {
      final sid = (o['sellerId'] as String? ?? '').trim();
      final isOwnOffer = buyerUid.isNotEmpty && sid == buyerUid;
      return sid.isNotEmpty && !isOwnOffer;
    }).toList();

    // ── Fetch cities from users collection ────────────────────────
    final missing = active
        .map((o) => (o['sellerId'] as String? ?? '').trim())
        .where((id) => id.isNotEmpty && !_cityCache.containsKey(id))
        .toSet()
        .toList();

    if (missing.isNotEmpty) {
      for (var i = 0; i < missing.length; i += 30) {
        final chunk = missing.skip(i).take(30).toList();
        try {
          final us = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final d in us.docs) {
            final ud = d.data();
            _cityCache[d.id] = ud.containsKey('city')
                ? (ud['city'] as String? ?? '').trim()
                : '';
          }
          for (final uid in chunk) _cityCache.putIfAbsent(uid, () => '');
        } catch (_) {
          for (final uid in chunk) _cityCache.putIfAbsent(uid, () => '');
        }
      }
    }

    final enriched = active.map((o) {
      final sid = (o['sellerId'] as String? ?? '').trim();
      return <String, dynamic>{...o, 'sellerCity': _cityCache[sid] ?? ''};
    }).toList();

    if (mounted)
      setState(() {
        _allOffers = enriched;
        _loading = false;
      });
  }

  // ── Filter + sort ─────────────────────────────────────────────
  List<Map<String, dynamic>> get _visible {
    var list = List<Map<String, dynamic>>.from(_allOffers);

    if (_nearMe && widget.buyerCity.isNotEmpty) {
      final bc = widget.buyerCity.trim().toLowerCase();
      list = list
          .where((o) => (o['sellerCity'] as String? ?? '').toLowerCase() == bc)
          .toList();
    }

    if (_cat != null && _cat != 'All') {
      final c = _cat!.toLowerCase();
      list = list.where((o) {
        final t = (o['title'] as String? ?? '').toLowerCase();
        final skills = (o['skills'] is List)
            ? List<String>.from(o['skills'] as List)
            : <String>[];
        return t.contains(c) || skills.join(' ').toLowerCase().contains(c);
      }).toList();
    }

    if (_query.isNotEmpty) {
      list = list.where((o) {
        final skills = (o['skills'] is List)
            ? List<String>.from(o['skills'] as List)
            : <String>[];
        final h = [
          o['title'] ?? '',
          o['description'] ?? '',
          o['sellerName'] ?? '',
          o['sellerCity'] ?? '',
          ...skills,
        ].join(' ').toLowerCase();
        return h.contains(_query);
      }).toList();
    }

    list.sort((a, b) {
      if (_sort == 'price_asc')
        return ((a['price'] ?? 0) as num).compareTo((b['price'] ?? 0) as num);
      if (_sort == 'price_desc')
        return ((b['price'] ?? 0) as num).compareTo((a['price'] ?? 0) as num);
      return ((b['rating'] ?? 0.0) as num).compareTo(
        (a['rating'] ?? 0.0) as num,
      );
    });

    if (!_nearMe && widget.buyerCity.isNotEmpty) {
      final bc = widget.buyerCity.trim().toLowerCase();
      list.sort((a, b) {
        final aL = (a['sellerCity'] as String? ?? '').toLowerCase() == bc
            ? 0
            : 1;
        final bL = (b['sellerCity'] as String? ?? '').toLowerCase() == bc
            ? 0
            : 1;
        return aL.compareTo(bL);
      });
    }

    return list;
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  //
  //  Layout tree:
  //  Scaffold
  //  ├─ AppBar  (standard — back / sort / lang)            ← bounded ✅
  //  └─ body: Column
  //       ├─ _SearchHeader  (gradient container)           ← bounded ✅
  //       ├─ _buildCats     (52 px horizontal list)
  //       ├─ _buildResultsBar
  //       └─ Expanded → ListView / empty / loading
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final shown = _visible;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),

      // ── Standard AppBar — no PreferredSize tricks ──────────────
      appBar: AppBar(
        backgroundColor: _tealDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Offers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 22),
            onPressed: _showSort,
          ),
          const GlobalLanguageButton(color: Colors.white),
          const SizedBox(width: 4),
        ],
      ),

      // ── Body ──────────────────────────────────────────────────
      body: Column(
        children: [
          // Search header — in body = always gets screen width ✅
          _buildSearchHeader(),
          // Categories
          _buildCats(),
          // Results bar
          _buildResultsBar(shown.length),
          // Offer list
          Expanded(child: _buildList(shown)),
        ],
      ),
    );
  }

  // ── Search header (gradient, subtitle, search bar, pills) ─────
  //  This widget is now in the BODY, so it always has
  //  a bounded width equal to the screen width — no crashes.
  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _tealDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Text(
            widget.buyerCity.isNotEmpty
                ? '${_allOffers.length} offers • ${widget.buyerCity}'
                : '${_allOffers.length} offers available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // ── Search bar ────────────────────────────────────────
          // Container has width: double.infinity + it is in a Column
          // that is a direct child of the body Column which is bounded
          // → TextField always gets a finite width. No crash.
          Container(
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search offers, skills…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _teal,
                  size: 20,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: Colors.grey,
                        ),
                        onPressed: _searchCtrl.clear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
            ),
          ),

          // Near-me pills
          if (widget.buyerCity.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _pill('All', !_nearMe, () => setState(() => _nearMe = false)),
                const SizedBox(width: 8),
                _pill(
                  '📍 ${widget.buyerCity}',
                  _nearMe,
                  () => setState(() => _nearMe = true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String l, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        l,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: active ? _teal : Colors.white,
        ),
      ),
    ),
  );

  // ── Category chips ────────────────────────────────────────────
  Widget _buildCats() => Container(
    color: Colors.white,
    height: 52,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _cats.length,
      itemBuilder: (_, i) {
        final label = _cats[i];
        final emoji = _catEmoji[label] ?? '';
        final isAll = label == 'All';
        final active = isAll ? (_cat == null || _cat == 'All') : _cat == label;
        return GestureDetector(
          onTap: () => setState(() => _cat = isAll ? null : label),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? _teal : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? _teal : Colors.grey.shade200),
            ),
            child: Text(
              '$emoji  $label',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      },
    ),
  );

  // ── Results bar ───────────────────────────────────────────────
  Widget _buildResultsBar(int count) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Row(
      children: [
        Text(
          '$count ${count == 1 ? 'offer' : 'offers'}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showSort,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _teal.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_vert_rounded, size: 14, color: _teal),
                const SizedBox(width: 4),
                Text(
                  _sort == 'price_asc'
                      ? 'Price ↑'
                      : _sort == 'price_desc'
                      ? 'Price ↓'
                      : 'Top Rated',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── Offer list ────────────────────────────────────────────────
  Widget _buildList(List<Map<String, dynamic>> offers) {
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 36,
                  color: _teal,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _query.isNotEmpty
                    ? 'No results for "$_query"'
                    : _nearMe
                    ? 'No offers near ${widget.buyerCity}'
                    : _cat != null
                    ? 'No "$_cat" offers yet'
                    : 'No active offers yet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different filter or check back soon.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 32),
      itemCount: offers.length,
      itemBuilder: (_, i) => _OfferCard(
        key: ValueKey(offers[i]['_docId'] ?? i),
        offerData: offers[i],
        offerId: offers[i]['_docId'] as String? ?? '',
        buyerUid: widget.phoneUID ?? UserSession().phoneUID ?? '',
        buyerCity: widget.buyerCity,
      ),
    );
  }

  // ── Sort sheet ────────────────────────────────────────────────
  void _showSort() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Sort Offers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          _sortTile('⭐  Top Rated', 'rating'),
          _sortTile('💰  Lowest Price', 'price_asc'),
          _sortTile('💎  Highest Price', 'price_desc'),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  Widget _sortTile(String l, String v) => ListTile(
    title: Text(
      l,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    trailing: _sort == v ? const Icon(Icons.check_rounded, color: _teal) : null,
    onTap: () {
      setState(() => _sort = v);
      Navigator.pop(context);
    },
  );
}

// ══════════════════════════════════════════════════════════════
//  OFFER CARD
// ══════════════════════════════════════════════════════════════
// class _OfferCard extends StatelessWidget {
//   final Map<String, dynamic> offerData;
//   final String offerId, buyerUid, buyerCity;
//   static const _teal = Color(0xFF00695C);

//   const _OfferCard({
//     super.key,
//     required this.offerData,
//     required this.offerId,
//     required this.buyerUid,
//     required this.buyerCity,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final title      = (offerData['title']        as String? ?? 'Service Offer').trim();
//     final desc       = (offerData['description']  as String? ?? '').trim();
//     final price      = (offerData['price']        as num?    ?? 0).toDouble();
//     final delivery   = (offerData['deliveryTime'] as String? ?? '').trim();
//     final skills     = (offerData['skills'] is List)
//         ? List<String>.from(offerData['skills'] as List) : <String>[];
//     final sellerName = (offerData['sellerName']   as String? ?? '').trim();
//     final sellerImg  = (offerData['sellerImage']  as String? ?? '').trim();
//     final sellerId   = (offerData['sellerId']     as String? ?? '').trim();
//     final sellerCity = (offerData['sellerCity']   as String? ?? '').trim();
//     final rating     = (offerData['rating']       as num?    ?? 0.0).toDouble();
//     final orders     = (offerData['ordersCount']  as int?    ?? 0);
//     final imageUrl   = (offerData['imageUrl']     as String? ?? '').trim();
//     final nearBuyer  = buyerCity.isNotEmpty &&
//         sellerCity.toLowerCase() == buyerCity.trim().toLowerCase();

//     final displayName = sellerName.isNotEmpty ? sellerName : 'Worker';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: nearBuyer
//             ? Border.all(color: _teal.withOpacity(0.3), width: 1.5)
//             : null,
//         boxShadow: [BoxShadow(
//           color: Colors.black.withOpacity(0.06),
//           blurRadius: 14, offset: const Offset(0, 4))]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           // Cover image
//           if (imageUrl.isNotEmpty)
//             ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//               child: Image.network(
//                 imageUrl,
//                 height: 150,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const SizedBox(),
//                 loadingBuilder: (_, child, p) => p == null ? child
//                     : Container(height: 150, color: Colors.grey[100],
//                         child: const Center(child: CircularProgressIndicator(
//                             color: _teal, strokeWidth: 2))),
//               ),
//             ),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 // ── Seller row ──────────────────────────────────
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   GestureDetector(
//                     onTap: () => _showProfile(context, sellerId),
//                     child: CircleAvatar(
//                       radius: 21,
//                       backgroundColor: _teal.withOpacity(0.1),
//                       backgroundImage: sellerImg.isNotEmpty
//                           ? NetworkImage(sellerImg) : null,
//                       child: sellerImg.isEmpty
//                           ? Text(displayName[0].toUpperCase(),
//                               style: const TextStyle(
//                                 color: _teal,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 17))
//                           : null),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(displayName,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w700,
//                           color: Colors.black87)),
//                       Row(children: [
//                         Icon(Icons.star_rounded,
//                             size: 12, color: Colors.amber[600]),
//                         const SizedBox(width: 2),
//                         Text(rating.toStringAsFixed(1),
//                           style: TextStyle(
//                             fontSize: 11.5, color: Colors.grey[600],
//                             fontWeight: FontWeight.w600)),
//                         if (orders > 0)
//                           Text('  · $orders orders',
//                             style: TextStyle(
//                                 fontSize: 11, color: Colors.grey[400])),
//                         if (sellerCity.isNotEmpty) ...[
//                           const SizedBox(width: 6),
//                           Flexible(child: Text(sellerCity,
//                             style: TextStyle(
//                                 fontSize: 11, color: Colors.grey[400]),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis)),
//                         ],
//                       ]),
//                     ])),
//                   // Price
//                   Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                     Text('PKR ${price.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.w900,
//                         color: _teal)),
//                     Text('starting',
//                       style: TextStyle(
//                           fontSize: 10, color: Colors.grey[400])),
//                   ]),
//                 ]),

//                 const Divider(height: 16, color: Color(0xFFEEEEEE)),

//                 // Title
//                 Text(title,
//                   maxLines: 2, overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 15, fontWeight: FontWeight.w800,
//                     color: Colors.black87)),

//                 // Description
//                 if (desc.isNotEmpty) ...[
//                   const SizedBox(height: 4),
//                   Text(desc,
//                     style: TextStyle(
//                       fontSize: 12.5, color: Colors.grey[600], height: 1.4),
//                     maxLines: 2, overflow: TextOverflow.ellipsis),
//                 ],
//                 const SizedBox(height: 8),

//                 // Skills
//                 if (skills.isNotEmpty)
//                   Wrap(spacing: 6, runSpacing: 4,
//                     children: skills.take(4).map((s) => Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 9, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: _teal.withOpacity(0.07),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: _teal.withOpacity(0.15))),
//                       child: Text(s,
//                         style: const TextStyle(
//                           fontSize: 11.5, color: _teal,
//                           fontWeight: FontWeight.w600)),
//                     )).toList()),
//                 const SizedBox(height: 10),

//                 // Footer
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                       // Left section: delivery time + near badge
//                       Expanded(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (delivery.isNotEmpty) ...[
//                               Icon(Icons.schedule_outlined,
//                                   size: 13, color: Colors.grey[400]),
//                               const SizedBox(width: 4),
//                               Flexible(
//                                 child: Text(delivery,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                       fontSize: 12, color: Colors.grey[500])),
//                               ),
//                               const SizedBox(width: 6),
//                             ],
//                             if (nearBuyer)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 7, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: _teal.withOpacity(0.08),
//                                   borderRadius: BorderRadius.circular(10)),
//                                 child: const Text('📍 Near You',
//                                   style: TextStyle(
//                                     fontSize: 10, color: _teal,
//                                     fontWeight: FontWeight.w700))),
//                           ],
//                         ),
//                       ),
//                       // Right section: speak button + order button
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SpeakButton(
//                             text: '$title. $desc.',
//                             contentId: 'offer_$offerId'),
//                           const SizedBox(width: 6),
//                           SizedBox(
//                             height: 40,
//                             child: ElevatedButton(
//                               onPressed: () => showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 useSafeArea: true,
//                                 backgroundColor: Colors.transparent,
//                                 builder: (_) => OfferPlaceOrderSheet(
//                                   offerData: offerData,
//                                   offerId  : offerId,
//                                   buyerUid : buyerUid,
//                                   buyerCity: buyerCity)),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _teal,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 14, vertical: 0),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12)),
//                                 elevation: 0,
//                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                               child: const Text('Place Order',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontSize: 11, fontWeight: FontWeight.w700)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showProfile(BuildContext ctx, String sid) {
//     if (sid.isEmpty) return;
//     showModalBottomSheet(
//       context: ctx, isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => SellerProfileSheet(
//         sellerId : sid,
//         buyerUid : buyerUid,
//         buyerCity: buyerCity));
//   }
// }

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  static const _teal = Color(0xFF00695C);

  const _OfferCard({
    super.key,
    required this.offerData,
    required this.offerId,
    required this.buyerUid,
    required this.buyerCity,
  });

  @override
  Widget build(BuildContext context) {
    final title = (offerData['title'] as String? ?? 'Service Offer').trim();
    final desc = (offerData['description'] as String? ?? '').trim();
    final price = (offerData['price'] as num? ?? 0).toDouble();
    final delivery = (offerData['deliveryTime'] as String? ?? '').trim();
    final skills = (offerData['skills'] is List)
        ? List<String>.from(offerData['skills'] as List)
        : <String>[];
    final sellerName = (offerData['sellerName'] as String? ?? '').trim();
    final sellerImg = (offerData['sellerImage'] as String? ?? '').trim();
    final sellerId = (offerData['sellerId'] as String? ?? '').trim();
    final sellerCity = (offerData['sellerCity'] as String? ?? '').trim();
    final rating = (offerData['rating'] as num? ?? 0.0).toDouble();
    final orders = (offerData['ordersCount'] as int? ?? 0);
    final imageUrl = (offerData['imageUrl'] as String? ?? '').trim();

    final nearBuyer =
        buyerCity.isNotEmpty &&
        sellerCity.toLowerCase() == buyerCity.trim().toLowerCase();

    final displayName = sellerName.isNotEmpty ? sellerName : 'Worker';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: nearBuyer
            ? Border.all(color: _teal.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SELLER ROW
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: sellerImg.isNotEmpty
                          ? NetworkImage(sellerImg)
                          : null,
                      child: sellerImg.isEmpty
                          ? Text(displayName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 10),

                    // ✅ FIX: wrap with Expanded
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            sellerCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    Text("PKR ${price.toStringAsFixed(0)}"),
                  ],
                ),

                const SizedBox(height: 10),

                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),

                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],

                const SizedBox(height: 8),

                if (skills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: skills
                        .take(3)
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),

                const SizedBox(height: 10),

                // ✅🔥 FIXED FOOTER ROW (MAIN ERROR SOURCE)
                Row(
                  children: [
                    // DELIVERY
                    if (delivery.isNotEmpty)
                      Expanded(
                        child: Text(
                          delivery,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    // SPEAK BUTTON (FIXED SIZE)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: SpeakButton(
                        text: '$title. $desc.',
                        contentId: 'offer_$offerId',
                      ),
                    ),

                    const SizedBox(width: 8),

                    // BUTTON (FIXED SIZE)
                    SizedBox(
                      width: 110,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => OfferPlaceOrderSheet(
                            offerData: offerData,
                            offerId: offerId,
                            buyerUid: buyerUid,
                            buyerCity: buyerCity,
                          ),
                        ),
                        child: const Text(
                          "Order",
                          overflow: TextOverflow.ellipsis,
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
}
