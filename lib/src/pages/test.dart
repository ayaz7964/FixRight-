// lib/src/pages/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

/// Single-file HomePage implementing:
/// - attractive Search bar that expands into a separate search-results area
/// - categories (horizontal), featured carousel, featured workers (horizontal)
/// - jobs list with card UI, pull-to-refresh, loading/error UI
/// - FAB + BottomNavigation behavior (uses local isLoggedIn bool)
///
/// Each visual block is implemented as a private method. If you want to extract any
/// block into a separate widget file later, inside the method you'll find a commented
/// `// To extract: return YourWidgetName();` line — simply replace the method body with that return.
class _HomePageState extends State<HomePage> {
  // UI state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  // Mock auth (replace with your AuthProvider)
  bool isLoggedIn = false;

  // Categories
  final List<String> categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'HVAC',
    'Cleaning',
    'Painting',
    'Appliance'
  ];
  String _selectedCategory = 'All';

  // Mock jobs (replace with real provider/backend)
  final List<Map<String, dynamic>> _allJobs = List.generate(12, (i) {
    final cats = ['Plumbing', 'Electrical', 'Carpentry', 'HVAC', 'Cleaning'];
    final cat = cats[i % cats.length];
    return {
      'id': '$i',
      'title': '${cat} Job #${i + 1}',
      'description': 'Short description for ${cat.toLowerCase()} job number ${i + 1}.',
      'price': 1500 + (i * 250),
      'category': cat,
      'locationName': ['Karachi', 'Lahore', 'Islamabad'][i % 3],
      'distanceKm': (i + 1) * 0.7,
    };
  });

  // Reactive job list & loading/error state
  List<Map<String, dynamic>> jobs = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _isSearching = _searchFocus.hasFocus || _searchController.text.isNotEmpty;
      });
    });
    _searchController.addListener(() {
      setState(() {
        // used to update clear icon in the search field
      });
    });

    // load initial jobs
    _fetchJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs({String category = '', String query = ''}) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 350));

      // Filtering locally (replace with API call / provider)
      final q = query.trim().toLowerCase();
      final filtered = _allJobs.where((j) {
        final matchesCat = category.isEmpty || j['category'] == category;
        final matchesQuery = q.isEmpty ||
            j['title'].toString().toLowerCase().contains(q) ||
            j['description'].toString().toLowerCase().contains(q) ||
            j['locationName'].toString().toLowerCase().contains(q);
        return matchesCat && matchesQuery;
      }).toList();

      setState(() {
        jobs = filtered;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load jobs';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _onSearch(String q) {
    // called while typing
    _fetchJobs(category: _selectedCategory == 'All' ? '' : _selectedCategory, query: q);
    setState(() {
      _isSearching = _searchFocus.hasFocus || q.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    _fetchJobs(category: _selectedCategory == 'All' ? '' : _selectedCategory, query: '');
    setState(() {
      _isSearching = false;
    });
  }

  void _onSelectCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _fetchJobs(category: cat == 'All' ? '' : cat, query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);
    final titleStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome,', style: bodySmall),
                // Replace with real user name from auth later
                const Text('Guest', style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
            IconButton(onPressed: () => _showSnack(context, 'Notifications (TODO)'), icon: const Icon(Icons.notifications_none)),
            IconButton(onPressed: () => _showSnack(context, 'Location (TODO)'), icon: const Icon(Icons.location_on_outlined)),
          ],
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top area with search, carousel, categories, featured pros, header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // SEARCH BAR
                  // Inline attractive search bar. To extract later, replace this entire widget with the widget name shown in the comment below.
                  //
                  // To extract: return SearchBarWidget(controller: _searchController, focusNode: _searchFocus, onChanged: _onSearch, onClear: _clearSearch);
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: _onSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search services, e.g., "AC cleaning"',
                        suffixIcon: _searchController.text.isEmpty
                            ? IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: () => _showSnack(context, 'Filters (TODO)'),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FEATURED CAROUSEL (small pageview)
                  // To extract: return FeaturedCarousel();
                  SizedBox(
                    height: 140,
                    child: PageView(
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network('https://picsum.photos/800/300?random=$i', fit: BoxFit.cover),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CATEGORIES HORIZONTAL LIST
                  SizedBox(
                    height: 92,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final selected = cat == _selectedCategory;
                        // Category tile inline. To extract later:
                        // To extract: return CategoryTile(title: cat, iconData: _iconForCategory(cat), selected: selected, onTap: () => _onSelectCategory(cat));
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => _onSelectCategory(cat),
                            child: Container(
                              width: 84,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(_iconForCategory(cat), size: 28),
                                const SizedBox(height: 8),
                                Text(cat, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter chips (inline)
                  Row(children: [
                    FilterChip(label: const Text('Nearby'), selected: false, onSelected: (_) => _showSnack(context, 'Nearby filter (TODO)')),
                    const SizedBox(width: 8),
                    FilterChip(label: const Text('Top rated'), selected: false, onSelected: (_) => _showSnack(context, 'Top rated (TODO)')),
                    const SizedBox(width: 8),
                    FilterChip(label: const Text('Under PKR 3000'), selected: false, onSelected: (_) => _showSnack(context, 'Price filter (TODO)')),
                  ]),

                  const SizedBox(height: 12),

                  // Featured Pros header + horizontal list
                  Row(children: [Text('Featured Pros', style: titleStyle), const Spacer(), TextButton(onPressed: () => _showSnack(context, 'See all pros (TODO)'), child: const Text('See all'))]),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: List.generate(6, (i) {
                        // Inline WorkerCard. To extract later:
                        // To extract: return WorkerCard(name: ..., skill: ..., rating: ..., imageUrl: ..., onTap: ...);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _showSnack(context, 'Open worker profile (TODO)'),
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${12 + i}')),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Worker ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(i % 2 == 0 ? 'Electrician' : 'Plumber'),
                                    const SizedBox(height: 6),
                                    Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text((4.5 - (i * 0.1)).toStringAsFixed(1))]),
                                  ]),
                                )
                              ]),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Available jobs header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    child: Row(children: [Text('Available jobs', style: titleStyle), const Spacer(), Text('${jobs.length} results', style: const TextStyle(color: Colors.grey))]),
                  ),
                  const SizedBox(height: 6),
                ]),
              ),
            ),

            // If searching: show search results area (separate scroll area) so carousel/categories are hidden
            if (_isSearching)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _buildSearchResults(),
                ),
              )
            else
              // Normal jobs list filling remaining space
              SliverFillRemaining(
                child: Builder(builder: (context) {
                  if (loading) return const Center(child: CircularProgressIndicator());
                  if (error != null) return Center(child: Text('Error: $error'));
                  if (jobs.isEmpty) return const Center(child: Text('No jobs found'));

                  return RefreshIndicator(
                    onRefresh: () => _fetchJobs(category: _selectedCategory == 'All' ? '' : _selectedCategory, query: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        // JobCard inline. To extract later:
                        // To extract: return JobCard(job: JobModel(...), onTap: () => ...);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showSnack(context, 'Open job ${job['title']} (TODO)'),
                              child: Row(children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                    child: Image.network('https://picsum.photos/200', fit: BoxFit.cover),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text(job['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                                        const SizedBox(width: 8),
                                        Text('PKR ${job['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ]),
                                      const SizedBox(height: 6),
                                      Text(job['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(job['locationName'] ?? 'Unknown', style: const TextStyle(color: Colors.grey)),
                                        const Spacer(),
                                        if (job['distanceKm'] != null) Text('${(job['distanceKm'] as double).toStringAsFixed(1)} km', style: const TextStyle(color: Colors.grey)),
                                      ])
                                    ]),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post Job'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            if (!isLoggedIn) {
              _showSnack(context, 'Please login first (TODO)');
            } else {
              _showSnack(context, 'Open post job screen (TODO)');
            }
          } else if (i == 2) {
            if (!isLoggedIn) {
              _showSnack(context, 'Please login first (TODO)');
            } else {
              _showSnack(context, 'Open profile (TODO)');
            }
          }
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Post Job'),
        icon: const Icon(Icons.add),
        onPressed: () {
          if (!isLoggedIn) {
            _showSnack(context, 'Please login first (TODO)');
          } else {
            _showSnack(context, 'Open post job (TODO)');
          }
        },
      ),
    );
  }

  // Build search results view (used when _isSearching is true)
  Widget _buildSearchResults() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Error: $error'));

    if (jobs.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No results found. Try different keywords.')));
    }

    // Inline list for search results. To extract later:
    // To extract: return SearchResultsList(items: jobs, onTap: ...);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            onTap: () => _showSnack(context, 'Open job ${job['title']} (TODO)'),
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://picsum.photos/80', fit: BoxFit.cover, width: 56, height: 56)),
            title: Text(job['title']),
            subtitle: Text(job['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text('PKR ${job['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'carpentry':
        return Icons.handyman;
      case 'hvac':
        return Icons.ac_unit;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'painting':
        return Icons.format_paint;
      case 'appliance':
        return Icons.kitchen;
      default:
        return Icons.build;
    }
  }

  void _showSnack(BuildContext ctx, String text) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(text)));
  }
}
