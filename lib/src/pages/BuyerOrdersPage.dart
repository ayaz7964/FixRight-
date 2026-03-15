// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';

// const int kFreeOrderLimit = 3;
// const double kCommissionRate = 0.10;
// const double kInsuranceRate = 0.20;
// const double kSellerMinBalance = 500.0;

// class BuyerOrdersPage extends StatefulWidget {
//   final String? phoneUID;
//   const BuyerOrdersPage({super.key, this.phoneUID});

//   @override
//   State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
// }

// class _BuyerOrdersPageState extends State<BuyerOrdersPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late String _uid;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _uid = _resolveUid();
//     debugPrint('✅ BuyerOrdersPage UID: $_uid');
//   }

//   /// Resolve uid from all sources and normalize to +digits format
//   String _resolveUid() {
//     final raw =
//         widget.phoneUID ??
//         UserSession().phoneUID ??
//         UserSession().phone ??
//         UserSession().uid ??
//         '';

//     return _normalizePhone(raw);
//   }

//   /// Ensures phone always has + prefix: "923163797857" → "+923163797857"
//   String _normalizePhone(String raw) {
//     if (raw.isEmpty) return '';
//     final trimmed = raw.trim();
//     if (trimmed.startsWith('+')) return trimmed;
//     // Has digits only — add +
//     if (RegExp(r'^\d+$').hasMatch(trimmed)) return '+$trimmed';
//     return trimmed;
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
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'My Jobs ',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
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
//       body: _uid.isEmpty
//           ? _buildUidError()
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 _JobsList(uid: _uid, status: 'open'),
//                 _JobsList(uid: _uid, status: 'in_progress'),
//                 _JobsList(uid: _uid, status: 'completed'),
//               ],
//             ),
//     );
//   }

//   Widget _buildUidError() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
//           const SizedBox(height: 16),
//           const Text(
//             'Could not identify user',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'UID resolved: "$_uid"\nPlease log out and log in again.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// // ─────────────────────────────────────────────────────────────
// // Jobs List
// // ─────────────────────────────────────────────────────────────
// class _JobsList extends StatelessWidget {
//   final String uid;
//   final String status;
//   const _JobsList({required this.uid, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     debugPrint(
//       '🔍 Querying jobs where postedBy == "$uid" && status == "$status"',
//     );

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('jobs')
//           .where('postedBy', isEqualTo: uid)
//           .where('status', isEqualTo: status)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.teal),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.cloud_off, size: 48, color: Colors.red[300]),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Error loading jobs:\n${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         final docs = snapshot.data?.docs ?? [];
//         debugPrint(
//           '📦 Jobs fetched for "$uid" status="$status": ${docs.length}',
//         );

//         if (docs.isEmpty) return _EmptyState(status: status);

//         // Sort by postedAt descending in Dart (no composite index needed)
//         final jobs = docs.toList()
//           ..sort((a, b) {
//             final aT = (a.data() as Map)['postedAt'] as Timestamp?;
//             final bT = (b.data() as Map)['postedAt'] as Timestamp?;
//             if (aT == null || bT == null) return 0;
//             return bT.compareTo(aT);
//           });

//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: jobs.length,
//           itemBuilder: (context, i) {
//             final data = jobs[i].data() as Map<String, dynamic>;
//             return _JobCard(jobData: data, jobId: jobs[i].id, buyerUid: uid);
//           },
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Job Card
// // ─────────────────────────────────────────────────────────────
// // class _JobCard extends StatelessWidget {
// //   final Map<String, dynamic> jobData;
// //   final String jobId;
// //   final String buyerUid;

// //   const _JobCard({
// //     required this.jobData,
// //     required this.jobId,
// //     required this.buyerUid,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final title = jobData['title'] ?? 'Untitled Job';
// //     final budget = (jobData['budget'] ?? 0).toDouble();
// //     final location = jobData['location'] ?? 'No location';
// //     final timing = jobData['timing'] ?? '';
// //     final status = jobData['status'] ?? 'open';
// //     final bidsCount = jobData['bidsCount'] ?? 0;
// //     final skills = List<String>.from(jobData['skills'] ?? []);
// //     final postedAt = jobData['postedAt'] as Timestamp?;
// //     final dateStr = postedAt != null
// //         ? DateFormat('dd MMM yyyy').format(postedAt.toDate())
// //         : 'Just now';

// //     return GestureDetector(
// //       onTap: () => Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (_) => _JobDetailPage(
// //             jobId: jobId,
// //             jobData: jobData,
// //             buyerUid: buyerUid,
// //           ),
// //         ),
// //       ),
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 8,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           children: [
// //             // Header
// //             Container(
// //               padding: const EdgeInsets.all(14),
// //               decoration: BoxDecoration(
// //                 color: Colors.teal.shade50,
// //                 borderRadius: const BorderRadius.vertical(
// //                   top: Radius.circular(14),
// //                 ),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           title,
// //                           style: const TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Row(
// //                           children: [
// //                             Icon(
// //                               Icons.location_on,
// //                               size: 12,
// //                               color: Colors.grey[500],
// //                             ),
// //                             const SizedBox(width: 4),
// //                             Expanded(
// //                               child: Text(
// //                                 location,
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                                 maxLines: 1,
// //                                 overflow: TextOverflow.ellipsis,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       Text(
// //                         'PKR ${budget.toStringAsFixed(0)}',
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                           color: Colors.teal,
// //                         ),
// //                       ),
// //                       _StatusBadge(status: status),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             // Body
// //             Padding(
// //               padding: const EdgeInsets.all(14),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
// //                       const SizedBox(width: 6),
// //                       Text(
// //                         timing,
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                       const Spacer(),
// //                       Icon(
// //                         Icons.calendar_today,
// //                         size: 14,
// //                         color: Colors.grey[500],
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         dateStr,
// //                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 10),

// //                   // Skills
// //                   Wrap(
// //                     spacing: 6,
// //                     runSpacing: 4,
// //                     children: skills
// //                         .take(4)
// //                         .map(
// //                           (s) => Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 3,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Colors.teal.shade50,
// //                               borderRadius: BorderRadius.circular(20),
// //                               border: Border.all(color: Colors.teal.shade200),
// //                             ),
// //                             child: Text(
// //                               s,
// //                               style: TextStyle(
// //                                 fontSize: 11,
// //                                 color: Colors.teal.shade700,
// //                               ),
// //                             ),
// //                           ),
// //                         )
// //                         .toList(),
// //                   ),
// //                   const SizedBox(height: 12),

// //                   // Row(
// //                   //   children: [
// //                   //     // Real-time bids count from subcollection
// //                   //     StreamBuilder<QuerySnapshot>(
// //                   //       stream: FirebaseFirestore.instance
// //                   //           .collection('jobs')
// //                   //           .doc(jobId)
// //                   //           .collection('bids')
// //                   //           .snapshots(),
// //                   //       builder: (ctx, bidSnap) {
// //                   //         final count = bidSnap.data?.docs.length ?? bidsCount;
// //                   //         return Container(
// //                   //           padding: const EdgeInsets.symmetric(
// //                   //               horizontal: 12, vertical: 6),
// //                   //           decoration: BoxDecoration(
// //                   //             color: count > 0
// //                   //                 ? Colors.orange.shade50
// //                   //                 : Colors.grey.shade100,
// //                   //             borderRadius: BorderRadius.circular(20),
// //                   //             border: Border.all(
// //                   //               color: count > 0
// //                   //                   ? Colors.orange.shade300
// //                   //                   : Colors.grey.shade300,
// //                   //             ),
// //                   //           ),
// //                   //           child: Row(
// //                   //             children: [
// //                   //               Icon(Icons.gavel,
// //                   //                   size: 14,
// //                   //                   color: count > 0
// //                   //                       ? Colors.orange
// //                   //                       : Colors.grey),
// //                   //               const SizedBox(width: 6),
// //                   //               Text(
// //                   //                 '$count ${count == 1 ? 'Bid' : 'Bids'}',
// //                   //                 style: TextStyle(
// //                   //                   fontWeight: FontWeight.bold,
// //                   //                   color: count > 0
// //                   //                       ? Colors.orange
// //                   //                       : Colors.grey,
// //                   //                   fontSize: 13,
// //                   //                 ),
// //                   //               ),
// //                   //             ],
// //                   //           ),
// //                   //         );
// //                   //       },
// //                   //     ),
// //                   //     const Spacer(),
// //                   //     if (status == 'open')
// //                   //       ElevatedButton.icon(
// //                   //         onPressed: () => Navigator.push(
// //                   //           context,
// //                   //           MaterialPageRoute(
// //                   //             builder: (_) => _JobDetailPage(
// //                   //               jobId: jobId,
// //                   //               jobData: jobData,
// //                   //               buyerUid: buyerUid,
// //                   //             ),
// //                   //           ),
// //                   //         ),
// //                   //         icon: const Icon(Icons.visibility, size: 16),
// //                   //         label: const Text('View Bids'),
// //                   //         style: ElevatedButton.styleFrom(
// //                   //           backgroundColor: Colors.teal,
// //                   //           foregroundColor: Colors.white,
// //                   //           padding: const EdgeInsets.symmetric(
// //                   //               horizontal: 14, vertical: 8),
// //                   //           shape: RoundedRectangleBorder(
// //                   //               borderRadius: BorderRadius.circular(8)),
// //                   //         ),
// //                   //       ),
// //                   //   ],
// //                   // ),

// //                   // REPLACE this entire Row in _JobCard (the bids counter + View Bids button row):
// //                   Row(
// //                     children: [
// //                       // Bids counter
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 6,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: bidsCount > 0
// //                               ? Colors.orange.shade50
// //                               : Colors.grey.shade100,
// //                           borderRadius: BorderRadius.circular(20),
// //                           border: Border.all(
// //                             color: bidsCount > 0
// //                                 ? Colors.orange.shade300
// //                                 : Colors.grey.shade300,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(
// //                               Icons.gavel,
// //                               size: 14,
// //                               color: bidsCount > 0
// //                                   ? Colors.orange
// //                                   : Colors.grey,
// //                             ),
// //                             const SizedBox(width: 6),
// //                             // ✅ Real-time count from subcollection
// //                             StreamBuilder<QuerySnapshot>(
// //                               stream: FirebaseFirestore.instance
// //                                   .collection('jobs')
// //                                   .doc(jobId)
// //                                   .collection('bids')
// //                                   .snapshots(),
// //                               builder: (ctx, bidSnap) {
// //                                 final count =
// //                                     bidSnap.data?.docs.length ?? bidsCount;
// //                                 return Text(
// //                                   '$count ${count == 1 ? 'Bid' : 'Bids'}',
// //                                   style: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: count > 0
// //                                         ? Colors.orange
// //                                         : Colors.grey,
// //                                     fontSize: 13,
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       // ✅ Button constrained — NOT inside StreamBuilder
// //                       if (status == 'open')
// //                         ElevatedButton.icon(
// //                           onPressed: () => Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => _JobDetailPage(
// //                                 jobId: jobId,
// //                                 jobData: jobData,
// //                                 buyerUid: buyerUid,
// //                               ),
// //                             ),
// //                           ),
// //                           icon: const Icon(Icons.visibility, size: 16),
// //                           label: const Text('View Bids'),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.teal,
// //                             foregroundColor: Colors.white,
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 14,
// //                               vertical: 8,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

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
//     final budget = (jobData['budget'] ?? 0).toDouble();
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
//           builder: (_) => _JobDetailPage(
//             jobId: jobId,
//             jobData: jobData,
//             buyerUid: buyerUid,
//           ),
//         ),
//       ),
//       child: Container(
//         // ✅ FIX 1: force bounded width — prevents unconstrained cascade
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── Header ──────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(14)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(title,
//                             style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.location_on,
//                                 size: 12, color: Colors.grey[500]),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 location,
//                                 style: TextStyle(
//                                     fontSize: 12, color: Colors.grey[600]),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'PKR ${budget.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.teal),
//                       ),
//                       _StatusBadge(status: status),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ── Body ────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Timing + Date row
//                   Row(
//                     children: [
//                       Icon(Icons.schedule,
//                           size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(timing,
//                             style: TextStyle(
//                                 fontSize: 13, color: Colors.grey[600])),
//                       ),
//                       Icon(Icons.calendar_today,
//                           size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 4),
//                       Text(dateStr,
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey[500])),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Skills chips
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 4,
//                     children: skills
//                         .take(4)
//                         .map((s) => Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: Colors.teal.shade50,
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                     color: Colors.teal.shade200),
//                               ),
//                               child: Text(s,
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.teal.shade700)),
//                             ))
//                         .toList(),
//                   ),
//                   const SizedBox(height: 12),

//                   // ✅ FIX 2: NO Spacer, use mainAxisAlignment.spaceBetween
//                   //    Both children get BoxConstraints(0<=w<=rowWidth) — BOUNDED
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Bids counter — StreamBuilder wraps only the Text
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: bidsCount > 0
//                               ? Colors.orange.shade50
//                               : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: bidsCount > 0
//                                 ? Colors.orange.shade300
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.gavel,
//                                 size: 14,
//                                 color: bidsCount > 0
//                                     ? Colors.orange
//                                     : Colors.grey),
//                             const SizedBox(width: 6),
//                             StreamBuilder<QuerySnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('jobs')
//                                   .doc(jobId)
//                                   .collection('bids')
//                                   .snapshots(),
//                               builder: (ctx, bidSnap) {
//                                 final count =
//                                     bidSnap.data?.docs.length ?? bidsCount;
//                                 return Text(
//                                   '$count ${count == 1 ? 'Bid' : 'Bids'}',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: count > 0
//                                         ? Colors.orange
//                                         : Colors.grey,
//                                     fontSize: 13,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       // View Bids button — directly in Row, no StreamBuilder wrapper
//                       if (status == 'open')
//                         ElevatedButton.icon(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => _JobDetailPage(
//                                 jobId: jobId,
//                                 jobData: jobData,
//                                 buyerUid: buyerUid,
//                               ),
//                             ),
//                           ),
//                           icon: const Icon(Icons.visibility, size: 16),
//                           label: const Text('View Bids'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 8),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
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
// // ═══════════════════════════════════════════════════════════════
// //  JOB DETAIL PAGE
// // ═══════════════════════════════════════════════════════════════
// class _JobDetailPage extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String buyerUid;

//   const _JobDetailPage({
//     required this.jobId,
//     required this.jobData,
//     required this.buyerUid,
//   });

//   @override
//   State<_JobDetailPage> createState() => _JobDetailPageState();
// }

// class _JobDetailPageState extends State<_JobDetailPage> {
//   late Map<String, dynamic> _jobData;

//   @override
//   void initState() {
//     super.initState();
//     _jobData = Map<String, dynamic>.from(widget.jobData);
//   }

//   void _showEditDialog() {
//     final titleCtrl = TextEditingController(text: _jobData['title'] ?? '');
//     final descCtrl = TextEditingController(text: _jobData['description'] ?? '');
//     final budgetCtrl = TextEditingController(
//       text: (_jobData['budget'] ?? 0).toStringAsFixed(0),
//     );

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Edit Job',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: titleCtrl,
//                 decoration: const InputDecoration(
//                   labelText: 'Job Title',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: descCtrl,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: budgetCtrl,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Maximum Budget (PKR)',
//                   prefixText: 'PKR ',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final newTitle = titleCtrl.text.trim();
//                     final newDesc = descCtrl.text.trim();
//                     final newBudget =
//                         double.tryParse(budgetCtrl.text.trim()) ?? 0;

//                     await FirebaseFirestore.instance
//                         .collection('jobs')
//                         .doc(widget.jobId)
//                         .update({
//                           'title': newTitle,
//                           'description': newDesc,
//                           'budget': newBudget,
//                           'updatedAt': FieldValue.serverTimestamp(),
//                         });

//                     setState(() {
//                       _jobData['title'] = newTitle;
//                       _jobData['description'] = newDesc;
//                       _jobData['budget'] = newBudget;
//                     });

//                     if (mounted) {
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Job updated'),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Changes',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _confirmCancel() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Cancel Job?'),
//         content: const Text('This will remove the job and all bids.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () async {
//               await FirebaseFirestore.instance
//                   .collection('jobs')
//                   .doc(widget.jobId)
//                   .update({'status': 'cancelled'});
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Yes, Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = _jobData['status'] ?? 'open';

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         title: Text(_jobData['title'] ?? 'Job Detail'),
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//         actions: [
//           if (status == 'open')
//             IconButton(
//               icon: const Icon(Icons.edit_outlined),
//               tooltip: 'Edit Job',
//               onPressed: _showEditDialog,
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _JobSummaryCard(jobData: _jobData),
//             const SizedBox(height: 20),

//             if (status == 'open') ...[
//               Row(
//                 children: [
//                   const Text(
//                     'Bids Received',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const Spacer(),
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('jobs')
//                         .doc(widget.jobId)
//                         .collection('bids')
//                         .snapshots(),
//                     builder: (ctx, s) {
//                       final count = s.data?.docs.length ?? 0;
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: count > 0
//                               ? Colors.orange.shade50
//                               : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: count > 0
//                                 ? Colors.orange.shade300
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Text(
//                           '$count bids',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             color: count > 0 ? Colors.orange : Colors.grey,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _BidsList(
//                 jobId: widget.jobId,
//                 buyerUid: widget.buyerUid,
//                 jobData: _jobData,
//               ),
//             ] else if (status == 'in_progress') ...[
//               const Text(
//                 'Accepted Worker',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               _AcceptedSellerCard(
//                 jobId: widget.jobId,
//                 acceptedBidder: _jobData['acceptedBidder'],
//               ),
//             ] else if (status == 'pending_payment') ...[
//               _PendingPaymentBanner(jobData: _jobData, jobId: widget.jobId),
//             ],

//             if (status == 'open') ...[
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: _confirmCancel,
//                   icon: const Icon(Icons.cancel_outlined, color: Colors.red),
//                   label: const Text(
//                     'Cancel Job',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.red),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Pending Payment Banner
// // ─────────────────────────────────────────────────────────────
// class _PendingPaymentBanner extends StatelessWidget {
//   final Map<String, dynamic> jobData;
//   final String jobId;
//   const _PendingPaymentBanner({required this.jobData, required this.jobId});

//   @override
//   Widget build(BuildContext context) {
//     final totalAmount = (jobData['totalAmount'] ?? 0).toDouble();

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.orange.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.pending_actions, color: Colors.orange.shade700),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Payment Required to Activate Order',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange.shade800,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Transfer PKR ${totalAmount.toStringAsFixed(0)} to the company account to activate this insured order.',
//             style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.orange.shade200),
//             ),
//             child: Column(
//               children: [
//                 _bankRow('Bank', 'HBL Bank'),
//                 _bankRow('Account Title', 'FixRight Pvt Ltd'),
//                 _bankRow('Account Number', '0123456789101112'),
//                 _bankRow('Amount', 'PKR ${totalAmount.toStringAsFixed(0)}'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Text(
//               'Admin will verify and activate your order within a few hours.',
//               style: TextStyle(fontSize: 12, color: Colors.blue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bankRow(String label, String value) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 13, color: Colors.black54),
//         ),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//         ),
//       ],
//     ),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// //  BIDS LIST
// // ═══════════════════════════════════════════════════════════════
// class _BidsList extends StatelessWidget {
//   final String jobId;
//   final String buyerUid;
//   final Map<String, dynamic> jobData;

//   const _BidsList({
//     required this.jobId,
//     required this.buyerUid,
//     required this.jobData,
//   });

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
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.teal),
//           );
//         }
//         if (!snap.hasData || snap.data!.docs.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Icon(Icons.gavel, size: 48, color: Colors.grey[300]),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'No bids yet',
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Sellers will place competitive bids shortly',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
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

// // ═══════════════════════════════════════════════════════════════
// //  BID CARD
// // ═══════════════════════════════════════════════════════════════
// class _BidCard extends StatefulWidget {
//   final Map<String, dynamic> bid;
//   final String jobId;
//   final String buyerUid;
//   final Map<String, dynamic> jobData;

//   const _BidCard({
//     required this.bid,
//     required this.jobId,
//     required this.buyerUid,
//     required this.jobData,
//   });

//   @override
//   State<_BidCard> createState() => _BidCardState();
// }

// class _BidCardState extends State<_BidCard> {
//   bool _isAccepting = false;

//   Future<Map<String, dynamic>> _getSellerInfo(String sellerId) async {
//     final doc = await FirebaseFirestore.instance
//         .collection('sellers')
//         .doc(sellerId)
//         .get();
//     final data = doc.data() ?? {};
//     final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
//     final availableBalance = (data['Available_Balance'] ?? 0).toDouble();

//     final bool isFreeOrder = jobsCompleted < kFreeOrderLimit;
//     final double proposedAmount = (widget.bid['proposedAmount'] ?? 0)
//         .toDouble();
//     final double commissionAmount = isFreeOrder
//         ? 0
//         : proposedAmount * kCommissionRate;
//     final bool isEligible =
//         isFreeOrder || availableBalance >= kSellerMinBalance;

//     return {
//       'isFreeOrder': isFreeOrder,
//       'jobsCompleted': jobsCompleted,
//       'freeOrdersLeft': isFreeOrder ? kFreeOrderLimit - jobsCompleted : 0,
//       'availableBalance': availableBalance,
//       'commissionAmount': commissionAmount,
//       'isEligible': isEligible,
//     };
//   }

//   void _showOrderConfirmationSheet(Map<String, dynamic> sellerInfo) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _OrderConfirmationSheet(
//         bid: widget.bid,
//         jobId: widget.jobId,
//         jobData: widget.jobData,
//         buyerUid: widget.buyerUid,
//         sellerInfo: sellerInfo,
//       ),
//     );
//   }

//   Future<void> _openConversation(BuildContext context) async {
//     final sellerId = widget.bid['sellerId'] as String;
//     final sellerName = widget.bid['sellerName'] as String? ?? '';
//     final sellerImage = widget.bid['sellerImage'] as String? ?? '';

//     final db = FirebaseFirestore.instance;
//     final phones = [widget.buyerUid, sellerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';

//     final convDoc = await db.collection('conversations').doc(convId).get();
//     if (!convDoc.exists) {
//       final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
//       final buyerData = buyerDoc.data() ?? {};
//       final buyerName =
//           '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
//               .trim();
//       final buyerImage = buyerData['profileImage'] ?? '';

//       await db.collection('conversations').doc(convId).set({
//         'participantIds': [widget.buyerUid, sellerId],
//         'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName},
//         'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'},
//         'participantProfileImages': {
//           widget.buyerUid: buyerImage,
//           sellerId: sellerImage,
//         },
//         'lastMessage': '',
//         'lastMessageAt': Timestamp.now(),
//         'createdAt': Timestamp.now(),
//         'unreadCounts': {widget.buyerUid: 0, sellerId: 0},
//         'relatedJobId': widget.jobId,
//         'relatedJobTitle': widget.jobData['title'] ?? '',
//       });
//     }

//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Chat opened with $sellerName')));
//       // Navigator.push(context, MaterialPageRoute(builder: (_) =>
//       //   ChatDetailScreen(conversationId: convId, otherUserId: sellerId,
//       //     otherUserName: sellerName, otherUserImage: sellerImage)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sellerName = widget.bid['sellerName'] ?? 'Unknown';
//     final sellerImage = widget.bid['sellerImage'] as String?;
//     final proposedAmount = (widget.bid['proposedAmount'] ?? 0).toDouble();
//     final proposal = widget.bid['proposal'] ?? '';
//     final rating = (widget.bid['rating'] ?? 0.0).toDouble();
//     final skills = List<String>.from(widget.bid['skills'] ?? []);
//     final bidStatus = widget.bid['status'] ?? 'pending';
//     final createdAt = widget.bid['createdAt'] as Timestamp?;
//     final sellerId = widget.bid['sellerId'] as String? ?? '';

//     final isAccepted = bidStatus == 'accepted';
//     final isRejected = bidStatus == 'rejected';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isAccepted
//               ? Colors.green.shade300
//               : isRejected
//               ? Colors.red.shade100
//               : Colors.grey.shade200,
//           width: isAccepted ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Seller info
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 26,
//                   backgroundColor: Colors.teal.shade100,
//                   backgroundImage: sellerImage != null && sellerImage.isNotEmpty
//                       ? NetworkImage(sellerImage)
//                       : null,
//                   child: sellerImage == null || sellerImage.isEmpty
//                       ? Text(
//                           sellerName.isNotEmpty
//                               ? sellerName[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal,
//                             fontSize: 18,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         sellerName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                       if (rating > 0)
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.star,
//                               size: 13,
//                               color: Colors.amber[600],
//                             ),
//                             const SizedBox(width: 3),
//                             Text(
//                               '$rating',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
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
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal,
//                       ),
//                     ),
//                     if (createdAt != null)
//                       Text(
//                         DateFormat(
//                           'dd MMM, hh:mm a',
//                         ).format(createdAt.toDate()),
//                         style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // Eligibility chip
//             FutureBuilder<Map<String, dynamic>>(
//               future: _getSellerInfo(sellerId),
//               builder: (ctx, snap) {
//                 if (!snap.hasData) {
//                   return const LinearProgressIndicator(
//                     minHeight: 2,
//                     color: Colors.teal,
//                   );
//                 }
//                 final info = snap.data!;
//                 if (!info['isEligible']) {
//                   return _infoChip(
//                     '⚠️ Balance too low (PKR ${info['availableBalance'].toStringAsFixed(0)} / min PKR 500)',
//                     Colors.red,
//                   );
//                 } else if (info['isFreeOrder']) {
//                   return _infoChip(
//                     '🎁 Free order — ${info['freeOrdersLeft']} free order(s) left',
//                     Colors.green,
//                   );
//                 } else {
//                   return _infoChip(
//                     '10% commission (PKR ${info['commissionAmount'].toStringAsFixed(0)}) from seller',
//                     Colors.orange,
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 10),

//             // Proposal
//             if (proposal.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Text(
//                   proposal,
//                   style: const TextStyle(fontSize: 13, height: 1.4),
//                 ),
//               ),

//             // Skills
//             if (skills.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 6,
//                 runSpacing: 4,
//                 children: skills
//                     .take(4)
//                     .map(
//                       (s) => Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.teal.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.teal.shade200),
//                         ),
//                         child: Text(
//                           s,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.teal.shade700,
//                           ),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ],

//             const SizedBox(height: 14),

//             // Action buttons
//             if (isAccepted)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.check_circle,
//                       color: Colors.green.shade600,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Bid Accepted — Order Placed',
//                       style: TextStyle(
//                         color: Colors.green.shade700,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             else if (!isRejected)
//               FutureBuilder<Map<String, dynamic>>(
//                 future: _getSellerInfo(sellerId),
//                 builder: (ctx, snap) {
//                   final info = snap.data;
//                   final isEligible = info?['isEligible'] ?? true;

//                   return Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => _openConversation(context),
//                           icon: const Icon(Icons.message_outlined, size: 16),
//                           label: const Text('Contact'),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.teal,
//                             side: const BorderSide(color: Colors.teal),
//                             padding: const EdgeInsets.symmetric(vertical: 10),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: (!isEligible || _isAccepting)
//                               ? null
//                               : () => _showOrderConfirmationSheet(info!),
//                           icon: _isAccepting
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.check_circle_outline,
//                                   size: 16,
//                                 ),
//                           label: Text(
//                             _isAccepting ? 'Placing...' : 'Place Order',
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isEligible
//                                 ? Colors.teal
//                                 : Colors.grey,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 10),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             disabledBackgroundColor: Colors.grey.shade300,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoChip(String text, Color color) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.08),
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: color.withOpacity(0.3)),
//     ),
//     child: Text(
//       text,
//       style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
//     ),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// //  ORDER CONFIRMATION SHEET
// // ═══════════════════════════════════════════════════════════════
// class _OrderConfirmationSheet extends StatefulWidget {
//   final Map<String, dynamic> bid;
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String buyerUid;
//   final Map<String, dynamic> sellerInfo;

//   const _OrderConfirmationSheet({
//     required this.bid,
//     required this.jobId,
//     required this.jobData,
//     required this.buyerUid,
//     required this.sellerInfo,
//   });

//   @override
//   State<_OrderConfirmationSheet> createState() =>
//       _OrderConfirmationSheetState();
// }

// class _OrderConfirmationSheetState extends State<_OrderConfirmationSheet> {
//   bool _wantsInsurance = false;
//   bool _isPlacing = false;

//   double get _proposedAmount => (widget.bid['proposedAmount'] ?? 0).toDouble();
//   double get _insuranceAmount =>
//       _wantsInsurance ? (_proposedAmount * kInsuranceRate) : 0;
//   double get _totalAmount => _proposedAmount + _insuranceAmount;

//   Future<void> _placeOrder() async {
//     setState(() => _isPlacing = true);
//     try {
//       final db = FirebaseFirestore.instance;
//       final sellerId = widget.bid['sellerId'] as String;
//       final sellerName = widget.bid['sellerName'] as String? ?? '';
//       final sellerImage = widget.bid['sellerImage'] as String? ?? '';
//       final isFreeOrder = widget.sellerInfo['isFreeOrder'] as bool;
//       final commissionAmount =
//           (widget.sellerInfo['commissionAmount'] as double);

//       final batch = db.batch();
//       final jobRef = db.collection('jobs').doc(widget.jobId);
//       final String newJobStatus = _wantsInsurance
//           ? 'pending_payment'
//           : 'in_progress';
//       final claimDeadline = DateTime.now().add(const Duration(days: 3));

//       // 1. Update job
//       batch.update(jobRef, {
//         'status': newJobStatus,
//         'acceptedBidder': sellerId,
//         'acceptedAmount': _proposedAmount,
//         'orderType': _wantsInsurance ? 'insured' : 'simple',
//         'insuranceAmount': _insuranceAmount,
//         'totalAmount': _totalAmount,
//         'paymentStatus': _wantsInsurance
//             ? 'pending_payment'
//             : 'cash_on_delivery',
//         'insuranceClaimed': false,
//         'claimDeadline': _wantsInsurance
//             ? null
//             : Timestamp.fromDate(claimDeadline),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       // 2. Accept bid
//       batch.update(jobRef.collection('bids').doc(sellerId), {
//         'status': 'accepted',
//       });

//       // 3. Reject others
//       final otherBids = await jobRef
//           .collection('bids')
//           .where('sellerId', isNotEqualTo: sellerId)
//           .get();
//       for (final d in otherBids.docs) {
//         batch.update(d.reference, {'status': 'rejected'});
//       }

//       // 4. Commission / Pending_Jobs on seller
//       if (!isFreeOrder && commissionAmount > 0) {
//         batch.update(db.collection('sellers').doc(sellerId), {
//           'Available_Balance': FieldValue.increment(-commissionAmount),
//           'Pending_Jobs': FieldValue.increment(1),
//         });
//       } else {
//         batch.update(db.collection('sellers').doc(sellerId), {
//           'Pending_Jobs': FieldValue.increment(1),
//         });
//       }

//       // 5. Order sub-doc in sellers/{sellerId}/orders
//       final orderRef = db
//           .collection('sellers')
//           .doc(sellerId)
//           .collection('orders')
//           .doc(widget.jobId);

//       batch.set(orderRef, {
//         'orderId': widget.jobId,
//         'jobId': widget.jobId,
//         'jobTitle': widget.jobData['title'] ?? '',
//         'jobDescription': widget.jobData['description'] ?? '',
//         'jobLocation': widget.jobData['location'] ?? '',
//         'skills': widget.jobData['skills'] ?? [],
//         'buyerId': widget.buyerUid,
//         'buyerName': '',
//         'sellerId': sellerId,
//         'sellerName': sellerName,
//         'proposedAmount': _proposedAmount,
//         'commissionDeducted': isFreeOrder ? 0 : commissionAmount,
//         'isFreeOrder': isFreeOrder,
//         'orderType': _wantsInsurance ? 'insured' : 'simple',
//         'insuranceAmount': _insuranceAmount,
//         'totalAmount': _totalAmount,
//         'status': newJobStatus,
//         'paymentStatus': _wantsInsurance
//             ? 'pending_payment'
//             : 'cash_on_delivery',
//         'insuranceClaimed': false,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       await batch.commit();

//       // 6. Fill buyer name
//       final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
//       final buyerData = buyerDoc.data() ?? {};
//       final buyerName =
//           '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
//               .trim();
//       final buyerImage = buyerData['profileImage'] ?? '';
//       await orderRef.update({'buyerName': buyerName});

//       // 7. Conversation
//       await _createConversation(
//         db,
//         sellerId,
//         sellerName,
//         sellerImage,
//         buyerName,
//         buyerImage: buyerImage,
//       );

//       if (!mounted) return;
//       Navigator.pop(context);
//       Navigator.pop(context);

//       final msg = _wantsInsurance
//           ? '✅ Order placed! Transfer PKR ${_totalAmount.toStringAsFixed(0)} to activate.'
//           : '✅ Order placed! Pay PKR ${_proposedAmount.toStringAsFixed(0)} cash on completion.';

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 6),
//         ),
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isPlacing = false);
//     }
//   }

//   Future<void> _createConversation(
//     FirebaseFirestore db,
//     String sellerId,
//     String sellerName,
//     String sellerImage,
//     String buyerName, {
//     required String buyerImage,
//   }) async {
//     final phones = [widget.buyerUid, sellerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';
//     final convDoc = await db.collection('conversations').doc(convId).get();
//     if (convDoc.exists) return;

//     await db.collection('conversations').doc(convId).set({
//       'participantIds': [widget.buyerUid, sellerId],
//       'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName},
//       'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'},
//       'participantProfileImages': {
//         widget.buyerUid: buyerImage,
//         sellerId: sellerImage,
//       },
//       'lastMessage': 'Order placed! Let\'s get started.',
//       'lastMessageAt': Timestamp.now(),
//       'createdAt': Timestamp.now(),
//       'unreadCounts': {widget.buyerUid: 0, sellerId: 1},
//       'relatedJobId': widget.jobId,
//       'relatedJobTitle': widget.jobData['title'] ?? '',
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sellerName = widget.bid['sellerName'] ?? 'Seller';
//     final isFreeOrder = widget.sellerInfo['isFreeOrder'] as bool;
//     final commission = (widget.sellerInfo['commissionAmount'] as double);

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Confirm Order',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Placing order with $sellerName',
//               style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 16),

//             _sheetRow(
//               'Worker\'s Bid',
//               'PKR ${_proposedAmount.toStringAsFixed(0)}',
//             ),
//             if (isFreeOrder)
//               _sheetRow(
//                 'Commission',
//                 'FREE (${widget.sellerInfo['freeOrdersLeft']} left)',
//                 color: Colors.green,
//               )
//             else
//               _sheetRow(
//                 'Commission (10%)',
//                 'PKR ${commission.toStringAsFixed(0)} from seller',
//                 color: Colors.orange,
//               ),
//             const Divider(height: 20),

//             // Insurance toggle
//             Container(
//               decoration: BoxDecoration(
//                 color: _wantsInsurance
//                     ? Colors.blue.shade50
//                     : Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: _wantsInsurance
//                       ? Colors.blue.shade300
//                       : Colors.grey.shade300,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   SwitchListTile(
//                     value: _wantsInsurance,
//                     onChanged: (v) => setState(() => _wantsInsurance = v),
//                     activeColor: Colors.blue,
//                     title: const Text(
//                       'Add Insurance',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     subtitle: const Text(
//                       '+20% — Guaranteed completion & 3-day claim',
//                       style: TextStyle(fontSize: 11),
//                     ),
//                     secondary: Icon(
//                       Icons.shield_outlined,
//                       color: _wantsInsurance ? Colors.blue : Colors.grey,
//                     ),
//                   ),
//                   if (_wantsInsurance)
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                       child: Column(
//                         children: [
//                           const Divider(height: 1),
//                           const SizedBox(height: 8),
//                           _sheetRow(
//                             'Insurance (20%)',
//                             'PKR ${_insuranceAmount.toStringAsFixed(0)}',
//                             color: Colors.blue,
//                           ),
//                           _sheetRow(
//                             'Total You Pay',
//                             'PKR ${_totalAmount.toStringAsFixed(0)}',
//                             bold: true,
//                             color: Colors.blue.shade700,
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.orange.shade200),
//                             ),
//                             child: Text(
//                               '⚠️ Transfer PKR ${_totalAmount.toStringAsFixed(0)} to company account to activate.',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.orange.shade800,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             if (!_wantsInsurance)
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.payments_outlined,
//                       color: Colors.green.shade700,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Pay PKR ${_proposedAmount.toStringAsFixed(0)} in cash to the worker after job completion.',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.green.shade800,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isPlacing ? null : _placeOrder,
//                 icon: _isPlacing
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(Icons.check_circle_outline),
//                 label: Text(
//                   _isPlacing
//                       ? 'Placing Order...'
//                       : _wantsInsurance
//                       ? 'Place Insured Order (PKR ${_totalAmount.toStringAsFixed(0)})'
//                       : 'Place Order (Cash on Delivery)',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _wantsInsurance ? Colors.blue : Colors.teal,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sheetRow(
//     String label,
//     String value, {
//     Color? color,
//     bool bold = false,
//   }) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: color ?? Colors.black87,
//             fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             textAlign: TextAlign.end,
//             style: TextStyle(
//               fontSize: 13,
//               color: color ?? Colors.black87,
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // ═══════════════════════════════════════════════════════════════
// //  SUPPORTING WIDGETS
// // ═══════════════════════════════════════════════════════════════
// class _JobSummaryCard extends StatelessWidget {
//   final Map<String, dynamic> jobData;
//   const _JobSummaryCard({required this.jobData});

//   @override
//   Widget build(BuildContext context) {
//     final skills = List<String>.from(jobData['skills'] ?? []);
//     final budget = (jobData['budget'] ?? 0).toDouble();

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
//                   child: Text(
//                     jobData['title'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'PKR ${budget.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if ((jobData['description'] ?? '').isNotEmpty)
//               Text(
//                 jobData['description'],
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   height: 1.4,
//                 ),
//               ),
//             const SizedBox(height: 12),
//             _infoRow(Icons.location_on, jobData['location'] ?? 'No location'),
//             const SizedBox(height: 6),
//             _infoRow(Icons.schedule, jobData['timing'] ?? ''),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 6,
//               runSpacing: 4,
//               children: skills
//                   .map(
//                     (s) => Chip(
//                       label: Text(s, style: const TextStyle(fontSize: 11)),
//                       backgroundColor: Colors.teal.shade50,
//                       side: BorderSide(color: Colors.teal.shade200),
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String text) => Row(
//     children: [
//       Icon(icon, size: 14, color: Colors.grey[500]),
//       const SizedBox(width: 6),
//       Expanded(
//         child: Text(
//           text,
//           style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//         ),
//       ),
//     ],
//   );
// }

// class _AcceptedSellerCard extends StatelessWidget {
//   final String jobId;
//   final String? acceptedBidder;
//   const _AcceptedSellerCard({required this.jobId, this.acceptedBidder});

//   @override
//   Widget build(BuildContext context) {
//     if (acceptedBidder == null) return const SizedBox();
//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(acceptedBidder)
//           .get(),
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.teal),
//           );
//         }
//         final data = snap.data?.data() as Map<String, dynamic>? ?? {};
//         final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
//             .trim();
//         final rating = (data['Rating'] ?? 0).toDouble();
//         final image = data['profileImage'] as String?;

//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.teal.shade100,
//                   backgroundImage: image != null && image.isNotEmpty
//                       ? NetworkImage(image)
//                       : null,
//                   child: image == null || image.isEmpty
//                       ? Text(
//                           name.isNotEmpty ? name[0].toUpperCase() : 'S',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                             color: Colors.teal,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Icon(Icons.star, size: 14, color: Colors.amber[600]),
//                           const SizedBox(width: 4),
//                           Text(
//                             '$rating',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'In Progress',
//                     style: TextStyle(
//                       color: Colors.blue.shade700,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
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
//       case 'open':
//         color = Colors.orange;
//         label = 'Open';
//         break;
//       case 'in_progress':
//         color = Colors.blue;
//         label = 'In Progress';
//         break;
//       case 'pending_payment':
//         color = Colors.purple;
//         label = 'Awaiting Payment';
//         break;
//       case 'completed':
//         color = Colors.green;
//         label = 'Completed';
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         label = 'Cancelled';
//         break;
//       default:
//         color = Colors.grey;
//         label = status;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//           fontSize: 11,
//         ),
//       ),
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
//           Icon(Icons.work_off_outlined, size: 64, color: Colors.grey[300]),
//           const SizedBox(height: 12),
//           Text(
//             status == 'open'
//                 ? 'No open jobs'
//                 : status == 'in_progress'
//                 ? 'No jobs in progress'
//                 : 'No completed jobs',
//             style: TextStyle(fontSize: 16, color: Colors.grey[500]),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             status == 'open'
//                 ? 'Post a job to get competitive bids'
//                 : 'Place an order to get started',
//             style: TextStyle(fontSize: 12, color: Colors.grey[400]),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';

const int kFreeOrderLimit = 3;
const double kCommissionRate = 0.10;
const double kInsuranceRate = 0.20;
const double kSellerMinBalance = 500.0;

// ═══════════════════════════════════════════════════════════════
//  BUYER ORDERS PAGE
// ═══════════════════════════════════════════════════════════════
class BuyerOrdersPage extends StatefulWidget {
  final String? phoneUID;
  const BuyerOrdersPage({super.key, this.phoneUID});

  @override
  State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
}

class _BuyerOrdersPageState extends State<BuyerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _uid = _resolveUid();
    debugPrint('✅ BuyerOrdersPage UID: $_uid');
  }

  String _resolveUid() {
    final raw = widget.phoneUID ??
        UserSession().phoneUID ??
        UserSession().phone ??
        UserSession().uid ??
        '';
    return _normalizePhone(raw);
  }

  String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    final t = raw.trim();
    if (t.startsWith('+')) return t;
    if (RegExp(r'^\d+$').hasMatch(t)) return '+$t';
    return t;
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
        automaticallyImplyLeading: false,
        title: const Text('My Jobs',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      body: _uid.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text('Could not identify user',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Please log out and log in again.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            )
          : TabBarView(
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

// ─────────────────────────────────────────────────────────────
// Jobs List
// ─────────────────────────────────────────────────────────────
class _JobsList extends StatelessWidget {
  final String uid;
  final String status;
  const _JobsList({required this.uid, required this.status});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Querying jobs where postedBy == "$uid" && status == "$status"');

    return StreamBuilder<QuerySnapshot>(
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

        final docs = snapshot.data?.docs ?? [];
        debugPrint('📦 Jobs fetched for "$uid" status="$status": ${docs.length}');

        if (docs.isEmpty) return _EmptyState(status: status);

        final jobs = docs.toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['postedAt'] as Timestamp?;
            final bT = (b.data() as Map)['postedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jobs.length,
          itemBuilder: (context, i) {
            final data = jobs[i].data() as Map<String, dynamic>;
            return _JobCard(
                jobData: data, jobId: jobs[i].id, buyerUid: uid);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Job Card  ← THE FIX IS HERE
// ─────────────────────────────────────────────────────────────
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
    final title    = jobData['title']    ?? 'Untitled Job';
    final budget   = (jobData['budget'] ?? 0).toDouble();
    final location = jobData['location'] ?? 'No location';
    final timing   = jobData['timing']   ?? '';
    final status   = jobData['status']   ?? 'open';
    final bidsCount = jobData['bidsCount'] ?? 0;
    final skills   = List<String>.from(jobData['skills'] ?? []);
    final postedAt = jobData['postedAt'] as Timestamp?;
    final dateStr  = postedAt != null
        ? DateFormat('dd MMM yyyy').format(postedAt.toDate())
        : 'Just now';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _JobDetailPage(
              jobId: jobId, jobData: jobData, buyerUid: buyerUid),
        ),
      ),
      child: Container(
        width: double.infinity,           // bounded width ✅
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(location,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('PKR ${budget.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.teal)),
                      _StatusBadge(status: status),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timing row
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(timing,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600])),
                      ),
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Skills
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills
                        .take(4)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
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
                                      color: Colors.teal.shade700)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // ── Bottom row: bids counter + View Bids ──
                  // KEY FIX: ElevatedButton.icon wrapped in Flexible
                  // so it never gets BoxConstraints(w=Infinity)
                  Row(
                    children: [
                      // Bids chip — static count, no StreamBuilder
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bidsCount > 0
                              ? Colors.orange.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: bidsCount > 0
                                ? Colors.orange.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ✅ THE FIX: Flexible prevents w=Infinity
                      if (status == 'open')
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _JobDetailPage(
                                  jobId: jobId,
                                  jobData: jobData,
                                  buyerUid: buyerUid,
                                ),
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

// ═══════════════════════════════════════════════════════════════
//  JOB DETAIL PAGE
// ═══════════════════════════════════════════════════════════════
class _JobDetailPage extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String buyerUid;

  const _JobDetailPage({
    required this.jobId,
    required this.jobData,
    required this.buyerUid,
  });

  @override
  State<_JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<_JobDetailPage> {
  late Map<String, dynamic> _jobData;

  @override
  void initState() {
    super.initState();
    _jobData = Map<String, dynamic>.from(widget.jobData);
  }

  void _showEditDialog() {
    final titleCtrl =
        TextEditingController(text: _jobData['title'] ?? '');
    final descCtrl =
        TextEditingController(text: _jobData['description'] ?? '');
    final budgetCtrl = TextEditingController(
        text: (_jobData['budget'] ?? 0).toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Edit Job',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Job Title',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Maximum Budget (PKR)',
                    prefixText: 'PKR ',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newTitle = titleCtrl.text.trim();
                    final newDesc = descCtrl.text.trim();
                    final newBudget =
                        double.tryParse(budgetCtrl.text.trim()) ?? 0;
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(widget.jobId)
                        .update({
                      'title': newTitle,
                      'description': newDesc,
                      'budget': newBudget,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    setState(() {
                      _jobData['title'] = newTitle;
                      _jobData['description'] = newDesc;
                      _jobData['budget'] = newBudget;
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Job updated'),
                            backgroundColor: Colors.green),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Job?'),
        content: const Text('This will remove the job and all bids.'),
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
                  .doc(widget.jobId)
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

  @override
  Widget build(BuildContext context) {
    final status = _jobData['status'] ?? 'open';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(_jobData['title'] ?? 'Job Detail'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (status == 'open')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Job',
              onPressed: _showEditDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JobSummaryCard(jobData: _jobData),
            const SizedBox(height: 20),

            if (status == 'open') ...[
              Row(
                children: [
                  const Text('Bids Received',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(widget.jobId)
                        .collection('bids')
                        .snapshots(),
                    builder: (ctx, s) {
                      final count = s.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? Colors.orange.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: count > 0
                                  ? Colors.orange.shade300
                                  : Colors.grey.shade300),
                        ),
                        child: Text('$count bids',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: count > 0
                                    ? Colors.orange
                                    : Colors.grey)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _BidsList(
                  jobId: widget.jobId,
                  buyerUid: widget.buyerUid,
                  jobData: _jobData),
            ] else if (status == 'in_progress') ...[
              const Text('Accepted Worker',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _AcceptedSellerCard(
                  jobId: widget.jobId,
                  acceptedBidder: _jobData['acceptedBidder']),
            ] else if (status == 'pending_payment') ...[
              _PendingPaymentBanner(
                  jobData: _jobData, jobId: widget.jobId),
            ],

            if (status == 'open') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmCancel,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pending Payment Banner
// ─────────────────────────────────────────────────────────────
class _PendingPaymentBanner extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  const _PendingPaymentBanner(
      {required this.jobData, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final totalAmount = (jobData['totalAmount'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment Required to Activate Order',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Transfer PKR ${totalAmount.toStringAsFixed(0)} to the company account to activate this insured order.',
            style:
                TextStyle(fontSize: 13, color: Colors.orange.shade800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                _bankRow('Bank', 'HBL Bank'),
                _bankRow('Account Title', 'FixRight Pvt Ltd'),
                _bankRow('Account Number', '0123456789101112'),
                _bankRow('Amount',
                    'PKR ${totalAmount.toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8)),
            child: const Text(
              'Admin will verify and activate your order within a few hours.',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  BIDS LIST
// ═══════════════════════════════════════════════════════════════
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
              child: CircularProgressIndicator(color: Colors.teal));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.gavel, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text('No bids yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Sellers will bid shortly',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (ctx, i) {
            final bid =
                snap.data!.docs[i].data() as Map<String, dynamic>;
            return _BidCard(
                bid: bid,
                jobId: jobId,
                buyerUid: buyerUid,
                jobData: jobData);
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  BID CARD
// ═══════════════════════════════════════════════════════════════
class _BidCard extends StatefulWidget {
  final Map<String, dynamic> bid;
  final String jobId;
  final String buyerUid;
  final Map<String, dynamic> jobData;

  const _BidCard({
    required this.bid,
    required this.jobId,
    required this.buyerUid,
    required this.jobData,
  });

  @override
  State<_BidCard> createState() => _BidCardState();
}

class _BidCardState extends State<_BidCard> {
  bool _isAccepting = false;

  Future<Map<String, dynamic>> _getSellerInfo(String sellerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .get();
    final data = doc.data() ?? {};
    final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
    final availableBalance =
        (data['Available_Balance'] ?? 0).toDouble();
    final bool isFreeOrder = jobsCompleted < kFreeOrderLimit;
    final double proposedAmount =
        (widget.bid['proposedAmount'] ?? 0).toDouble();
    final double commissionAmount =
        isFreeOrder ? 0 : proposedAmount * kCommissionRate;
    final bool isEligible =
        isFreeOrder || availableBalance >= kSellerMinBalance;

    return {
      'isFreeOrder': isFreeOrder,
      'jobsCompleted': jobsCompleted,
      'freeOrdersLeft':
          isFreeOrder ? kFreeOrderLimit - jobsCompleted : 0,
      'availableBalance': availableBalance,
      'commissionAmount': commissionAmount,
      'isEligible': isEligible,
    };
  }

  void _showOrderConfirmationSheet(Map<String, dynamic> sellerInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OrderConfirmationSheet(
        bid: widget.bid,
        jobId: widget.jobId,
        jobData: widget.jobData,
        buyerUid: widget.buyerUid,
        sellerInfo: sellerInfo,
      ),
    );
  }

  Future<void> _openConversation(BuildContext ctx) async {
    final sellerId = widget.bid['sellerId'] as String;
    final sellerName = widget.bid['sellerName'] as String? ?? '';
    final sellerImage = widget.bid['sellerImage'] as String? ?? '';
    final db = FirebaseFirestore.instance;
    final phones = [widget.buyerUid, sellerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';

    final convDoc =
        await db.collection('conversations').doc(convId).get();
    if (!convDoc.exists) {
      final buyerDoc =
          await db.collection('users').doc(widget.buyerUid).get();
      final buyerData = buyerDoc.data() ?? {};
      final buyerName =
          '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
              .trim();
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
          widget.buyerUid: buyerData['profileImage'] ?? '',
          sellerId: sellerImage
        },
        'lastMessage': '',
        'lastMessageAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'unreadCounts': {widget.buyerUid: 0, sellerId: 0},
        'relatedJobId': widget.jobId,
        'relatedJobTitle': widget.jobData['title'] ?? '',
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Chat opened with $sellerName')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerName  = widget.bid['sellerName']  ?? 'Unknown';
    final sellerImage = widget.bid['sellerImage'] as String?;
    final proposedAmount =
        (widget.bid['proposedAmount'] ?? 0).toDouble();
    final proposal  = widget.bid['proposal']  ?? '';
    final rating    = (widget.bid['rating'] ?? 0.0).toDouble();
    final skills    = List<String>.from(widget.bid['skills'] ?? []);
    final bidStatus = widget.bid['status'] ?? 'pending';
    final createdAt = widget.bid['createdAt'] as Timestamp?;
    final sellerId  = widget.bid['sellerId'] as String? ?? '';

    final isAccepted = bidStatus == 'accepted';
    final isRejected = bidStatus == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller info row
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage:
                      sellerImage != null && sellerImage.isNotEmpty
                          ? NetworkImage(sellerImage)
                          : null,
                  child: sellerImage == null || sellerImage.isEmpty
                      ? Text(
                          sellerName.isNotEmpty
                              ? sellerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sellerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 13, color: Colors.amber[600]),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('PKR ${proposedAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)),
                    if (createdAt != null)
                      Text(
                          DateFormat('dd MMM, hh:mm a')
                              .format(createdAt.toDate()),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Eligibility chip
            FutureBuilder<Map<String, dynamic>>(
              future: _getSellerInfo(sellerId),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const LinearProgressIndicator(
                      minHeight: 2, color: Colors.teal);
                }
                final info = snap.data!;
                if (!info['isEligible']) {
                  return _infoChip(
                    '⚠️ Balance too low (PKR ${info['availableBalance'].toStringAsFixed(0)} / min PKR 500)',
                    Colors.red,
                  );
                } else if (info['isFreeOrder']) {
                  return _infoChip(
                    '🎁 Free order — ${info['freeOrdersLeft']} free left',
                    Colors.green,
                  );
                } else {
                  return _infoChip(
                    '10% commission (PKR ${info['commissionAmount'].toStringAsFixed(0)}) from seller',
                    Colors.orange,
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            if (proposal.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.grey.shade200)),
                child: Text(proposal,
                    style: const TextStyle(
                        fontSize: 13, height: 1.4)),
              ),

            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: skills
                    .take(4)
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.teal.shade200),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.teal.shade700)),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 14),

            if (isAccepted)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text('Bid Accepted — Order Placed',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else if (!isRejected)
              FutureBuilder<Map<String, dynamic>>(
                future: _getSellerInfo(sellerId),
                builder: (ctx, snap) {
                  final info = snap.data;
                  final isEligible = info?['isEligible'] ?? true;

                  // ✅ Both buttons in Expanded — always bounded
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openConversation(context),
                          icon: const Icon(
                              Icons.message_outlined,
                              size: 16),
                          label: const Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side:
                                const BorderSide(color: Colors.teal),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (!isEligible || _isAccepting)
                              ? null
                              : () =>
                                  _showOrderConfirmationSheet(info!),
                          icon: _isAccepting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Icon(
                                  Icons.check_circle_outline,
                                  size: 16),
                          label: Text(_isAccepting
                              ? 'Placing...'
                              : 'Place Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEligible
                                ? Colors.teal
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8)),
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600)),
      );
}

// ═══════════════════════════════════════════════════════════════
//  ORDER CONFIRMATION SHEET
// ═══════════════════════════════════════════════════════════════
class _OrderConfirmationSheet extends StatefulWidget {
  final Map<String, dynamic> bid;
  final String jobId;
  final Map<String, dynamic> jobData;
  final String buyerUid;
  final Map<String, dynamic> sellerInfo;

  const _OrderConfirmationSheet({
    required this.bid,
    required this.jobId,
    required this.jobData,
    required this.buyerUid,
    required this.sellerInfo,
  });

  @override
  State<_OrderConfirmationSheet> createState() =>
      _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState
    extends State<_OrderConfirmationSheet> {
  bool _wantsInsurance = false;
  bool _isPlacing = false;

  double get _proposedAmount =>
      (widget.bid['proposedAmount'] ?? 0).toDouble();
  double get _insuranceAmount =>
      _wantsInsurance ? (_proposedAmount * kInsuranceRate) : 0;
  double get _totalAmount => _proposedAmount + _insuranceAmount;

  Future<void> _placeOrder() async {
    setState(() => _isPlacing = true);
    try {
      final db = FirebaseFirestore.instance;
      final sellerId = widget.bid['sellerId'] as String;
      final sellerName = widget.bid['sellerName'] as String? ?? '';
      final sellerImage = widget.bid['sellerImage'] as String? ?? '';
      final isFreeOrder =
          widget.sellerInfo['isFreeOrder'] as bool;
      final commissionAmount =
          (widget.sellerInfo['commissionAmount'] as double);

      final batch = db.batch();
      final jobRef = db.collection('jobs').doc(widget.jobId);
      final newJobStatus =
          _wantsInsurance ? 'pending_payment' : 'in_progress';
      final claimDeadline =
          DateTime.now().add(const Duration(days: 3));

      batch.update(jobRef, {
        'status': newJobStatus,
        'acceptedBidder': sellerId,
        'acceptedAmount': _proposedAmount,
        'orderType': _wantsInsurance ? 'insured' : 'simple',
        'insuranceAmount': _insuranceAmount,
        'totalAmount': _totalAmount,
        'paymentStatus': _wantsInsurance
            ? 'pending_payment'
            : 'cash_on_delivery',
        'insuranceClaimed': false,
        'claimDeadline': _wantsInsurance
            ? null
            : Timestamp.fromDate(claimDeadline),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(jobRef.collection('bids').doc(sellerId),
          {'status': 'accepted'});

      final otherBids = await jobRef
          .collection('bids')
          .where('sellerId', isNotEqualTo: sellerId)
          .get();
      for (final d in otherBids.docs) {
        batch.update(d.reference, {'status': 'rejected'});
      }

      if (!isFreeOrder && commissionAmount > 0) {
        batch.update(db.collection('sellers').doc(sellerId), {
          'Available_Balance':
              FieldValue.increment(-commissionAmount),
          'Pending_Jobs': FieldValue.increment(1),
        });
      } else {
        batch.update(db.collection('sellers').doc(sellerId),
            {'Pending_Jobs': FieldValue.increment(1)});
      }

      final orderRef = db
          .collection('sellers')
          .doc(sellerId)
          .collection('orders')
          .doc(widget.jobId);

      batch.set(orderRef, {
        'orderId': widget.jobId,
        'jobId': widget.jobId,
        'jobTitle': widget.jobData['title'] ?? '',
        'jobDescription': widget.jobData['description'] ?? '',
        'jobLocation': widget.jobData['location'] ?? '',
        'skills': widget.jobData['skills'] ?? [],
        'buyerId': widget.buyerUid,
        'buyerName': '',
        'sellerId': sellerId,
        'sellerName': sellerName,
        'proposedAmount': _proposedAmount,
        'commissionDeducted': isFreeOrder ? 0 : commissionAmount,
        'isFreeOrder': isFreeOrder,
        'orderType': _wantsInsurance ? 'insured' : 'simple',
        'insuranceAmount': _insuranceAmount,
        'totalAmount': _totalAmount,
        'status': newJobStatus,
        'paymentStatus': _wantsInsurance
            ? 'pending_payment'
            : 'cash_on_delivery',
        'insuranceClaimed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      final buyerDoc =
          await db.collection('users').doc(widget.buyerUid).get();
      final buyerData = buyerDoc.data() ?? {};
      final buyerName =
          '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
              .trim();
      final buyerImage = buyerData['profileImage'] ?? '';
      await orderRef.update({'buyerName': buyerName});

      await _createConversation(db, sellerId, sellerName,
          sellerImage, buyerName,
          buyerImage: buyerImage);

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      final msg = _wantsInsurance
          ? '✅ Order placed! Transfer PKR ${_totalAmount.toStringAsFixed(0)} to activate.'
          : '✅ Order placed! Pay PKR ${_proposedAmount.toStringAsFixed(0)} cash on completion.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  Future<void> _createConversation(
      FirebaseFirestore db,
      String sellerId,
      String sellerName,
      String sellerImage,
      String buyerName,
      {required String buyerImage}) async {
    final phones = [widget.buyerUid, sellerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';
    final convDoc =
        await db.collection('conversations').doc(convId).get();
    if (convDoc.exists) return;
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
      'lastMessage': 'Order placed! Let\'s get started.',
      'lastMessageAt': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'unreadCounts': {widget.buyerUid: 0, sellerId: 1},
      'relatedJobId': widget.jobId,
      'relatedJobTitle': widget.jobData['title'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerName = widget.bid['sellerName'] ?? 'Seller';
    final isFreeOrder = widget.sellerInfo['isFreeOrder'] as bool;
    final commission =
        (widget.sellerInfo['commissionAmount'] as double);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Confirm Order',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Placing order with $sellerName',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),

            _sheetRow('Worker\'s Bid',
                'PKR ${_proposedAmount.toStringAsFixed(0)}'),
            if (isFreeOrder)
              _sheetRow(
                  'Commission',
                  'FREE (${widget.sellerInfo['freeOrdersLeft']} left)',
                  color: Colors.green)
            else
              _sheetRow('Commission (10%)',
                  'PKR ${commission.toStringAsFixed(0)} from seller',
                  color: Colors.orange),
            const Divider(height: 20),

            Container(
              decoration: BoxDecoration(
                color: _wantsInsurance
                    ? Colors.blue.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _wantsInsurance
                        ? Colors.blue.shade300
                        : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _wantsInsurance,
                    onChanged: (v) =>
                        setState(() => _wantsInsurance = v),
                    activeColor: Colors.blue,
                    title: const Text('Add Insurance',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    subtitle: const Text(
                        '+20% — Guaranteed completion & 3-day claim',
                        style: TextStyle(fontSize: 11)),
                    secondary: Icon(Icons.shield_outlined,
                        color: _wantsInsurance
                            ? Colors.blue
                            : Colors.grey),
                  ),
                  if (_wantsInsurance)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          _sheetRow('Insurance (20%)',
                              'PKR ${_insuranceAmount.toStringAsFixed(0)}',
                              color: Colors.blue),
                          _sheetRow(
                              'Total You Pay',
                              'PKR ${_totalAmount.toStringAsFixed(0)}',
                              bold: true,
                              color: Colors.blue.shade700),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange.shade200),
                            ),
                            child: Text(
                              '⚠️ Transfer PKR ${_totalAmount.toStringAsFixed(0)} to company account to activate.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!_wantsInsurance)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payments_outlined,
                        color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pay PKR ${_proposedAmount.toStringAsFixed(0)} in cash after job completion.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPlacing ? null : _placeOrder,
                icon: _isPlacing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isPlacing
                      ? 'Placing Order...'
                      : _wantsInsurance
                          ? 'Place Insured Order (PKR ${_totalAmount.toStringAsFixed(0)})'
                          : 'Place Order (Cash on Delivery)',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _wantsInsurance ? Colors.blue : Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(String label, String value,
      {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.black87,
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 13,
                      color: color ?? Colors.black87,
                      fontWeight: bold
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  SUPPORTING WIDGETS (unchanged)
// ═══════════════════════════════════════════════════════════════
class _JobSummaryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const _JobSummaryCard({required this.jobData});

  @override
  Widget build(BuildContext context) {
    final skills = List<String>.from(jobData['skills'] ?? []);
    final budget = (jobData['budget'] ?? 0).toDouble();

    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Text('PKR ${budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 8),
            if ((jobData['description'] ?? '').isNotEmpty)
              Text(jobData['description'],
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4)),
            const SizedBox(height: 12),
            _infoRow(
                Icons.location_on, jobData['location'] ?? 'No location'),
            const SizedBox(height: 6),
            _infoRow(Icons.schedule, jobData['timing'] ?? ''),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: skills
                  .map((s) => Chip(
                        label: Text(s,
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.teal.shade50,
                        side: BorderSide(color: Colors.teal.shade200),
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

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[600]))),
        ],
      );
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
              child: CircularProgressIndicator(color: Colors.teal));
        }
        final data =
            snap.data?.data() as Map<String, dynamic>? ?? {};
        final name =
            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                .trim();
        final rating = (data['Rating'] ?? 0).toDouble();
        final image = data['profileImage'] as String?;

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
                  backgroundImage: image != null && image.isNotEmpty
                      ? NetworkImage(image)
                      : null,
                  child: image == null || image.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.teal))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 14, color: Colors.amber[600]),
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
                      borderRadius: BorderRadius.circular(20)),
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
      case 'open':            color = Colors.orange; label = 'Open';            break;
      case 'in_progress':     color = Colors.blue;   label = 'In Progress';     break;
      case 'pending_payment': color = Colors.purple; label = 'Awaiting Payment'; break;
      case 'completed':       color = Colors.green;  label = 'Completed';        break;
      case 'cancelled':       color = Colors.red;    label = 'Cancelled';        break;
      default:                color = Colors.grey;   label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20)),
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
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            status == 'open'
                ? 'No open jobs'
                : status == 'in_progress'
                    ? 'No jobs in progress'
                    : 'No completed jobs',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Text(
            status == 'open'
                ? 'Post a job to get competitive bids'
                : 'Place an order to get started',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}