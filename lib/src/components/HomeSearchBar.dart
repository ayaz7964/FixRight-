// lib/components/HomeSearchBar.dart

import 'package:flutter/material.dart';
import './FiverrSearchDelegate.dart'; // We will create this next

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Launch the custom search overlay when the bar is tapped
          showSearch(
            context: context,
            delegate: FiverrSearchDelegate(),
          ).then((selectedQuery) {
            // Optional: Handle the result (the selected query) if needed
            if (selectedQuery != null && selectedQuery.isNotEmpty) {
              print('User searched for: $selectedQuery');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search action for: $selectedQuery')),
              );
              // You would typically navigate to a search results page here.
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 8.0),
              Expanded( 
                child: Text(
                  'What service are you looking for?',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                  // Optional: Ensure it doesn't wrap to a second line
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),)
            ],
          ),
        ),
      ),
    );
  }
}