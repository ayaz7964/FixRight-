// lib/components/TrustBanners.dart

import 'package:flutter/material.dart';

class TrustBanners extends StatelessWidget {
  const TrustBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose FixRight?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Scrollable horizontal list of feature cards
          SizedBox(
            height: 130, // Fixed height for the horizontal view
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFeatureCard(
                  'Verified Professionals',
                  'Background-checked workers only.',
                  Icons.verified_user,
                  Colors.green,
                ),
                _buildFeatureCard(
                  'Competitive Bidding',
                  'Compare bids from multiple workers.',
                  Icons.gavel,
                  Colors.orange,
                ),
                _buildFeatureCard(
                  'Rework Guarantee',
                  'Optional insurance for job replacement.',
                  Icons.handshake,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}