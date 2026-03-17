



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'offer_place_order_sheet.dart';
import 'tts_translation_service.dart';

// ═══════════════════════════════════════════════════════════════
//  ALL OFFERS SCREEN — Professional browse experience
// ═══════════════════════════════════════════════════════════════
class AllOffersScreen extends StatefulWidget {
  final String? phoneUID;
  final String  buyerCity;
  final String? initialCategory;
  const AllOffersScreen({super.key, this.phoneUID, this.buyerCity = '', this.initialCategory});
  @override
  State<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends State<AllOffersScreen> with SingleTickerProviderStateMixin {
  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String  _query        = '';
  String? _selectedCat;
  String  _selectedCity = '';
  String  _sortBy       = 'rating';    // rating | price_asc | price_desc | newest
  bool    _gridView     = false;
  bool    _searchFocused = false;
  List<String> _availableCities = [];

  late TabController _tabCtrl;

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
    _tabCtrl = TabController(length: _cats.length, vsync: this);
    _selectedCat  = widget.initialCategory;
    _selectedCity = widget.buyerCity;
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
    _loadCities();

    // Sync tab if initial category set
    if (_selectedCat != null) {
      final idx = _cats.indexWhere((c) => c['n'] == _selectedCat);
      if (idx >= 0) _tabCtrl.index = idx;
    }
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() { _selectedCat = _tabCtrl.index == 0 ? null : _cats[_tabCtrl.index]['n'] as String; });
      }
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); _scrollCtrl.dispose(); _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadCities() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sellers').where('status', isEqualTo: 'approved').get();
      final set = <String>{};
      for (final d in snap.docs) {
        final c = (d.data()['city'] as String? ?? '').trim();
        if (c.isNotEmpty) set.add(c);
      }
      if (mounted) setState(() => _availableCities = set.toList()..sort());
    } catch (_) {}
  }

  bool _matches(Map<String, dynamic> d) {
    if (_selectedCat != null) {
      final cat    = _selectedCat!.toLowerCase();
      final title  = (d['title']  ?? '').toString().toLowerCase();
      final skills = List<String>.from(d['skills'] ?? []).map((s) => s.toLowerCase());
      if (!title.contains(cat) && !skills.any((s) => s.contains(cat))) return false;
    }
    if (_query.isNotEmpty) {
      final haystack = [
        d['title']       ?? '',
        d['description'] ?? '',
        d['sellerName']  ?? '',
        ...List<String>.from(d['skills'] ?? []),
      ].join(' ').toLowerCase();
      if (!haystack.contains(_query)) return false;
    }
    return true;
  }

  List<QueryDocumentSnapshot> _sorted(List<QueryDocumentSnapshot> docs) {
    final list = List<QueryDocumentSnapshot>.from(docs);
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) {
          final ap = ((a.data() as Map)['price'] ?? 0).toDouble();
          final bp = ((b.data() as Map)['price'] ?? 0).toDouble();
          return ap.compareTo(bp);
        });
        break;
      case 'price_desc':
        list.sort((a, b) {
          final ap = ((a.data() as Map)['price'] ?? 0).toDouble();
          final bp = ((b.data() as Map)['price'] ?? 0).toDouble();
          return bp.compareTo(ap);
        });
        break;
      case 'newest':
        list.sort((a, b) {
          final at = ((a.data() as Map)['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bt = ((b.data() as Map)['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return bt.compareTo(at);
        });
        break;
      case 'rating':
      default:
        list.sort((a, b) {
          final ar = ((a.data() as Map)['rating'] ?? 0).toDouble();
          final br = ((b.data() as Map)['rating'] ?? 0).toDouble();
          return br.compareTo(ar);
        });
    }
    // city-match first
    if (_selectedCity.isNotEmpty) {
      final city = _selectedCity.toLowerCase();
      list.sort((a, b) {
        final aCity = ((a.data() as Map)['sellerCity'] as String? ?? '').toLowerCase() == city ? 0 : 1;
        final bCity = ((b.data() as Map)['sellerCity'] as String? ?? '').toLowerCase() == city ? 0 : 1;
        return aCity.compareTo(bCity);
      });
    }
    return list;
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            pinned: true, floating: false,
            expandedHeight: 160,
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
              title: _buildSearchBar(),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_teal, _tealDark])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('Browse Offers', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                      const Spacer(),
                      _iconPill(Icons.tune_rounded, _showFilterSheet),
                      const SizedBox(width: 8),
                      _iconPill(_gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        () => setState(() => _gridView = !_gridView)),
                    ]),
                    const SizedBox(height: 4),
                    Text('Discover trusted services in your city', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5)),
                  ]),
                )),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('offers')
              .where('status', isEqualTo: 'active')
              .snapshots(),
          builder: (ctx, snap) {
            // Loading
            if (snap.connectionState == ConnectionState.waiting) {
              return _buildShimmer();
            }

            // Firestore index error — helpful guidance
            if (snap.hasError) {
              return _buildErrorState(snap.error.toString());
            }

            final raw    = snap.data?.docs ?? [];
            final docs   = _sorted(raw.where((d) => _matches(d.data() as Map<String, dynamic>)).toList());
            final total  = raw.length;
            final shown  = docs.length;

            return CustomScrollView(slivers: [
              // Active filters bar
              if (_query.isNotEmpty || _selectedCity.isNotEmpty || _selectedCat != null)
                SliverToBoxAdapter(child: _buildActiveFilters()),
              // Results count
              SliverToBoxAdapter(child: _buildResultsBar(shown, total)),
              // Empty
              if (docs.isEmpty)
                SliverFillRemaining(child: _buildEmptyState()),
              // Grid or list
              if (docs.isNotEmpty && _gridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                    delegate: SliverChildBuilderDelegate((_, i) => _GridOfferCard(
                        offerData: docs[i].data() as Map<String, dynamic>,
                        offerId:   docs[i].id,
                        buyerUid:  widget.phoneUID ?? '',
                        buyerCity: widget.buyerCity,
                      ), childCount: docs.length),
                  ),
                ),
              if (docs.isNotEmpty && !_gridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) => _ListOfferCard(
                        offerData: docs[i].data() as Map<String, dynamic>,
                        offerId:   docs[i].id,
                        buyerUid:  widget.phoneUID ?? '',
                        buyerCity: widget.buyerCity,
                      ), childCount: docs.length),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return SizedBox(height: 44,
      child: TextField(
        controller: _searchCtrl,
        onTap: () => setState(() => _searchFocused = true),
        onSubmitted: (_) => setState(() => _searchFocused = false),
        style: const TextStyle(fontSize: 13.5, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search offers, skills, workers…',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00695C), size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: () => _searchCtrl.clear())
              : null,
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF00695C), width: 1.5)),
        ),
      ),
    );
  }

  // ── TAB BAR (categories) ───────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _tealDark,
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorColor: Colors.white,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _cats.map((c) => Tab(text: '${c['e']}  ${c['n']}')).toList(),
      ),
    );
  }

  // ── ICON PILL ──────────────────────────────────────────────
  Widget _iconPill(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white, size: 20)),
  );

  // ── ACTIVE FILTERS ─────────────────────────────────────────
  Widget _buildActiveFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Wrap(spacing: 8, runSpacing: 6, children: [
        if (_query.isNotEmpty)
          _filterChip('🔍 "$_query"', () => _searchCtrl.clear()),
        if (_selectedCity.isNotEmpty)
          _filterChip('📍 $_selectedCity', () => setState(() => _selectedCity = '')),
        if (_selectedCat != null)
          _filterChip('🏷️ $_selectedCat', () { setState(() => _selectedCat = null); _tabCtrl.index = 0; }),
        GestureDetector(
          onTap: () { _searchCtrl.clear(); setState(() { _selectedCity = ''; _selectedCat = null; }); _tabCtrl.index = 0; },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade200)),
            child: Text('Clear All', style: TextStyle(fontSize: 11.5, color: Colors.red.shade600, fontWeight: FontWeight.w700)))),
      ]),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.08), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF00695C).withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF00695C), fontWeight: FontWeight.w600)),
      const SizedBox(width: 5),
      GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 14, color: Color(0xFF00695C))),
    ]),
  );

  // ── RESULTS BAR ────────────────────────────────────────────
  Widget _buildResultsBar(int shown, int total) {
    final sortLabels = {'rating': 'Top Rated', 'price_asc': 'Price ↑', 'price_desc': 'Price ↓', 'newest': 'Newest'};
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        Text('$shown ${shown == 1 ? 'offer' : 'offers'} found',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700])),
        if (shown < total) Text(' of $total', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        const Spacer(),
        GestureDetector(
          onTap: _showSortSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF00695C)),
              const SizedBox(width: 5),
              Text(sortLabels[_sortBy] ?? 'Sort',
                style: const TextStyle(fontSize: 12, color: Color(0xFF00695C), fontWeight: FontWeight.w700)),
            ])),
        ),
      ]),
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────
  Widget _buildEmptyState() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 90, height: 90,
        decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.07), borderRadius: BorderRadius.circular(28)),
        child: const Center(child: Icon(Icons.search_off_rounded, size: 46, color: Color(0xFF00695C)))),
      const SizedBox(height: 20),
      Text(_query.isNotEmpty ? 'No results for "$_query"' : 'No Offers Found',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
      const SizedBox(height: 8),
      Text(_query.isNotEmpty ? 'Try different keywords or clear filters'
          : 'Be the first to discover new services.\nSellers are adding offers daily!',
        style: TextStyle(fontSize: 13.5, color: Colors.grey[500], height: 1.5), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      if (_query.isNotEmpty || _selectedCat != null || _selectedCity.isNotEmpty)
        OutlinedButton.icon(
          onPressed: () { _searchCtrl.clear(); setState(() { _selectedCat = null; _selectedCity = ''; }); _tabCtrl.index = 0; },
          icon: const Icon(Icons.clear_all, color: Color(0xFF00695C)),
          label: const Text('Clear All Filters', style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF00695C)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
    ]),
  ));

  // ── ERROR STATE ────────────────────────────────────────────
  Widget _buildErrorState(String error) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.cloud_off_rounded, size: 56, color: Color(0xFF00695C)),
      const SizedBox(height: 16),
      const Text('Index Setup Required', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Create a Firestore collectionGroup index for "offers" with status and rating fields in Firebase Console.',
        style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5), textAlign: TextAlign.center),
      const SizedBox(height: 6),
      const Text('sellers → offers → status (ASC), rating (DESC)',
        style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF00695C))),
    ]),
  ));

  // ── SHIMMER ────────────────────────────────────────────────
  Widget _buildShimmer() => ListView.builder(
    padding: const EdgeInsets.all(14), itemCount: 4,
    itemBuilder: (_, __) => Container(
      height: 220, margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 130, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.vertical(top: Radius.circular(20)))),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 12, width: 180, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(height: 10, width: 120, color: Colors.grey[200]),
        ])),
      ]),
    ),
  );

  // ── SORT SHEET ─────────────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Sort By', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...[ {'k': 'rating',     'l': '⭐  Top Rated'},
             {'k': 'price_asc',  'l': '💰  Price: Low to High'},
             {'k': 'price_desc', 'l': '💰  Price: High to Low'},
             {'k': 'newest',     'l': '🆕  Newest First'}, ].map((o) =>
          ListTile(
            title: Text(o['l']!, style: TextStyle(fontWeight: _sortBy == o['k'] ? FontWeight.w700 : FontWeight.w500)),
            trailing: _sortBy == o['k'] ? const Icon(Icons.check, color: Color(0xFF00695C)) : null,
            onTap: () { setState(() => _sortBy = o['k']!); Navigator.pop(context); }),
        ),
        const SizedBox(height: 8),
      ])),
    );
  }

  // ── FILTER SHEET ───────────────────────────────────────────
  void _showFilterSheet() {
    String tempCity = _selectedCity;
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx2, ss) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.85, expand: false,
        builder: (_, sc) => ListView(controller: sc, padding: const EdgeInsets.all(20), children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const Text('Filter Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          const Text('Filter by City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _cityFilterChip('All Cities', '', tempCity, (v) => ss(() => tempCity = v)),
            ..._availableCities.map((c) => _cityFilterChip(c, c, tempCity, (v) => ss(() => tempCity = v))),
          ]),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () { ss(() => tempCity = ''); setState(() => _selectedCity = ''); Navigator.pop(context); },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w700)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { setState(() => _selectedCity = tempCity); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)))),
          ]),
        ]),
      )),
    );
  }

  Widget _cityFilterChip(String label, String value, String current, ValueChanged<String> onTap) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _teal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _teal : Colors.grey.shade300)),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.grey[700]))),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LIST OFFER CARD
// ═══════════════════════════════════════════════════════════════
class _ListOfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  const _ListOfferCard({required this.offerData, required this.offerId, required this.buyerUid, required this.buyerCity});

  static const _teal = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final title      = offerData['title']        as String? ?? 'Service Offer';
    final desc       = offerData['description']  as String? ?? '';
    final price      = (offerData['price']       ?? 0).toDouble();
    final delivery   = offerData['deliveryTime'] as String? ?? '';
    final skills     = List<String>.from(offerData['skills'] ?? []);
    final sellerName = offerData['sellerName']   as String? ?? 'Worker';
    final sellerImg  = offerData['sellerImage']  as String? ?? '';
    final rating     = (offerData['rating']      ?? 0.0).toDouble();
    final orders     = (offerData['ordersCount'] ?? 0) as int;
    final imgUrl     = offerData['imageUrl']     as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cover image
        if (imgUrl.isNotEmpty)
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(imgUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox())),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Seller + price row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 21, backgroundColor: _teal.withOpacity(0.1),
              backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
              child: sellerImg.isEmpty ? Text(sellerName[0].toUpperCase(),
                style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 17)) : null),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(sellerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
              Row(children: [
                Icon(Icons.star_rounded, size: 13, color: Colors.amber[600]),
                const SizedBox(width: 2),
                Text('$rating', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                if (orders > 0) ...[
                  Text('  ·  ', style: TextStyle(color: Colors.grey[400])),
                  Icon(Icons.shopping_bag_outlined, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text('$orders orders', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('PKR ${price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _teal)),
              Text('starting price', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ]),
          ]),
          const Divider(height: 18, color: Color(0xFFEEEEEE)),
          // Title & description
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.2)),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 5),
            TranslatedText(text: desc, contentId: 'offer_$offerId',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.45),
              maxLines: 3, showListenButton: false),
          ],
          const SizedBox(height: 11),
          // Skills
          if (skills.isNotEmpty) Wrap(spacing: 6, runSpacing: 5,
            children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _teal.withOpacity(0.15))),
              child: Text(s, style: const TextStyle(fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
            )).toList()),
          const SizedBox(height: 13),
          // Bottom row
          Row(children: [
            if (delivery.isNotEmpty) ...[
              Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(delivery, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 8),
            ],
            JobListenRow(title: title, description: desc, location: '', timing: delivery, jobId: offerId),
            const Spacer(),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => _openSheet(context),
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
            label: const Text('Place Order', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ])),
      ]),
    );
  }

  void _openSheet(BuildContext ctx) => showModalBottomSheet(context: ctx,
    isScrollControlled: true, useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => OfferPlaceOrderSheet(offerData: offerData, offerId: offerId, buyerUid: buyerUid, buyerCity: buyerCity));
}

// ═══════════════════════════════════════════════════════════════
//  GRID OFFER CARD
// ═══════════════════════════════════════════════════════════════
class _GridOfferCard extends StatelessWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  const _GridOfferCard({required this.offerData, required this.offerId, required this.buyerUid, required this.buyerCity});

  static const _teal = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final title      = offerData['title']       as String? ?? 'Service';
    final price      = (offerData['price']      ?? 0).toDouble();
    final skills     = List<String>.from(offerData['skills'] ?? []);
    final sellerName = offerData['sellerName']  as String? ?? 'Worker';
    final sellerImg  = offerData['sellerImage'] as String? ?? '';
    final rating     = (offerData['rating']     ?? 0.0).toDouble();
    final imgUrl     = offerData['imageUrl']    as String? ?? '';

    return GestureDetector(
      onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => OfferPlaceOrderSheet(offerData: offerData, offerId: offerId, buyerUid: buyerUid, buyerCity: buyerCity)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image or placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: imgUrl.isNotEmpty
                ? Image.network(imgUrl, height: 110, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(title))
                : _placeholder(title)),
          Padding(padding: const EdgeInsets.fromLTRB(10, 10, 10, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black87),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [
              CircleAvatar(radius: 10, backgroundColor: _teal.withOpacity(0.1),
                backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
                child: sellerImg.isEmpty ? Text(sellerName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 9, color: _teal, fontWeight: FontWeight.bold)) : null),
              const SizedBox(width: 5),
              Expanded(child: Text(sellerName, style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
              const SizedBox(width: 2),
              Text('$rating', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
            ]),
            const SizedBox(height: 6),
            if (skills.isNotEmpty) Text(skills.take(2).join(', '),
              style: TextStyle(fontSize: 10, color: _teal.withOpacity(0.8), fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('PKR ${price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _teal)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(8)),
                child: const Text('Order', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold))),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _placeholder(String title) {
    final colors = [0xFF00695C, 0xFF1565C0, 0xFF6A1B9A, 0xFFBF360C, 0xFF2E7D32];
    final color  = Color(colors[title.length % colors.length]);
    return Container(height: 110, width: double.infinity, color: color.withOpacity(0.12),
      child: Center(child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: color))));
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'offer_place_order_sheet.dart';
// import 'tts_translation_service.dart';

// // ═══════════════════════════════════════════════════════════════
// //  ALL OFFERS SCREEN  — No composite index required
// //  Query: collectionGroup('offers').where('status','active') only
// //  All sorting + filtering done CLIENT-SIDE
// // ═══════════════════════════════════════════════════════════════
// class AllOffersScreen extends StatefulWidget {
//   final String? phoneUID;
//   final String  buyerCity;
//   final String? initialCategory;
//   const AllOffersScreen({
//     super.key,
//     this.phoneUID,
//     this.buyerCity = '',
//     this.initialCategory,
//   });
//   @override
//   State<AllOffersScreen> createState() => _AllOffersScreenState();
// }

// class _AllOffersScreenState extends State<AllOffersScreen>
//     with SingleTickerProviderStateMixin {
//   static const _teal     = Color(0xFF00695C);
//   static const _tealDark = Color(0xFF004D40);

//   final _searchCtrl = TextEditingController();
//   String  _query        = '';
//   String? _selectedCat;
//   String  _selectedCity = '';
//   String  _sortBy       = 'rating';
//   bool    _gridView     = false;
//   List<String> _availableCities = [];

//   late TabController _tabCtrl;

//   static const _cats = [
//     {'n': 'All',        'e': '🌟'},
//     {'n': 'Plumbing',   'e': '🔧'},
//     {'n': 'Electrical', 'e': '⚡'},
//     {'n': 'Cleaning',   'e': '🧹'},
//     {'n': 'Carpentry',  'e': '🪚'},
//     {'n': 'AC Repair',  'e': '❄️'},
//     {'n': 'Painting',   'e': '🎨'},
//     {'n': 'Mechanic',   'e': '🔩'},
//     {'n': 'Roofing',    'e': '🏗️'},
//     {'n': 'Gardening',  'e': '🌿'},
//     {'n': 'Welding',    'e': '🔥'},
//     {'n': 'Masonry',    'e': '🧱'},
//     {'n': 'Tiling',     'e': '🪟'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabCtrl      = TabController(length: _cats.length, vsync: this);
//     _selectedCat  = widget.initialCategory;
//     _selectedCity = widget.buyerCity;

//     _searchCtrl.addListener(
//         () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));

//     if (_selectedCat != null) {
//       final idx = _cats.indexWhere((c) => c['n'] == _selectedCat);
//       if (idx >= 0) _tabCtrl.index = idx;
//     }
//     _tabCtrl.addListener(() {
//       if (!_tabCtrl.indexIsChanging) {
//         setState(() {
//           _selectedCat =
//               _tabCtrl.index == 0 ? null : _cats[_tabCtrl.index]['n'] as String;
//         });
//       }
//     });

//     _loadCitiesFromOffers();
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     _tabCtrl.dispose();
//     super.dispose();
//   }

//   // Load unique cities from offer documents (field 'sellerCity')
//   Future<void> _loadCitiesFromOffers() async {
//     try {
//       final snap = await FirebaseFirestore.instance
//           .collectionGroup('offers')
//           .where('status', isEqualTo: 'active')
//           .get();
//       final set = <String>{};
//       for (final d in snap.docs) {
//         final c = (d.data()['sellerCity'] as String? ?? '').trim();
//         if (c.isNotEmpty) set.add(c);
//       }
//       if (mounted) setState(() => _availableCities = set.toList()..sort());
//     } catch (_) {}
//   }

//   // ── CLIENT-SIDE FILTER ─────────────────────────────────────
//   bool _matches(Map<String, dynamic> d) {
//     // City filter using sellerCity stored on the offer
//     if (_selectedCity.isNotEmpty) {
//       final oc = (d['sellerCity'] as String? ?? '').trim().toLowerCase();
//       if (oc != _selectedCity.toLowerCase()) return false;
//     }
//     // Category filter
//     if (_selectedCat != null) {
//       final cat   = _selectedCat!.toLowerCase();
//       final title = (d['title']  ?? '').toString().toLowerCase();
//       final skills = List<String>.from(d['skills'] ?? []).map((s) => s.toLowerCase());
//       if (!title.contains(cat) && !skills.any((s) => s.contains(cat))) return false;
//     }
//     // Text search
//     if (_query.isNotEmpty) {
//       final haystack = [
//         d['title']       ?? '',
//         d['description'] ?? '',
//         d['sellerName']  ?? '',
//         d['sellerCity']  ?? '',
//         ...List<String>.from(d['skills'] ?? []),
//       ].join(' ').toLowerCase();
//       if (!haystack.contains(_query)) return false;
//     }
//     return true;
//   }

//   List<QueryDocumentSnapshot> _sortedDocs(List<QueryDocumentSnapshot> raw) {
//     final buyerCityL = widget.buyerCity.trim().toLowerCase();
//     final list = List<QueryDocumentSnapshot>.from(raw);

//     // Primary sort
//     switch (_sortBy) {
//       case 'price_asc':
//         list.sort((a, b) => ((a.data() as Map)['price'] ?? 0)
//             .toDouble()
//             .compareTo(((b.data() as Map)['price'] ?? 0).toDouble()));
//         break;
//       case 'price_desc':
//         list.sort((a, b) => ((b.data() as Map)['price'] ?? 0)
//             .toDouble()
//             .compareTo(((a.data() as Map)['price'] ?? 0).toDouble()));
//         break;
//       case 'newest':
//         list.sort((a, b) {
//           final at = ((a.data() as Map)['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
//           final bt = ((b.data() as Map)['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
//           return bt.compareTo(at);
//         });
//         break;
//       default: // rating
//         list.sort((a, b) => ((b.data() as Map)['rating'] ?? 0)
//             .toDouble()
//             .compareTo(((a.data() as Map)['rating'] ?? 0).toDouble()));
//     }

//     // Secondary: buyer's city always floats to top
//     if (buyerCityL.isNotEmpty && _selectedCity.isEmpty) {
//       list.sort((a, b) {
//         final ac = ((a.data() as Map)['sellerCity'] as String? ?? '').toLowerCase() == buyerCityL ? 0 : 1;
//         final bc = ((b.data() as Map)['sellerCity'] as String? ?? '').toLowerCase() == buyerCityL ? 0 : 1;
//         return ac.compareTo(bc);
//       });
//     }
//     return list;
//   }

//   // ── BUILD ──────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       body: NestedScrollView(
//         headerSliverBuilder: (ctx, _) => [_buildSliverHeader()],
//         body: StreamBuilder<QuerySnapshot>(
//           // ✅ No orderBy → No composite index needed
//           stream: FirebaseFirestore.instance
//               .collectionGroup('offers')
//               .where('status', isEqualTo: 'active')
//               .snapshots(),
//           builder: (ctx, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return _shimmer();
//             }
//             if (snap.hasError) {
//               // Rare: single-field index missing
//               return _errorState();
//             }

//             final raw   = snap.data?.docs ?? [];
//             final docs  = _sortedDocs(raw.where((d) => _matches(d.data() as Map<String, dynamic>)).toList());
//             final total = raw.length;
//             final shown = docs.length;

//             return CustomScrollView(slivers: [
//               if (_query.isNotEmpty || _selectedCity.isNotEmpty || _selectedCat != null)
//                 SliverToBoxAdapter(child: _activeFiltersBar()),
//               SliverToBoxAdapter(child: _resultsBar(shown, total)),
//               if (docs.isEmpty)
//                 SliverFillRemaining(child: _emptyState()),
//               if (docs.isNotEmpty && _gridView)
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
//                   sliver: SliverGrid(
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, crossAxisSpacing: 12,
//                         mainAxisSpacing: 12, childAspectRatio: 0.70),
//                     delegate: SliverChildBuilderDelegate(
//                       (_, i) => _GridCard(
//                         offerData: docs[i].data() as Map<String, dynamic>,
//                         offerId:   docs[i].id,
//                         buyerUid:  widget.phoneUID ?? '',
//                         buyerCity: widget.buyerCity,
//                       ),
//                       childCount: docs.length,
//                     ),
//                   ),
//                 ),
//               if (docs.isNotEmpty && !_gridView)
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (_, i) => _ListCard(
//                         offerData: docs[i].data() as Map<String, dynamic>,
//                         offerId:   docs[i].id,
//                         buyerUid:  widget.phoneUID ?? '',
//                         buyerCity: widget.buyerCity,
//                       ),
//                       childCount: docs.length,
//                     ),
//                   ),
//                 ),
//             ]);
//           },
//         ),
//       ),
//     );
//   }

//   // ── SLIVER HEADER ──────────────────────────────────────────
//   Widget _buildSliverHeader() {
//     return SliverAppBar(
//       pinned: true, floating: false,
//       expandedHeight: 162,
//       backgroundColor: _teal,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 54),
//         title: _searchBar(),
//         background: Container(
//           decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft, end: Alignment.bottomRight,
//                   colors: [_teal, _tealDark])),
//           child: SafeArea(child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 const Text('Browse Offers',
//                     style: TextStyle(color: Colors.white, fontSize: 21,
//                         fontWeight: FontWeight.w900, letterSpacing: -0.3)),
//                 const Spacer(),
//                 _pill(Icons.tune_rounded, _showFilterSheet),
//                 const SizedBox(width: 8),
//                 _pill(_gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
//                     () => setState(() => _gridView = !_gridView)),
//               ]),
//               const SizedBox(height: 3),
//               Row(children: [
//                 Icon(Icons.location_on, size: 12, color: Colors.white60),
//                 const SizedBox(width: 4),
//                 Text(
//                   widget.buyerCity.isNotEmpty
//                       ? 'Showing results near ${widget.buyerCity}'
//                       : 'Discover trusted services',
//                   style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
//                 ),
//               ]),
//             ]),
//           )),
//         ),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(46),
//         child: _tabBar(),
//       ),
//     );
//   }

//   Widget _searchBar() => SizedBox(
//     height: 44,
//     child: TextField(
//       controller: _searchCtrl,
//       style: const TextStyle(fontSize: 13.5, color: Colors.black87),
//       decoration: InputDecoration(
//         hintText: 'Search offers, skills, city, workers…',
//         hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.5),
//         prefixIcon: const Icon(Icons.search_rounded, color: _teal, size: 20),
//         suffixIcon: _query.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.close, size: 18, color: Colors.grey),
//                 onPressed: () => _searchCtrl.clear())
//             : null,
//         filled: true, fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(vertical: 11),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(28),
//             borderSide: const BorderSide(color: _teal, width: 1.5)),
//       ),
//     ),
//   );

//   Widget _tabBar() => Container(
//     color: _tealDark,
//     child: TabBar(
//       controller: _tabCtrl,
//       isScrollable: true,
//       labelColor: Colors.white,
//       unselectedLabelColor: Colors.white54,
//       indicatorColor: Colors.white,
//       indicatorWeight: 2.5,
//       labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
//       unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
//       tabAlignment: TabAlignment.start,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       tabs: _cats.map((c) => Tab(text: '${c['e']}  ${c['n']}')).toList(),
//     ),
//   );

//   Widget _pill(IconData icon, VoidCallback onTap) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.18),
//           borderRadius: BorderRadius.circular(11)),
//       child: Icon(icon, color: Colors.white, size: 20)),
//   );

//   // ── ACTIVE FILTERS ─────────────────────────────────────────
//   Widget _activeFiltersBar() => Container(
//     color: Colors.white,
//     padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//     child: Wrap(spacing: 8, runSpacing: 6, children: [
//       if (_query.isNotEmpty)
//         _chip('🔍 "$_query"', () => _searchCtrl.clear()),
//       if (_selectedCity.isNotEmpty)
//         _chip('📍 $_selectedCity', () => setState(() => _selectedCity = '')),
//       if (_selectedCat != null)
//         _chip('🏷️ $_selectedCat', () {
//           setState(() => _selectedCat = null);
//           _tabCtrl.index = 0;
//         }),
//       GestureDetector(
//         onTap: _clearAll,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//               color: Colors.red.shade50,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.red.shade200)),
//           child: Text('Clear All',
//               style: TextStyle(
//                   fontSize: 11.5,
//                   color: Colors.red.shade600,
//                   fontWeight: FontWeight.w700)))),
//     ]),
//   );

//   Widget _chip(String label, VoidCallback remove) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     decoration: BoxDecoration(
//         color: _teal.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _teal.withOpacity(0.2))),
//     child: Row(mainAxisSize: MainAxisSize.min, children: [
//       Text(label,
//           style: const TextStyle(
//               fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
//       const SizedBox(width: 5),
//       GestureDetector(
//           onTap: remove,
//           child: const Icon(Icons.close, size: 14, color: _teal)),
//     ]),
//   );

//   void _clearAll() {
//     _searchCtrl.clear();
//     setState(() { _selectedCity = ''; _selectedCat = null; });
//     _tabCtrl.index = 0;
//   }

//   // ── RESULTS BAR ────────────────────────────────────────────
//   Widget _resultsBar(int shown, int total) {
//     final labels = {
//       'rating':     'Top Rated',
//       'price_asc':  'Price ↑',
//       'price_desc': 'Price ↓',
//       'newest':     'Newest',
//     };
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
//       child: Row(children: [
//         Text('$shown ${shown == 1 ? 'offer' : 'offers'} found',
//             style: TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700])),
//         if (shown < total)
//           Text(' of $total',
//               style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//         const Spacer(),
//         GestureDetector(
//           onTap: _showSortSheet,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//                 color: _teal.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(16)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               const Icon(Icons.sort_rounded, size: 14, color: _teal),
//               const SizedBox(width: 5),
//               Text(labels[_sortBy] ?? 'Sort',
//                   style: const TextStyle(
//                       fontSize: 12, color: _teal, fontWeight: FontWeight.w700)),
//             ])),
//         ),
//       ]),
//     );
//   }

//   // ── EMPTY STATE ────────────────────────────────────────────
//   Widget _emptyState() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Container(
//           width: 88, height: 88,
//           decoration: BoxDecoration(
//               color: _teal.withOpacity(0.07),
//               borderRadius: BorderRadius.circular(28)),
//           child: const Center(
//               child: Icon(Icons.search_off_rounded, size: 44, color: _teal))),
//         const SizedBox(height: 20),
//         Text(
//           _query.isNotEmpty ? 'No results for "$_query"' : 'No Offers Found',
//           style: const TextStyle(
//               fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
//         const SizedBox(height: 8),
//         Text(
//           _query.isNotEmpty
//               ? 'Try different keywords or remove filters'
//               : 'Sellers haven\'t posted offers yet.\nCheck back soon!',
//           style: TextStyle(
//               fontSize: 13.5, color: Colors.grey[500], height: 1.5),
//           textAlign: TextAlign.center),
//         const SizedBox(height: 24),
//         if (_query.isNotEmpty || _selectedCat != null || _selectedCity.isNotEmpty)
//           OutlinedButton.icon(
//             onPressed: _clearAll,
//             icon: const Icon(Icons.clear_all, color: _teal),
//             label: const Text('Clear All Filters',
//                 style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
//             style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: _teal),
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14))),
//           ),
//       ]),
//     ),
//   );

//   Widget _errorState() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Container(
//           width: 88, height: 88,
//           decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(24)),
//           child: const Center(
//               child: Icon(Icons.cloud_off_rounded, size: 44, color: Colors.orange))),
//         const SizedBox(height: 18),
//         const Text('Could not load offers',
//             style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
//         const SizedBox(height: 8),
//         Text('Check your internet connection and try again.',
//             style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
//             textAlign: TextAlign.center),
//       ]),
//     ),
//   );

//   Widget _shimmer() => ListView.builder(
//     padding: const EdgeInsets.all(14),
//     itemCount: 4,
//     itemBuilder: (_, __) => Container(
//       height: 230, margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(20)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//             height: 140,
//             decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(20)))),
//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Container(height: 12, width: 200, color: Colors.grey[300]),
//             const SizedBox(height: 8),
//             Container(height: 10, width: 130, color: Colors.grey[200]),
//           ])),
//       ]),
//     ),
//   );

//   // ── SORT SHEET ─────────────────────────────────────────────
//   void _showSortSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => SafeArea(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           const SizedBox(height: 8),
//           Container(width: 40, height: 4,
//               decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 16),
//           const Text('Sort By',
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
//           const SizedBox(height: 8),
//           ...[
//             {'k': 'rating',     'l': '⭐  Top Rated'},
//             {'k': 'price_asc',  'l': '💰  Price: Low to High'},
//             {'k': 'price_desc', 'l': '💰  Price: High to Low'},
//             {'k': 'newest',     'l': '🆕  Newest First'},
//           ].map((o) => ListTile(
//             title: Text(o['l']!,
//                 style: TextStyle(
//                     fontWeight: _sortBy == o['k']
//                         ? FontWeight.w700
//                         : FontWeight.w500)),
//             trailing: _sortBy == o['k']
//                 ? const Icon(Icons.check_circle_rounded, color: _teal)
//                 : null,
//             onTap: () {
//               setState(() => _sortBy = o['k']!);
//               Navigator.pop(context);
//             })),
//           const SizedBox(height: 8),
//         ]),
//       ),
//     );
//   }

//   // ── FILTER SHEET (city) ────────────────────────────────────
//   void _showFilterSheet() {
//     String tempCity = _selectedCity;
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx2, ss) => DraggableScrollableSheet(
//           initialChildSize: 0.55,
//           minChildSize: 0.4,
//           maxChildSize: 0.85,
//           expand: false,
//           builder: (_, sc) => ListView(
//             controller: sc,
//             padding: const EdgeInsets.all(20),
//             children: [
//               Center(
//                 child: Container(
//                   width: 40, height: 4,
//                   margin: const EdgeInsets.only(bottom: 18),
//                   decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2)))),
//               const Text('Filter by City',
//                   style: TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.w800)),
//               const SizedBox(height: 6),
//               Text(
//                 _availableCities.isEmpty
//                     ? 'No cities available yet'
//                     : 'Select a city to see nearby workers',
//                 style: TextStyle(fontSize: 13, color: Colors.grey[500])),
//               const SizedBox(height: 16),
//               Wrap(spacing: 10, runSpacing: 10, children: [
//                 _cityChip('📍 All Cities', '', tempCity,
//                     (v) => ss(() => tempCity = v)),
//                 if (widget.buyerCity.isNotEmpty)
//                   _cityChip(
//                       '🏠 My City (${widget.buyerCity})',
//                       widget.buyerCity, tempCity,
//                       (v) => ss(() => tempCity = v)),
//                 ..._availableCities
//                     .where((c) => c != widget.buyerCity)
//                     .map((c) => _cityChip(c, c, tempCity,
//                         (v) => ss(() => tempCity = v))),
//               ]),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(child: OutlinedButton(
//                   onPressed: () {
//                     ss(() => tempCity = '');
//                     setState(() => _selectedCity = '');
//                     Navigator.pop(context);
//                   },
//                   style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.red,
//                       side: const BorderSide(color: Colors.red),
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12))),
//                   child: const Text('Reset',
//                       style: TextStyle(fontWeight: FontWeight.w700)))),
//                 const SizedBox(width: 12),
//                 Expanded(child: ElevatedButton(
//                   onPressed: () {
//                     setState(() => _selectedCity = tempCity);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: _teal,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 13),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12))),
//                   child: const Text('Apply',
//                       style: TextStyle(fontWeight: FontWeight.w700)))),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _cityChip(
//       String label, String value, String current, ValueChanged<String> onTap) {
//     final sel = current == value;
//     return GestureDetector(
//       onTap: () => onTap(value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//             color: sel ? _teal : Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(22),
//             border: Border.all(color: sel ? _teal : Colors.grey.shade300),
//             boxShadow: sel
//                 ? [BoxShadow(color: _teal.withOpacity(0.25), blurRadius: 8)]
//                 : []),
//         child: Text(label,
//             style: TextStyle(
//                 fontSize: 12.5,
//                 fontWeight: FontWeight.w600,
//                 color: sel ? Colors.white : Colors.grey[700]))),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  LIST OFFER CARD
// // ═══════════════════════════════════════════════════════════════
// class _ListCard extends StatelessWidget {
//   final Map<String, dynamic> offerData;
//   final String offerId, buyerUid, buyerCity;
//   const _ListCard({
//     required this.offerData,
//     required this.offerId,
//     required this.buyerUid,
//     required this.buyerCity,
//   });
//   static const _teal = Color(0xFF00695C);

//   @override
//   Widget build(BuildContext context) {
//     final title      = offerData['title']        as String? ?? 'Service Offer';
//     final desc       = offerData['description']  as String? ?? '';
//     final price      = (offerData['price']       ?? 0).toDouble();
//     final delivery   = offerData['deliveryTime'] as String? ?? '';
//     final skills     = List<String>.from(offerData['skills'] ?? []);
//     final sellerName = offerData['sellerName']   as String? ?? 'Worker';
//     final sellerImg  = offerData['sellerImage']  as String? ?? '';
//     final sellerCity = offerData['sellerCity']   as String? ?? '';
//     final rating     = (offerData['rating']      ?? 0.0).toDouble();
//     final orders     = (offerData['ordersCount'] ?? 0) as int;
//     final imgUrl     = offerData['imageUrl']     as String? ?? '';
//     final isSameCity = buyerCity.isNotEmpty &&
//         sellerCity.toLowerCase() == buyerCity.toLowerCase();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: isSameCity
//             ? Border.all(color: _teal.withOpacity(0.35), width: 1.5)
//             : null,
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.07),
//               blurRadius: 14, offset: const Offset(0, 4)),
//         ],
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Image
//         if (imgUrl.isNotEmpty)
//           Stack(children: [
//             ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//               child: Image.network(imgUrl, height: 175, width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const SizedBox())),
//             // Same city badge on image
//             if (isSameCity)
//               Positioned(top: 12, right: 12,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                       color: _teal,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)]),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.location_on, size: 12, color: Colors.white),
//                     const SizedBox(width: 4),
//                     Text('Near You', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
//                   ]))),
//           ]),
//         if (imgUrl.isEmpty && isSameCity)
//           Container(
//             margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//                 color: _teal.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               const Icon(Icons.location_on, size: 13, color: _teal),
//               const SizedBox(width: 5),
//               Text('Near You · $sellerCity',
//                   style: const TextStyle(
//                       fontSize: 12, color: _teal, fontWeight: FontWeight.w700)),
//             ])),
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // Seller + price
//             Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundColor: _teal.withOpacity(0.1),
//                 backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
//                 child: sellerImg.isEmpty
//                     ? Text(sellerName[0].toUpperCase(),
//                         style: const TextStyle(
//                             color: _teal, fontWeight: FontWeight.bold, fontSize: 18))
//                     : null),
//               const SizedBox(width: 10),
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(sellerName,
//                     style: const TextStyle(
//                         fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87)),
//                 const SizedBox(height: 2),
//                 Row(children: [
//                   Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
//                   const SizedBox(width: 2),
//                   Text('$rating',
//                       style: TextStyle(fontSize: 12.5, color: Colors.grey[700],
//                           fontWeight: FontWeight.w700)),
//                   if (orders > 0) ...[
//                     Text('  ·  ', style: TextStyle(color: Colors.grey[400])),
//                     Icon(Icons.shopping_bag_outlined, size: 12, color: Colors.grey[400]),
//                     const SizedBox(width: 3),
//                     Text('$orders orders',
//                         style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
//                   ],
//                 ]),
//                 if (sellerCity.isNotEmpty)
//                   Row(children: [
//                     Icon(Icons.location_city_outlined, size: 12, color: Colors.grey[400]),
//                     const SizedBox(width: 3),
//                     Text(sellerCity,
//                         style: TextStyle(fontSize: 11.5, color: Colors.grey[500],
//                             fontWeight: FontWeight.w500)),
//                   ]),
//               ])),
//               Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                 Text('PKR ${price.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.w900, color: _teal)),
//                 Text('starting price',
//                     style: TextStyle(fontSize: 10, color: Colors.grey[400])),
//               ]),
//             ]),
//             const Divider(height: 18, color: Color(0xFFF0F0F0)),
//             // Title & desc
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.w800,
//                     color: Colors.black87, letterSpacing: -0.2)),
//             if (desc.isNotEmpty) ...[
//               const SizedBox(height: 5),
//               TranslatedText(
//                 text: desc,
//                 contentId: 'offer_$offerId',
//                 style: TextStyle(
//                     fontSize: 13, color: Colors.grey[600], height: 1.45),
//                 maxLines: 3,
//                 showListenButton: false),
//             ],
//             const SizedBox(height: 11),
//             // Skills
//             if (skills.isNotEmpty)
//               Wrap(spacing: 6, runSpacing: 5,
//                   children: skills.map((s) => Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                         color: _teal.withOpacity(0.07),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: _teal.withOpacity(0.15))),
//                     child: Text(s,
//                         style: const TextStyle(
//                             fontSize: 11.5, color: _teal, fontWeight: FontWeight.w600)),
//                   )).toList()),
//             const SizedBox(height: 12),
//             // Footer
//             Row(children: [
//               if (delivery.isNotEmpty) ...[
//                 Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[500]),
//                 const SizedBox(width: 4),
//                 Text(delivery,
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                 const SizedBox(width: 10),
//               ],
//               JobListenRow(
//                   title: title, description: desc, location: '', timing: delivery, jobId: offerId),
//               const Spacer(),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _open(context),
//                 icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
//                 label: const Text('Place Order',
//                     style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: _teal, foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 13),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14))),
//               )),
//           ])),
//       ]),
//     );
//   }

//   void _open(BuildContext ctx) => showModalBottomSheet(
//     context: ctx, isScrollControlled: true, useSafeArea: true,
//     shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//     builder: (_) => OfferPlaceOrderSheet(
//         offerData: offerData, offerId: offerId,
//         buyerUid: buyerUid, buyerCity: buyerCity));
// }

// // ═══════════════════════════════════════════════════════════════
// //  GRID OFFER CARD
// // ═══════════════════════════════════════════════════════════════
// class _GridCard extends StatelessWidget {
//   final Map<String, dynamic> offerData;
//   final String offerId, buyerUid, buyerCity;
//   const _GridCard({
//     required this.offerData,
//     required this.offerId,
//     required this.buyerUid,
//     required this.buyerCity,
//   });
//   static const _teal = Color(0xFF00695C);

//   @override
//   Widget build(BuildContext context) {
//     final title      = offerData['title']       as String? ?? 'Service';
//     final price      = (offerData['price']      ?? 0).toDouble();
//     final skills     = List<String>.from(offerData['skills'] ?? []);
//     final sellerName = offerData['sellerName']  as String? ?? 'Worker';
//     final sellerImg  = offerData['sellerImage'] as String? ?? '';
//     final sellerCity = offerData['sellerCity']  as String? ?? '';
//     final rating     = (offerData['rating']     ?? 0.0).toDouble();
//     final imgUrl     = offerData['imageUrl']    as String? ?? '';
//     final isSameCity = buyerCity.isNotEmpty &&
//         sellerCity.toLowerCase() == buyerCity.toLowerCase();

//     return GestureDetector(
//       onTap: () => showModalBottomSheet(
//         context: context, isScrollControlled: true, useSafeArea: true,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//         builder: (_) => OfferPlaceOrderSheet(
//             offerData: offerData, offerId: offerId,
//             buyerUid: buyerUid, buyerCity: buyerCity)),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: isSameCity
//               ? Border.all(color: _teal.withOpacity(0.4), width: 1.5)
//               : null,
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.07),
//                 blurRadius: 12, offset: const Offset(0, 3)),
//           ],
//         ),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Stack(children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
//               child: imgUrl.isNotEmpty
//                   ? Image.network(imgUrl, height: 105, width: double.infinity, fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _placeholder(title))
//                   : _placeholder(title)),
//             if (isSameCity)
//               Positioned(top: 8, right: 8,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//                   decoration: BoxDecoration(
//                       color: _teal, borderRadius: BorderRadius.circular(10)),
//                   child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.location_on, size: 10, color: Colors.white),
//                     SizedBox(width: 2),
//                     Text('Near', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
//                   ]))),
//           ]),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black87),
//                   maxLines: 2, overflow: TextOverflow.ellipsis),
//               const SizedBox(height: 5),
//               Row(children: [
//                 CircleAvatar(radius: 10, backgroundColor: _teal.withOpacity(0.1),
//                     backgroundImage: sellerImg.isNotEmpty ? NetworkImage(sellerImg) : null,
//                     child: sellerImg.isEmpty
//                         ? Text(sellerName[0].toUpperCase(),
//                             style: const TextStyle(
//                                 fontSize: 9, color: _teal, fontWeight: FontWeight.bold))
//                         : null),
//                 const SizedBox(width: 5),
//                 Expanded(child: Text(sellerName,
//                     style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
//                     maxLines: 1, overflow: TextOverflow.ellipsis)),
//               ]),
//               const SizedBox(height: 4),
//               Row(children: [
//                 Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
//                 const SizedBox(width: 2),
//                 Text('$rating',
//                     style: const TextStyle(
//                         fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
//                 if (sellerCity.isNotEmpty) ...[
//                   const SizedBox(width: 4),
//                   Expanded(child: Text('· $sellerCity',
//                       style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//                       maxLines: 1, overflow: TextOverflow.ellipsis)),
//                 ],
//               ]),
//               if (skills.isNotEmpty) ...[
//                 const SizedBox(height: 5),
//                 Text(skills.take(2).join(', '),
//                     style: TextStyle(
//                         fontSize: 10, color: _teal.withOpacity(0.8), fontWeight: FontWeight.w600),
//                     maxLines: 1, overflow: TextOverflow.ellipsis),
//               ],
//               const SizedBox(height: 8),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Text('PKR ${price.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                         fontSize: 13.5, fontWeight: FontWeight.w900, color: _teal)),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: _teal, borderRadius: BorderRadius.circular(8)),
//                   child: const Text('Order',
//                       style: TextStyle(
//                           color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold))),
//               ]),
//             ])),
//         ]),
//       ),
//     );
//   }

//   Widget _placeholder(String t) {
//     final palette = [0xFF00695C, 0xFF1565C0, 0xFF6A1B9A, 0xFFBF360C, 0xFF2E7D32];
//     final color   = Color(palette[t.length % palette.length]);
//     return Container(height: 105, width: double.infinity,
//         color: color.withOpacity(0.12),
//         child: Center(child: Text(t.isNotEmpty ? t[0].toUpperCase() : '?',
//             style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: color))));
//   }
// }