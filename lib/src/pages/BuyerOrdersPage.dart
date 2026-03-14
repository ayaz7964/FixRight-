// // import 'package:flutter/material.dart';
// // import 'order_detail_page.dart';

// // class OrdersPage extends StatefulWidget {
// //   final String? phoneUID;

// //   const OrdersPage({super.key, this.phoneUID});

// //   @override
// //   State<OrdersPage> createState() => _OrdersPageState();
// // }

// // class _OrdersPageState extends State<OrdersPage> {
// //   String _selectedFilter = 'All';
// //   String _searchQuery = '';

// //   // Dummy orders (backend-ready format)
// //   final List<Map<String, dynamic>> _orders = [
// //     {
// //       'id': 'ORD1001',
// //       'title': 'Home AC Repair',
// //       'status': 'Completed',
// //       'price': 40,
// //       'client': 'Ali Khan',
// //       'date': 'Oct 10, 2025',
// //       'image': 'https://i.imgur.com/8Km9tLL.png',
// //       'description':
// //           'Technician repaired the AC unit and refilled the gas. Cooling is now working perfectly.',
// //     },
// //     {
// //       'id': 'ORD1002',
// //       'title': 'Plumbing Fix',
// //       'status': 'Pending',
// //       'price': 25,
// //       'client': 'Sara Malik',
// //       'date': 'Oct 22, 2025',
// //       'image': 'https://i.imgur.com/QCNbOAo.png',
// //       'description':
// //           'The client reported water leakage in the kitchen. The plumber will visit tomorrow morning.',
// //     },
// //     {
// //       'id': 'ORD1003',
// //       'title': 'Car Wash Service',
// //       'status': 'In Progress',
// //       'price': 15,
// //       'client': 'Hassan Ahmed',
// //       'date': 'Oct 23, 2025',
// //       'image': 'https://i.imgur.com/x3M7QyJ.png',
// //       'description':
// //           'Car wash is currently being handled at the service center. Estimated completion in 30 minutes.',
// //     },
// //     {
// //       'id': 'ORD1004',
// //       'title': 'Electric Wiring',
// //       'status': 'Completed',
// //       'price': 60,
// //       'client': 'Fatima Noor',
// //       'date': 'Oct 20, 2025',
// //       'image': 'https://i.imgur.com/Yy6zO7R.png',
// //       'description':
// //           'New electrical wiring completed successfully with safety inspection and testing.',
// //     },
// //     {
// //       'id': 'ORD1005',
// //       'title': 'Painting Service',
// //       'status': 'Cancelled',
// //       'price': 35,
// //       'client': 'Usman Tariq',
// //       'date': 'Oct 12, 2025',
// //       'image': 'https://i.imgur.com/zYxDCQT.png',
// //       'description':
// //           'Client cancelled due to schedule conflict. Partial payment refunded.',
// //     },
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     final filteredOrders = _orders.where((order) {
// //       final matchesFilter =
// //           _selectedFilter == 'All' || order['status'] == _selectedFilter;
// //       final matchesSearch =
// //           order['title'].toString().toLowerCase().contains(
// //             _searchQuery.toLowerCase(),
// //           ) ||
// //           order['client'].toString().toLowerCase().contains(
// //             _searchQuery.toLowerCase(),
// //           );
// //       return matchesFilter && matchesSearch;
// //     }).toList();

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F8F8),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 1,
// //         title: const Text(
// //           'AH Manage Orders',
// //           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
// //         ),
// //         actions: [
// //           Padding(
// //             padding: const EdgeInsets.only(right: 12),
// //             child: DropdownButtonHideUnderline(
// //               child: DropdownButton<String>(
// //                 value: _selectedFilter,
// //                 icon: const Icon(Icons.filter_list, color: Colors.black),
// //                 dropdownColor: Colors.white,
// //                 items: const [
// //                   DropdownMenuItem(value: 'All', child: Text('All Orders')),
// //                   DropdownMenuItem(
// //                     value: 'Completed',
// //                     child: Text('Completed'),
// //                   ),
// //                   DropdownMenuItem(value: 'Pending', child: Text('Pending')),
// //                   DropdownMenuItem(
// //                     value: 'In Progress',
// //                     child: Text('In Progress'),
// //                   ),
// //                   DropdownMenuItem(
// //                     value: 'Cancelled',
// //                     child: Text('Cancelled'),
// //                   ),
// //                 ],
// //                 onChanged: (value) {
// //                   setState(() => _selectedFilter = value!);
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Search bar
// //           Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: TextField(
// //               decoration: InputDecoration(
// //                 hintText: 'Search orders by service or client...',
// //                 prefixIcon: const Icon(Icons.search),
// //                 filled: true,
// //                 fillColor: Colors.white,
// //                 contentPadding: const EdgeInsets.symmetric(
// //                   vertical: 0,
// //                   horizontal: 16,
// //                 ),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(30),
// //                   borderSide: BorderSide.none,
// //                 ),
// //               ),
// //               onChanged: (value) {
// //                 setState(() => _searchQuery = value);
// //               },
// //             ),
// //           ),

// //           // Orders list
// //           Expanded(
// //             child: filteredOrders.isEmpty
// //                 ? const Center(child: Text('No orders found'))
// //                 : ListView.builder(
// //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// //                     itemCount: filteredOrders.length,
// //                     itemBuilder: (context, index) {
// //                       final order = filteredOrders[index];
// //                       return GestureDetector(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => OrderDetailPage(order: order),
// //                             ),
// //                           );
// //                         },
// //                         child: Container(
// //                           margin: const EdgeInsets.only(bottom: 12),
// //                           padding: const EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(12),
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.grey.withOpacity(0.1),
// //                                 blurRadius: 6,
// //                                 offset: const Offset(0, 3),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               ClipRRect(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 child: Image.network(
// //                                   order['image'],
// //                                   height: 60,
// //                                   width: 80,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 10),
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       order['title'],
// //                                       style: const TextStyle(
// //                                         fontSize: 16,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: Colors.black,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     Text(
// //                                       "Client: ${order['client']}",
// //                                       style: const TextStyle(
// //                                         fontSize: 13,
// //                                         color: Colors.black54,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     Text(
// //                                       order['date'],
// //                                       style: const TextStyle(
// //                                         fontSize: 12,
// //                                         color: Colors.black45,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.end,
// //                                 children: [
// //                                   Text(
// //                                     "\$${order['price']}",
// //                                     style: const TextStyle(
// //                                       fontSize: 15,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.green,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 4),
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 8,
// //                                       vertical: 3,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: _statusColor(
// //                                         order['status'],
// //                                       ).withOpacity(0.1),
// //                                       borderRadius: BorderRadius.circular(20),
// //                                     ),
// //                                     child: Text(
// //                                       order['status'],
// //                                       style: TextStyle(
// //                                         color: _statusColor(order['status']),
// //                                         fontWeight: FontWeight.w600,
// //                                         fontSize: 12,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Color _statusColor(String status) {
// //     switch (status) {
// //       case 'Completed':
// //         return Colors.green;
// //       case 'Pending':
// //         return Colors.orange;
// //       case 'In Progress':
// //         return Colors.blue;
// //       case 'Cancelled':
// //         return Colors.red;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// // }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';

// class BuyerOrdersPage extends StatefulWidget {
//   final String? phoneUID;
//   const BuyerOrdersPage({super.key, this.phoneUID});

//   @override
//   State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
// }

// class _BuyerOrdersPageState extends State<BuyerOrdersPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String get _uid => widget.phoneUID ?? UserSession().phoneUID ?? '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: const Text('My Jobs', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.teal,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.teal,
//           tabs: const [
//             Tab(text: 'Open'),
//             Tab(text: 'In Progress'),
//             Tab(text: 'Completed'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _JobsList(uid: _uid, status: 'open'),
//           _JobsList(uid: _uid, status: 'in_progress'),
//           _JobsList(uid: _uid, status: 'completed'),
//         ],
//       ),
//     );
//   }
// }

// class _JobsList extends StatelessWidget {
//   final String uid;
//   final String status;
//   const _JobsList({required this.uid, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('jobs')
//           .where('postedBy', isEqualTo: uid)
//           .where('status', isEqualTo: status)
//           .orderBy('postedAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.teal));
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return _EmptyState(status: status);
//         }

//         final jobs = snapshot.data!.docs;
//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: jobs.length,
//           itemBuilder: (context, i) {
//             final data = jobs[i].data() as Map<String, dynamic>;
//             return _JobCard(
//               jobData: data,
//               jobId: jobs[i].id,
//               buyerUid: uid,
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _JobCard extends StatelessWidget {
//   final Map<String, dynamic> jobData;
//   final String jobId;
//   final String buyerUid;

//   const _JobCard({
//     required this.jobData,
//     required this.jobId,
//     required this.buyerUid,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final title = jobData['title'] ?? 'Untitled Job';
//     final budget = jobData['budget'] ?? 0;
//     final location = jobData['location'] ?? 'No location';
//     final timing = jobData['timing'] ?? '';
//     final status = jobData['status'] ?? 'open';
//     final bidsCount = jobData['bidsCount'] ?? 0;
//     final skills = List<String>.from(jobData['skills'] ?? []);
//     final postedAt = jobData['postedAt'] as Timestamp?;
//     final dateStr = postedAt != null
//         ? DateFormat('dd MMM yyyy').format(postedAt.toDate())
//         : 'Just now';

//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid),
//         ),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade50,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 location,
//                                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'PKR ${budget.toStringAsFixed(0)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
//                       ),
//                       _StatusBadge(status: status),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Body
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 6),
//                       Text(timing, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//                       const Spacer(),
//                       Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 4),
//                       Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Skills
//                   Wrap(
//                     spacing: 6, runSpacing: 4,
//                     children: skills.take(4).map((s) => Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: Colors.teal.shade50,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.teal.shade200),
//                           ),
//                           child: Text(s, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
//                         )).toList(),
//                   ),
//                   const SizedBox(height: 12),

//                   // Bid count + action
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: bidsCount > 0 ? Colors.orange.shade50 : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: bidsCount > 0 ? Colors.orange.shade300 : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.gavel, size: 14, color: bidsCount > 0 ? Colors.orange : Colors.grey),
//                             const SizedBox(width: 6),
//                             Text(
//                               '$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: bidsCount > 0 ? Colors.orange : Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Spacer(),
//                       if (status == 'open')
//                         ElevatedButton.icon(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid),
//                             ),
//                           ),
//                           icon: const Icon(Icons.visibility, size: 16),
//                           label: const Text('View Bids'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Job Detail + Bids Page ─────────────────────────────────────
// class _JobDetailPage extends StatelessWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String buyerUid;

//   const _JobDetailPage({
//     required this.jobId,
//     required this.jobData,
//     required this.buyerUid,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final status = jobData['status'] ?? 'open';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         title: Text(jobData['title'] ?? 'Job Detail'),
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Job Summary Card
//             _JobSummaryCard(jobData: jobData),
//             const SizedBox(height: 20),

//             // Bids Section
//             if (status == 'open') ...[
//               const Text('Bids Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               _BidsList(jobId: jobId, buyerUid: buyerUid, jobData: jobData),
//             ] else if (status == 'in_progress') ...[
//               const Text('Accepted Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               _AcceptedSellerCard(jobId: jobId, acceptedBidder: jobData['acceptedBidder']),
//             ],

//             // Cancel Job Button (only if open)
//             if (status == 'open') ...[
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _confirmCancel(context),
//                   icon: const Icon(Icons.cancel_outlined, color: Colors.red),
//                   label: const Text('Cancel Job', style: TextStyle(color: Colors.red)),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.red),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   void _confirmCancel(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Cancel Job?'),
//         content: const Text('This will remove the job and all associated bids.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({'status': 'cancelled'});
//               Navigator.pop(context);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Job cancelled'), backgroundColor: Colors.red),
//               );
//             },
//             child: const Text('Yes, Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _JobSummaryCard extends StatelessWidget {
//   final Map<String, dynamic> jobData;
//   const _JobSummaryCard({required this.jobData});

//   @override
//   Widget build(BuildContext context) {
//     final skills = List<String>.from(jobData['skills'] ?? []);
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(jobData['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 Text(
//                   'PKR ${(jobData['budget'] ?? 0).toStringAsFixed(0)}',
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if ((jobData['description'] ?? '').isNotEmpty)
//               Text(jobData['description'], style: TextStyle(color: Colors.grey[600], fontSize: 14)),
//             const SizedBox(height: 12),
//             _infoRow(Icons.location_on, jobData['location'] ?? 'No location'),
//             const SizedBox(height: 6),
//             _infoRow(Icons.schedule, jobData['timing'] ?? ''),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 6, runSpacing: 4,
//               children: skills.map((s) => Chip(
//                     label: Text(s, style: const TextStyle(fontSize: 11)),
//                     backgroundColor: Colors.teal.shade50,
//                     side: BorderSide(color: Colors.teal.shade200),
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                   )).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: Colors.grey[500]),
//         const SizedBox(width: 6),
//         Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
//       ],
//     );
//   }
// }

// class _BidsList extends StatelessWidget {
//   final String jobId;
//   final String buyerUid;
//   final Map<String, dynamic> jobData;

//   const _BidsList({required this.jobId, required this.buyerUid, required this.jobData});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('jobs')
//           .doc(jobId)
//           .collection('bids')
//           .orderBy('createdAt', descending: false)
//           .snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.teal));
//         }
//         if (!snap.hasData || snap.data!.docs.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.gavel, size: 40, color: Colors.grey),
//                   SizedBox(height: 8),
//                   Text('No bids yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
//                   Text('Sellers will bid on your job shortly', style: TextStyle(color: Colors.grey, fontSize: 12)),
//                 ],
//               ),
//             ),
//           );
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: snap.data!.docs.length,
//           itemBuilder: (ctx, i) {
//             final bid = snap.data!.docs[i].data() as Map<String, dynamic>;
//             return _BidCard(
//               bid: bid,
//               jobId: jobId,
//               buyerUid: buyerUid,
//               jobData: jobData,
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _BidCard extends StatefulWidget {
//   final Map<String, dynamic> bid;
//   final String jobId;
//   final String buyerUid;
//   final Map<String, dynamic> jobData;

//   const _BidCard({required this.bid, required this.jobId, required this.buyerUid, required this.jobData});

//   @override
//   State<_BidCard> createState() => _BidCardState();
// }

// class _BidCardState extends State<_BidCard> {
//   bool _isAccepting = false;

//   Future<void> _acceptBid() async {
//     setState(() => _isAccepting = true);

//     try {
//       final db = FirebaseFirestore.instance;
//       final sellerId = widget.bid['sellerId'] as String;
//       final sellerName = widget.bid['sellerName'] as String? ?? '';
//       final sellerImage = widget.bid['sellerImage'] as String? ?? '';
//       final proposedAmount = widget.bid['proposedAmount'] ?? 0;

//       final batch = db.batch();

//       // 1. Update job status
//       final jobRef = db.collection('jobs').doc(widget.jobId);
//       batch.update(jobRef, {
//         'status': 'in_progress',
//         'acceptedBidder': sellerId,
//         'acceptedAmount': proposedAmount,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       // 2. Mark this bid accepted
//       final bidRef = jobRef.collection('bids').doc(sellerId);
//       batch.update(bidRef, {'status': 'accepted'});

//       // 3. Reject other bids
//       final otherBids = await jobRef.collection('bids')
//           .where('sellerId', isNotEqualTo: sellerId)
//           .get();
//       for (final d in otherBids.docs) {
//         batch.update(d.reference, {'status': 'rejected'});
//       }

//       // 4. Update seller's Pending_Jobs
//       final sellerRef = db.collection('sellers').doc(sellerId);
//       batch.update(sellerRef, {'Pending_Jobs': FieldValue.increment(1)});

//       await batch.commit();

//       // 5. Create conversation between buyer and seller
//       await _createConversation(sellerId, sellerName, sellerImage);

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('✅ Bid accepted! $sellerName will start the job.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       _showSnack('Error: $e', Colors.red);
//     } finally {
//       if (mounted) setState(() => _isAccepting = false);
//     }
//   }

//   Future<void> _createConversation(String sellerId, String sellerName, String sellerImage) async {
//     final db = FirebaseFirestore.instance;
//     final phones = [widget.buyerUid, sellerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';

//     final convDoc = await db.collection('conversations').doc(convId).get();
//     if (convDoc.exists) return;

//     final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
//     final buyerData = buyerDoc.data() ?? {};
//     final buyerName = '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'.trim();
//     final buyerImage = buyerData['profileImage'] ?? '';

//     await db.collection('conversations').doc(convId).set({
//       'participantIds': [widget.buyerUid, sellerId],
//       'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName},
//       'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'},
//       'participantProfileImages': {widget.buyerUid: buyerImage, sellerId: sellerImage},
//       'lastMessage': 'Job accepted! Let\'s get started.',
//       'lastMessageAt': Timestamp.now(),
//       'createdAt': Timestamp.now(),
//       'unreadCounts': {widget.buyerUid: 0, sellerId: 1},
//       'relatedJobId': widget.jobId,
//       'relatedJobTitle': widget.jobData['title'] ?? '',
//     });
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sellerName = widget.bid['sellerName'] ?? 'Unknown Seller';
//     final sellerImage = widget.bid['sellerImage'] as String?;
//     final proposedAmount = widget.bid['proposedAmount'] ?? 0;
//     final proposal = widget.bid['proposal'] ?? '';
//     final rating = (widget.bid['rating'] ?? 0.0).toDouble();
//     final skills = List<String>.from(widget.bid['skills'] ?? []);
//     final bidStatus = widget.bid['status'] ?? 'pending';
//     final createdAt = widget.bid['createdAt'] as Timestamp?;

//     final isAccepted = bidStatus == 'accepted';
//     final isRejected = bidStatus == 'rejected';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isAccepted ? Colors.green.shade300 : isRejected ? Colors.red.shade100 : Colors.grey.shade200,
//           width: isAccepted ? 2 : 1,
//         ),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.teal.shade100,
//                   backgroundImage: sellerImage != null && sellerImage.isNotEmpty
//                       ? NetworkImage(sellerImage)
//                       : null,
//                   child: sellerImage == null || sellerImage.isEmpty
//                       ? Text(sellerName[0].toUpperCase(),
//                           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                       if (rating > 0)
//                         Row(
//                           children: [
//                             Icon(Icons.star, size: 12, color: Colors.amber[600]),
//                             const SizedBox(width: 3),
//                             Text('$rating', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'PKR ${proposedAmount.toStringAsFixed(0)}',
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
//                     ),
//                     if (createdAt != null)
//                       Text(
//                         DateFormat('dd MMM, hh:mm a').format(createdAt.toDate()),
//                         style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//                       ),
//                   ],
//                 ),
//               ],
//             ),

//             if (proposal.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(proposal, style: const TextStyle(fontSize: 13)),
//               ),
//             ],

//             if (skills.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 6, runSpacing: 4,
//                 children: skills.take(3).map((s) => Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.teal.shade200),
//                       ),
//                       child: Text(s, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
//                     )).toList(),
//               ),
//             ],

//             const SizedBox(height: 12),

//             if (isAccepted)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
//                     const SizedBox(width: 8),
//                     Text('Bid Accepted', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               )
//             else if (!isRejected)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _isAccepting ? null : _acceptBid,
//                   icon: _isAccepting
//                       ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                       : const Icon(Icons.check_circle_outline, size: 18),
//                   label: Text(_isAccepting ? 'Accepting...' : 'Accept This Bid'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AcceptedSellerCard extends StatelessWidget {
//   final String jobId;
//   final String? acceptedBidder;
//   const _AcceptedSellerCard({required this.jobId, this.acceptedBidder});

//   @override
//   Widget build(BuildContext context) {
//     if (acceptedBidder == null) return const SizedBox();

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('sellers').doc(acceptedBidder).get(),
//       builder: (context, snap) {
//         if (!snap.hasData) return const Center(child: CircularProgressIndicator());
//         final data = snap.data?.data() as Map<String, dynamic>? ?? {};
//         final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
//         final image = data['cnicFrontUrl'] ?? '';
//         final rating = (data['Rating'] ?? 0).toDouble();

//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.teal.shade100,
//                   child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal)),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                       Row(
//                         children: [
//                           Icon(Icons.star, size: 14, color: Colors.amber[600]),
//                           const SizedBox(width: 4),
//                           Text('$rating', style: TextStyle(color: Colors.grey[600])),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text('In Progress', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     String label;
//     switch (status) {
//       case 'open': color = Colors.orange; label = 'Open'; break;
//       case 'in_progress': color = Colors.blue; label = 'In Progress'; break;
//       case 'completed': color = Colors.green; label = 'Completed'; break;
//       case 'cancelled': color = Colors.red; label = 'Cancelled'; break;
//       default: color = Colors.grey; label = status;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final String status;
//   const _EmptyState({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.work_off_outlined, size: 60, color: Colors.grey[400]),
//           const SizedBox(height: 12),
//           Text('No $status jobs', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
//           const SizedBox(height: 6),
//           Text('Post a job to get competitive bids', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//         ],
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';

class BuyerOrdersPage extends StatefulWidget {
  final String? phoneUID;
  const BuyerOrdersPage({super.key, this.phoneUID});

  @override
  State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
}

class _BuyerOrdersPageState extends State<BuyerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get _uid =>
      widget.phoneUID ?? UserSession().phoneUID ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('My Jobs',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _JobsList(uid: _uid, status: 'open'),
          _JobsList(uid: _uid, status: 'in_progress'),
          _JobsList(uid: _uid, status: 'completed'),
        ],
      ),
    );
  }
}

// ── Jobs list — sorted in Dart (no composite index needed) ────
class _JobsList extends StatelessWidget {
  final String uid;
  final String status;
  const _JobsList({required this.uid, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // ✅ Only two where clauses — no composite index required
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('postedBy', isEqualTo: uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.teal));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyState(status: status);
        }

        // ✅ Sort in Dart — no index needed
        final jobs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aT = (a.data()
                as Map)['postedAt'] as Timestamp?;
            final bT = (b.data()
                as Map)['postedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jobs.length,
          itemBuilder: (context, i) {
            final data =
                jobs[i].data() as Map<String, dynamic>;
            return _JobCard(
              jobData: data,
              jobId: jobs[i].id,
              buyerUid: uid,
            );
          },
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  final String buyerUid;

  const _JobCard({
    required this.jobData,
    required this.jobId,
    required this.buyerUid,
  });

  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] ?? 'Untitled Job';
    final budget = (jobData['budget'] ?? 0).toDouble();
    final location = jobData['location'] ?? 'No location';
    final timing = jobData['timing'] ?? '';
    final status = jobData['status'] ?? 'open';
    final bidsCount = jobData['bidsCount'] ?? 0;
    final skills =
        List<String>.from(jobData['skills'] ?? []);
    final orderType = jobData['orderType'] ?? 'simple';
    final totalAmount =
        (jobData['totalAmount'] ?? budget).toDouble();
    final postedAt = jobData['postedAt'] as Timestamp?;
    final dateStr = postedAt != null
        ? DateFormat('dd MMM yyyy').format(postedAt.toDate())
        : 'Just now';
    final isInsured = orderType == 'insured';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _JobDetailPage(
              jobId: jobId,
              jobData: jobData,
              buyerUid: buyerUid),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isInsured
              ? Border.all(color: Colors.blue.shade200, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isInsured
                    ? Colors.blue.shade50
                    : Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                            if (isInsured)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.shield,
                                        size: 10,
                                        color: Colors.white),
                                    SizedBox(width: 3),
                                    Text('INSURED',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12,
                                color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(location,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isInsured
                                ? Colors.blue.shade700
                                : Colors.teal),
                      ),
                      if (isInsured)
                        Text('(incl. insurance)',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue.shade400)),
                      _StatusBadge(status: status),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14,
                          color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(timing,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600])),
                      const Spacer(),
                      Icon(Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills
                        .take(4)
                        .map((s) => Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.teal.shade200),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors
                                          .teal.shade700)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Insurance claim section
                  if (isInsured && status == 'completed')
                    _InsuranceClaimSection(
                        jobId: jobId, jobData: jobData),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bidsCount > 0
                              ? Colors.orange.shade50
                              : Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: bidsCount > 0
                                ? Colors.orange.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gavel,
                                size: 14,
                                color: bidsCount > 0
                                    ? Colors.orange
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              '$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bidsCount > 0
                                      ? Colors.orange
                                      : Colors.grey,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (status == 'open')
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _JobDetailPage(
                                  jobId: jobId,
                                  jobData: jobData,
                                  buyerUid: buyerUid),
                            ),
                          ),
                          icon: const Icon(Icons.visibility,
                              size: 16),
                          label: const Text('View Bids'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Insurance Claim Section ───────────────────────────────────
class _InsuranceClaimSection extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  const _InsuranceClaimSection(
      {required this.jobId, required this.jobData});

  @override
  State<_InsuranceClaimSection> createState() =>
      _InsuranceClaimSectionState();
}

class _InsuranceClaimSectionState
    extends State<_InsuranceClaimSection> {
  bool _isClaiming = false;

  bool get _canClaim {
    final claimed = widget.jobData['insuranceClaimed'] ?? false;
    if (claimed) return false;
    final deadline =
        widget.jobData['claimDeadline'] as Timestamp?;
    if (deadline == null) return false;
    return DateTime.now().isBefore(deadline.toDate());
  }

  bool get _alreadyClaimed =>
      widget.jobData['insuranceClaimed'] ?? false;

  Future<void> _claimInsurance() async {
    setState(() => _isClaiming = true);
    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({
        'insuranceClaimed': true,
        'claimStatus': 'pending_review', // admin reviews
        'claimedAt': FieldValue.serverTimestamp(),
        'status': 'claim_in_review',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Insurance claim submitted! We will send a top expert within 24 hours.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadline =
        widget.jobData['claimDeadline'] as Timestamp?;
    final daysLeft = deadline != null
        ? deadline.toDate().difference(DateTime.now()).inDays
        : 0;

    if (_alreadyClaimed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.verified,
                color: Colors.blue.shade700, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Insurance claimed. Expert team dispatched.',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    if (!_canClaim) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                'Insurance Window Open — $daysLeft day(s) left',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.orange.shade800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Not satisfied? Claim insurance to get a top expert + the seller to redo the job.',
            style:
                TextStyle(fontSize: 12, color: Colors.orange.shade800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isClaiming ? null : _claimInsurance,
              icon: const Icon(Icons.policy, size: 16),
              label: Text(
                  _isClaiming ? 'Submitting...' : 'Claim Insurance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Job Detail + Bids Page ─────────────────────────────────────
class _JobDetailPage extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String buyerUid;

  const _JobDetailPage({
    required this.jobId,
    required this.jobData,
    required this.buyerUid,
  });

  @override
  Widget build(BuildContext context) {
    final status = jobData['status'] ?? 'open';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(jobData['title'] ?? 'Job Detail'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JobSummaryCard(jobData: jobData),
            const SizedBox(height: 20),

            if (status == 'open') ...[
              const Text('Bids Received',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _BidsList(
                  jobId: jobId,
                  buyerUid: buyerUid,
                  jobData: jobData),
            ] else if (status == 'in_progress') ...[
              const Text('Accepted Seller',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _AcceptedSellerCard(
                  jobId: jobId,
                  acceptedBidder: jobData['acceptedBidder']),
            ],

            if (status == 'open') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.red),
                  label: const Text('Cancel Job',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Job?'),
        content: const Text(
            'This will remove the job and all bids.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('jobs')
                  .doc(jobId)
                  .update({'status': 'cancelled'});
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _JobSummaryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const _JobSummaryCard({required this.jobData});

  @override
  Widget build(BuildContext context) {
    final skills =
        List<String>.from(jobData['skills'] ?? []);
    final isInsured =
        (jobData['orderType'] ?? 'simple') == 'insured';
    final budget =
        (jobData['budget'] ?? 0).toDouble();
    final insuranceAmount =
        (jobData['insuranceAmount'] ?? 0).toDouble();
    final totalAmount =
        (jobData['totalAmount'] ?? budget).toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(jobData['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                if (isInsured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.circular(8)),
                    child: Row(
                      children: const [
                        Icon(Icons.shield,
                            size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('INSURED',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (isInsured) ...[
              _summaryRow('Job Budget',
                  'PKR ${budget.toStringAsFixed(0)}'),
              _summaryRow('Insurance (20%)',
                  'PKR ${insuranceAmount.toStringAsFixed(0)}',
                  color: Colors.blue),
              const Divider(height: 12),
              _summaryRow('Total',
                  'PKR ${totalAmount.toStringAsFixed(0)}',
                  bold: true, color: Colors.blue.shade700),
              const SizedBox(height: 8),
            ] else
              _summaryRow('Budget',
                  'PKR ${budget.toStringAsFixed(0)}',
                  bold: true),
            const SizedBox(height: 8),
            if ((jobData['description'] ?? '').isNotEmpty)
              Text(jobData['description'],
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            _infoRow(
                Icons.location_on, jobData['location'] ?? ''),
            const SizedBox(height: 6),
            _infoRow(Icons.schedule, jobData['timing'] ?? ''),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: skills
                  .map((s) => Chip(
                        label: Text(s,
                            style:
                                const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.teal.shade50,
                        side: BorderSide(
                            color: Colors.teal.shade200),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.black87,
                    fontWeight: bold
                        ? FontWeight.bold
                        : FontWeight.normal)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.black87,
                    fontWeight: bold
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        ),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600]))),
        ],
      );
}

class _BidsList extends StatelessWidget {
  final String jobId;
  final String buyerUid;
  final Map<String, dynamic> jobData;

  const _BidsList(
      {required this.jobId,
      required this.buyerUid,
      required this.jobData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .collection('bids')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Colors.teal));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.gavel, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No bids yet',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 16)),
                  Text('Sellers will bid shortly',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (ctx, i) {
            final bid = snap.data!.docs[i].data()
                as Map<String, dynamic>;
            return _BidCard(
              bid: bid,
              jobId: jobId,
              buyerUid: buyerUid,
              jobData: jobData,
            );
          },
        );
      },
    );
  }
}

class _BidCard extends StatefulWidget {
  final Map<String, dynamic> bid;
  final String jobId;
  final String buyerUid;
  final Map<String, dynamic> jobData;

  const _BidCard(
      {required this.bid,
      required this.jobId,
      required this.buyerUid,
      required this.jobData});

  @override
  State<_BidCard> createState() => _BidCardState();
}

class _BidCardState extends State<_BidCard> {
  bool _isAccepting = false;

  // ── Commission Logic ───────────────────────────────────────
  /// Returns commission rate: 0 if free orders remain, else 10-15%
  Future<Map<String, dynamic>> _getSellerCommissionInfo(
      String sellerId) async {
    final sellerDoc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .get();
    final data = sellerDoc.data() ?? {};
    final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
    final availableBalance =
        (data['Available_Balance'] ?? 0).toDouble();

    const int freeOrderLimit = 3;
    const double commissionRate = 0.10; // 10%

    final bool isFreeOrder = jobsCompleted < freeOrderLimit;
    final double commissionAmount = isFreeOrder
        ? 0
        : (widget.bid['proposedAmount'] ?? 0) * commissionRate;
    final bool hasSufficientBalance =
        isFreeOrder || availableBalance >= commissionAmount;

    return {
      'isFreeOrder': isFreeOrder,
      'jobsCompleted': jobsCompleted,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'availableBalance': availableBalance,
      'hasSufficientBalance': hasSufficientBalance,
      'freeOrdersLeft':
          isFreeOrder ? freeOrderLimit - jobsCompleted : 0,
    };
  }

  Future<void> _acceptBid() async {
    setState(() => _isAccepting = true);

    try {
      final db = FirebaseFirestore.instance;
      final sellerId = widget.bid['sellerId'] as String;
      final sellerName =
          widget.bid['sellerName'] as String? ?? '';
      final sellerImage =
          widget.bid['sellerImage'] as String? ?? '';
      final proposedAmount =
          (widget.bid['proposedAmount'] ?? 0).toDouble();

      // Check commission
      final commInfo =
          await _getSellerCommissionInfo(sellerId);

      if (!commInfo['hasSufficientBalance']) {
        if (mounted) {
          _showInsufficientBalanceDialog(sellerId,
              commInfo['commissionAmount'], sellerName);
        }
        setState(() => _isAccepting = false);
        return;
      }

      final batch = db.batch();

      // 1. Update job
      final jobRef = db.collection('jobs').doc(widget.jobId);
      final claimDeadline = DateTime.now()
          .add(const Duration(days: 3)); // 3 days after completion
      batch.update(jobRef, {
        'status': 'in_progress',
        'acceptedBidder': sellerId,
        'acceptedAmount': proposedAmount,
        'claimDeadline': Timestamp.fromDate(claimDeadline),
        'paymentStatus': widget.jobData['orderType'] == 'insured'
            ? 'locked'
            : 'cash_on_delivery',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Accept this bid
      batch.update(
          jobRef.collection('bids').doc(sellerId),
          {'status': 'accepted'});

      // 3. Reject others
      final others = await jobRef
          .collection('bids')
          .where('sellerId', isNotEqualTo: sellerId)
          .get();
      for (final d in others.docs) {
        batch.update(d.reference, {'status': 'rejected'});
      }

      // 4. Deduct commission if not free
      if (!commInfo['isFreeOrder']) {
        batch.update(db.collection('sellers').doc(sellerId), {
          'Available_Balance':
              FieldValue.increment(-commInfo['commissionAmount']),
          'Pending_Jobs': FieldValue.increment(1),
        });
      } else {
        batch.update(db.collection('sellers').doc(sellerId),
            {'Pending_Jobs': FieldValue.increment(1)});
      }

      await batch.commit();

      // 5. Create conversation
      await _createConversation(
          sellerId, sellerName, sellerImage);

      if (!mounted) return;

      // Show order type specific message
      final msg = widget.jobData['orderType'] == 'insured'
          ? '✅ Bid accepted! Please transfer PKR ${widget.jobData['totalAmount']?.toStringAsFixed(0)} to company account to lock insurance.'
          : '✅ Bid accepted! Pay seller PKR ${proposedAmount.toStringAsFixed(0)} in cash after job completion.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6)),
      );
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _showInsufficientBalanceDialog(
      String sellerId, double commission, String sellerName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seller Has Insufficient Balance'),
        content: Text(
          '$sellerName has used their 3 free orders and their balance is too low to cover the PKR ${commission.toStringAsFixed(0)} commission (10%).\n\nThey need to top up their wallet before you can book them.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _createConversation(String sellerId,
      String sellerName, String sellerImage) async {
    final db = FirebaseFirestore.instance;
    final phones = [widget.buyerUid, sellerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';

    final convDoc =
        await db.collection('conversations').doc(convId).get();
    if (convDoc.exists) return;

    final buyerDoc = await db
        .collection('users')
        .doc(widget.buyerUid)
        .get();
    final buyerData = buyerDoc.data() ?? {};
    final buyerName =
        '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
            .trim();
    final buyerImage = buyerData['profileImage'] ?? '';

    await db.collection('conversations').doc(convId).set({
      'participantIds': [widget.buyerUid, sellerId],
      'participantNames': {
        widget.buyerUid: buyerName,
        sellerId: sellerName
      },
      'participantRoles': {
        widget.buyerUid: 'buyer',
        sellerId: 'seller'
      },
      'participantProfileImages': {
        widget.buyerUid: buyerImage,
        sellerId: sellerImage
      },
      'lastMessage': 'Job accepted! Let\'s coordinate.',
      'lastMessageAt': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'unreadCounts': {
        widget.buyerUid: 0,
        sellerId: 1
      },
      'relatedJobId': widget.jobId,
      'relatedJobTitle': widget.jobData['title'] ?? '',
    });
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color));

  @override
  Widget build(BuildContext context) {
    final sellerName =
        widget.bid['sellerName'] ?? 'Unknown';
    final sellerImage =
        widget.bid['sellerImage'] as String?;
    final proposedAmount =
        (widget.bid['proposedAmount'] ?? 0).toDouble();
    final proposal = widget.bid['proposal'] ?? '';
    final rating =
        (widget.bid['rating'] ?? 0.0).toDouble();
    final skills = List<String>.from(
        widget.bid['skills'] ?? []);
    final bidStatus =
        widget.bid['status'] ?? 'pending';
    final createdAt =
        widget.bid['createdAt'] as Timestamp?;

    final isAccepted = bidStatus == 'accepted';
    final isRejected = bidStatus == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted
              ? Colors.green.shade300
              : isRejected
                  ? Colors.red.shade100
                  : Colors.grey.shade200,
          width: isAccepted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage:
                      sellerImage != null && sellerImage.isNotEmpty
                          ? NetworkImage(sellerImage)
                          : null,
                  child: sellerImage == null ||
                          sellerImage.isEmpty
                      ? Text(sellerName[0].toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(sellerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 12,
                                color: Colors.amber[600]),
                            const SizedBox(width: 3),
                            Text('$rating',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600])),
                          ],
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${proposedAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    if (createdAt != null)
                      Text(
                        DateFormat('dd MMM, hh:mm a')
                            .format(createdAt.toDate()),
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500]),
                      ),
                  ],
                ),
              ],
            ),

            // Commission info
            FutureBuilder<Map<String, dynamic>>(
              future: _getSellerCommissionInfo(
                  widget.bid['sellerId']),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox();
                final info = snap.data!;
                if (info['isFreeOrder']) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard,
                              size: 14,
                              color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Free order (${info['freeOrdersLeft']} free left for this seller)',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!info['hasSufficientBalance']) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 14,
                              color: Colors.red.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Seller\'s balance is low (PKR ${info['availableBalance'].toStringAsFixed(0)}). Cannot accept.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade700,
                                  fontWeight:
                                      FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.percent,
                              size: 14,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '10% commission (PKR ${info['commissionAmount'].toStringAsFixed(0)}) will be deducted from seller',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            if (proposal.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(proposal,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],

            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: skills
                    .take(3)
                    .map((s) => Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.teal.shade200),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.teal.shade700)),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),

            if (isAccepted)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16),
                    const SizedBox(width: 8),
                    Text('Bid Accepted',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else if (!isRejected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isAccepting ? null : _acceptBid,
                  icon: _isAccepting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Icon(
                          Icons.check_circle_outline,
                          size: 18),
                  label: Text(_isAccepting
                      ? 'Accepting...'
                      : 'Accept This Bid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AcceptedSellerCard extends StatelessWidget {
  final String jobId;
  final String? acceptedBidder;
  const _AcceptedSellerCard(
      {required this.jobId, this.acceptedBidder});

  @override
  Widget build(BuildContext context) {
    if (acceptedBidder == null) return const SizedBox();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('sellers')
          .doc(acceptedBidder)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final data =
            snap.data?.data() as Map<String, dynamic>? ??
                {};
        final name =
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                .trim();
        final rating =
            (data['Rating'] ?? 0).toDouble();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 14,
                              color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text('$rating',
                              style: TextStyle(
                                  color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('In Progress',
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'open':
        color = Colors.orange;
        label = 'Open';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'claim_in_review':
        color = Colors.purple;
        label = 'Claim Review';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String status;
  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined,
              size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No $status jobs',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('Post a job to get competitive bids',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}