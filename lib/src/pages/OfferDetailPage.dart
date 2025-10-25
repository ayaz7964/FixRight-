// lib/pages/OfferDetailPage.dart

import 'package:flutter/material.dart';
import '../components/TopOffersList.dart'; 

class OfferDetailPage extends StatelessWidget {
  final Offer offer;

  const OfferDetailPage({required this.offer, super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: This boilerplate code for the page structure remains the same
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.favorite_border, color: Colors.white), 
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    // NOTE: Ensure you have fixed the pubspec.yaml and image path issue!
                    'assets/floor.jpg', 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Text("Image Placeholder")),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(offer.price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                      const SizedBox(height: 20),
                      _buildDescriptionSection(offer.description),
                      const Divider(height: 1, color: Colors.black12),
                      _buildTermsSection(),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 20),
                      
                      // --- THE FIXED WIDGET IS CALLED HERE ---
                      _buildProviderCard(offer.provider),
                      
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ordering ${offer.title}...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Order Now',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS REMAIN UNCHANGED (Description, Terms) ---

  Widget _buildDescriptionSection(String description) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      tilePadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return const ExpansionTile(
      title: Text('Terms and Conditions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      tilePadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Offer valid for new customers only. Cancellations must be made 24 hours in advance. Standard service guarantee applies.',
            style: TextStyle(color: Color(0xFF808080), fontSize: 14),
          ),
        ),
      ],
    );
  }

  // --- THE FIXED _buildProviderCard METHOD ---
  Widget _buildProviderCard(Map<String, dynamic> provider) {
    // Helper function to render stars
    Widget buildStars(double rating) {
      return Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating - 0.5 ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18, // Slightly larger stars for emphasis
          );
        }),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Aligns the content nicely
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Avatar (with rating bubble built-in)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(provider['name'][0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                      child: Text(
                        '${provider['rating']}', // Only show the number here
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),

              // 2. Provider Details
              Expanded( // <-- Crucial: Takes up all available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Star icons
                        buildStars(provider['rating']),
                        const SizedBox(width: 8),
                        // Rating and Review Count
                        Expanded( // Use Expanded here to manage space for the text block
                          child: Text(
                            '${provider['rating']} (${provider['reviews']} reviews)',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis, // FIX: Ellipsis to prevent overflow
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. View Profile Button
              TextButton(
                onPressed: () {},
                child: Text(
                  'View Profile',
                  style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Quote
          Text(
            '"${provider['quote']}"',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}