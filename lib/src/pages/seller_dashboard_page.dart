//   // import 'package:flutter/material.dart';
//   // import 'package:cloud_firestore/cloud_firestore.dart';
//   // import 'LocationMapScreen.dart';
//   // import 'deposit_withdraw_page.dart';

//   // class SellerDashboardPage extends StatefulWidget {
//   //   final String? phoneUID;

//   //   const SellerDashboardPage({super.key, this.phoneUID});

//   //   @override
//   //   State<SellerDashboardPage> createState() => _SellerDashboardPageState();
//   // }

//   // class _SellerDashboardPageState extends State<SellerDashboardPage> {
//   //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   //   // Fetch seller data as a stream (real-time updates)
//   //   Stream<DocumentSnapshot> _getSellerStream() {
//   //     return _firestore.collection('sellers').doc(widget.phoneUID).snapshots();
//   //   }

//   //   Widget _buildStatCard({
//   //     required String title,
//   //     required String value,
//   //     required Color color,
//   //     IconData? icon,
//   //   }) {
//   //     return Expanded(
//   //       child: Card(
//   //         color: color.withOpacity(0.1),
//   //         elevation: 0,
//   //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //         child: Padding(
//   //           padding: const EdgeInsets.all(14.0),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               if (icon != null) Icon(icon, color: color, size: 20),
//   //               if (icon != null) const SizedBox(height: 6),
//   //               Text(
//   //                 title,
//   //                 style: TextStyle(
//   //                   color: color,
//   //                   fontWeight: FontWeight.bold,
//   //                   fontSize: 12,
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 6),
//   //               Text(
//   //                 value,
//   //                 style: TextStyle(
//   //                   color: color,
//   //                   fontWeight: FontWeight.w900,
//   //                   fontSize: 22,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   Widget _buildQuickLink(
//   //     BuildContext context,
//   //     String title,
//   //     IconData icon,
//   //     Color color,
//   //   ) {
//   //     return Card(
//   //       elevation: 2,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //       child: InkWell(
//   //         borderRadius: BorderRadius.circular(12),
//   //         onTap: () {
//   //           // Handle navigation
//   //         },
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: [
//   //             Icon(icon, size: 38, color: color),
//   //             const SizedBox(height: 8),
//   //             Text(
//   //               title,
//   //               textAlign: TextAlign.center,
//   //               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   /// Builds the profile header section
//   //   Widget _buildProfileHeader(Map<String, dynamic> data) {
//   //     final firstName = data['firstName'] ?? '';
//   //     final lastName = data['lastName'] ?? '';
//   //     final status = data['status'] ?? 'N/A';
//   //     final skills = List<String>.from(data['skills'] ?? []);

//   //     Color statusColor;
//   //     switch (status) {
//   //       case 'approved':
//   //         statusColor = Colors.green;
//   //         break;
//   //       case 'submitted':
//   //         statusColor = Colors.orange;
//   //         break;
//   //       case 'rejected':
//   //         statusColor = Colors.red;
//   //         break;
//   //       default:
//   //         statusColor = Colors.grey;
//   //     }

//   //     return Card(
//   //       elevation: 2,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //       child: Padding(
//   //         padding: const EdgeInsets.all(16.0),
//   //         child: Row(
//   //           children: [
//   //             CircleAvatar(
//   //               radius: 30,
//   //               backgroundColor: Colors.green.withOpacity(0.15),
//   //               child: Text(
//   //                 firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
//   //                 style: const TextStyle(
//   //                   fontSize: 24,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.green,
//   //                 ),
//   //               ),
//   //             ),
//   //             const SizedBox(width: 14),
//   //             Expanded(
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Text(
//   //                     '$firstName $lastName',
//   //                     style: const TextStyle(
//   //                       fontSize: 18,
//   //                       fontWeight: FontWeight.bold,
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 4),
//   //                   Row(
//   //                     children: [
//   //                       Container(
//   //                         padding: const EdgeInsets.symmetric(
//   //                           horizontal: 8,
//   //                           vertical: 2,
//   //                         ),
//   //                         decoration: BoxDecoration(
//   //                           color: statusColor.withOpacity(0.15),
//   //                           borderRadius: BorderRadius.circular(20),
//   //                         ),
//   //                         child: Text(
//   //                           status.toUpperCase(),
//   //                           style: TextStyle(
//   //                             color: statusColor,
//   //                             fontWeight: FontWeight.bold,
//   //                             fontSize: 11,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   if (skills.isNotEmpty) ...[
//   //                     const SizedBox(height: 6),
//   //                     Text(
//   //                       skills.join(' • '),
//   //                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//   //                       maxLines: 1,
//   //                       overflow: TextOverflow.ellipsis,
//   //                     ),
//   //                   ],
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   @override
//   //   Widget build(BuildContext context) {
//   //     return Scaffold(
//   //       appBar: AppBar(
//   //         title: const Text(
//   //           'FixRight Dashboard ',
//   //           style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//   //         ),
//   //         automaticallyImplyLeading: false,
//   //         elevation: 0,
//   //       ),
//   //       body: StreamBuilder<DocumentSnapshot>(
//   //         stream: _getSellerStream(),
//   //         builder: (context, snapshot) {
//   //           // ---------- Loading State ----------
//   //           if (snapshot.connectionState == ConnectionState.waiting) {
//   //             return const Center(
//   //               child: CircularProgressIndicator(color: Colors.green),
//   //             );
//   //           }

//   //           // ---------- Error State ----------
//   //           if (snapshot.hasError) {
//   //             return Center(
//   //               child: Column(
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 children: [
//   //                   const Icon(Icons.error_outline, color: Colors.red, size: 50),
//   //                   const SizedBox(height: 10),
//   //                   Text(
//   //                     'Error: ${snapshot.error}',
//   //                     textAlign: TextAlign.center,
//   //                     style: const TextStyle(color: Colors.red),
//   //                   ),
//   //                 ],
//   //               ),
//   //             );
//   //           }

//   //           // ---------- No Data State ----------
//   //           if (!snapshot.hasData || !snapshot.data!.exists) {
//   //             return const Center(
//   //               child: Text(
//   //                 'No seller data found.',
//   //                 style: TextStyle(fontSize: 16, color: Colors.grey),
//   //               ),
//   //             );
//   //           }

//   //           // ---------- Data Loaded ----------
//   //           final data = snapshot.data!.data() as Map<String, dynamic>;

//   //           final availableBalance = data['Available_Balance'] ?? 0;
//   //           final earning = data['Earning'] ?? 0;
//   //           final deposit = data['Deposit'] ?? 0;
//   //           final jobsCompleted = data['Jobs_Completed'] ?? 0;
//   //           final pendingJobs = data['Pending_Jobs'] ?? 0;
//   //           final totalJobs = data['Total_Jobs'] ?? 0;
//   //           final rating = (data['Rating'] ?? 0).toDouble();
//   //           final withdrawalAmount = data['withdrawal_amount'] ?? 0;

//   //           return SingleChildScrollView(
//   //             padding: const EdgeInsets.all(16.0),
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 // ── Profile Header ──────────────────────────────
//   //                 _buildProfileHeader(data),
//   //                 const SizedBox(height: 20),

//   //                 // ── Key Metrics ─────────────────────────────────
//   //                 const Text(
//   //                   'Your Performance',
//   //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 Row(
//   //                   children: [
//   //                     _buildStatCard(
//   //                       title: 'Net Earnings',
//   //                       value: 'Rs $earning',
//   //                       color: Colors.green,
//   //                       icon: Icons.payments,
//   //                     ),
//   //                     const SizedBox(width: 10),
//   //                     _buildStatCard(
//   //                       title: 'Active Orders',
//   //                       value: '$pendingJobs',
//   //                       color: Colors.orange,
//   //                       icon: Icons.pending_actions,
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 Row(
//   //                   children: [
//   //                     _buildStatCard(
//   //                       title: 'Jobs Completed',
//   //                       value: '$jobsCompleted / $totalJobs',
//   //                       color: Colors.blue,
//   //                       icon: Icons.check_circle,
//   //                     ),
//   //                     const SizedBox(width: 10),
//   //                     _buildStatCard(
//   //                       title: 'Average Rating',
//   //                       value: '$rating ⭐',
//   //                       color: Colors.purple,
//   //                       icon: Icons.star,
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 Row(
//   //                   children: [
//   //                     _buildStatCard(
//   //                       title: 'Available Balance',
//   //                       value: 'Rs $availableBalance',
//   //                       color: Colors.teal,
//   //                       icon: Icons.account_balance_wallet,
//   //                     ),
//   //                     const SizedBox(width: 10),
//   //                     _buildStatCard(
//   //                       title: 'Deposited',
//   //                       value: 'Rs $deposit',
//   //                       color: Colors.indigo,
//   //                       icon: Icons.savings,
//   //                     ),
//   //                   ],
//   //                 ),

//   //                 const SizedBox(height: 25),

//   //                 // ── Pending Actions ──────────────────────────────
//   //                 const Text(
//   //                   'Pending Actions',
//   //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 if (pendingJobs > 0)
//   //                   Card(
//   //                     elevation: 2,
//   //                     shape: RoundedRectangleBorder(
//   //                       borderRadius: BorderRadius.circular(10),
//   //                     ),
//   //                     child: ListTile(
//   //                       leading: const Icon(
//   //                         Icons.work_outline,
//   //                         color: Colors.orange,
//   //                       ),
//   //                       title: Text('$pendingJobs Pending Job(s)'),
//   //                       subtitle: const Text(
//   //                         'Complete them to maintain your rating.',
//   //                       ),
//   //                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//   //                       onTap: () {},
//   //                     ),
//   //                   ),
//   //                 if (withdrawalAmount > 0)
//   //                   Card(
//   //                     elevation: 2,
//   //                     shape: RoundedRectangleBorder(
//   //                       borderRadius: BorderRadius.circular(10),
//   //                     ),
//   //                     child: ListTile(
//   //                       leading: const Icon(
//   //                         Icons.monetization_on,
//   //                         color: Colors.green,
//   //                       ),
//   //                       title: Text('Withdrawal Pending: Rs $withdrawalAmount'),
//   //                       subtitle: const Text('Approve your funds transfer.'),
//   //                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//   //                       onTap: () {},
//   //                     ),
//   //                   ),
//   //                 if (pendingJobs == 0 && withdrawalAmount == 0)
//   //                   Card(
//   //                     elevation: 0,
//   //                     color: Colors.green.withOpacity(0.08),
//   //                     shape: RoundedRectangleBorder(
//   //                       borderRadius: BorderRadius.circular(10),
//   //                     ),
//   //                     child: const ListTile(
//   //                       leading: Icon(Icons.check_circle, color: Colors.green),
//   //                       title: Text('All caught up!'),
//   //                       subtitle: Text('No pending actions right now.'),
//   //                     ),
//   //                   ),

//   //                 const SizedBox(height: 25),
//   //                 // _buildQuickLink(
//   //                 //   context,
//   //                 //   'Wallet',
//   //                 //   Icons.account_balance_wallet,
//   //                 //   Colors.teal,
//   //                 //   onTap: 
//   //                 // ),
//   //                 ElevatedButton(onPressed: () => Navigator.push(
//   //                     context,
//   //                     MaterialPageRoute(
//   //                       builder: (_) =>
//   //                           DepositWithdrawPage(phoneUID: widget.phoneUID!),
//   //                     ),
//   //                   ), child: Column(
//   //                     children: const [
//   //                       Text('Go to Wallet'),
//   //                       Icon(Icons.account_balance_wallet),
//   //                     ],
//   //                   )),
//   //                 // ── Quick Access ─────────────────────────────────
//   //                 const Text(
//   //                   'Quick Access',
//   //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 GridView.count(
//   //                   crossAxisCount: 2,
//   //                   shrinkWrap: true,
//   //                   physics: const NeverScrollableScrollPhysics(),
//   //                   crossAxisSpacing: 8,
//   //                   mainAxisSpacing: 8,
//   //                   children: [
//   //                     _buildQuickLink(
//   //                       context,
//   //                       'Post a New Gig',
//   //                       Icons.add_circle,
//   //                       Colors.green,
//   //                     ),
//   //                     _buildQuickLink(
//   //                       context,
//   //                       'View Analytics',
//   //                       Icons.analytics,
//   //                       Colors.indigo,
//   //                     ),
//   //                     _buildQuickLink(
//   //                       context,
//   //                       'Service Templates',
//   //                       Icons.copy,
//   //                       Colors.brown,
//   //                     ),
//   //                     _buildQuickLink(
//   //                       context,
//   //                       'Promote Services',
//   //                       Icons.share,
//   //                       Colors.pink,
//   //                     ),
//   //                   ],
//   //                 ),

//   //                 const SizedBox(height: 20),
//   //               ],
//   //             ),
//   //           );
//   //         },
//   //       ),
//   //     );
//   //   }
//   // }


//   // // lib/src/pages/seller_dashboard_page.dart

//   // // import 'package:flutter/material.dart';
//   // // import 'package:cloud_firestore/cloud_firestore.dart';
//   // // import '../../services/location_service.dart';
//   // // import '../../services/user_session.dart';
//   // // import 'LocationMapScreen.dart';
//   // // import 'package:cloud_firestore/cloud_firestore.dart';

//   // // class SellerDashboardPage extends StatefulWidget {
//   // //   // const SellerDashboardPage({super.key});
//   // //   final String? phoneUID;

//   // //   const SellerDashboardPage({super.key, this.phoneUID});

//   // //   @override
//   // //   State<SellerDashboardPage> createState() => _SellerDashboardPageState();
//   // // }

//   // // class _SellerDashboardPageState extends State<SellerDashboardPage> {
//   // //   // @override
//   // //   // Widget build(BuildContext context) {
//   // //   //   return Container();
//   // //   // }

  
  
//   // //   // A reusable card for displaying key stats
//   // //   Widget _buildStatCard({
//   // //     required String title,
//   // //     required String value,
//   // //     required Color color,
//   // //   }) {
//   // //     return Expanded(
//   // //       child: Card(
//   // //         color: color.withOpacity(0.1),
//   // //         elevation: 0,
//   // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   // //         child: Padding(
//   // //           padding: const EdgeInsets.all(16.0),
//   // //           child: Column(
//   // //             crossAxisAlignment: CrossAxisAlignment.start,
//   // //             children: [
//   // //               Text(
//   // //                 title,
//   // //                 style: TextStyle(
//   // //                   color: color,
//   // //                   fontWeight: FontWeight.bold,
//   // //                   fontSize: 14,
//   // //                 ),
//   // //               ),
//   // //               const SizedBox(height: 8),
//   // //               Text(
//   // //                 value,
//   // //                 style: TextStyle(
//   // //                   color: color,
//   // //                   fontWeight: FontWeight.w900,
//   // //                   fontSize: 24,
//   // //                 ),
//   // //               ),
//   // //             ],
//   // //           ),
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }

//   // //   @override
//   // //   Widget build(BuildContext context) {
//   // //      String ? uid = widget.phoneUID;
      
//   // //      void getSellerData(){
        
//   // //      }
//   // //     return Scaffold(
//   // //       appBar: AppBar(
//   // //         title: const Text(
//   // //           'FixRight Dashboard ',
//   // //           style: TextStyle(color: Colors.green),
//   // //         ),
//   // //         automaticallyImplyLeading: false, // Hide back button on main nav screen
//   // //       ),
//   // //       body: SingleChildScrollView(
//   // //         padding: const EdgeInsets.all(16.0),
//   // //         child: Column(
//   // //           crossAxisAlignment: CrossAxisAlignment.start,
//   // //           children: [
//   // //             // 1. Key Metrics Row
//   // //             Text('$uid'),
//   // //             const Text(
//   // //               'Your Performance',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             const SizedBox(height: 10),
//   // //             Row(
//   // //               children: [
//   // //                 _buildStatCard(
//   // //                   title: 'Net Earnings',
//   // //                   value: '\$1,250',
//   // //                   color: Colors.green,
//   // //                 ),
//   // //                 const SizedBox(width: 10),
//   // //                 _buildStatCard(
//   // //                   title: 'Active Orders',
//   // //                   value: '4',
//   // //                   color: Colors.orange,
//   // //                 ),
//   // //               ],
//   // //             ),
//   // //             Row(
//   // //               children: [
//   // //                 _buildStatCard(
//   // //                   title: 'Response Rate',
//   // //                   value: '95%',
//   // //                   color: Colors.blue,
//   // //                 ),
//   // //                 const SizedBox(width: 10),
//   // //                 _buildStatCard(
//   // //                   title: 'Average Rating',
//   // //                   value: '4.9',
//   // //                   color: Colors.purple,
//   // //                 ),
//   // //               ],
//   // //             ),

//   // //             const SizedBox(height: 25),

//   // //             // 2. Pending Actions
//   // //             const Text(
//   // //               'Pending Actions',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             const SizedBox(height: 10),
//   // //             Card(
//   // //               elevation: 2,
//   // //               child: ListTile(
//   // //                 leading: const Icon(Icons.pending_actions, color: Colors.red),
//   // //                 title: const Text('2 New Messages'),
//   // //                 subtitle: const Text('Respond quickly to maintain your score.'),
//   // //                 trailing: const Icon(Icons.arrow_forward),
//   // //                 onTap: () {
//   // //                   // Navigate to Messages screen
//   // //                 },
//   // //               ),
//   // //             ),
//   // //             Card(
//   // //               elevation: 2,
//   // //               child: ListTile(
//   // //                 leading: const Icon(
//   // //                   Icons.monetization_on,
//   // //                   color: Colors.orange,
//   // //                 ),
//   // //                 title: const Text('1 Pending Withdrawal'),
//   // //                 subtitle: const Text('Approve funds transfer.'),
//   // //                 trailing: const Icon(Icons.arrow_forward),
//   // //                 onTap: () {
//   // //                   // Navigate to Earnings screen
//   // //                 },
//   // //               ),
//   // //             ),

//   // //             const SizedBox(height: 25),

//   // //             // 3. Quick Links
//   // //             const Text(
//   // //               'Quick Access',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             GridView.count(
//   // //               crossAxisCount: 2,
//   // //               shrinkWrap: true,
//   // //               physics: const NeverScrollableScrollPhysics(),
//   // //               children: [
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Post a New Gig',
//   // //                   Icons.add_circle,
//   // //                   Colors.green,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'View Analytics',
//   // //                   Icons.analytics,
//   // //                   Colors.indigo,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Service Templates',
//   // //                   Icons.copy,
//   // //                   Colors.brown,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Promote Services',
//   // //                   Icons.share,
//   // //                   Colors.pink,
//   // //                 ),
//   // //               ],
//   // //             ),
//   // //           ],
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }

//   // //   Widget _buildQuickLink(
//   // //     BuildContext context,
//   // //     String title,
//   // //     IconData icon,
//   // //     Color color,
//   // //   ) {
//   // //     return Card(
//   // //       elevation: 2,
//   // //       child: InkWell(
//   // //         onTap: () {
//   // //           // Handle navigation for quick links
//   // //         },
//   // //         child: Column(
//   // //           mainAxisAlignment: MainAxisAlignment.center,
//   // //           children: [
//   // //             Icon(icon, size: 40, color: color),
//   // //             const SizedBox(height: 8),
//   // //             Text(
//   // //               title,
//   // //               textAlign: TextAlign.center,
//   // //               style: const TextStyle(fontWeight: FontWeight.w600),
//   // //             ),
//   // //           ],
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }
//   // // }

//   // // class SellerDashboardPage extends StatelessWidget {
//   // //   final String? phoneUID;

//   // //   const SellerDashboardPage({super.key, this.phoneUID});

//   // //   // A reusable card for displaying key stats
//   // //   Widget _buildStatCard({
//   // //     required String title,
//   // //     required String value,
//   // //     required Color color,
//   // //   }) {
//   // //     return Expanded(
//   // //       child: Card(
//   // //         color: color.withOpacity(0.1),
//   // //         elevation: 0,
//   // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   // //         child: Padding(
//   // //           padding: const EdgeInsets.all(16.0),
//   // //           child: Column(
//   // //             crossAxisAlignment: CrossAxisAlignment.start,
//   // //             children: [
//   // //               Text(
//   // //                 title,
//   // //                 style: TextStyle(
//   // //                   color: color,
//   // //                   fontWeight: FontWeight.bold,
//   // //                   fontSize: 14,
//   // //                 ),
//   // //               ),
//   // //               const SizedBox(height: 8),
//   // //               Text(
//   // //                 value,
//   // //                 style: TextStyle(
//   // //                   color: color,
//   // //                   fontWeight: FontWeight.w900,
//   // //                   fontSize: 24,
//   // //                 ),
//   // //               ),
//   // //             ],
//   // //           ),
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }

//   // //   @override
//   // //   Widget build(BuildContext context) {
//   // //     return Scaffold(
//   // //       appBar: AppBar(
//   // //         title: const Text(
//   // //           'FixRight Dashboard ',
//   // //           style: TextStyle(color: Colors.green),
//   // //         ),
//   // //         automaticallyImplyLeading: false, // Hide back button on main nav screen
//   // //       ),
//   // //       body: SingleChildScrollView(
//   // //         padding: const EdgeInsets.all(16.0),
//   // //         child: Column(
//   // //           crossAxisAlignment: CrossAxisAlignment.start,
//   // //           children: [
//   // //             // 1. Key Metrics Row
//   // //             const Text(
//   // //               'Your Performance',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             const SizedBox(height: 10),
//   // //             Row(
//   // //               children: [
//   // //                 _buildStatCard(
//   // //                   title: 'Net Earnings',
//   // //                   value: '\$1,250',
//   // //                   color: Colors.green,
//   // //                 ),
//   // //                 const SizedBox(width: 10),
//   // //                 _buildStatCard(
//   // //                   title: 'Active Orders',
//   // //                   value: '4',
//   // //                   color: Colors.orange,
//   // //                 ),
//   // //               ],
//   // //             ),
//   // //             Row(
//   // //               children: [
//   // //                 _buildStatCard(
//   // //                   title: 'Response Rate',
//   // //                   value: '95%',
//   // //                   color: Colors.blue,
//   // //                 ),
//   // //                 const SizedBox(width: 10),
//   // //                 _buildStatCard(
//   // //                   title: 'Average Rating',
//   // //                   value: '4.9',
//   // //                   color: Colors.purple,
//   // //                 ),
//   // //               ],
//   // //             ),

//   // //             const SizedBox(height: 25),

//   // //             // 2. Pending Actions
//   // //             const Text(
//   // //               'Pending Actions',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             const SizedBox(height: 10),
//   // //             Card(
//   // //               elevation: 2,
//   // //               child: ListTile(
//   // //                 leading: const Icon(Icons.pending_actions, color: Colors.red),
//   // //                 title: const Text('2 New Messages'),
//   // //                 subtitle: const Text('Respond quickly to maintain your score.'),
//   // //                 trailing: const Icon(Icons.arrow_forward),
//   // //                 onTap: () {
//   // //                   // Navigate to Messages screen
//   // //                 },
//   // //               ),
//   // //             ),
//   // //             Card(
//   // //               elevation: 2,
//   // //               child: ListTile(
//   // //                 leading: const Icon(
//   // //                   Icons.monetization_on,
//   // //                   color: Colors.orange,
//   // //                 ),
//   // //                 title: const Text('1 Pending Withdrawal'),
//   // //                 subtitle: const Text('Approve funds transfer.'),
//   // //                 trailing: const Icon(Icons.arrow_forward),
//   // //                 onTap: () {
//   // //                   // Navigate to Earnings screen
//   // //                 },
//   // //               ),
//   // //             ),

//   // //             const SizedBox(height: 25),

//   // //             // 3. Quick Links
//   // //             const Text(
//   // //               'Quick Access',
//   // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   // //             ),
//   // //             GridView.count(
//   // //               crossAxisCount: 2,
//   // //               shrinkWrap: true,
//   // //               physics: const NeverScrollableScrollPhysics(),
//   // //               children: [
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Post a New Gig',
//   // //                   Icons.add_circle,
//   // //                   Colors.green,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'View Analytics',
//   // //                   Icons.analytics,
//   // //                   Colors.indigo,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Service Templates',
//   // //                   Icons.copy,
//   // //                   Colors.brown,
//   // //                 ),
//   // //                 _buildQuickLink(
//   // //                   context,
//   // //                   'Promote Services',
//   // //                   Icons.share,
//   // //                   Colors.pink,
//   // //                 ),
//   // //               ],
//   // //             ),
//   // //           ],
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }

//   // //   Widget _buildQuickLink(
//   // //     BuildContext context,
//   // //     String title,
//   // //     IconData icon,
//   // //     Color color,
//   // //   ) {
//   // //     return Card(
//   // //       elevation: 2,
//   // //       child: InkWell(
//   // //         onTap: () {
//   // //           // Handle navigation for quick links
//   // //         },
//   // //         child: Column(
//   // //           mainAxisAlignment: MainAxisAlignment.center,
//   // //           children: [
//   // //             Icon(icon, size: 40, color: color),
//   // //             const SizedBox(height: 8),
//   // //             Text(
//   // //               title,
//   // //               textAlign: TextAlign.center,
//   // //               style: const TextStyle(fontWeight: FontWeight.w600),
//   // //             ),
//   // //           ],
//   // //         ),
//   // //       ),
//   // //     );
//   // //   }
//   // // }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'deposit_withdraw_page.dart';
// import 'SellerDirectoryScreen.dart';

// class SellerDashboardPage extends StatefulWidget {
//   final String? phoneUID;
//   const SellerDashboardPage({super.key, this.phoneUID});

//   @override
//   State<SellerDashboardPage> createState() => _SellerDashboardPageState();
// }

// class _SellerDashboardPageState extends State<SellerDashboardPage> {
//   static const _teal     = Color(0xFF00695C);
//   static const _tealDark = Color(0xFF004D40);

//   Map<String, dynamic> _userData    = {};
//   Map<String, dynamic> _sellerData  = {};
//   bool _loadingProfile = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }

//   Future<void> _loadProfile() async {
//     if (widget.phoneUID == null) return;
//     try {
//       final results = await Future.wait([
//         FirebaseFirestore.instance.collection('users').doc(widget.phoneUID).get(),
//         FirebaseFirestore.instance.collection('sellers').doc(widget.phoneUID).get(),
//       ]);
//       if (mounted) {
//         setState(() {
//           _userData   = results[0].data() as Map<String, dynamic>? ?? {};
//           _sellerData = results[1].data() as Map<String, dynamic>? ?? {};
//           _loadingProfile = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _loadingProfile = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F4F7),
//       body: _loadingProfile
//           ? const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
//           : StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('sellers')
//                   .doc(widget.phoneUID)
//                   .snapshots(),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting && _sellerData.isEmpty) {
//                   return const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2));
//                 }
//                 final data = (snap.data?.data() as Map<String, dynamic>?) ?? _sellerData;
//                 return CustomScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   slivers: [
//                     SliverToBoxAdapter(child: _buildHeader(data)),
//                     SliverToBoxAdapter(child: _buildStatsGrid(data)),
//                     SliverToBoxAdapter(child: _buildActionRow(data)),
//                     SliverToBoxAdapter(child: _buildOffersSection()),
//                     const SliverToBoxAdapter(child: SizedBox(height: 40)),
//                   ],
//                 );
//               },
//             ),
//     );
//   }

//   // ── Header with profile image ──────────────────────────────
//   Widget _buildHeader(Map<String, dynamic> data) {
//     final firstName = (_userData['firstName'] ?? data['firstName'] ?? '') as String;
//     final lastName  = (_userData['lastName']  ?? data['lastName']  ?? '') as String;
//     final name      = '$firstName $lastName'.trim();
//     final img       = (_userData['profileImage'] as String? ?? '').trim();
//     final status    = (data['status'] as String? ?? 'pending');
//     final city      = (_userData['city'] as String? ?? '').trim();
//     final skills    = List<String>.from(data['skills'] ?? []);
//     final rating    = (data['Rating'] ?? 0.0).toDouble();
//     final jobs      = (data['Jobs_Completed'] ?? 0) as int;

//     Color statusColor;
//     String statusLabel;
//     switch (status) {
//       case 'approved': statusColor = Colors.green; statusLabel = '✓ Approved'; break;
//       case 'submitted': statusColor = Colors.orange; statusLabel = '⏳ Pending'; break;
//       case 'rejected': statusColor = Colors.red; statusLabel = '✗ Rejected'; break;
//       default: statusColor = Colors.grey; statusLabel = status.toUpperCase();
//     }

//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//             begin: Alignment.topLeft, end: Alignment.bottomRight,
//             colors: [_teal, _tealDark]),
//         borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
//         boxShadow: [BoxShadow(color: Color(0x55004D40), blurRadius: 20, offset: Offset(0, 8))]),
//       child: SafeArea(bottom: false, child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // top bar
//           Row(children: [
//             const Text('My Dashboard',
//                 style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: statusColor.withOpacity(0.5))),
//               child: Text(statusLabel,
//                   style: TextStyle(color: statusColor == Colors.green ? Colors.greenAccent : statusColor,
//                       fontSize: 11.5, fontWeight: FontWeight.w700)),
//             ),
//           ]),

//           const SizedBox(height: 20),

//           // Profile row
//           Row(children: [
//             // Avatar with border
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
//                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
//               child: CircleAvatar(
//                 radius: 38, backgroundColor: Colors.white.withOpacity(0.2),
//                 backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
//                 child: img.isEmpty
//                     ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30))
//                     : null,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(name.isNotEmpty ? name : 'Seller',
//                   style: const TextStyle(color: Colors.white, fontSize: 22,
//                       fontWeight: FontWeight.w900, letterSpacing: -0.3)),
//               if (city.isNotEmpty) ...[
//                 const SizedBox(height: 4),
//                 Row(children: [
//                   const Icon(Icons.location_on, size: 13, color: Colors.white60),
//                   const SizedBox(width: 3),
//                   Text(city, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//                 ]),
//               ],
//               const SizedBox(height: 6),
//               Row(children: [
//                 Icon(Icons.star_rounded, size: 14, color: Colors.amber[300]),
//                 const SizedBox(width: 3),
//                 Text(rating.toStringAsFixed(1),
//                     style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
//                 Text('  ·  $jobs jobs done',
//                     style: const TextStyle(color: Colors.white60, fontSize: 12)),
//               ]),
//               if (skills.isNotEmpty) ...[
//                 const SizedBox(height: 8),
//                 Text(skills.take(3).join(' · '),
//                     style: const TextStyle(color: Colors.white60, fontSize: 11.5),
//                     maxLines: 1, overflow: TextOverflow.ellipsis),
//               ],
//             ])),
//           ]),
//         ]),
//       )),
//     );
//   }

//   // ── Stats grid ────────────────────────────────────────────
//   Widget _buildStatsGrid(Map<String, dynamic> data) {
//     final balance  = (data['Available_Balance'] ?? 0).toDouble();
//     final earning  = (data['Earning']           ?? 0).toDouble();
//     final pending  = (data['Pending_Jobs']      ?? 0) as int;
//     final total    = (data['Total_Jobs']        ?? 0) as int;
//     final reserved = (data['Reserved_Commission'] ?? 0).toDouble();
//     final deposit  = (data['Deposit']           ?? 0).toDouble();

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('Overview', style: TextStyle(
//             fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
//         const SizedBox(height: 14),
//         Row(children: [
//           _statCard('Net Earnings', 'PKR ${earning.toStringAsFixed(0)}',
//               Icons.payments_rounded, const Color(0xFF1B5E20), const Color(0xFFE8F5E9)),
//           const SizedBox(width: 12),
//           _statCard('Available', 'PKR ${balance.toStringAsFixed(0)}',
//               Icons.account_balance_wallet_rounded, _teal, const Color(0xFFE0F2F1)),
//         ]),
//         const SizedBox(height: 12),
//         Row(children: [
//           _statCard('Active Jobs', '$pending / $total',
//               Icons.pending_actions_rounded, const Color(0xFFE65100), const Color(0xFFFFF3E0)),
//           const SizedBox(width: 12),
//           _statCard('Reserved', 'PKR ${reserved.toStringAsFixed(0)}',
//               Icons.lock_outline_rounded, const Color(0xFF4A148C), const Color(0xFFF3E5F5)),
//         ]),
//         const SizedBox(height: 12),
//         _statCardWide('Total Deposited', 'PKR ${deposit.toStringAsFixed(0)}',
//             Icons.savings_rounded, const Color(0xFF0D47A1), const Color(0xFFE3F2FD)),
//       ]),
//     );
//   }

//   Widget _statCard(String title, String value, IconData icon, Color color, Color bg) =>
//       Expanded(child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
//         child: Row(children: [
//           Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
//               child: Icon(icon, color: color, size: 22)),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
//             const SizedBox(height: 3),
//             Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
//                 maxLines: 1, overflow: TextOverflow.ellipsis),
//           ])),
//         ]),
//       ));

//   Widget _statCardWide(String title, String value, IconData icon, Color color, Color bg) =>
//       Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
//         child: Row(children: [
//           Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
//               child: Icon(icon, color: color, size: 22)),
//           const SizedBox(width: 12),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
//             const SizedBox(height: 3),
//             Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
//           ]),
//           const Spacer(),
//           // Wallet button embedded in the deposited card
//           GestureDetector(
//             onTap: () => Navigator.push(context, MaterialPageRoute(
//                 builder: (_) => DepositWithdrawPage(phoneUID: widget.phoneUID!))),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(colors: [_teal, _tealDark]),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
//               ),
//               child: Row(mainAxisSize: MainAxisSize.min, children: const [
//                 Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
//                 SizedBox(width: 6),
//                 Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
//               ]),
//             ),
//           ),
//         ]),
//       );

//   // ── Quick action row ──────────────────────────────────────
//   Widget _buildActionRow(Map<String, dynamic> data) {
//     final mergedDoc = {
//       ..._sellerData,
//       ...data,
//       'profileImage': (_userData['profileImage'] as String? ?? '').trim(),
//       'city':         (_userData['city']         as String? ?? '').trim(),
//       'firstName':    (_userData['firstName'] as String? ?? data['firstName'] as String? ?? '').trim(),
//       'lastName':     (_userData['lastName']  as String? ?? data['lastName']  as String? ?? '').trim(),
//       'bio':          _userData['bio'] ?? data['bio'] ?? '',
//       '_uid':         widget.phoneUID ?? '',
//     };

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//       child: Row(children: [
//         // See My Profile
//         Expanded(child: GestureDetector(
//           onTap: () => showModalBottomSheet(
//             context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
//             builder: (_) => SellerProfileSheet(
//               sellerId: widget.phoneUID ?? '',
//               preloadedSellerDoc: mergedDoc,
//               buyerUid: '',  // viewing own profile — no chat needed
//               buyerCity: (_userData['city'] as String? ?? '').trim(),
//             ),
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: _teal, width: 1.5),
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
//             ),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
//               Icon(Icons.person_outline_rounded, color: _teal, size: 18),
//               SizedBox(width: 7),
//               Text('My Profile', style: TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 13.5)),
//             ]),
//           ),
//         )),
//         const SizedBox(width: 12),
//         // Deposit / Withdraw
//         Expanded(child: GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) => DepositWithdrawPage(phoneUID: widget.phoneUID!))),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(colors: [_teal, _tealDark]),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [BoxShadow(color: _teal.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
//             ),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
//               Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
//               SizedBox(width: 7),
//               Text('Deposit / Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
//             ]),
//           ),
//         )),
//       ]),
//     );
//   }

//   // ── My Offers section ─────────────────────────────────────
//   Widget _buildOffersSection() {
//     if (widget.phoneUID == null) return const SizedBox();
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           const Text('My Offers', style: TextStyle(
//               fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
//           const Spacer(),
//           // total count badge via StreamBuilder
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('sellers')
//                 .doc(widget.phoneUID)
//                 .collection('offers')
//                 .snapshots(),
//             builder: (_, s) {
//               final count = s.data?.docs.length ?? 0;
//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: _teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//                 child: Text('$count total',
//                     style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w700)),
//               );
//             },
//           ),
//         ]),
//         const SizedBox(height: 14),
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('sellers')
//               .doc(widget.phoneUID)
//               .collection('offers')
//               .orderBy('createdAt', descending: true)
//               .snapshots(),
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Center(child: Padding(
//                 padding: EdgeInsets.all(24),
//                 child: CircularProgressIndicator(color: _teal, strokeWidth: 2)));
//             }
//             final docs = snap.data?.docs ?? [];
//             if (docs.isEmpty) return _emptyOffers();
//             return Column(children: docs.map((doc) => _OfferManageCard(
//               doc: doc,
//               sellerId: widget.phoneUID!,
//             )).toList());
//           },
//         ),
//       ]),
//     );
//   }

//   Widget _emptyOffers() => Container(
//     padding: const EdgeInsets.symmetric(vertical: 36),
//     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
//     child: Center(child: Column(children: [
//       Icon(Icons.storefront_outlined, size: 46, color: Colors.grey[300]),
//       const SizedBox(height: 10),
//       Text("You haven't posted any offers yet",
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[500])),
//       const SizedBox(height: 4),
//       Text('Create your first offer to start getting orders',
//           style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//     ])),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// //  OFFER MANAGE CARD  — edit title/price/delivery + cancel offer
// // ═══════════════════════════════════════════════════════════════
// class _OfferManageCard extends StatelessWidget {
//   final QueryDocumentSnapshot doc;
//   final String sellerId;

//   static const _teal     = Color(0xFF00695C);
//   static const _tealDark = Color(0xFF004D40);

//   const _OfferManageCard({required this.doc, required this.sellerId});

//   @override
//   Widget build(BuildContext context) {
//     final data     = doc.data() as Map<String, dynamic>;
//     final title    = (data['title']       as String? ?? 'Offer').trim();
//     final price    = (data['price']       as num?    ?? 0).toDouble();
//     final delivery = (data['deliveryTime'] as String? ?? '').trim();
//     final status   = (data['status']      as String? ?? 'active').trim();
//     final orders   = (data['ordersCount'] as int?    ?? 0);
//     final skills   = (data['skills'] is List) ? List<String>.from(data['skills'] as List) : <String>[];
//     final imageUrl = (data['imageUrl']    as String? ?? '').trim();

//     final isActive = status == 'active';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: isActive ? Border.all(color: _teal.withOpacity(0.2), width: 1) : null,
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//         // image thumbnail
//         if (imageUrl.isNotEmpty)
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const SizedBox()),
//           )
//         else
//           Container(
//             height: 54,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: [_teal.withOpacity(0.8), _tealDark],
//                   begin: Alignment.topLeft, end: Alignment.bottomRight),
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             child: Align(alignment: Alignment.centerLeft,
//               child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
//           ),

//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//             if (imageUrl.isNotEmpty) ...[
//               Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.black87)),
//               const SizedBox(height: 6),
//             ],

//             // stats row
//             Row(children: [
//               _badge('PKR ${price.toStringAsFixed(0)}', _teal, Colors.white),
//               const SizedBox(width: 8),
//               if (delivery.isNotEmpty) _badge(delivery, Colors.grey.shade100, Colors.grey.shade700),
//               const Spacer(),
//               _badge(isActive ? '● Active' : '● Inactive',
//                   isActive ? Colors.green.shade50 : Colors.grey.shade100,
//                   isActive ? Colors.green.shade700 : Colors.grey.shade500),
//             ]),

//             if (orders > 0) ...[
//               const SizedBox(height: 6),
//               Text('$orders order${orders > 1 ? 's' : ''} received',
//                   style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
//             ],

//             if (skills.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Row(children: skills.take(3).map((s) => Container(
//                 margin: const EdgeInsets.only(right: 6),
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: _teal.withOpacity(0.18)),
//                 ),
//                 child: Text(s, style: const TextStyle(fontSize: 10.5, color: _teal, fontWeight: FontWeight.w600)),
//               )).toList()),
//             ],

//             const SizedBox(height: 12),

//             // action buttons
//             Row(children: [
//               // Edit
//               Expanded(child: GestureDetector(
//                 onTap: () => _showEditSheet(context, data),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: _teal, width: 1.5),
//                   ),
//                   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
//                     Icon(Icons.edit_outlined, color: _teal, size: 15),
//                     SizedBox(width: 5),
//                     Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 13)),
//                   ]),
//                 ),
//               )),
//               const SizedBox(width: 10),
//               // Cancel / Delete
//               Expanded(child: GestureDetector(
//                 onTap: () => _confirmCancel(context),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.red.shade300, width: 1.5),
//                   ),
//                   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 15),
//                     const SizedBox(width: 5),
//                     Text('Remove', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700, fontSize: 13)),
//                   ]),
//                 ),
//               )),
//             ]),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _badge(String text, Color bg, Color fg) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//     decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
//     child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
//   );

//   void _showEditSheet(BuildContext context, Map<String, dynamic> data) {
//     final titleCtrl    = TextEditingController(text: data['title']        as String? ?? '');
//     final priceCtrl    = TextEditingController(text: (data['price'] ?? '').toString());
//     final deliveryCtrl = TextEditingController(text: data['deliveryTime'] as String? ?? '');
//     final descCtrl     = TextEditingController(text: data['description']  as String? ?? '');

//     showModalBottomSheet(
//       context: context, isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
//             const Text('Edit Offer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
//             const SizedBox(height: 20),
//             _field(titleCtrl, 'Title', Icons.title),
//             const SizedBox(height: 12),
//             _field(priceCtrl, 'Price (PKR)', Icons.payments_outlined, numeric: true),
//             const SizedBox(height: 12),
//             _field(deliveryCtrl, 'Delivery Time (e.g. 2 days)', Icons.schedule_outlined),
//             const SizedBox(height: 12),
//             _field(descCtrl, 'Description', Icons.description_outlined, maxLines: 3),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () async {
//                 final newPrice = double.tryParse(priceCtrl.text.trim()) ?? (data['price'] as num? ?? 0).toDouble();
//                 await FirebaseFirestore.instance
//                     .collection('sellers').doc(sellerId)
//                     .collection('offers').doc(doc.id)
//                     .update({
//                   'title':        titleCtrl.text.trim(),
//                   'price':        newPrice,
//                   'deliveryTime': deliveryCtrl.text.trim(),
//                   'description':  descCtrl.text.trim(),
//                 });
//                 if (ctx.mounted) Navigator.pop(ctx);
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(colors: [_teal, _tealDark]),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
//                 ),
//                 child: const Center(child: Text('Save Changes',
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget _field(TextEditingController ctrl, String hint, IconData icon,
//       {bool numeric = false, int maxLines = 1}) =>
//       Container(
//         decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200)),
//         child: TextField(
//           controller: ctrl,
//           keyboardType: numeric ? TextInputType.number : TextInputType.text,
//           maxLines: maxLines,
//           style: const TextStyle(fontSize: 14),
//           decoration: InputDecoration(
//             hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
//             prefixIcon: Icon(icon, color: _teal, size: 20),
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//           ),
//         ),
//       );

//   void _confirmCancel(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Remove Offer', style: TextStyle(fontWeight: FontWeight.w800)),
//         content: const Text('Are you sure you want to remove this offer? This cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx),
//               child: const Text('Keep', style: TextStyle(color: Colors.grey))),
//           TextButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance
//                   .collection('sellers').doc(sellerId)
//                   .collection('offers').doc(doc.id)
//                   .delete();
//               if (ctx.mounted) Navigator.pop(ctx);
//             },
//             child: Text('Remove', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700)),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deposit_withdraw_page.dart';


class SellerDashboardPage extends StatefulWidget {
  final String? phoneUID;
  const SellerDashboardPage({super.key, this.phoneUID});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  Map<String, dynamic> _userData    = {};
  Map<String, dynamic> _sellerData  = {};
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.phoneUID == null) return;
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(widget.phoneUID).get(),
        FirebaseFirestore.instance.collection('sellers').doc(widget.phoneUID).get(),
      ]);
      if (mounted) {
        setState(() {
          _userData   = results[0].data() ?? {};
          _sellerData = results[1].data() ?? {};
          _loadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sellers')
                  .doc(widget.phoneUID)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && _sellerData.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2));
                }
                final data = (snap.data?.data() as Map<String, dynamic>?) ?? _sellerData;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(data)),
                    SliverToBoxAdapter(child: _buildStatsGrid(data)),
                    SliverToBoxAdapter(child: _buildActionRow(data)),
                    SliverToBoxAdapter(child: _buildOffersSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
    );
  }

  // ── Header with profile image ──────────────────────────────
  Widget _buildHeader(Map<String, dynamic> data) {
    final firstName = (_userData['firstName'] ?? data['firstName'] ?? '') as String;
    final lastName  = (_userData['lastName']  ?? data['lastName']  ?? '') as String;
    final name      = '$firstName $lastName'.trim();
    final img       = (_userData['profileImage'] as String? ?? '').trim();
    final status    = (data['status'] as String? ?? 'pending');
    final city      = (_userData['city'] as String? ?? '').trim();
    final skills    = List<String>.from(data['skills'] ?? []);
    final rating    = (data['Rating'] ?? 0.0).toDouble();
    final jobs      = (data['Jobs_Completed'] ?? 0) as int;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'approved': statusColor = Colors.green; statusLabel = '✓ Approved'; break;
      case 'submitted': statusColor = Colors.orange; statusLabel = '⏳ Pending'; break;
      case 'rejected': statusColor = Colors.red; statusLabel = '✗ Rejected'; break;
      default: statusColor = Colors.grey; statusLabel = status.toUpperCase();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [_teal, _tealDark]),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x55004D40), blurRadius: 20, offset: Offset(0, 8))]),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // top bar
          Row(children: [
            const Text('My Dashboard',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.5))),
              child: Text(statusLabel,
                  style: TextStyle(color: statusColor == Colors.green ? Colors.greenAccent : statusColor,
                      fontSize: 11.5, fontWeight: FontWeight.w700)),
            ),
          ]),

          const SizedBox(height: 20),

          // Profile row
          Row(children: [
            // Avatar with border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
              child: CircleAvatar(
                radius: 38, backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30))
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.isNotEmpty ? name : 'Seller',
                  style: const TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w900, letterSpacing: -0.3)),
              if (city.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.white60),
                  const SizedBox(width: 3),
                  Text(city, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.star_rounded, size: 14, color: Colors.amber[300]),
                const SizedBox(width: 3),
                Text(rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                Text('  ·  $jobs jobs done',
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(skills.take(3).join(' · '),
                    style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ])),
          ]),
        ]),
      )),
    );
  }

  // ── Stats grid ────────────────────────────────────────────
  Widget _buildStatsGrid(Map<String, dynamic> data) {
    final balance  = (data['Available_Balance'] ?? 0).toDouble();
    final earning  = (data['Earning']           ?? 0).toDouble();
    final pending  = (data['Pending_Jobs']      ?? 0) as int;
    final total    = (data['Total_Jobs']        ?? 0) as int;
    final reserved = (data['Reserved_Commission'] ?? 0).toDouble();
    final deposit  = (data['Deposit']           ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 14),
        Row(children: [
          _statCard('Net Earnings', 'PKR ${earning.toStringAsFixed(0)}',
              Icons.payments_rounded, const Color(0xFF1B5E20), const Color(0xFFE8F5E9)),
          const SizedBox(width: 12),
          _statCard('Available', 'PKR ${balance.toStringAsFixed(0)}',
              Icons.account_balance_wallet_rounded, _teal, const Color(0xFFE0F2F1)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _statCard('Active Jobs', '$pending / $total',
              Icons.pending_actions_rounded, const Color(0xFFE65100), const Color(0xFFFFF3E0)),
          const SizedBox(width: 12),
          _statCard('Reserved', 'PKR ${reserved.toStringAsFixed(0)}',
              Icons.lock_outline_rounded, const Color(0xFF4A148C), const Color(0xFFF3E5F5)),
        ]),
        const SizedBox(height: 12),
        _statCardWide('Total Deposited', 'PKR ${deposit.toStringAsFixed(0)}',
            Icons.savings_rounded, const Color(0xFF0D47A1), const Color(0xFFE3F2FD)),
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, Color bg) =>
      Expanded(child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ));

  Widget _statCardWide(String title, String value, IconData icon, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
          ]),
          const Spacer(),
          // Wallet button embedded in the deposited card
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => DepositWithdrawPage(phoneUID: widget.phoneUID!))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_teal, _tealDark]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
              ]),
            ),
          ),
        ]),
      );

  // ── Quick action row ──────────────────────────────────────
  Widget _buildActionRow(Map<String, dynamic> data) {
    final mergedDoc = {
      ..._sellerData,
      ...data,
      'profileImage': (_userData['profileImage'] as String? ?? '').trim(),
      'city':         (_userData['city']         as String? ?? '').trim(),
      'firstName':    (_userData['firstName'] as String? ?? data['firstName'] as String? ?? '').trim(),
      'lastName':     (_userData['lastName']  as String? ?? data['lastName']  as String? ?? '').trim(),
      'bio':          _userData['bio'] ?? data['bio'] ?? '',
      '_uid':         widget.phoneUID ?? '',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(children: [
        // See My Profile
        Expanded(child: GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => _SellerOwnProfileSheet(sellerData: mergedDoc),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _teal, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.person_outline_rounded, color: _teal, size: 18),
              SizedBox(width: 7),
              Text('My Profile', style: TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 13.5)),
            ]),
          ),
        )),
        const SizedBox(width: 12),
        // Deposit / Withdraw
        Expanded(child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => DepositWithdrawPage(phoneUID: widget.phoneUID!))),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_teal, _tealDark]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _teal.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
              SizedBox(width: 7),
              Text('Deposit / Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
            ]),
          ),
        )),
      ]),
    );
  }

  // ── My Offers section ─────────────────────────────────────
  Widget _buildOffersSection() {
    if (widget.phoneUID == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('My Offers', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
          const Spacer(),
          // total count badge via StreamBuilder
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sellers')
                .doc(widget.phoneUID)
                .collection('offers')
                .snapshots(),
            builder: (_, s) {
              final count = s.data?.docs.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('$count total',
                    style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w700)),
              );
            },
          ),
        ]),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sellers')
              .doc(widget.phoneUID)
              .collection('offers')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _teal, strokeWidth: 2)));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return _emptyOffers();
            return Column(children: docs.map((doc) => _OfferManageCard(
              doc: doc,
              sellerId: widget.phoneUID!,
            )).toList());
          },
        ),
      ]),
    );
  }

  Widget _emptyOffers() => Container(
    padding: const EdgeInsets.symmetric(vertical: 36),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
    child: Center(child: Column(children: [
      Icon(Icons.storefront_outlined, size: 46, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text("You haven't posted any offers yet",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[500])),
      const SizedBox(height: 4),
      Text('Create your first offer to start getting orders',
          style: TextStyle(fontSize: 12, color: Colors.grey[400])),
    ])),
  );
}

// ═══════════════════════════════════════════════════════════════
//  OFFER MANAGE CARD  — edit title/price/delivery + cancel offer
// ═══════════════════════════════════════════════════════════════
class _OfferManageCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String sellerId;

  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  const _OfferManageCard({required this.doc, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final data     = doc.data() as Map<String, dynamic>;
    final title    = (data['title']       as String? ?? 'Offer').trim();
    final price    = (data['price']       as num?    ?? 0).toDouble();
    final delivery = (data['deliveryTime'] as String? ?? '').trim();
    final status   = (data['status']      as String? ?? 'active').trim();
    final orders   = (data['ordersCount'] as int?    ?? 0);
    final skills   = (data['skills'] is List) ? List<String>.from(data['skills'] as List) : <String>[];
    final imageUrl = (data['imageUrl']    as String? ?? '').trim();

    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: _teal.withOpacity(0.2), width: 1) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // image thumbnail
        if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox()),
          )
        else
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_teal.withOpacity(0.8), _tealDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(alignment: Alignment.centerLeft,
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
          ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if (imageUrl.isNotEmpty) ...[
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 6),
            ],

            // stats row
            Row(children: [
              _badge('PKR ${price.toStringAsFixed(0)}', _teal, Colors.white),
              const SizedBox(width: 8),
              if (delivery.isNotEmpty) _badge(delivery, Colors.grey.shade100, Colors.grey.shade700),
              const Spacer(),
              _badge(isActive ? '● Active' : '● Inactive',
                  isActive ? Colors.green.shade50 : Colors.grey.shade100,
                  isActive ? Colors.green.shade700 : Colors.grey.shade500),
            ]),

            if (orders > 0) ...[
              const SizedBox(height: 6),
              Text('$orders order${orders > 1 ? 's' : ''} received',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
            ],

            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: skills.take(3).map((s) => Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.07), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _teal.withOpacity(0.18)),
                ),
                child: Text(s, style: const TextStyle(fontSize: 10.5, color: _teal, fontWeight: FontWeight.w600)),
              )).toList()),
            ],

            const SizedBox(height: 12),

            // action buttons
            Row(children: [
              // Edit
              Expanded(child: GestureDetector(
                onTap: () => _showEditSheet(context, data),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _teal, width: 1.5),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.edit_outlined, color: _teal, size: 15),
                    SizedBox(width: 5),
                    Text('Edit', style: TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                ),
              )),
              const SizedBox(width: 10),
              // Cancel / Delete
              Expanded(child: GestureDetector(
                onTap: () => _confirmCancel(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300, width: 1.5),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 15),
                    const SizedBox(width: 5),
                    Text('Remove', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                ),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
  );

  void _showEditSheet(BuildContext context, Map<String, dynamic> data) {
    final titleCtrl    = TextEditingController(text: data['title']        as String? ?? '');
    final priceCtrl    = TextEditingController(text: (data['price'] ?? '').toString());
    final deliveryCtrl = TextEditingController(text: data['deliveryTime'] as String? ?? '');
    final descCtrl     = TextEditingController(text: data['description']  as String? ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Text('Edit Offer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _field(titleCtrl, 'Title', Icons.title),
            const SizedBox(height: 12),
            _field(priceCtrl, 'Price (PKR)', Icons.payments_outlined, numeric: true),
            const SizedBox(height: 12),
            _field(deliveryCtrl, 'Delivery Time (e.g. 2 days)', Icons.schedule_outlined),
            const SizedBox(height: 12),
            _field(descCtrl, 'Description', Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final newPrice = double.tryParse(priceCtrl.text.trim()) ?? (data['price'] as num? ?? 0).toDouble();
                await FirebaseFirestore.instance
                    .collection('sellers').doc(sellerId)
                    .collection('offers').doc(doc.id)
                    .update({
                  'title':        titleCtrl.text.trim(),
                  'price':        newPrice,
                  'deliveryTime': deliveryCtrl.text.trim(),
                  'description':  descCtrl.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_teal, _tealDark]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('Save Changes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool numeric = false, int maxLines = 1}) =>
      Container(
        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
        child: TextField(
          controller: ctrl,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: _teal, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      );

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Offer', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to remove this offer? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('sellers').doc(sellerId)
                  .collection('offers').doc(doc.id)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('Remove', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SELLER OWN PROFILE SHEET
//  Same as SellerProfileSheet but without Hire Now / Message buttons
//  — because a seller is viewing their own profile.
// ═══════════════════════════════════════════════════════════════
class _SellerOwnProfileSheet extends StatefulWidget {
  final Map<String, dynamic> sellerData;
  const _SellerOwnProfileSheet({required this.sellerData});
  @override
  State<_SellerOwnProfileSheet> createState() => _SellerOwnProfileSheetState();
}

class _SellerOwnProfileSheetState extends State<_SellerOwnProfileSheet> {
  static const _teal = Color(0xFF00695C);

  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final uid = (widget.sellerData['_uid'] as String? ?? '').trim();
    if (uid.isEmpty) { setState(() => _loadingReviews = false); return; }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sellers').doc(uid)
          .collection('ratings').limit(20).get();
      final reviews = snap.docs.map((d) => d.data()).toList();
      reviews.sort((a, b) {
        final at = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bt = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bt.compareTo(at);
      });
      if (mounted) setState(() { _reviews = reviews; _loadingReviews = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d      = widget.sellerData;
    final name   = '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
    final img    = (d['profileImage'] as String? ?? '').trim();
    final city   = (d['city']         as String? ?? '').trim();
    final rating = (d['Rating']        ?? 0.0).toDouble();
    final jobs   = (d['Jobs_Completed'] ?? 0) as int;
    final skills = List<String>.from(d['skills'] ?? []);
    final bio    = (d['bio'] as String? ?? '').trim();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        // drag handle
        Container(width: 44, height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [

            // avatar
            Center(child: Stack(alignment: Alignment.bottomRight, children: [
              CircleAvatar(radius: 50, backgroundColor: _teal.withOpacity(0.1),
                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                child: img.isEmpty
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 38))
                    : null),
              Container(width: 26, height: 26,
                decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2)]),
                child: const Icon(Icons.build_rounded, size: 14, color: Colors.white)),
            ])),
            const SizedBox(height: 12),

            Center(child: Text(name.isEmpty ? 'My Profile' : name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
              textAlign: TextAlign.center)),

            if (city.isNotEmpty) ...[
              const SizedBox(height: 5),
              Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 3),
                Text(city, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ])),
            ],

            const SizedBox(height: 18),

            // stats bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.05), borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _teal.withOpacity(0.12))),
              child: Row(children: [
                _stat('⭐', rating.toStringAsFixed(1), 'Rating'),
                _vDiv(),
                _stat('✅', '$jobs', 'Jobs Done'),
                _vDiv(),
                _stat('💬', '${_reviews.length}', 'Reviews'),
              ]),
            ),

            const SizedBox(height: 20),

            // bio
            if (bio.isNotEmpty) ...[
              _sec('About'),
              const SizedBox(height: 8),
              Text(bio, style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 20),
            ],

            // skills
            if (skills.isNotEmpty) ...[
              _sec('Skills & Services'),
              const SizedBox(height: 10),
              Wrap(spacing: 7, runSpacing: 7, children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _teal.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _teal.withOpacity(0.2))),
                child: Text(s, style: const TextStyle(fontSize: 12.5, color: _teal, fontWeight: FontWeight.w600)),
              )).toList()),
              const SizedBox(height: 20),
            ],

            // reviews
            _sec('Buyer Reviews (${_reviews.length})'),
            const SizedBox(height: 10),
            if (_loadingReviews)
              const Center(child: Padding(padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: _teal, strokeWidth: 2)))
            else if (_reviews.isEmpty)
              _noReviews()
            else
              ..._reviews.map((r) => _ReviewCard(r)),
            // no buttons at the bottom — this is the seller's own profile view
          ],
        )),
      ]),
    );
  }

  Widget _noReviews() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200)),
    child: Center(child: Column(children: [
      Icon(Icons.reviews_outlined, size: 38, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text('No reviews yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[500])),
      const SizedBox(height: 4),
      Text('Complete jobs to earn your first review!',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]), textAlign: TextAlign.center),
    ])),
  );

  Widget _stat(String e, String v, String l) => Expanded(child: Column(children: [
    Text(e, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
  ]));

  Widget _vDiv() => Container(width: 1, height: 40, color: Colors.grey.shade200);
  Widget _sec(String t) => Text(t,
      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.black87));
}

// ── Review Card (shared) ──────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> r;
  const _ReviewCard(this.r);

  @override
  Widget build(BuildContext context) {
    final name     = r['buyerName']  as String? ?? 'Client';
    final comment  = r['comment']    as String? ?? '';
    final stars    = (r['stars']     ?? 5) as int;
    final jobTitle = r['jobTitle']   as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade100,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
            if (jobTitle.isNotEmpty) Text(jobTitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 14, color: Colors.amber[600]))),
        ]),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(comment, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
        ],
      ]),
    );
  }
}