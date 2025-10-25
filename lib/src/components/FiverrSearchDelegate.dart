// lib/delegates/FiverrSearchDelegate.dart

import 'package:flutter/material.dart';

// --- Mock Data ---
const List<String> _searchHistory = [
  'Logo Design',
  'Mobile App Development',
  'Video Editing',
  'SEO optimization'
];
const List<String> _popularSuggestions = [
  'Web design',
  'WordPress developer',
  'Voice over',
  'Data entry expert',
  'Social media manager',
  'Illustrator'
];

class FiverrSearchDelegate extends SearchDelegate<String> {
  // 1. Override the hint text shown in the search bar
  @override
  String get searchFieldLabel => 'Search for services or sellers...';

  // 2. Clear Button on the right of the search bar
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = ''; // Clear the text
            showSuggestions(context); // Show suggestions again
          },
        ),
    ];
  }

  // 3. Back Arrow on the left of the search bar
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close the search and return an empty result
      },
    );
  }

  // 4. Content shown when the user types (suggestions, history, or live results)
  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> displayList = query.isEmpty
        ? _popularSuggestions // Show popular suggestions when nothing is typed
        : _searchHistory.where((s) => s.toLowerCase().startsWith(query.toLowerCase())).toList(); // Filter history/suggestions based on input
    
    // Combine filtered history and a few popular suggestions
    if (query.isEmpty) {
      return _buildInitialView(context);
    }

    return ListView.builder(
      itemCount: displayList.length + 1, // +1 for the "search for query" option
      itemBuilder: (context, index) {
        if (index == 0) {
          // Show the current search term as the top option
          return ListTile(
            leading: const Icon(Icons.search),
            title: Text(
              query,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Execute the search action (sends result back to HomePage)
              close(context, query);
            },
          );
        }

        final suggestion = displayList[index - 1];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(suggestion),
          onTap: () {
            // Select a suggestion, update the search bar, and show results
            query = suggestion;
            showResults(context); // Immediately jump to showing results/preview
          },
        );
      },
    );
  }

  // Helper widget for the initial state (history + popular keywords)
  Widget _buildInitialView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History Section
          const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ..._searchHistory.map((term) => ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(term),
                trailing: const Icon(Icons.call_made, size: 18),
                onTap: () {
                  query = term;
                  showResults(context);
                },
              )).take(3), // Limit history display

          const SizedBox(height: 20),
          
          // Popular Keywords Section
          const Text('Popular Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _popularSuggestions.map((term) => ActionChip(
                  label: Text(term),
                  onPressed: () {
                    query = term;
                    showResults(context);
                  },
                )).toList(),
          ),
        ],
      ),
    );
  }

  // 5. Content shown after user submits or selects a suggestion (The "live preview" area)
  @override
  Widget buildResults(BuildContext context) {
    // This is the area where the user sees a rich preview of their search.
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The main search term button
            ElevatedButton.icon(
              onPressed: () {
                // Final submission action (sends result back to HomePage)
                close(context, query); 
              },
              icon: const Icon(Icons.search),
              label: Text('See All Results for: "$query"', style: const TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            
            const SizedBox(height: 20),

            // Mock Preview/Suggestion Section
            const Text(
              'Top Suggested Gigs (Preview)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Text('G1')),
              title: Text('Expert Gig related to "$query"'),
              subtitle: const Text('Starting at \$20'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to this specific gig page
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.red, child: Text('G2')),
              title: Text('Popular seller for "$query"'),
              subtitle: const Text('Top Rated Seller'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to this specific gig page
              },
            ),
          ],
        ),
      ),
    );
  }
}