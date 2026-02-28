import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LocationMapScreen.dart';
import 'deposit_withdraw_page.dart';

class SellerDashboardPage extends StatefulWidget {
  final String? phoneUID;

  const SellerDashboardPage({super.key, this.phoneUID});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch seller data as a stream (real-time updates)
  Stream<DocumentSnapshot> _getSellerStream() {
    return _firestore.collection('sellers').doc(widget.phoneUID).snapshots();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    IconData? icon,
  }) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) Icon(icon, color: color, size: 20),
              if (icon != null) const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle navigation
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final status = data['status'] ?? 'N/A';
    final skills = List<String>.from(data['skills'] ?? []);

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'submitted':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.withOpacity(0.15),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (skills.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      skills.join(' • '),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FixRight Dashboard',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getSellerStream(),
        builder: (context, snapshot) {
          // ---------- Loading State ----------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // ---------- Error State ----------
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          // ---------- No Data State ----------
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No seller data found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // ---------- Data Loaded ----------
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final availableBalance = data['Available_Balance'] ?? 0;
          final earning = data['Earning'] ?? 0;
          final deposit = data['Deposit'] ?? 0;
          final jobsCompleted = data['Jobs_Completed'] ?? 0;
          final pendingJobs = data['Pending_Jobs'] ?? 0;
          final totalJobs = data['Total_Jobs'] ?? 0;
          final rating = (data['Rating'] ?? 0).toDouble();
          final withdrawalAmount = data['withdrawal_amount'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile Header ──────────────────────────────
                _buildProfileHeader(data),
                const SizedBox(height: 20),

                // ── Key Metrics ─────────────────────────────────
                const Text(
                  'Your Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Net Earnings',
                      value: 'Rs ${earning}',
                      color: Colors.green,
                      icon: Icons.payments,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      title: 'Active Orders',
                      value: '$pendingJobs',
                      color: Colors.orange,
                      icon: Icons.pending_actions,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Jobs Completed',
                      value: '$jobsCompleted / $totalJobs',
                      color: Colors.blue,
                      icon: Icons.check_circle,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      title: 'Average Rating',
                      value: '$rating ⭐',
                      color: Colors.purple,
                      icon: Icons.star,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Available Balance',
                      value: 'Rs $availableBalance',
                      color: Colors.teal,
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      title: 'Deposited',
                      value: 'Rs $deposit',
                      color: Colors.indigo,
                      icon: Icons.savings,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ── Pending Actions ──────────────────────────────
                const Text(
                  'Pending Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (pendingJobs > 0)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.work_outline,
                        color: Colors.orange,
                      ),
                      title: Text('$pendingJobs Pending Job(s)'),
                      subtitle: const Text(
                        'Complete them to maintain your rating.',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ),
                if (withdrawalAmount > 0)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                      title: Text('Withdrawal Pending: Rs $withdrawalAmount'),
                      subtitle: const Text('Approve your funds transfer.'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ),
                if (pendingJobs == 0 && withdrawalAmount == 0)
                  Card(
                    elevation: 0,
                    color: Colors.green.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('All caught up!'),
                      subtitle: Text('No pending actions right now.'),
                    ),
                  ),

                const SizedBox(height: 25),
                // _buildQuickLink(
                //   context,
                //   'Wallet',
                //   Icons.account_balance_wallet,
                //   Colors.teal,
                //   onTap: 
                // ),
                ElevatedButton(onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DepositWithdrawPage(phoneUID: widget.phoneUID!),
                    ),
                  ), child: Column(
                    children: const [
                      Text('Go to Wallet'),
                      Icon(Icons.account_balance_wallet),
                    ],
                  )),
                // ── Quick Access ─────────────────────────────────
                const Text(
                  'Quick Access',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}


// lib/src/pages/seller_dashboard_page.dart

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../services/location_service.dart';
// import '../../services/user_session.dart';
// import 'LocationMapScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SellerDashboardPage extends StatefulWidget {
//   // const SellerDashboardPage({super.key});
//   final String? phoneUID;

//   const SellerDashboardPage({super.key, this.phoneUID});

//   @override
//   State<SellerDashboardPage> createState() => _SellerDashboardPageState();
// }

// class _SellerDashboardPageState extends State<SellerDashboardPage> {
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Container();
//   // }

 
 
//   // A reusable card for displaying key stats
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.1),
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//      String ? uid = widget.phoneUID;
     
//      void getSellerData(){
      
//      }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'FixRight Dashboard ',
//           style: TextStyle(color: Colors.green),
//         ),
//         automaticallyImplyLeading: false, // Hide back button on main nav screen
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Key Metrics Row
//             Text('$uid'),
//             const Text(
//               'Your Performance',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 _buildStatCard(
//                   title: 'Net Earnings',
//                   value: '\$1,250',
//                   color: Colors.green,
//                 ),
//                 const SizedBox(width: 10),
//                 _buildStatCard(
//                   title: 'Active Orders',
//                   value: '4',
//                   color: Colors.orange,
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 _buildStatCard(
//                   title: 'Response Rate',
//                   value: '95%',
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 10),
//                 _buildStatCard(
//                   title: 'Average Rating',
//                   value: '4.9',
//                   color: Colors.purple,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 25),

//             // 2. Pending Actions
//             const Text(
//               'Pending Actions',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 leading: const Icon(Icons.pending_actions, color: Colors.red),
//                 title: const Text('2 New Messages'),
//                 subtitle: const Text('Respond quickly to maintain your score.'),
//                 trailing: const Icon(Icons.arrow_forward),
//                 onTap: () {
//                   // Navigate to Messages screen
//                 },
//               ),
//             ),
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 leading: const Icon(
//                   Icons.monetization_on,
//                   color: Colors.orange,
//                 ),
//                 title: const Text('1 Pending Withdrawal'),
//                 subtitle: const Text('Approve funds transfer.'),
//                 trailing: const Icon(Icons.arrow_forward),
//                 onTap: () {
//                   // Navigate to Earnings screen
//                 },
//               ),
//             ),

//             const SizedBox(height: 25),

//             // 3. Quick Links
//             const Text(
//               'Quick Access',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 _buildQuickLink(
//                   context,
//                   'Post a New Gig',
//                   Icons.add_circle,
//                   Colors.green,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'View Analytics',
//                   Icons.analytics,
//                   Colors.indigo,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'Service Templates',
//                   Icons.copy,
//                   Colors.brown,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'Promote Services',
//                   Icons.share,
//                   Colors.pink,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickLink(
//     BuildContext context,
//     String title,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           // Handle navigation for quick links
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SellerDashboardPage extends StatelessWidget {
//   final String? phoneUID;

//   const SellerDashboardPage({super.key, this.phoneUID});

//   // A reusable card for displaying key stats
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Card(
//         color: color.withOpacity(0.1),
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'FixRight Dashboard ',
//           style: TextStyle(color: Colors.green),
//         ),
//         automaticallyImplyLeading: false, // Hide back button on main nav screen
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Key Metrics Row
//             const Text(
//               'Your Performance',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 _buildStatCard(
//                   title: 'Net Earnings',
//                   value: '\$1,250',
//                   color: Colors.green,
//                 ),
//                 const SizedBox(width: 10),
//                 _buildStatCard(
//                   title: 'Active Orders',
//                   value: '4',
//                   color: Colors.orange,
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 _buildStatCard(
//                   title: 'Response Rate',
//                   value: '95%',
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 10),
//                 _buildStatCard(
//                   title: 'Average Rating',
//                   value: '4.9',
//                   color: Colors.purple,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 25),

//             // 2. Pending Actions
//             const Text(
//               'Pending Actions',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 leading: const Icon(Icons.pending_actions, color: Colors.red),
//                 title: const Text('2 New Messages'),
//                 subtitle: const Text('Respond quickly to maintain your score.'),
//                 trailing: const Icon(Icons.arrow_forward),
//                 onTap: () {
//                   // Navigate to Messages screen
//                 },
//               ),
//             ),
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 leading: const Icon(
//                   Icons.monetization_on,
//                   color: Colors.orange,
//                 ),
//                 title: const Text('1 Pending Withdrawal'),
//                 subtitle: const Text('Approve funds transfer.'),
//                 trailing: const Icon(Icons.arrow_forward),
//                 onTap: () {
//                   // Navigate to Earnings screen
//                 },
//               ),
//             ),

//             const SizedBox(height: 25),

//             // 3. Quick Links
//             const Text(
//               'Quick Access',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 _buildQuickLink(
//                   context,
//                   'Post a New Gig',
//                   Icons.add_circle,
//                   Colors.green,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'View Analytics',
//                   Icons.analytics,
//                   Colors.indigo,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'Service Templates',
//                   Icons.copy,
//                   Colors.brown,
//                 ),
//                 _buildQuickLink(
//                   context,
//                   'Promote Services',
//                   Icons.share,
//                   Colors.pink,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickLink(
//     BuildContext context,
//     String title,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           // Handle navigation for quick links
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
