// // // lib/pages/JobPostingScreen.dart

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import '../../services/user_session.dart';

// // class JobPostingScreen extends StatefulWidget {
// //   const JobPostingScreen({super.key});

// //   @override
// //   State<JobPostingScreen> createState() => _JobPostingScreenState();
// // }

// // class _JobPostingScreenState extends State<JobPostingScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _titleController = TextEditingController();
// //   final _budgetController = TextEditingController();
// //   final _locationController = TextEditingController();

// //   // ── Job Timing dropdown ──────────────────────────────────────
// //   static const List<String> _timingOptions = [
// //     'Immediately',
// //     'Within 2 Hours',
// //     'Today',
// //     'Tomorrow',
// //     'This Week',
// //     'Flexible / Anytime',
// //   ];
// //   String? _selectedTiming;

// //   // ── Skills chip input ────────────────────────────────────────
// //   static const List<String> _suggestedSkills = [
// //     'Plumbing',
// //     'Electrical',
// //     'Carpentry',
// //     'Painting',
// //     'AC Repair',
// //     'Tiling',
// //     'Welding',
// //     'Gas Fitting',
// //     'Masonry',
// //     'Roof Repair',
// //   ];
// //   final List<String> _selectedSkills = [];
// //   final TextEditingController _skillInputController = TextEditingController();

// //   bool _isPosting = false; // shows loading while saving to Firestore

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _budgetController.dispose();
// //     _locationController.dispose();
// //     _skillInputController.dispose();
// //     super.dispose();
// //   }

// //   void _addSkill(String skill) {
// //     final trimmed = skill.trim();
// //     if (trimmed.isEmpty) return;
// //     if (_selectedSkills.contains(trimmed)) return;
// //     setState(() => _selectedSkills.add(trimmed));
// //     _skillInputController.clear();
// //   }

// //   void _removeSkill(String skill) {
// //     setState(() => _selectedSkills.remove(skill));
// //   }

// //   /// Save job to Firestore and navigate back
// //   Future<void> _submitJob() async {
// //     if (!_formKey.currentState!.validate()) return;
// //     if (_selectedSkills.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please add at least one skill'),
// //           backgroundColor: Colors.orange,
// //         ),
// //       );
// //       return;
// //     }

// //     setState(() => _isPosting = true);

// //     try {
// //       final uid = UserSession().phoneUID ?? 'unknown';
// //       await FirebaseFirestore.instance.collection('jobs').add({
// //         'title': _titleController.text.trim(),
// //         'skills': _selectedSkills,
// //         'timing': _selectedTiming,
// //         'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
// //         'location': _locationController.text.trim(),
// //         'postedBy': uid,
// //         'status': 'open',
// //         'bidsCount': 0,
// //         'postedAt': FieldValue.serverTimestamp(),
// //       });

// //       if (!mounted) return;
// //       Navigator.pop(context);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('✅ Job Posted! Waiting for competitive bids...'),
// //           backgroundColor: Colors.teal,
// //         ),
// //       );
// //     } catch (e) {
// //       setState(() => _isPosting = false);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error posting job: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Post a New Job'),
// //         backgroundColor: Colors.teal,
// //         foregroundColor: Colors.white,
// //       ),
// //       body: Form(
// //         key: _formKey,
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // ── Header ───────────────────────────────────────
// //               const Text(
// //                 'Detail Your Job for Bidding',
// //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 8),
// //               const Text(
// //                 'Workers will place competitive bids. Set your maximum budget to facilitate the bargaining process.',
// //                 style: TextStyle(fontSize: 14, color: Colors.grey),
// //               ),
// //               const Divider(height: 30),

// //               // ── Job Title ────────────────────────────────────
// //               TextFormField(
// //                 controller: _titleController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Job Title (e.g., Water Pump Repair)',
// //                   border: OutlineInputBorder(),
// //                 ),
// //                 validator: (v) =>
// //                     v == null || v.trim().isEmpty ? 'Please enter a job title' : null,
// //               ),
// //               const SizedBox(height: 20),

// //               // ── Skills Required ──────────────────────────────
// //               _sectionLabel('Skills Required'),
// //               const SizedBox(height: 8),

// //               // Input row
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: TextFormField(
// //                       controller: _skillInputController,
// //                       decoration: InputDecoration(
// //                         hintText: 'Type a skill and press +',
// //                         border: const OutlineInputBorder(),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 12, vertical: 12),
// //                       ),
// //                       onFieldSubmitted: _addSkill,
// //                       textInputAction: TextInputAction.done,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   ElevatedButton(
// //                     onPressed: () => _addSkill(_skillInputController.text),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.teal,
// //                       foregroundColor: Colors.white,
// //                       minimumSize: const Size(48, 50),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: const Icon(Icons.add),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 10),

// //               // Suggested quick-add chips
// //               Wrap(
// //                 spacing: 8,
// //                 runSpacing: 4,
// //                 children: _suggestedSkills
// //                     .where((s) => !_selectedSkills.contains(s))
// //                     .map(
// //                       (skill) => ActionChip(
// //                         label: Text(skill, style: const TextStyle(fontSize: 12)),
// //                         avatar: const Icon(Icons.add, size: 14),
// //                         backgroundColor: Colors.teal.shade50,
// //                         side: BorderSide(color: Colors.teal.shade200),
// //                         onPressed: () => _addSkill(skill),
// //                       ),
// //                     )
// //                     .toList(),
// //               ),
// //               const SizedBox(height: 10),

// //               // Selected skills display
// //               if (_selectedSkills.isNotEmpty) ...[
// //                 Container(
// //                   width: double.infinity,
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.teal.shade50,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.teal.shade200),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Added Skills (${_selectedSkills.length})',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.teal.shade700,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Wrap(
// //                         spacing: 8,
// //                         runSpacing: 6,
// //                         children: _selectedSkills
// //                             .map(
// //                               (skill) => Chip(
// //                                 label: Text(skill),
// //                                 deleteIcon: const Icon(Icons.close, size: 16),
// //                                 onDeleted: () => _removeSkill(skill),
// //                                 backgroundColor: Colors.teal,
// //                                 labelStyle: const TextStyle(
// //                                   color: Colors.white,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                                 deleteIconColor: Colors.white,
// //                                 side: BorderSide.none,
// //                               ),
// //                             )
// //                             .toList(),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ] else ...[
// //                 Container(
// //                   width: double.infinity,
// //                   padding: const EdgeInsets.symmetric(vertical: 14),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade100,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.grey.shade300),
// //                   ),
// //                   child: const Center(
// //                     child: Text(
// //                       'No skills added yet — tap + or select from suggestions',
// //                       style: TextStyle(color: Colors.grey, fontSize: 13),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //               const SizedBox(height: 20),

// //               // ── Job Timing dropdown ──────────────────────────
// //               _sectionLabel('Job Timing'),
// //               const SizedBox(height: 8),
// //               DropdownButtonFormField<String>(
// //                 value: _selectedTiming,
// //                 decoration: const InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   hintText: 'When do you need this done?',
// //                   prefixIcon: Icon(Icons.schedule, color: Colors.teal),
// //                 ),
// //                 items: _timingOptions
// //                     .map(
// //                       (option) => DropdownMenuItem(
// //                         value: option,
// //                         child: Text(option),
// //                       ),
// //                     )
// //                     .toList(),
// //                 onChanged: (value) => setState(() => _selectedTiming = value),
// //                 validator: (v) =>
// //                     v == null ? 'Please select when you need this done' : null,
// //               ),
// //               const SizedBox(height: 20),

// //               // ── Maximum Budget ───────────────────────────────
// //               TextFormField(
// //                 controller: _budgetController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Maximum Budget (PKR) — Workers will bid below this',
// //                   border: OutlineInputBorder(),
// //                   prefixText: 'PKR ',
// //                 ),
// //                 keyboardType: TextInputType.number,
// //                 validator: (v) =>
// //                     v == null || v.trim().isEmpty ? 'Please enter a budget' : null,
// //               ),
// //               const SizedBox(height: 20),

// //               // ── Location ─────────────────────────────────────
// //               TextFormField(
// //                 controller: _locationController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Job Location (Tap to use GPS)',
// //                   border: OutlineInputBorder(),
// //                   suffixIcon: Icon(Icons.location_on, color: Colors.teal),
// //                 ),
// //                 readOnly: true,
// //                 onTap: () {
// //                   /* TODO: Launch map picker */
// //                 },
// //               ),
// //               const SizedBox(height: 30),

// //               // ── Submit Button ─────────────────────────────────
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   onPressed: _isPosting ? null : _submitJob,
// //                   // disabled while posting
// //                   style: ElevatedButton.styleFrom(
// //                     padding: const EdgeInsets.symmetric(vertical: 15),
// //                     backgroundColor: Colors.orange,
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                   child: const Text(
// //                     'Post Job & Start Bidding',
// //                     style: TextStyle(fontSize: 18),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _sectionLabel(String text) => Text(
// //         text,
// //         style: const TextStyle(
// //           fontSize: 15,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.black87,
// //         ),
// //       );
// // }



// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../services/user_session.dart';
// import './cloudinary_service.dart';

// class JobPostingScreen extends StatefulWidget {
//   final bool isSellerMode; // true = Post Offer, false = Post Job
//   const JobPostingScreen({super.key, this.isSellerMode = false});

//   @override
//   State<JobPostingScreen> createState() => _JobPostingScreenState();
// }

// class _JobPostingScreenState extends State<JobPostingScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     // If seller, default to offer tab; if buyer, default to job tab
//     _tabController = TabController(
//       length: 2,
//       vsync: this,
//       initialIndex: widget.isSellerMode ? 1 : 0,
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.isSellerMode ? 'Post an Offer' : 'Post a New Job'),
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white60,
//           tabs: const [
//             Tab(icon: Icon(Icons.work_outline), text: 'Post Job'),
//             Tab(icon: Icon(Icons.local_offer_outlined), text: 'Post Offer'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           _PostJobTab(),
//           _PostOfferTab(),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  POST JOB TAB  (Buyer Posts a Job)
// // ═══════════════════════════════════════════════════════════════
// class _PostJobTab extends StatefulWidget {
//   const _PostJobTab();

//   @override
//   State<_PostJobTab> createState() => _PostJobTabState();
// }

// class _PostJobTabState extends State<_PostJobTab> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _budgetController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _skillInputController = TextEditingController();

//   static const List<String> _timingOptions = [
//     'Immediately',
//     'Within 2 Hours',
//     'Today',
//     'Tomorrow',
//     'This Week',
//     'Flexible / Anytime',
//   ];

//   static const List<String> _suggestedSkills = [
//     'Plumbing', 'Electrical', 'Carpentry', 'Painting',
//     'AC Repair', 'Tiling', 'Welding', 'Gas Fitting',
//     'Masonry', 'Roof Repair', 'Gardening', 'Cleaning',
//   ];

//   String? _selectedTiming;
//   final List<String> _selectedSkills = [];
//   double? _latitude;
//   double? _longitude;
//   bool _isPosting = false;
//   bool _isLocating = false;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _budgetController.dispose();
//     _locationController.dispose();
//     _descriptionController.dispose();
//     _skillInputController.dispose();
//     super.dispose();
//   }

//   // ── GPS Location ─────────────────────────────────────────────
//   Future<void> _getCurrentLocation() async {
//     setState(() => _isLocating = true);

//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showSnack('Location permission denied', Colors.red);
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         _showSnack('Enable location in settings', Colors.red);
//         return;
//       }

//       final Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       _latitude = position.latitude;
//       _longitude = position.longitude;

//       // Reverse geocode
//       final List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         final address = [
//           p.street,
//           p.subLocality,
//           p.locality,
//           p.country,
//         ].where((e) => e != null && e.isNotEmpty).join(', ');

//         _locationController.text = address;
//       }
//     } catch (e) {
//       _showSnack('Could not get location: $e', Colors.red);
//     } finally {
//       setState(() => _isLocating = false);
//     }
//   }

//   void _addSkill(String skill) {
//     final trimmed = skill.trim();
//     if (trimmed.isEmpty || _selectedSkills.contains(trimmed)) return;
//     setState(() => _selectedSkills.add(trimmed));
//     _skillInputController.clear();
//   }

//   void _removeSkill(String skill) => setState(() => _selectedSkills.remove(skill));

//   /// Job ID = phoneUID_timestamp  (traceable + unique)
//   String _generateJobId(String uid) {
//     final ts = DateTime.now().millisecondsSinceEpoch;
//     return '${uid}_$ts';
//   }

//   Future<void> _submitJob() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSkills.isEmpty) {
//       _showSnack('Please add at least one skill', Colors.orange);
//       return;
//     }

//     setState(() => _isPosting = true);

//     try {
//       final uid = UserSession().phoneUID ?? 'unknown';
//       final jobId = _generateJobId(uid);

//       // Fetch poster's name & image for display in bid screens
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//       final userData = userDoc.data() ?? {};
//       final posterName =
//           '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
//       final posterImage = userData['profileImage'] ?? '';

//       await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
//         'jobId': jobId,
//         'title': _titleController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'skills': _selectedSkills,
//         'timing': _selectedTiming,
//         'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
//         'location': _locationController.text.trim(),
//         'latitude': _latitude,
//         'longitude': _longitude,
//         'postedBy': uid,
//         'posterName': posterName,
//         'posterImage': posterImage,
//         'status': 'open', // open | in_progress | completed | cancelled
//         'bidsCount': 0,
//         'acceptedBidder': null,
//         'postedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       Navigator.pop(context);
//       _showSnack('✅ Job posted! Waiting for bids...', Colors.teal);
//     } catch (e) {
//       setState(() => _isPosting = false);
//       _showSnack('Error posting job: $e', Colors.red);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ─────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.teal.shade100),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.teal.shade700),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Sellers will place competitive bids. Set your maximum budget.',
//                       style: TextStyle(fontSize: 13, color: Colors.teal.shade800),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ── Job Title ───────────────────────────────────────
//             TextFormField(
//               controller: _titleController,
//               decoration: _inputDeco('Job Title (e.g., Water Pump Repair)', Icons.title),
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter a job title' : null,
//             ),
//             const SizedBox(height: 14),

//             // ── Description ─────────────────────────────────────
//             TextFormField(
//               controller: _descriptionController,
//               decoration: _inputDeco('Job Description (optional)', Icons.description),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 20),

//             // ── Skills Required ─────────────────────────────────
//             _sectionLabel('Skills Required'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _skillInputController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a skill and press +',
//                       border: const OutlineInputBorder(),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     ),
//                     onFieldSubmitted: _addSkill,
//                     textInputAction: TextInputAction.done,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () => _addSkill(_skillInputController.text),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(48, 50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Icon(Icons.add),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // Suggested chips
//             Wrap(
//               spacing: 8, runSpacing: 4,
//               children: _suggestedSkills
//                   .where((s) => !_selectedSkills.contains(s))
//                   .map((skill) => ActionChip(
//                         label: Text(skill, style: const TextStyle(fontSize: 12)),
//                         avatar: const Icon(Icons.add, size: 14),
//                         backgroundColor: Colors.teal.shade50,
//                         side: BorderSide(color: Colors.teal.shade200),
//                         onPressed: () => _addSkill(skill),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 10),

//             // Selected skills
//             if (_selectedSkills.isNotEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.teal.shade200),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Added Skills (${_selectedSkills.length})',
//                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal.shade700),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8, runSpacing: 6,
//                       children: _selectedSkills.map((skill) => Chip(
//                             label: Text(skill),
//                             deleteIcon: const Icon(Icons.close, size: 16),
//                             onDeleted: () => _removeSkill(skill),
//                             backgroundColor: Colors.teal,
//                             labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//                             deleteIconColor: Colors.white,
//                             side: BorderSide.none,
//                           )).toList(),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'No skills added yet — tap + or select from suggestions',
//                     style: TextStyle(color: Colors.grey, fontSize: 13),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // ── Job Timing ──────────────────────────────────────
//             _sectionLabel('Job Timing'),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: _selectedTiming,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'When do you need this done?',
//                 prefixIcon: Icon(Icons.schedule, color: Colors.teal),
//               ),
//               items: _timingOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
//               onChanged: (v) => setState(() => _selectedTiming = v),
//               validator: (v) => v == null ? 'Please select timing' : null,
//             ),
//             const SizedBox(height: 14),

//             // ── Budget ──────────────────────────────────────────
//             TextFormField(
//               controller: _budgetController,
//               decoration: _inputDeco('Maximum Budget (PKR) — Sellers bid below this', Icons.payments_outlined, prefix: 'PKR '),
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter a budget' : null,
//             ),
//             const SizedBox(height: 14),

//             // ── Location with GPS ───────────────────────────────
//             _sectionLabel('Job Location'),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _locationController,
//               decoration: InputDecoration(
//                 hintText: 'Tap GPS button to auto-fill location',
//                 border: const OutlineInputBorder(),
//                 prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.teal),
//                 suffixIcon: _isLocating
//                     ? const Padding(
//                         padding: EdgeInsets.all(12),
//                         child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
//                       )
//                     : IconButton(
//                         icon: const Icon(Icons.my_location, color: Colors.teal),
//                         tooltip: 'Use my current location',
//                         onPressed: _getCurrentLocation,
//                       ),
//               ),
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter job location' : null,
//             ),
//             if (_latitude != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
//                     const SizedBox(width: 4),
//                     Text(
//                       'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
//                       style: TextStyle(fontSize: 11, color: Colors.green.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 30),

//             // ── Submit ──────────────────────────────────────────
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isPosting ? null : _submitJob,
//                 icon: _isPosting
//                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.send),
//                 label: Text(_isPosting ? 'Posting...' : 'Post Job & Start Bidding',
//                     style: const TextStyle(fontSize: 16)),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// //  POST OFFER TAB  (Seller Posts a Default Offer)
// // ═══════════════════════════════════════════════════════════════
// class _PostOfferTab extends StatefulWidget {
//   const _PostOfferTab();

//   @override
//   State<_PostOfferTab> createState() => _PostOfferTabState();
// }

// class _PostOfferTabState extends State<_PostOfferTab> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _deliveryTimeController = TextEditingController();
//   final _skillInputController = TextEditingController();

//   final List<String> _selectedSkills = [];
//   File? _offerImageFile;
//   bool _isPosting = false;
//   bool _isUploadingImage = false;

//   static const List<String> _suggestedSkills = [
//     'Plumbing', 'Electrical', 'Carpentry', 'Painting',
//     'AC Repair', 'Tiling', 'Welding', 'Gas Fitting',
//     'Masonry', 'Roof Repair', 'Gardening', 'Cleaning',
//   ];

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _deliveryTimeController.dispose();
//     _skillInputController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickOfferImage() async {
//     final XFile? picked = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );
//     if (picked != null) setState(() => _offerImageFile = File(picked.path));
//   }

//   void _addSkill(String skill) {
//     final trimmed = skill.trim();
//     if (trimmed.isEmpty || _selectedSkills.contains(trimmed)) return;
//     setState(() => _selectedSkills.add(trimmed));
//     _skillInputController.clear();
//   }

//   void _removeSkill(String skill) => setState(() => _selectedSkills.remove(skill));

//   Future<void> _submitOffer() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSkills.isEmpty) {
//       _showSnack('Please add at least one skill', Colors.orange);
//       return;
//     }

//     setState(() => _isPosting = true);

//     try {
//       final uid = UserSession().phoneUID ?? 'unknown';

//       // Upload offer image if selected
//       String? imageUrl;
//       if (_offerImageFile != null) {
//         setState(() => _isUploadingImage = true);
//         imageUrl = await CloudinaryService.uploadImage(
//           _offerImageFile!,
//           folder: 'fixright/offers/$uid',
//         );
//         setState(() => _isUploadingImage = false);
//       }

//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final userData = userDoc.data() ?? {};
//       final sellerName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
//       final sellerImage = userData['profileImage'] ?? '';

//       final offerId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';

//       await FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(uid)
//           .collection('offers')
//           .doc(offerId)
//           .set({
//         'offerId': offerId,
//         'sellerId': uid,
//         'sellerName': sellerName,
//         'sellerImage': sellerImage,
//         'title': _titleController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'price': double.tryParse(_priceController.text.trim()) ?? 0,
//         'deliveryTime': _deliveryTimeController.text.trim(),
//         'skills': _selectedSkills,
//         'imageUrl': imageUrl ?? '',
//         'status': 'active', // active | paused
//         'ordersCount': 0,
//         'rating': 0.0,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       Navigator.pop(context);
//       _showSnack('✅ Offer posted! Buyers can now find and book you.', Colors.green);
//     } catch (e) {
//       setState(() => _isPosting = false);
//       _showSnack('Error posting offer: $e', Colors.red);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.green.shade100),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.local_offer, color: Colors.green.shade700),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Create a default offer. Buyers can browse and book you directly.',
//                       style: TextStyle(fontSize: 13, color: Colors.green.shade800),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Offer Image
//             _sectionLabel('Offer Image (optional)'),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: _pickOfferImage,
//               child: Container(
//                 height: 140,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: _offerImageFile != null ? Colors.green : Colors.grey.shade300,
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.grey.shade50,
//                 ),
//                 child: _offerImageFile != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(_offerImageFile!, fit: BoxFit.cover),
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey[400]),
//                           const SizedBox(height: 6),
//                           Text('Tap to add offer image', style: TextStyle(color: Colors.grey[500])),
//                         ],
//                       ),
//               ),
//             ),
//             const SizedBox(height: 14),

//             TextFormField(
//               controller: _titleController,
//               decoration: _inputDeco('Offer Title (e.g., Expert AC Repair)', Icons.title),
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter an offer title' : null,
//             ),
//             const SizedBox(height: 14),

//             TextFormField(
//               controller: _descriptionController,
//               decoration: _inputDeco('Describe what you offer', Icons.description),
//               maxLines: 3,
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter a description' : null,
//             ),
//             const SizedBox(height: 14),

//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _priceController,
//                     decoration: _inputDeco('Starting Price (PKR)', Icons.payments_outlined, prefix: 'PKR '),
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _deliveryTimeController,
//                     decoration: _inputDeco('Delivery Time', Icons.schedule),
//                     validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             _sectionLabel('Skills / Services'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _skillInputController,
//                     decoration: InputDecoration(
//                       hintText: 'Add a skill',
//                       border: const OutlineInputBorder(),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     ),
//                     onFieldSubmitted: _addSkill,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () => _addSkill(_skillInputController.text),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(48, 50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Icon(Icons.add),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8, runSpacing: 4,
//               children: _suggestedSkills
//                   .where((s) => !_selectedSkills.contains(s))
//                   .map((skill) => ActionChip(
//                         label: Text(skill, style: const TextStyle(fontSize: 12)),
//                         avatar: const Icon(Icons.add, size: 14),
//                         backgroundColor: Colors.green.shade50,
//                         side: BorderSide(color: Colors.green.shade200),
//                         onPressed: () => _addSkill(skill),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 8),
//             if (_selectedSkills.isNotEmpty)
//               Wrap(
//                 spacing: 8, runSpacing: 6,
//                 children: _selectedSkills.map((skill) => Chip(
//                       label: Text(skill),
//                       deleteIcon: const Icon(Icons.close, size: 16),
//                       onDeleted: () => _removeSkill(skill),
//                       backgroundColor: Colors.green,
//                       labelStyle: const TextStyle(color: Colors.white),
//                       deleteIconColor: Colors.white,
//                       side: BorderSide.none,
//                     )).toList(),
//               ),
//             const SizedBox(height: 30),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isPosting ? null : _submitOffer,
//                 icon: _isPosting
//                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.local_offer),
//                 label: Text(
//                   _isPosting
//                       ? (_isUploadingImage ? 'Uploading image...' : 'Posting...')
//                       : 'Publish Offer',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// InputDecoration _inputDeco(String label, IconData icon, {String? prefix}) {
//   return InputDecoration(
//     labelText: label,
//     prefixIcon: Icon(icon, size: 20),
//     prefixText: prefix,
//     border: const OutlineInputBorder(),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//   );
// }

// Widget _sectionLabel(String text) => Text(
//       text,
//       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
//     );


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_session.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillInputController = TextEditingController();

  static const List<String> _timingOptions = [
    'Immediately', 'Within 2 Hours', 'Today',
    'Tomorrow', 'This Week', 'Flexible / Anytime',
  ];

  static const List<String> _suggestedSkills = [
    'Plumbing', 'Electrical', 'Carpentry', 'Painting',
    'AC Repair', 'Tiling', 'Welding', 'Gas Fitting',
    'Masonry', 'Roof Repair', 'Gardening', 'Cleaning',
  ];

  String? _selectedTiming;
  final List<String> _selectedSkills = [];
  double? _latitude;
  double? _longitude;
  bool _isPosting = false;
  bool _isLocating = false;

  bool _wantsInsurance = false;
  static const double _insuranceRate = 0.20;

  double get _budget =>
      double.tryParse(_budgetController.text.trim()) ?? 0;
  double get _insuranceAmount =>
      _wantsInsurance ? (_budget * _insuranceRate) : 0;
  double get _totalAmount => _budget + _insuranceAmount;

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────
  InputDecoration _inputDeco(String label, IconData icon,
      {String? prefix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefix,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
      );

  Widget _infoBanner(String text, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 13, color: color)),
            ),
          ],
        ),
      );

  Widget _insuranceRow(String label, String value,
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
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.black87,
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      );

  // ── GPS ────────────────────────────────────────────────────
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        _showSnack('Location permission denied', Colors.red);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _latitude = pos.latitude;
      _longitude = pos.longitude;

      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _locationController.text = [
          p.street, p.subLocality, p.locality, p.country
        ].where((e) => e != null && e!.isNotEmpty).join(', ');
      }
      setState(() {});
    } catch (e) {
      _showSnack('GPS error: $e', Colors.red);
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _openGoogleMaps() async {
    const url = 'https://maps.google.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (mounted) {
        _showSnack(
            'Copy the address from Maps and paste it below',
            Colors.blue);
      }
    }
  }

  void _addSkill(String skill) {
    final t = skill.trim();
    if (t.isEmpty || _selectedSkills.contains(t)) return;
    setState(() => _selectedSkills.add(t));
    _skillInputController.clear();
  }

  void _removeSkill(String s) =>
      setState(() => _selectedSkills.remove(s));

  String _generateJobId(String uid) =>
      '${uid}_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      _showSnack('Add at least one skill', Colors.orange);
      return;
    }
    setState(() => _isPosting = true);
    try {
      final uid = UserSession().phoneUID ?? 'unknown';
      final jobId = _generateJobId(uid);

      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final uData = userSnap.data() ?? {};
      final posterName =
          '${uData['firstName'] ?? ''} ${uData['lastName'] ?? ''}'
              .trim();
      final posterImage = uData['profileImage'] ?? '';

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .set({
        'jobId': jobId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'skills': _selectedSkills,
        'timing': _selectedTiming,
        'budget': _budget,
        'insuranceAmount': _insuranceAmount,
        'totalAmount': _totalAmount,
        'orderType': _wantsInsurance ? 'insured' : 'simple',
        'location': _locationController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'postedBy': uid,
        'posterName': posterName,
        'posterImage': posterImage,
        'status': 'open',
        'bidsCount': 0,
        'acceptedBidder': null,
        'acceptedAmount': null,
        'paymentStatus': 'pending',
        'insuranceClaimed': false,
        'claimDeadline': null,
        'postedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('✅ Job posted! Waiting for bids...', Colors.teal);
    } catch (e) {
      setState(() => _isPosting = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color));

  // ── Skill sub-widgets ──────────────────────────────────────
  Widget _skillInputRow() => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _skillInputController,
              decoration: InputDecoration(
                hintText: 'Type a skill and press +',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
              onFieldSubmitted: _addSkill,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addSkill(_skillInputController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      );

  Widget _suggestedSkillsWrap() => Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _suggestedSkills
            .where((s) => !_selectedSkills.contains(s))
            .map((skill) => ActionChip(
                  label: Text(skill,
                      style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.add, size: 14),
                  backgroundColor: Colors.teal.shade50,
                  side: BorderSide(color: Colors.teal.shade200),
                  onPressed: () => _addSkill(skill),
                ))
            .toList(),
      );

  Widget _selectedSkillsBox() {
    if (_selectedSkills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'No skills added — tap + or choose from suggestions',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _selectedSkills
            .map((skill) => Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeSkill(skill),
                  backgroundColor: Colors.teal,
                  labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  deleteIconColor: Colors.white,
                  side: BorderSide.none,
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoBanner(
                'Sellers will bid competitively. Set your maximum budget.',
                Colors.teal,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: _inputDeco(
                    'Job Title (e.g., Water Pump Repair)', Icons.title),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                decoration: _inputDeco(
                    'Describe the job in detail', Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              _sectionLabel('Skills Required'),
              const SizedBox(height: 8),
              _skillInputRow(),
              const SizedBox(height: 8),
              _suggestedSkillsWrap(),
              const SizedBox(height: 8),
              _selectedSkillsBox(),
              const SizedBox(height: 20),

              _sectionLabel('Job Timing'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTiming,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'When do you need this done?',
                  prefixIcon: Icon(Icons.schedule, color: Colors.teal),
                ),
                items: _timingOptions
                    .map((o) =>
                        DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTiming = v),
                validator: (v) => v == null ? 'Select timing' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _budgetController,
                decoration: _inputDeco(
                  'Maximum Budget (PKR)',
                  Icons.payments_outlined,
                  prefix: 'PKR ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              _sectionLabel('Job Location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Type address or use GPS / Maps',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.teal),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isLocating ? null : _getCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : const Icon(Icons.my_location, size: 16),
                      label: Text(
                          _isLocating ? 'Getting GPS...' : 'Use GPS'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon:
                          const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Open Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_latitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'GPS confirmed: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ── Insurance ──────────────────────────────────
              _sectionLabel('Order Protection'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _wantsInsurance
                      ? Colors.blue.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _wantsInsurance
                        ? Colors.blue.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _wantsInsurance,
                      onChanged: (v) =>
                          setState(() => _wantsInsurance = v),
                      activeColor: Colors.blue,
                      title: const Text(
                        'Add Insurance Pack',
                        style: TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        '+20% of budget — Full protection & guaranteed completion',
                        style: TextStyle(fontSize: 12),
                      ),
                      secondary: Icon(
                        Icons.shield_outlined,
                        color: _wantsInsurance
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    if (_wantsInsurance)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 14),
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            _insuranceRow('Job Budget',
                                'PKR ${_budget.toStringAsFixed(0)}'),
                            _insuranceRow(
                                'Insurance (20%)',
                                'PKR ${_insuranceAmount.toStringAsFixed(0)}',
                                color: Colors.blue),
                            const Divider(height: 16),
                            _insuranceRow(
                              'Total to Pay',
                              'PKR ${_totalAmount.toStringAsFixed(0)}',
                              bold: true,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                    BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.info_outline,
                                        size: 14,
                                        color:
                                            Colors.blue.shade700),
                                    const SizedBox(width: 6),
                                    Text(
                                      'How Insurance Works',
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors
                                              .blue.shade700),
                                    ),
                                  ]),
                                  const SizedBox(height: 6),
                                  ...[
                                    '• Pay total amount to company account before work starts',
                                    '• Funds locked until work is completed',
                                    '• 3 days to claim if unsatisfied',
                                    '• If claimed: top expert + seller redo the job',
                                    '• Seller 50%, expert 40%, company keeps 10%',
                                  ].map((t) => Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                bottom: 3),
                                        child: Text(t,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue
                                                    .shade800)),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPosting ? null : _submitJob,
                  icon: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Icon(Icons.send),
                  label: Text(
                    _isPosting
                        ? 'Posting...'
                        : _wantsInsurance
                            ? 'Post Job with Insurance (PKR ${_totalAmount.toStringAsFixed(0)})'
                            : 'Post Job & Start Bidding',
                    style: const TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: _wantsInsurance
                        ? Colors.blue
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}