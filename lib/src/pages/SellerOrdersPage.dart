// // import 'package:flutter/material.dart';

// // class Order {
// //   final String id;
// //   final String title;
// //   final String price;
// //   final String description;
// //   final String sellerId;
// //   final String orderstatus;
// //   final String time;
// //   final String proImg;

// //   const Order({
// //     required this.id,
// //     required this.title,
// //     required this.price,
// //     required this.description,
// //     required this.sellerId,
// //     required this.orderstatus,
// //     required this.time,
// //     required this.proImg,
// //   });
// // }

// // class ManageOrdersScreen extends StatelessWidget {
// //   final String? phoneUID;

// //   const ManageOrdersScreen({super.key, this.phoneUID});

// //   final List<Order> orders = const [
// //     Order(
// //       id: 'ORD1001',
// //       title: 'Pro Java Developer',
// //       price: "30",
// //       description:
// //           'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
// //       sellerId: 'Simmon07',
// //       orderstatus: 'Completed',
// //       time: 'Feb 18, 2024',
// //       proImg: 'https://i.imgur.com/x3M7QyJ.png',
// //     ),
// //     Order(
// //       id: 'ORD1002',
// //       title: 'Pro Java Developer',
// //       price: "10",
// //       description:
// //           'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
// //       sellerId: 'Simmon07',
// //       orderstatus: 'Completed',
// //       time: 'Feb 18, 2024',
// //       proImg: 'https://i.imgur.com/x3M7QyJ.png',
// //     ),
// //     Order(
// //       id: 'ORD1003',
// //       title: 'Pro Java Developer',
// //       price: "5",
// //       description:
// //           'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
// //       sellerId: 'Simmon07',
// //       orderstatus: 'Completed',
// //       time: 'Feb 18, 2024',
// //       proImg: 'https://i.imgur.com/x3M7QyJ.png',
// //     ),
// //   ];

// //   Widget _buildOrderCard(BuildContext context, Order order) {
// //     return GestureDetector(
// //       onTap: () {
// //         Navigator.of(context).push(
// //           MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
// //         );
// //       },
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.06),
// //               blurRadius: 6,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // top section with image, price and description
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(8),
// //                   child: Image.network(
// //                     order.proImg,
// //                     height: 60,
// //                     width: 80,
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         "\$${order.price}",
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         order.description,
// //                         maxLines: 2,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: const TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 10),

// //             // seller info + status chip
// //             Row(
// //               children: [
// //                 const CircleAvatar(
// //                   radius: 12,
// //                   backgroundImage: NetworkImage(
// //                     'https://i.imgur.com/Yy6zO7R.png',
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   order.sellerId,
// //                   style: const TextStyle(fontSize: 13, color: Colors.black87),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 10,
// //                     vertical: 4,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.green.shade100,
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     order.orderstatus.toUpperCase(),
// //                     style: const TextStyle(
// //                       color: Colors.green,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F8F8),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         title: const Text(
// //           'Manage orders',
// //           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
// //         ),
// //         actions: const [
// //           Icon(Icons.notifications_none, color: Colors.black),
// //           SizedBox(width: 15),
// //           Icon(Icons.filter_list, color: Colors.black),
// //           SizedBox(width: 10),
// //         ],
// //       ),
// //       body: ListView.builder(
// //         padding: const EdgeInsets.only(bottom: 20, top: 8),
// //         itemCount: orders.length,
// //         itemBuilder: (context, index) =>
// //             _buildOrderCard(context, orders[index]),
// //       ),
// //     );
// //   }
// // }

// // class OrderDetailsScreen extends StatefulWidget {
// //   final Order order;
// //   const OrderDetailsScreen({super.key, required this.order});

// //   @override
// //   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// // }

// // class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
// //   // state to control expansions if you want (optional)
// //   final Map<String, bool> _expanded = {
// //     'orderCompleted': false,
// //     'myReview': false,
// //     'buyerReview': false,
// //     'youDelivered': false,
// //     'orderRequirements': true,
// //     'orderCreated': false,
// //   };

// //   Widget _timelineDot(IconData icon, {Color? color}) {
// //     return Container(
// //       width: 36,
// //       height: 36,
// //       decoration: BoxDecoration(
// //         color: color ?? Colors.white,
// //         border: Border.all(color: Colors.grey.shade300),
// //         borderRadius: BorderRadius.circular(10),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.05),
// //             blurRadius: 4,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Icon(icon, size: 18, color: Colors.black54),
// //     );
// //   }

// //   Widget _buildSectionTitle(String title, {String? subtitle}) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Text(
// //               title,
// //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
// //             ),
// //           ),
// //           if (subtitle != null)
// //             Text(
// //               subtitle,
// //               style: const TextStyle(fontSize: 13, color: Colors.black54),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _attachmentTile(String name) {
// //     return ListTile(
// //       contentPadding: EdgeInsets.zero,
// //       leading: const Icon(Icons.insert_drive_file_outlined),
// //       title: Text(name),
// //       subtitle: const Text('docx • 24 KB'),
// //       trailing: IconButton(
// //         onPressed: () {
// //           // TODO: download/open file
// //         },
// //         icon: const Icon(Icons.download_rounded),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final order = widget.order;

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F8F8),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         title: Text(
// //           order.sellerId,
// //           style: const TextStyle(
// //             color: Colors.black,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black87),
// //           onPressed: () => Navigator.of(context).pop(),
// //         ),
// //         actions: const [
// //           Icon(Icons.more_vert, color: Colors.black87),
// //           SizedBox(width: 8),
// //         ],
// //       ),
// //       body: Stack(
// //         children: [
// //           ListView(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
// //             children: [
// //               // top card with thumbnail, title, price, status
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     ClipRRect(
// //                       borderRadius: BorderRadius.circular(8),
// //                       child: Image.network(
// //                         order.proImg,
// //                         height: 70,
// //                         width: 92,
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             order.title,
// //                             style: const TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Text(
// //                             order.description,
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: const TextStyle(fontSize: 13),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Row(
// //                             children: [
// //                               Container(
// //                                 padding: const EdgeInsets.symmetric(
// //                                   horizontal: 8,
// //                                   vertical: 5,
// //                                 ),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.green.shade100,
// //                                   borderRadius: BorderRadius.circular(20),
// //                                 ),
// //                                 child: Text(
// //                                   order.orderstatus.toUpperCase(),
// //                                   style: const TextStyle(
// //                                     color: Colors.green,
// //                                     fontWeight: FontWeight.bold,
// //                                     fontSize: 12,
// //                                   ),
// //                                 ),
// //                               ),
// //                               const Spacer(),
// //                               Text(
// //                                 '\$${order.price}',
// //                                 style: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 16,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 14),

// //               // timeline / events
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // left timeline column
// //                     Column(
// //                       children: [
// //                         _timelineDot(Icons.check_box, color: Colors.white),
// //                         Container(
// //                           width: 2,
// //                           height: 26,
// //                           color: Colors.grey.shade300,
// //                         ),
// //                         _timelineDot(Icons.star_border),
// //                         Container(
// //                           width: 2,
// //                           height: 26,
// //                           color: Colors.grey.shade300,
// //                         ),
// //                         _timelineDot(Icons.person_outline),
// //                         Container(
// //                           width: 2,
// //                           height: 26,
// //                           color: Colors.grey.shade300,
// //                         ),
// //                         _timelineDot(Icons.calendar_today),
// //                         Container(
// //                           width: 2,
// //                           height: 26,
// //                           color: Colors.grey.shade300,
// //                         ),
// //                         _timelineDot(Icons.event_note),
// //                       ],
// //                     ),

// //                     const SizedBox(width: 12),

// //                     // right detail column
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           // completed
// //                           ExpansionTile(
// //                             initiallyExpanded: _expanded['orderCompleted']!,
// //                             onExpansionChanged: (v) =>
// //                                 setState(() => _expanded['orderCompleted'] = v),
// //                             title: const Text(
// //                               'The order was completed',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             subtitle: const Text(
// //                               'You earned \$4 for this order. Great job, Ayazengima!',
// //                             ),
// //                             children: [
// //                               ListTile(
// //                                 leading: const Icon(Icons.info_outline),
// //                                 title: const Text('Order details'),
// //                                 subtitle: const Text(
// //                                   'Completed on Feb 19, 2024 • Delivered',
// //                                 ),
// //                               ),
// //                             ],
// //                           ),

// //                           // my review
// //                           ExpansionTile(
// //                             initiallyExpanded: _expanded['myReview']!,
// //                             onExpansionChanged: (v) =>
// //                                 setState(() => _expanded['myReview'] = v),
// //                             title: const Text(
// //                               'My review',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             children: [
// //                               Padding(
// //                                 padding: const EdgeInsets.symmetric(
// //                                   horizontal: 16,
// //                                   vertical: 8,
// //                                 ),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: const [
// //                                     Text('You haven\'t left a review yet.'),
// //                                     SizedBox(height: 8),
// //                                     Text('Rate the buyer and leave feedback.'),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),

// //                           // buyer review
// //                           ExpansionTile(
// //                             initiallyExpanded: _expanded['buyerReview']!,
// //                             onExpansionChanged: (v) =>
// //                                 setState(() => _expanded['buyerReview'] = v),
// //                             title: const Text(
// //                               'Buyer review',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             children: const [
// //                               Padding(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 16,
// //                                   vertical: 8,
// //                                 ),
// //                                 child: Text(
// //                                   'Buyer left a 5-star review. Great communication',
// //                                 ),
// //                               ),
// //                             ],
// //                           ),

// //                           // delivered
// //                           ExpansionTile(
// //                             initiallyExpanded: _expanded['youDelivered']!,
// //                             onExpansionChanged: (v) =>
// //                                 setState(() => _expanded['youDelivered'] = v),
// //                             title: const Text(
// //                               'You delivered the order',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             children: const [
// //                               Padding(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 16,
// //                                   vertical: 8,
// //                                 ),
// //                                 child: Text('Delivered files attached below.'),
// //                               ),
// //                             ],
// //                           ),

// //                           // delivery date
// //                           ListTile(
// //                             contentPadding: EdgeInsets.zero,
// //                             title: const Text(
// //                               'Your delivery date was updated to 2/19/24',
// //                             ),
// //                           ),

// //                           // Order started (collapsible)
// //                           ExpansionTile(
// //                             initiallyExpanded:
// //                                 _expanded['orderStarted'] ?? false,
// //                             title: const Text(
// //                               'Order started',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             children: const [
// //                               Padding(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 16,
// //                                   vertical: 8,
// //                                 ),
// //                                 child: Text('Order started on Feb 12, 2024'),
// //                               ),
// //                             ],
// //                           ),

// //                           const Divider(),

// //                           // Order Requirements submitted (big section)
// //                           _buildSectionTitle(
// //                             'Order requirements submitted',
// //                             subtitle: '',
// //                           ),
// //                           const SizedBox(height: 8),

// //                           // A list of typical Q/A fields like Fiverr
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 6,
// //                               vertical: 8,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Colors.grey.shade50,
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 const Text(
// //                                   'What is the purpose of your project?',
// //                                   style: TextStyle(fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 const Text(
// //                                   'As we discuss',
// //                                   style: TextStyle(color: Colors.black54),
// //                                 ),
// //                                 const SizedBox(height: 10),
// //                                 const Text(
// //                                   'Can you provide a detailed description of your project?',
// //                                   style: TextStyle(fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 6),
// //                                 _attachmentTile('Assignment 2.docx'),
// //                                 const SizedBox(height: 6),
// //                                 const Text(
// //                                   'Who is your target audience or end-users?',
// //                                   style: TextStyle(fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 const Text(
// //                                   'As we discuss',
// //                                   style: TextStyle(color: Colors.black54),
// //                                 ),
// //                                 const SizedBox(height: 10),
// //                                 const Text(
// //                                   'Do you have any design preferences or examples in mind? Note create pdf file and attach images that clearly explain your ideas or design',
// //                                   style: TextStyle(fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 6),
// //                                 _attachmentTile('Design-Reference.pdf'),
// //                                 const SizedBox(height: 10),
// //                                 const Text(
// //                                   'Any additional information you want to give',
// //                                   style: TextStyle(fontWeight: FontWeight.bold),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 const Text(
// //                                   'As we discuss',
// //                                   style: TextStyle(color: Colors.black54),
// //                                 ),
// //                                 const SizedBox(height: 8),
// //                               ],
// //                             ),
// //                           ),

// //                           const SizedBox(height: 12),

// //                           // Order created section
// //                           ExpansionTile(
// //                             initiallyExpanded: _expanded['orderCreated']!,
// //                             onExpansionChanged: (v) =>
// //                                 setState(() => _expanded['orderCreated'] = v),
// //                             title: const Text(
// //                               'Order created',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             children: const [
// //                               Padding(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 16,
// //                                   vertical: 8,
// //                                 ),
// //                                 child: Text(
// //                                   'Order created on Feb 12, 2024 by Simmon07',
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),

// //           // floating message bubble with avatar positioned bottom right
// //           Positioned(
// //             right: 16,
// //             bottom: 18,
// //             child: GestureDetector(
// //               onTap: () {
// //                 // Open chat
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(content: Text('Open chat / message screen')),
// //                 );
// //               },
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 12,
// //                   vertical: 8,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(28),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.08),
// //                       blurRadius: 14,
// //                       offset: const Offset(0, 6),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const CircleAvatar(
// //                       radius: 18,
// //                       backgroundImage: NetworkImage(
// //                         'https://i.imgur.com/Yy6zO7R.png',
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     const Text(
// //                       'Message',
// //                       style: TextStyle(fontWeight: FontWeight.w600),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../../services/user_session.dart';

// class SellerOrdersPage extends StatefulWidget {
//   final String? phoneUID;
//   const SellerOrdersPage({super.key, this.phoneUID});

//   @override
//   State<SellerOrdersPage> createState() => _SellerOrdersPageState();
// }

// class _SellerOrdersPageState extends State<SellerOrdersPage>
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
//         backgroundColor: Colors.green.shade700,
//         foregroundColor: Colors.white,
//         elevation: 1,
//         title: const Text('Find Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white60,
//           tabs: const [
//             Tab(text: 'Open Jobs'),
//             Tab(text: 'My Bids'),
//             Tab(text: 'Active'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _OpenJobsList(sellerUid: _uid),
//           _MyBidsList(sellerUid: _uid),
//           _ActiveJobsList(sellerUid: _uid),
//         ],
//       ),
//     );
//   }
// }

// // ── Open Jobs (all open jobs, seller can bid) ─────────────────
// class _OpenJobsList extends StatefulWidget {
//   final String sellerUid;
//   const _OpenJobsList({required this.sellerUid});

//   @override
//   State<_OpenJobsList> createState() => _OpenJobsListState();
// }

// class _OpenJobsListState extends State<_OpenJobsList> {
//   String _searchQuery = '';
//   final _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Search bar
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.all(12),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search jobs by title or skill...',
//               prefixIcon: const Icon(Icons.search, color: Colors.green),
//               suffixIcon: _searchQuery.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () {
//                         _searchController.clear();
//                         setState(() => _searchQuery = '');
//                       },
//                     )
//                   : null,
//               filled: true,
//               fillColor: Colors.grey.shade100,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             ),
//             onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
//           ),
//         ),

//         // Jobs list
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('jobs')
//                 .where('status', isEqualTo: 'open')
//                 .orderBy('postedAt', descending: true)
//                 .snapshots(),
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator(color: Colors.green));
//               }
//               if (!snap.hasData || snap.data!.docs.isEmpty) {
//                 return _SellerEmptyState(
//                   icon: Icons.work_outline,
//                   message: 'No open jobs right now',
//                   subtitle: 'Check back soon for new jobs',
//                 );
//               }

//               var docs = snap.data!.docs.where((d) {
//                 final data = d.data() as Map<String, dynamic>;
//                 // Filter out seller's own jobs
//                 if (data['postedBy'] == widget.sellerUid) return false;
//                 // Search filter
//                 if (_searchQuery.isNotEmpty) {
//                   final title = (data['title'] ?? '').toString().toLowerCase();
//                   final skills = List<String>.from(data['skills'] ?? [])
//                       .join(' ').toLowerCase();
//                   return title.contains(_searchQuery) || skills.contains(_searchQuery);
//                 }
//                 return true;
//               }).toList();

//               if (docs.isEmpty) {
//                 return _SellerEmptyState(
//                   icon: Icons.search_off,
//                   message: 'No jobs match your search',
//                   subtitle: 'Try different keywords',
//                 );
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.all(12),
//                 itemCount: docs.length,
//                 itemBuilder: (ctx, i) {
//                   final data = docs[i].data() as Map<String, dynamic>;
//                   return _OpenJobCard(
//                     jobId: docs[i].id,
//                     jobData: data,
//                     sellerUid: widget.sellerUid,
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _OpenJobCard extends StatelessWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;

//   const _OpenJobCard({required this.jobId, required this.jobData, required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     final title = jobData['title'] ?? 'Untitled';
//     final budget = jobData['budget'] ?? 0;
//     final location = jobData['location'] ?? '';
//     final timing = jobData['timing'] ?? '';
//     final skills = List<String>.from(jobData['skills'] ?? []);
//     final posterName = jobData['posterName'] ?? 'Unknown Client';
//     final bidsCount = jobData['bidsCount'] ?? 0;
//     final postedAt = jobData['postedAt'] as Timestamp?;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 4),
//                       Text('by $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'PKR ${budget.toStringAsFixed(0)}',
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700),
//                     ),
//                     Text('Max Budget', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
//                     const SizedBox(width: 4),
//                     Expanded(child: Text(location.isNotEmpty ? location : 'Location not specified',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
//                     Icon(Icons.schedule, size: 13, color: Colors.grey[500]),
//                     const SizedBox(width: 4),
//                     Text(timing, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 // Skills
//                 Wrap(
//                   spacing: 6, runSpacing: 4,
//                   children: skills.take(4).map((s) => Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.green.shade200),
//                         ),
//                         child: Text(s, style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
//                       )).toList(),
//                 ),
//                 const SizedBox(height: 10),

//                 Row(
//                   children: [
//                     Text(
//                       '$bidsCount competing bids',
//                       style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.w600),
//                     ),
//                     if (postedAt != null)
//                       Text(
//                         '  •  ${DateFormat('dd MMM').format(postedAt.toDate())}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       ),
//                     const Spacer(),

//                     // Check if already bid
//                     FutureBuilder<DocumentSnapshot>(
//                       future: FirebaseFirestore.instance
//                           .collection('jobs')
//                           .doc(jobId)
//                           .collection('bids')
//                           .doc(sellerUid)
//                           .get(),
//                       builder: (ctx, bidSnap) {
//                         final alreadyBid = bidSnap.data?.exists ?? false;
//                         return ElevatedButton.icon(
//                           onPressed: alreadyBid
//                               ? null
//                               : () => _showBidDialog(context),
//                           icon: Icon(alreadyBid ? Icons.check : Icons.gavel, size: 16),
//                           label: Text(alreadyBid ? 'Bid Placed' : 'Place Bid'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: alreadyBid ? Colors.grey : Colors.green.shade700,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                             disabledBackgroundColor: Colors.grey.shade300,
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showBidDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _PlaceBidSheet(
//         jobId: jobId,
//         jobData: jobData,
//         sellerUid: sellerUid,
//       ),
//     );
//   }
// }

// // ── Place Bid Bottom Sheet ─────────────────────────────────────
// class _PlaceBidSheet extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;

//   const _PlaceBidSheet({required this.jobId, required this.jobData, required this.sellerUid});

//   @override
//   State<_PlaceBidSheet> createState() => _PlaceBidSheetState();
// }

// class _PlaceBidSheetState extends State<_PlaceBidSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _proposalController = TextEditingController();
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _proposalController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitBid() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSubmitting = true);

//     try {
//       final db = FirebaseFirestore.instance;
//       final amount = double.parse(_amountController.text.trim());
//       final budget = (widget.jobData['budget'] ?? 0).toDouble();

//       if (amount > budget) {
//         _showSnack('Your bid cannot exceed the buyer\'s budget of PKR ${budget.toStringAsFixed(0)}', Colors.red);
//         setState(() => _isSubmitting = false);
//         return;
//       }

//       // Get seller info
//       final sellerDoc = await db.collection('sellers').doc(widget.sellerUid).get();
//       final sellerData = sellerDoc.data() ?? {};
//       final userDoc = await db.collection('users').doc(widget.sellerUid).get();
//       final userData = userDoc.data() ?? {};

//       final sellerName = '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim();
//       final sellerImage = userData['profileImage'] ?? '';
//       final rating = (sellerData['Rating'] ?? 0).toDouble();
//       final skills = List<String>.from(sellerData['skills'] ?? []);

//       final batch = db.batch();

//       // 1. Write bid to subcollection (doc ID = sellerUid for easy lookup)
//       final bidRef = db.collection('jobs').doc(widget.jobId).collection('bids').doc(widget.sellerUid);
//       batch.set(bidRef, {
//         'sellerId': widget.sellerUid,
//         'sellerName': sellerName,
//         'sellerImage': sellerImage,
//         'rating': rating,
//         'skills': skills,
//         'proposedAmount': amount,
//         'proposal': _proposalController.text.trim(),
//         'status': 'pending', // pending | accepted | rejected
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       // 2. Increment bidsCount on job
//       final jobRef = db.collection('jobs').doc(widget.jobId);
//       batch.update(jobRef, {'bidsCount': FieldValue.increment(1)});

//       await batch.commit();

//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Bid placed successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       _showSnack('Error placing bid: $e', Colors.red);
//       setState(() => _isSubmitting = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final budget = widget.jobData['budget'] ?? 0;
//     final title = widget.jobData['title'] ?? '';

//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Handle
//               Center(
//                 child: Container(
//                   width: 40, height: 4,
//                   decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Text('Place a Bid', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               Text('For: $title', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: Text(
//                   'Buyer\'s Max Budget: PKR ${budget.toStringAsFixed(0)}',
//                   style: TextStyle(fontSize: 13, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: InputDecoration(
//                   labelText: 'Your Bid Amount (PKR)',
//                   prefixText: 'PKR ',
//                   prefixIcon: const Icon(Icons.payments_outlined, color: Colors.green),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   helperText: 'Bid competitively to win this job',
//                 ),
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Enter your bid amount';
//                   final amt = double.tryParse(v);
//                   if (amt == null || amt <= 0) return 'Enter a valid amount';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: _proposalController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Your Proposal (Why hire you?)',
//                   prefixIcon: const Icon(Icons.description_outlined, color: Colors.green),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   helperText: 'Describe your experience and approach',
//                 ),
//                 validator: (v) => v == null || v.trim().isEmpty ? 'Write a brief proposal' : null,
//               ),
//               const SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _isSubmitting ? null : _submitBid,
//                   icon: _isSubmitting
//                       ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                       : const Icon(Icons.gavel),
//                   label: Text(_isSubmitting ? 'Submitting...' : 'Submit Bid',
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: Colors.grey.shade300,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── My Bids Tab ────────────────────────────────────────────────
// class _MyBidsList extends StatelessWidget {
//   final String sellerUid;
//   const _MyBidsList({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     // Query all jobs and check bids subcollection using collectionGroup
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collectionGroup('bids')
//           .where('sellerId', isEqualTo: sellerUid)
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.green));
//         }
//         if (!snap.hasData || snap.data!.docs.isEmpty) {
//           return _SellerEmptyState(
//             icon: Icons.gavel,
//             message: 'No bids placed yet',
//             subtitle: 'Browse open jobs and place your first bid',
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: snap.data!.docs.length,
//           itemBuilder: (ctx, i) {
//             final bid = snap.data!.docs[i].data() as Map<String, dynamic>;
//             final jobId = snap.data!.docs[i].reference.parent.parent!.id;
//             return _MyBidCard(bid: bid, jobId: jobId);
//           },
//         );
//       },
//     );
//   }
// }

// class _MyBidCard extends StatelessWidget {
//   final Map<String, dynamic> bid;
//   final String jobId;
//   const _MyBidCard({required this.bid, required this.jobId});

//   @override
//   Widget build(BuildContext context) {
//     final amount = bid['proposedAmount'] ?? 0;
//     final proposal = bid['proposal'] ?? '';
//     final status = bid['status'] ?? 'pending';
//     final createdAt = bid['createdAt'] as Timestamp?;

//     Color statusColor;
//     IconData statusIcon;
//     switch (status) {
//       case 'accepted': statusColor = Colors.green; statusIcon = Icons.check_circle; break;
//       case 'rejected': statusColor = Colors.red; statusIcon = Icons.cancel; break;
//       default: statusColor = Colors.orange; statusIcon = Icons.hourglass_empty;
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
//       builder: (context, snap) {
//         final jobData = snap.data?.data() as Map<String, dynamic>? ?? {};
//         final jobTitle = jobData['title'] ?? 'Loading...';
//         final posterName = jobData['posterName'] ?? '';
//         final jobBudget = jobData['budget'] ?? 0;

//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: status == 'accepted' ? Colors.green.shade200 : Colors.grey.shade200,
//             ),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(jobTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//                           if (posterName.isNotEmpty)
//                             Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(statusIcon, size: 12, color: statusColor),
//                           const SizedBox(width: 4),
//                           Text(status.toUpperCase(),
//                               style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 16),
//                 Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Your Bid', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//                         Text(
//                           'PKR ${amount.toStringAsFixed(0)}',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 20),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Job Budget', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//                         Text(
//                           'PKR ${jobBudget.toStringAsFixed(0)}',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     if (createdAt != null)
//                       Text(
//                         DateFormat('dd MMM').format(createdAt.toDate()),
//                         style: TextStyle(fontSize: 11, color: Colors.grey[500]),
//                       ),
//                   ],
//                 ),
//                 if (proposal.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                     child: Text(proposal, style: const TextStyle(fontSize: 13)),
//                   ),
//                 ],
//                 if (status == 'accepted') ...[
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.celebration, color: Colors.green.shade600, size: 16),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Your bid was accepted! Contact the client to start.',
//                             style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Active Jobs Tab ────────────────────────────────────────────
// class _ActiveJobsList extends StatelessWidget {
//   final String sellerUid;
//   const _ActiveJobsList({required this.sellerUid});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('jobs')
//           .where('acceptedBidder', isEqualTo: sellerUid)
//           .where('status', isEqualTo: 'in_progress')
//           .orderBy('updatedAt', descending: true)
//           .snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.green));
//         }
//         if (!snap.hasData || snap.data!.docs.isEmpty) {
//           return _SellerEmptyState(
//             icon: Icons.construction,
//             message: 'No active jobs',
//             subtitle: 'Win a bid to start working',
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(12),
//           itemCount: snap.data!.docs.length,
//           itemBuilder: (ctx, i) {
//             final data = snap.data!.docs[i].data() as Map<String, dynamic>;
//             final jobId = snap.data!.docs[i].id;
//             return _ActiveJobCard(jobId: jobId, jobData: data, sellerUid: sellerUid);
//           },
//         );
//       },
//     );
//   }
// }

// class _ActiveJobCard extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;
//   final String sellerUid;

//   const _ActiveJobCard({required this.jobId, required this.jobData, required this.sellerUid});

//   @override
//   State<_ActiveJobCard> createState() => _ActiveJobCardState();
// }

// class _ActiveJobCardState extends State<_ActiveJobCard> {
//   bool _isCompleting = false;

//   Future<void> _markCompleted() async {
//     setState(() => _isCompleting = true);
//     try {
//       final db = FirebaseFirestore.instance;
//       final batch = db.batch();

//       // Update job
//       batch.update(db.collection('jobs').doc(widget.jobId), {
//         'status': 'completed',
//         'completedAt': FieldValue.serverTimestamp(),
//       });

//       // Update seller stats
//       batch.update(db.collection('sellers').doc(widget.sellerUid), {
//         'Jobs_Completed': FieldValue.increment(1),
//         'Pending_Jobs': FieldValue.increment(-1),
//         'Total_Jobs': FieldValue.increment(1),
//         'Earning': FieldValue.increment(widget.jobData['acceptedAmount'] ?? 0),
//         'Available_Balance': FieldValue.increment(widget.jobData['acceptedAmount'] ?? 0),
//       });

//       await batch.commit();

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('🎉 Job marked as completed!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       _showSnack('Error: $e', Colors.red);
//     } finally {
//       if (mounted) setState(() => _isCompleting = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.jobData['title'] ?? '';
//     final posterName = widget.jobData['posterName'] ?? 'Client';
//     final acceptedAmount = widget.jobData['acceptedAmount'] ?? 0;
//     final skills = List<String>.from(widget.jobData['skills'] ?? []);
//     final location = widget.jobData['location'] ?? '';
//     final buyerId = widget.jobData['postedBy'] ?? '';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.blue.shade100, width: 1.5),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       Text('Client: $posterName', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text('PKR ${acceptedAmount.toStringAsFixed(0)}',
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700)),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
//                       child: const Text('In Progress', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (location.isNotEmpty) ...[
//                   Row(children: [
//                     Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
//                     const SizedBox(width: 4),
//                     Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
//                   ]),
//                   const SizedBox(height: 8),
//                 ],
//                 Wrap(
//                   spacing: 6, runSpacing: 4,
//                   children: skills.take(3).map((s) => Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.blue.shade200),
//                         ),
//                         child: Text(s, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
//                       )).toList(),
//                 ),
//                 const SizedBox(height: 14),

//                 Row(
//                   children: [
//                     // Message client
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () => _openChat(context, buyerId, posterName),
//                         icon: const Icon(Icons.message_outlined, size: 16),
//                         label: const Text('Message Client'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.blue,
//                           side: const BorderSide(color: Colors.blue),
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     // Mark completed
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _isCompleting ? null : _markCompleted,
//                         icon: _isCompleting
//                             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                             : const Icon(Icons.check_circle_outline, size: 16),
//                         label: Text(_isCompleting ? 'Updating...' : 'Mark Done'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openChat(BuildContext context, String buyerId, String buyerName) async {
//     if (buyerId.isEmpty) return;

//     final db = FirebaseFirestore.instance;
//     final phones = [widget.sellerUid, buyerId]..sort();
//     final convId = '${phones[0]}_${phones[1]}';

//     final convDoc = await db.collection('conversations').doc(convId).get();
//     if (!convDoc.exists) {
//       final buyerDoc = await db.collection('users').doc(buyerId).get();
//       final buyerData = buyerDoc.data() ?? {};
//       final sellerDoc = await db.collection('users').doc(widget.sellerUid).get();
//       final sellerData = sellerDoc.data() ?? {};

//       await db.collection('conversations').doc(convId).set({
//         'participantIds': [widget.sellerUid, buyerId],
//         'participantNames': {
//           widget.sellerUid: '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'.trim(),
//           buyerId: buyerName,
//         },
//         'participantRoles': {widget.sellerUid: 'seller', buyerId: 'buyer'},
//         'participantProfileImages': {
//           widget.sellerUid: sellerData['profileImage'] ?? '',
//           buyerId: buyerData['profileImage'] ?? '',
//         },
//         'lastMessage': '',
//         'lastMessageAt': Timestamp.now(),
//         'createdAt': Timestamp.now(),
//         'unreadCounts': {widget.sellerUid: 0, buyerId: 0},
//         'relatedJobId': widget.jobId,
//       });
//     }

//     // Navigate using your existing ChatDetailScreen pattern
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Opening chat with $buyerName...')),
//       );
//       // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
//       //   conversationId: convId,
//       //   otherUserId: buyerId,
//       //   otherUserName: buyerName,
//       // )));
//     }
//   }
// }

// class _SellerEmptyState extends StatelessWidget {
//   final IconData icon;
//   final String message;
//   final String subtitle;
//   const _SellerEmptyState({required this.icon, required this.message, required this.subtitle});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 60, color: Colors.grey[400]),
//           const SizedBox(height: 12),
//           Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
//           const SizedBox(height: 6),
//           Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
//         ],
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';

class SellerOrdersPage extends StatefulWidget {
  final String? phoneUID;
  const SellerOrdersPage({super.key, this.phoneUID});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get _uid =>
      widget.phoneUID ?? UserSession().phoneUID ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkBalanceAndNotify();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Balance & Free Order Check on Load ────────────────────
  Future<void> _checkBalanceAndNotify() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(_uid)
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final jobsCompleted =
          (data['Jobs_Completed'] ?? 0) as int;
      final availableBalance =
          (data['Available_Balance'] ?? 0).toDouble();

      const int freeLimit = 3;
      const double minBalance = 100.0; // PKR 100 minimum

      if (jobsCompleted >= freeLimit &&
          availableBalance < minBalance &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLowBalanceBanner(context, availableBalance);
        });
      }
    } catch (_) {}
  }

  void _showLowBalanceBanner(
      BuildContext context, double balance) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.red.shade50,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade700, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Low Balance — Orders Paused',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'You\'ve used your 3 free orders. Balance: PKR ${balance.toStringAsFixed(0)}. Add funds to receive new orders.',
              style: TextStyle(
                  fontSize: 12, color: Colors.red.shade800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context)
                .hideCurrentMaterialBanner(),
            child: const Text('DISMISS'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .hideCurrentMaterialBanner();
              // Navigate to deposit page
              // Navigator.push(context, MaterialPageRoute(builder: (_) => DepositWithdrawPage(phoneUID: _uid)));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white),
            child: const Text('ADD FUNDS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 1,
        title: const Text('Find Jobs',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Browse Jobs'),
            Tab(text: 'My Bids'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Balance status bar
          _SellerBalanceBar(sellerUid: _uid),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OpenJobsList(sellerUid: _uid),
                _MyBidsList(sellerUid: _uid),
                _ActiveJobsList(sellerUid: _uid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seller Balance Status Bar ─────────────────────────────────
class _SellerBalanceBar extends StatelessWidget {
  final String sellerUid;
  const _SellerBalanceBar({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final data =
            snap.data?.data() as Map<String, dynamic>? ?? {};
        final jobsCompleted =
            (data['Jobs_Completed'] ?? 0) as int;
        final availableBalance =
            (data['Available_Balance'] ?? 0).toDouble();
        const int freeLimit = 3;
        final bool isFreeMode = jobsCompleted < freeLimit;
        final int freeLeft = isFreeMode
            ? freeLimit - jobsCompleted
            : 0;
        final bool isLowBalance =
            !isFreeMode && availableBalance < 100;

        if (isFreeMode) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: Colors.green.shade700,
            child: Row(
              children: [
                const Icon(Icons.card_giftcard,
                    size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  '$freeLeft free order(s) remaining',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  'Balance: PKR ${availableBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (isLowBalance) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: Colors.red.shade700,
            child: Row(
              children: [
                const Icon(Icons.warning_amber,
                    size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Low balance (PKR ${availableBalance.toStringAsFixed(0)}) — Add funds to receive orders',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          color: Colors.green.shade800,
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'Balance: PKR ${availableBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '10% commission per order',
                style: TextStyle(
                    color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Browse Open Jobs ──────────────────────────────────────────
class _OpenJobsList extends StatefulWidget {
  final String sellerUid;
  const _OpenJobsList({required this.sellerUid});

  @override
  State<_OpenJobsList> createState() => _OpenJobsListState();
}

class _OpenJobsListState extends State<_OpenJobsList> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs by title or skill...',
              prefixIcon: const Icon(Icons.search,
                  color: Colors.green),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      })
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            onChanged: (v) =>
                setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // ✅ Only one where clause — no index needed
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .where('status', isEqualTo: 'open')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.green));
              }
              if (!snap.hasData ||
                  snap.data!.docs.isEmpty) {
                return _SellerEmptyState(
                    icon: Icons.work_outline,
                    message: 'No open jobs right now',
                    subtitle: 'Check back soon');
              }

              // Filter & sort in Dart
              var docs = snap.data!.docs
                  .where((d) {
                    final data =
                        d.data() as Map<String, dynamic>;
                    if (data['postedBy'] ==
                        widget.sellerUid) return false;
                    if (_searchQuery.isNotEmpty) {
                      final title = (data['title'] ?? '')
                          .toString()
                          .toLowerCase();
                      final skills = List<String>.from(
                              data['skills'] ?? [])
                          .join(' ')
                          .toLowerCase();
                      return title
                              .contains(_searchQuery) ||
                          skills.contains(_searchQuery);
                    }
                    return true;
                  })
                  .toList()
                ..sort((a, b) {
                    final aT =
                        (a.data() as Map)['postedAt']
                            as Timestamp?;
                    final bT =
                        (b.data() as Map)['postedAt']
                            as Timestamp?;
                    if (aT == null || bT == null) return 0;
                    return bT.compareTo(aT);
                  });

              if (docs.isEmpty) {
                return _SellerEmptyState(
                    icon: Icons.search_off,
                    message: 'No jobs match your search',
                    subtitle: 'Try different keywords');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final data = docs[i].data()
                      as Map<String, dynamic>;
                  return _OpenJobCard(
                    jobId: docs[i].id,
                    jobData: data,
                    sellerUid: widget.sellerUid,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OpenJobCard extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;

  const _OpenJobCard({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
  });

  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] ?? 'Untitled';
    final budget = (jobData['budget'] ?? 0).toDouble();
    final location = jobData['location'] ?? '';
    final timing = jobData['timing'] ?? '';
    final skills =
        List<String>.from(jobData['skills'] ?? []);
    final posterName =
        jobData['posterName'] ?? 'Unknown Client';
    final bidsCount = jobData['bidsCount'] ?? 0;
    final isInsured =
        (jobData['orderType'] ?? 'simple') == 'insured';
    final postedAt = jobData['postedAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isInsured
            ? Border.all(
                color: Colors.blue.shade200, width: 1.5)
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isInsured
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
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
                                          FontWeight.bold))),
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
                                          color:
                                              Colors.white,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight
                                                  .bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text('by $posterName',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade700),
                    ),
                    Text('Max Budget',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 13,
                        color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location.isNotEmpty
                            ? location
                            : 'Location not specified',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.schedule,
                        size: 13,
                        color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(timing,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 8),
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
                              color: Colors.green.shade50,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      Colors.green.shade200),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors
                                        .green.shade700)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '$bidsCount competing bid(s)',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                    if (postedAt != null)
                      Text(
                        '  •  ${DateFormat('dd MMM').format(postedAt.toDate())}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500]),
                      ),
                    const Spacer(),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(jobId)
                          .collection('bids')
                          .doc(sellerUid)
                          .get(),
                      builder: (ctx, bidSnap) {
                        final alreadyBid =
                            bidSnap.data?.exists ?? false;
                        return ElevatedButton.icon(
                          onPressed: alreadyBid
                              ? null
                              : () =>
                                  _showBidDialog(context),
                          icon: Icon(
                              alreadyBid
                                  ? Icons.check
                                  : Icons.gavel,
                              size: 16),
                          label: Text(alreadyBid
                              ? 'Bid Placed'
                              : 'Place Bid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: alreadyBid
                                ? Colors.grey
                                : Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 14,
                                vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        8)),
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                          ),
                        );
                      },
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

  void _showBidDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PlaceBidSheet(
          jobId: jobId,
          jobData: jobData,
          sellerUid: sellerUid),
    );
  }
}

// ── Place Bid Bottom Sheet ─────────────────────────────────────
class _PlaceBidSheet extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;

  const _PlaceBidSheet({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
  });

  @override
  State<_PlaceBidSheet> createState() =>
      _PlaceBidSheetState();
}

class _PlaceBidSheetState extends State<_PlaceBidSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _proposalController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final db = FirebaseFirestore.instance;
      final amount =
          double.parse(_amountController.text.trim());
      final budget =
          (widget.jobData['budget'] ?? 0).toDouble();

      if (amount > budget) {
        _showSnack(
            'Bid cannot exceed max budget PKR ${budget.toStringAsFixed(0)}',
            Colors.red);
        setState(() => _isSubmitting = false);
        return;
      }

      final sellerDoc = await db
          .collection('sellers')
          .doc(widget.sellerUid)
          .get();
      final sellerData = sellerDoc.data() ?? {};
      final userDoc = await db
          .collection('users')
          .doc(widget.sellerUid)
          .get();
      final userData = userDoc.data() ?? {};

      final sellerName =
          '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'
              .trim();
      final sellerImage =
          userData['profileImage'] ?? '';
      final rating =
          (sellerData['Rating'] ?? 0).toDouble();
      final skills = List<String>.from(
          sellerData['skills'] ?? []);
      final jobsCompleted =
          (sellerData['Jobs_Completed'] ?? 0) as int;

      final batch = db.batch();

      final bidRef = db
          .collection('jobs')
          .doc(widget.jobId)
          .collection('bids')
          .doc(widget.sellerUid);

      batch.set(bidRef, {
        'sellerId': widget.sellerUid,
        'sellerName': sellerName,
        'sellerImage': sellerImage,
        'rating': rating,
        'skills': skills,
        'jobsCompleted': jobsCompleted,
        'proposedAmount': amount,
        'proposal': _proposalController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(
          db.collection('jobs').doc(widget.jobId),
          {'bidsCount': FieldValue.increment(1)});

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Bid placed!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color));

  @override
  Widget build(BuildContext context) {
    final budget = widget.jobData['budget'] ?? 0;
    final title = widget.jobData['title'] ?? '';
    final isInsured =
        (widget.jobData['orderType'] ?? 'simple') == 'insured';

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                      borderRadius:
                          BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Place a Bid',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('For: $title',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600])),
              const SizedBox(height: 8),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Max Budget: PKR ${budget.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (isInsured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shield,
                              size: 12,
                              color: Colors.blue),
                          SizedBox(width: 4),
                          Text('Insured Job',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight:
                                      FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Commission info
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sellers')
                    .doc(widget.sellerUid)
                    .get(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final data = snap.data?.data()
                          as Map<String, dynamic>? ??
                      {};
                  final jc =
                      (data['Jobs_Completed'] ?? 0) as int;
                  final bal = (data['Available_Balance'] ?? 0)
                      .toDouble();
                  final isFree = jc < 3;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isFree
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                          color: isFree
                              ? Colors.green.shade200
                              : Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isFree
                              ? Icons.card_giftcard
                              : Icons.percent,
                          size: 14,
                          color: isFree
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isFree
                                ? '🎁 Free order (${3 - jc} free left) — No commission charged'
                                : '10% commission will be deducted • Balance: PKR ${bal.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: isFree
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: 'Your Bid Amount (PKR)',
                  prefixText: 'PKR ',
                  prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: Colors.green),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Enter bid amount';
                  final amt = double.tryParse(v);
                  if (amt == null || amt <= 0)
                    return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _proposalController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your Proposal',
                  prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: Colors.green),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10)),
                  helperText:
                      'Explain why you are the right choice',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Write a proposal'
                        : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting ? null : _submitBid,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Icon(Icons.gavel),
                  label: Text(
                      _isSubmitting
                          ? 'Submitting...'
                          : 'Submit Bid',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── My Bids Tab ────────────────────────────────────────────────
class _MyBidsList extends StatelessWidget {
  final String sellerUid;
  const _MyBidsList({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('bids')
          .where('sellerId', isEqualTo: sellerUid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Colors.green));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _SellerEmptyState(
            icon: Icons.gavel,
            message: 'No bids placed yet',
            subtitle:
                'Browse open jobs and place your first bid',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snap.data!.docs.length,
          itemBuilder: (ctx, i) {
            final bid = snap.data!.docs[i].data()
                as Map<String, dynamic>;
            final jobId = snap.data!.docs[i].reference
                .parent.parent!.id;
            return _MyBidCard(bid: bid, jobId: jobId);
          },
        );
      },
    );
  }
}

class _MyBidCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final String jobId;
  const _MyBidCard({required this.bid, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final amount =
        (bid['proposedAmount'] ?? 0).toDouble();
    final proposal = bid['proposal'] ?? '';
    final status = bid['status'] ?? 'pending';
    final createdAt = bid['createdAt'] as Timestamp?;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .get(),
      builder: (context, snap) {
        final jData = snap.data?.data()
                as Map<String, dynamic>? ??
            {};
        final jobTitle = jData['title'] ?? 'Loading...';
        final posterName = jData['posterName'] ?? '';
        final jobBudget =
            (jData['budget'] ?? 0).toDouble();
        final isInsured =
            (jData['orderType'] ?? 'simple') == 'insured';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: status == 'accepted'
                  ? Colors.green.shade200
                  : Colors.grey.shade200,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(jobTitle,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold)),
                              ),
                              if (isInsured)
                                const Icon(Icons.shield,
                                    size: 14,
                                    color: Colors.blue),
                            ],
                          ),
                          if (posterName.isNotEmpty)
                            Text('Client: $posterName',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon,
                              size: 12,
                              color: statusColor),
                          const SizedBox(width: 4),
                          Text(status.toUpperCase(),
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Your Bid',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500])),
                        Text(
                          'PKR ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Max Budget',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500])),
                        Text(
                          'PKR ${jobBudget.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (createdAt != null)
                      Text(
                        DateFormat('dd MMM')
                            .format(createdAt.toDate()),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500]),
                      ),
                  ],
                ),
                if (proposal.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius:
                            BorderRadius.circular(8)),
                    child: Text(proposal,
                        style:
                            const TextStyle(fontSize: 13)),
                  ),
                ],
                if (status == 'accepted') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.celebration,
                            color: Colors.green.shade600,
                            size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isInsured
                                ? '🎉 Accepted! Insurance job — ensure buyer has paid company before you start.'
                                : '🎉 Your bid was accepted! Collect cash on job completion.',
                            style: TextStyle(
                                color:
                                    Colors.green.shade700,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Active Jobs Tab ────────────────────────────────────────────
class _ActiveJobsList extends StatelessWidget {
  final String sellerUid;
  const _ActiveJobsList({required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // ✅ Only one where clause — no index needed
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('acceptedBidder', isEqualTo: sellerUid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Colors.green));
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _SellerEmptyState(
            icon: Icons.construction,
            message: 'No active jobs',
            subtitle: 'Win a bid to start working',
          );
        }

        // Filter in_progress in Dart
        final docs = snap.data!.docs
            .where((d) =>
                (d.data() as Map)['status'] == 'in_progress')
            .toList();

        if (docs.isEmpty) {
          return _SellerEmptyState(
            icon: Icons.construction,
            message: 'No active jobs',
            subtitle: 'Win a bid to start working',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data =
                docs[i].data() as Map<String, dynamic>;
            return _ActiveJobCard(
              jobId: docs[i].id,
              jobData: data,
              sellerUid: sellerUid,
            );
          },
        );
      },
    );
  }
}

class _ActiveJobCard extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String sellerUid;

  const _ActiveJobCard({
    required this.jobId,
    required this.jobData,
    required this.sellerUid,
  });

  @override
  State<_ActiveJobCard> createState() =>
      _ActiveJobCardState();
}

class _ActiveJobCardState extends State<_ActiveJobCard> {
  bool _isCompleting = false;

  Future<void> _markCompleted() async {
    setState(() => _isCompleting = true);
    try {
      final db = FirebaseFirestore.instance;
      final acceptedAmount =
          (widget.jobData['acceptedAmount'] ?? 0).toDouble();
      final isInsured =
          (widget.jobData['orderType'] ?? 'simple') ==
              'insured';

      final batch = db.batch();

      // For cash jobs, credit seller immediately
      // For insured jobs, amount is released by admin
      final claimDeadline =
          Timestamp.fromDate(DateTime.now().add(
        const Duration(days: 3),
      ));

      batch.update(db.collection('jobs').doc(widget.jobId), {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'claimDeadline': claimDeadline,
        'paymentStatus': isInsured ? 'locked' : 'released',
      });

      if (!isInsured) {
        // Cash job — credit seller immediately
        batch.update(
            db.collection('sellers').doc(widget.sellerUid), {
          'Jobs_Completed': FieldValue.increment(1),
          'Total_Jobs': FieldValue.increment(1),
          'Pending_Jobs': FieldValue.increment(-1),
          'Earning':
              FieldValue.increment(acceptedAmount),
          'Available_Balance':
              FieldValue.increment(acceptedAmount),
        });
      } else {
        // Insured — only update job stats, earnings come after admin release
        batch.update(
            db.collection('sellers').doc(widget.sellerUid), {
          'Jobs_Completed': FieldValue.increment(1),
          'Total_Jobs': FieldValue.increment(1),
          'Pending_Jobs': FieldValue.increment(-1),
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isInsured
              ? '✅ Job marked complete! Buyer has 3 days to claim insurance. Earnings will be released after that.'
              : '🎉 Job completed! Collect PKR ${acceptedAmount.toStringAsFixed(0)} in cash from the buyer.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.jobData['title'] ?? '';
    final posterName =
        widget.jobData['posterName'] ?? 'Client';
    final acceptedAmount =
        (widget.jobData['acceptedAmount'] ?? 0).toDouble();
    final skills = List<String>.from(
        widget.jobData['skills'] ?? []);
    final location = widget.jobData['location'] ?? '';
    final buyerId = widget.jobData['postedBy'] ?? '';
    final isInsured =
        (widget.jobData['orderType'] ?? 'simple') ==
            'insured';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isInsured
              ? Colors.blue.shade200
              : Colors.green.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isInsured
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
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
                                      BorderRadius.circular(
                                          8)),
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
                                          color:
                                              Colors.white,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight
                                                  .bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text('Client: $posterName',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${acceptedAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isInsured
                              ? Colors.blue.shade700
                              : Colors.green.shade700),
                    ),
                    Text(
                      isInsured
                          ? 'Held by company'
                          : 'Cash on delivery',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 13,
                          color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(location,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600]),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Payment instruction
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isInsured
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isInsured
                            ? Colors.blue.shade200
                            : Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isInsured
                            ? Icons.lock_outline
                            : Icons.payments_outlined,
                        size: 14,
                        color: isInsured
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isInsured
                              ? 'Payment is locked with company. Will be released after 3-day claim window.'
                              : 'Collect PKR ${acceptedAmount.toStringAsFixed(0)} in cash from client after job completion.',
                          style: TextStyle(
                              fontSize: 11,
                              color: isInsured
                                  ? Colors.blue.shade800
                                  : Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: skills
                      .take(3)
                      .map((s) => Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      Colors.green.shade200),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors
                                        .green.shade700)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openChat(
                            context, buyerId, posterName),
                        icon: const Icon(
                            Icons.message_outlined,
                            size: 16),
                        label:
                            const Text('Message Client'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(
                              color: Colors.blue),
                          padding:
                              const EdgeInsets.symmetric(
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
                        onPressed: _isCompleting
                            ? null
                            : _markCompleted,
                        icon: _isCompleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Colors.white))
                            : const Icon(
                                Icons.check_circle_outline,
                                size: 16),
                        label: Text(_isCompleting
                            ? 'Updating...'
                            : 'Mark Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 10),
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
    );
  }

  void _openChat(BuildContext context, String buyerId,
      String buyerName) async {
    if (buyerId.isEmpty) return;
    final db = FirebaseFirestore.instance;
    final phones = [widget.sellerUid, buyerId]..sort();
    final convId = '${phones[0]}_${phones[1]}';

    final convDoc = await db
        .collection('conversations')
        .doc(convId)
        .get();
    if (!convDoc.exists) {
      final buyerDoc =
          await db.collection('users').doc(buyerId).get();
      final buyerData = buyerDoc.data() ?? {};
      final sellerDoc = await db
          .collection('users')
          .doc(widget.sellerUid)
          .get();
      final sellerData = sellerDoc.data() ?? {};

      await db
          .collection('conversations')
          .doc(convId)
          .set({
        'participantIds': [widget.sellerUid, buyerId],
        'participantNames': {
          widget.sellerUid:
              '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'
                  .trim(),
          buyerId: buyerName,
        },
        'participantRoles': {
          widget.sellerUid: 'seller',
          buyerId: 'buyer'
        },
        'participantProfileImages': {
          widget.sellerUid:
              sellerData['profileImage'] ?? '',
          buyerId: buyerData['profileImage'] ?? '',
        },
        'lastMessage': '',
        'lastMessageAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'unreadCounts': {
          widget.sellerUid: 0,
          buyerId: 0
        },
        'relatedJobId': widget.jobId,
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Opening chat with $buyerName...')),
      );
      // Uncomment when ChatDetailScreen is available:
      // Navigator.push(context, MaterialPageRoute(builder: (_) =>
      //   ChatDetailScreen(conversationId: convId, otherUserId: buyerId,
      //     otherUserName: buyerName)));
    }
  }
}

// ── Shared helpers ─────────────────────────────────────────────
class _SellerEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  const _SellerEmptyState(
      {required this.icon,
      required this.message,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontSize: 16, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}