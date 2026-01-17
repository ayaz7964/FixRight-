// lib/src/pages/seller_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/location_service.dart';
import '../../services/user_session.dart';
import 'LocationMapScreen.dart';

class SellerDashboardPage extends StatelessWidget {
  final String? phoneUID;

  const SellerDashboardPage({super.key, this.phoneUID});

  // A reusable card for displaying key stats
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(color: Colors.green),
        ),
        automaticallyImplyLeading: false, // Hide back button on main nav screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Key Metrics Row
            const Text(
              'Your Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  title: 'Net Earnings',
                  value: '\$1,250',
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  title: 'Active Orders',
                  value: '4',
                  color: Colors.orange,
                ),
              ],
            ),
            Row(
              children: [
                _buildStatCard(
                  title: 'Response Rate',
                  value: '95%',
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  title: 'Average Rating',
                  value: '4.9',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 2. Pending Actions
            const Text(
              'Pending Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.red),
                title: const Text('2 New Messages'),
                subtitle: const Text('Respond quickly to maintain your score.'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to Messages screen
                },
              ),
            ),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(
                  Icons.monetization_on,
                  color: Colors.orange,
                ),
                title: const Text('1 Pending Withdrawal'),
                subtitle: const Text('Approve funds transfer.'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to Earnings screen
                },
              ),
            ),

            const SizedBox(height: 25),

            // 3. Quick Links
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickLink(
                  context,
                  'Post a New Gig',
                  Icons.add_circle,
                  Colors.green,
                ),
                _buildQuickLink(
                  context,
                  'View Analytics',
                  Icons.analytics,
                  Colors.indigo,
                ),
                _buildQuickLink(
                  context,
                  'Service Templates',
                  Icons.copy,
                  Colors.brown,
                ),
                _buildQuickLink(
                  context,
                  'Promote Services',
                  Icons.share,
                  Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Handle navigation for quick links
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
