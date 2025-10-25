  // lib/components/LocalWorkerHighlight.dart

  import 'package:flutter/material.dart';

  class LocalWorkerHighlight extends StatelessWidget {
    final List<Map<String, dynamic>> localWorkers = const [
      {'name': 'Usman A.', 'rating': 4.9, 'job': 'Electrician', 'distance': '0.8km', 'tag': 'Verified Pro'},
      {'name': 'Zain B.', 'rating': 4.7, 'job': 'Plumber', 'distance': '1.2km', 'tag': 'Top Rated'},
      {'name': 'Hina C.', 'rating': 5.0, 'job': 'Cleaner', 'distance': '2.5km', 'tag': 'Recommended'},
      {'name': 'Asif D.', 'rating': 4.5, 'job': 'Carpenter', 'distance': '0.5km', 'tag': 'Verified Pro'},
    ];

    const LocalWorkerHighlight({super.key});

    @override
    Widget build(BuildContext context) {
      // We keep the main container for the title and padding
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section padding
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Top Workers Near You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal Scrollable Cards (The FIX and NEW DESIGN)
            SizedBox(
              height: 220, // Give a fixed height for the horizontal scroll area
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: localWorkers.length,
                itemBuilder: (context, index) {
                  final worker = localWorkers[index];
                  
                  // Add left padding to the first item and right padding to all
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 16.0 : 8.0, 
                      right: 8.0,
                    ),
                    child: _buildWorkerCard(worker), // Use the new card builder
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // New component to build the individual professional worker card
    Widget _buildWorkerCard(Map<String, dynamic> worker) {
      return Container(
        width: 180, // Fix the card width for a scrollable design
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Picture/Avatar Area (Takes ~70% of height)
            Container(
              height: 120, // Fixed height for the visual top half
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal.shade200,
                    child: Text(
                      worker['name'][0],
                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Corner Tag (e.g., Verified Pro)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        worker['tag'].toString().toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // 2. Text Content Area (Takes ~30% of height)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Worker Name
                  Text(
                    worker['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                  // Job Title
                  Text(
                    worker['job'].toString(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating and Distance
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${worker['rating']} (${worker['distance']} away)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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