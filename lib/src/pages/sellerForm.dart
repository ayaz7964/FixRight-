// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

// class Sellerform extends StatefulWidget {
//   final String? uid;
//   final dynamic userData;

//   const Sellerform({super.key, required this.uid, required this.userData});

//   @override
//   State<Sellerform> createState() => _SellerformState();
// }

// class _SellerformState extends State<Sellerform> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _imagePicker = ImagePicker();

//   // Form fields
//   late String firstName;
//   late String lastName;
//   late String mobileNumber;

//   // Image selections
//   XFile? cnicFrontImage;
//   XFile? cnicBackImage;

//   // Skills
//   List<String> selectedSkills = [];
//   bool isSubmitting = false;

//   // Seller status and comments
//   String sellerStatus = ''; // 'none', 'submitted', 'approved'
//   String adminComments = '';
//   bool isResubmission = false;
//   String? existingSellerDocId;

//   // All available skills (50+ common domestic services)
//   final List<String> allSkills = [
//     'Carpenter',
//     'Electrician',
//     'Plumber',
//     'Mechanic',
//     'Painter',
//     'AC Technician',
//     'Cleaner',
//     'Driver',
//     'Gardener',
//     'Mason',
//     'Welder',
//     'CCTV Installer',
//     'Appliance Repair',
//     'Roofer',
//     'Locksmith',
//     'Solar Technician',
//     'Plumbing Repair',
//     'Electrical Wiring',
//     'Door Repair',
//     'Window Repair',
//     'Furniture Repair',
//     'Refrigerator Repair',
//     'Washing Machine Repair',
//     'Microwave Repair',
//     'TV Repair',
//     'Mobile Repair',
//     'Computer Repair',
//     'Laptop Repair',
//     'Printer Repair',
//     'Pest Control',
//     'Tile Installer',
//     'Concrete Worker',
//     'Glass Installer',
//     'Steel Fabricator',
//     'Upholsterer',
//     'Tailor',
//     'Shoe Repair',
//     'Jewelry Repair',
//     'Watch Repair',
//     'Electrical Panel Installation',
//     'Safety Auditor',
//     'Fire Safety Inspector',
//     'Water Purification Technician',
//     'Solar Panel Installer',
//     'Heat Pump Technician',
//     'HVAC Technician',
//     'Gas Line Installation',
//     'Valve Installation',
//     'Pipe Fitting',
//     'Water Tank Cleaning',
//     'Septic Tank Cleaning',
//     'Drain Cleaning',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserData();
//     _checkExistingSellerDocument();
//   }

//   void _initializeUserData() {
//     if (widget.userData is Map) {
//       firstName = widget.userData['firstName'] ?? '';
//       lastName = widget.userData['lastName'] ?? '';
//       mobileNumber =
//           widget.userData['phoneNumber'] ?? widget.userData['mobile'] ?? '';
//     } else {
//       firstName = '';
//       lastName = '';
//       mobileNumber = '';
//     }
//   }

//   /// Check if seller document already exists and load its data
//   Future<void> _checkExistingSellerDocument() async {
//     try {
//       final sellerDoc = await _firestore
//           .collection('sellers')
//           .doc(widget.uid)
//           .get();
//       if (sellerDoc.exists) {
//         final data = sellerDoc.data();
//         setState(() {
//           sellerStatus = data?['status'] ?? '';
//           adminComments = data?['comments'] ?? '';
//           isResubmission = true;
//           existingSellerDocId = widget.uid;

//           // Pre-populate skills if resubmitting
//           final skills = data?['skills'] as List?;
//           if (skills != null) {
//             selectedSkills = List<String>.from(skills);
//           }
//         });
//       }
//     } catch (e) {
//       print('Error checking existing seller document: $e');
//     }
//   }

//   Future<void> _pickImage(bool isFront) async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           if (isFront) {
//             cnicFrontImage = pickedFile;
//           } else {
//             cnicBackImage = pickedFile;
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
//     }
//   }

//   void _toggleSkill(String skill) {
//     setState(() {
//       if (selectedSkills.contains(skill)) {
//         selectedSkills.remove(skill);
//       } else {
//         selectedSkills.add(skill);
//       }
//     });
//   }

//   Future<void> _submitSellerForm() async {
//     // Validation
//     if (selectedSkills.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select at least one skill')),
//       );
//       return;
//     }

//     if (cnicFrontImage == null || cnicBackImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please upload both CNIC images')),
//       );
//       return;
//     }

//     setState(() => isSubmitting = true);

//     try {
//       // Create or update seller document in Firestore
//       await _firestore.collection('sellers').doc(widget.uid).set({
//         'uid': widget.uid,
//         'firstName': firstName,
//         'lastName': lastName,
//         'mobileNumber': mobileNumber,
//         'Available_Balance':0,
//         'Deposit':0,
//         'Earning':0,
//         'Jobs_Completed':0,
//         'Pending_Jobs':0,
//         'Rating':5,
//         'withdrawal_amount':0,
//         'Total_Jobs':0,
//         'cnicFrontUrl':
//             'https://i.dawn.com/primary/2015/12/566683b21750f.jpg', // Dummy URL
//         'cnicBackUrl':
//             'https://i.dawn.com/primary/2015/12/566683b21750f.jpg', // Dummy URL
//         'skills': selectedSkills,
//         'status': 'submitted',
//         'comments': '', // Clear previous comments when resubmitting
//         'createdAt': isResubmission
//             ? FieldValue.serverTimestamp()
//             : Timestamp.now(),
//         'updatedAt': Timestamp.now(),
//       }, SetOptions(merge: true));

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isResubmission
//                 ? 'Form updated and resubmitted successfully'
//                 : 'Seller form submitted successfully',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate back
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => isSubmitting = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error submitting form: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           isResubmission ? 'Update Your Application' : 'Become a Seller',
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Admin Comments Section (if resubmitting) ---
//             if (isResubmission && adminComments.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   border: Border.all(color: Colors.blue.shade300, width: 1.5),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info, color: Colors.blue.shade600, size: 20),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Admin Feedback',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       adminComments,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade800,
//                         height: 1.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Please address the feedback and resubmit your application.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue.shade600,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             // --- Status Badge ---
//             if (isResubmission)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: sellerStatus == 'approved'
//                         ? Colors.green.shade100
//                         : Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     sellerStatus == 'approved' ? 'Approved ✓' : 'Under Review',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: sellerStatus == 'approved'
//                           ? Colors.green.shade700
//                           : Colors.orange.shade700,
//                     ),
//                   ),
//                 ),
//               ),

//             // --- User Information Section ---
//             const Text(
//               'Your Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // First Name (Read-only)
//             _buildReadOnlyField(
//               label: 'First Name',
//               value: firstName,
//               icon: Icons.person,
//             ),
//             const SizedBox(height: 12),

//             // Last Name (Read-only)
//             _buildReadOnlyField(
//               label: 'Last Name',
//               value: lastName,
//               icon: Icons.person_outline,
//             ),
//             const SizedBox(height: 12),

//             // Mobile Number (Read-only)
//             _buildReadOnlyField(
//               label: 'Mobile Number',
//               value: mobileNumber,
//               icon: Icons.phone,
//             ),
//             const SizedBox(height: 24),

//             // --- CNIC Documents Section ---
//             const Text(
//               'CNIC Documents',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // CNIC Front
//             _buildImagePicker(
//               title: 'CNIC Front',
//               isSelected: cnicFrontImage != null,
//               onTap: () => _pickImage(true),
//             ),
//             const SizedBox(height: 12),

//             // CNIC Back
//             _buildImagePicker(
//               title: 'CNIC Back',
//               isSelected: cnicBackImage != null,
//               onTap: () => _pickImage(false),
//             ),
//             const SizedBox(height: 24),

//             // --- Skills Section ---
//             const Text(
//               'Select Your Skills',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Selected: ${selectedSkills.length}',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//             ),
//             const SizedBox(height: 12),

//             // Skills Grid
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               childAspectRatio: 3.5,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               children: allSkills.map((skill) {
//                 final isSelected = selectedSkills.contains(skill);
//                 return GestureDetector(
//                   onTap: () => _toggleSkill(skill),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.blue.shade600
//                           : Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected
//                             ? Colors.blue.shade600
//                             : Colors.grey.shade400,
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (isSelected)
//                             const Icon(
//                               Icons.check,
//                               color: Colors.white,
//                               size: 18,
//                             )
//                           else
//                             Icon(
//                               Icons.add,
//                               color: Colors.grey.shade600,
//                               size: 18,
//                             ),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               skill,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 32),

//             // Submit Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: isSubmitting ? null : _submitSellerForm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: isSubmitting
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                         isResubmission
//                             ? 'Update & Resubmit Application'
//                             : 'Submit Seller Application',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyField({
//     required String label,
//     required String value,
//     required IconData icon,
//   }) {
//     return TextField(
//       controller: TextEditingController(text: value),
//       readOnly: true,
//       enabled: false,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.grey.shade600),
//         suffixIcon: Icon(Icons.lock, color: Colors.grey.shade400, size: 18),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         contentPadding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//     );
//   }

//   Widget _buildImagePicker({
//     required String title,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? Colors.green : Colors.grey.shade400,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(8),
//           color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6),
//                 color: Colors.grey.shade300,
//               ),
//               child: isSelected
//                   ? Icon(
//                       Icons.check_circle,
//                       color: Colors.green.shade600,
//                       size: 40,
//                     )
//                   : Icon(Icons.image, color: Colors.grey.shade600, size: 32),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     isSelected ? 'Image selected ✓' : 'Tap to upload',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: isSelected
//                           ? Colors.green.shade600
//                           : Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.grey.shade600,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import './cloudinary_service.dart';   // ← same import used in buyer_orders_page.dart

class Sellerform extends StatefulWidget {
  final String? uid;
  final dynamic userData;
  const Sellerform({super.key, required this.uid, required this.userData});
  @override
  State<Sellerform> createState() => _SellerformState();
}

class _SellerformState extends State<Sellerform> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late String firstName, lastName, mobileNumber;

  // ── CNIC images ───────────────────────────────────────────
  XFile? cnicFrontImage;
  XFile? cnicBackImage;
  bool _uploadingFront = false;
  bool _uploadingBack  = false;
  // Holds the Cloudinary URL after upload
  String? _cnicFrontUrl;
  String? _cnicBackUrl;

  List<String> selectedSkills = [];
  bool isSubmitting = false;

  String sellerStatus   = '';
  String adminComments  = '';
  bool   isResubmission = false;
  String? existingSellerDocId;

  final List<String> allSkills = [
    'Carpenter','Electrician','Plumber','Mechanic','Painter','AC Technician',
    'Cleaner','Driver','Gardener','Mason','Welder','CCTV Installer',
    'Appliance Repair','Roofer','Locksmith','Solar Technician','Plumbing Repair',
    'Electrical Wiring','Door Repair','Window Repair','Furniture Repair',
    'Refrigerator Repair','Washing Machine Repair','Microwave Repair','TV Repair',
    'Mobile Repair','Computer Repair','Laptop Repair','Printer Repair',
    'Pest Control','Tile Installer','Concrete Worker','Glass Installer',
    'Steel Fabricator','Upholsterer','Tailor','Shoe Repair','Jewelry Repair',
    'Watch Repair','Electrical Panel Installation','Safety Auditor',
    'Fire Safety Inspector','Water Purification Technician','Solar Panel Installer',
    'Heat Pump Technician','HVAC Technician','Gas Line Installation',
    'Valve Installation','Pipe Fitting','Water Tank Cleaning',
    'Septic Tank Cleaning','Drain Cleaning',
  ];

  // ── Init ──────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initUserData();
    _checkExistingSellerDocument();
  }

  void _initUserData() {
    if (widget.userData is Map) {
      firstName    = widget.userData['firstName']   ?? '';
      lastName     = widget.userData['lastName']    ?? '';
      mobileNumber = widget.userData['phoneNumber'] ?? widget.userData['mobile'] ?? '';
    } else { firstName = ''; lastName = ''; mobileNumber = ''; }
  }

  Future<void> _checkExistingSellerDocument() async {
    try {
      final doc = await _firestore.collection('sellers').doc(widget.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          sellerStatus        = data['status']   ?? '';
          adminComments       = data['comments'] ?? '';
          isResubmission      = true;
          existingSellerDocId = widget.uid;
          final skills = data['skills'] as List?;
          if (skills != null) selectedSkills = List<String>.from(skills);
          _cnicFrontUrl = data['cnicFrontUrl'];
          _cnicBackUrl  = data['cnicBackUrl'];
        });
      }
    } catch (e) { debugPrint('Seller doc check: $e'); }
  }

  // ── Pick + Upload CNIC ────────────────────────────────────
  Future<void> _pickAndUpload({required bool isFront}) async {
    final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() { isFront ? _uploadingFront = true : _uploadingBack = true; });

    try {
      final file   = File(picked.path);
      final folder = 'fixright/cnic/${widget.uid}';
      final url    = await CloudinaryService.uploadImage(file, folder: folder);

      if (url != null && url.isNotEmpty) {
        setState(() {
          if (isFront) { cnicFrontImage = picked; _cnicFrontUrl = url; }
          else         { cnicBackImage  = picked; _cnicBackUrl  = url; }
        });
      } else {
        _snack('Upload failed — please try again', Colors.red);
      }
    } catch (e) {
      _snack('Upload error: $e', Colors.red);
    } finally {
      setState(() { isFront ? _uploadingFront = false : _uploadingBack = false; });
    }
  }

  void _toggleSkill(String skill) => setState(() {
    selectedSkills.contains(skill) ? selectedSkills.remove(skill) : selectedSkills.add(skill);
  });

  // ── Submit ────────────────────────────────────────────────
  Future<void> _submitSellerForm() async {
    if (selectedSkills.isEmpty) { _snack('Please select at least one skill', Colors.orange); return; }
    if (_cnicFrontUrl == null || _cnicBackUrl == null) {
      _snack('Please upload both CNIC images', Colors.orange);
      return;
    }
    setState(() => isSubmitting = true);
    try {
      await _firestore.collection('sellers').doc(widget.uid).set({
        'uid': widget.uid,
        'firstName': firstName, 'lastName': lastName, 'mobileNumber': mobileNumber,
        'Available_Balance': 0, 'Deposit': 0, 'Earning': 0,
        'Jobs_Completed': 0, 'Pending_Jobs': 0, 'Rating': 5,
        'withdrawal_amount': 0, 'Total_Jobs': 0,
        'cnicFrontUrl': _cnicFrontUrl,   // ✅ real Cloudinary URL
        'cnicBackUrl':  _cnicBackUrl,    // ✅ real Cloudinary URL
        'skills': selectedSkills,
        'status': 'submitted',
        'comments': '',
        'createdAt': isResubmission ? FieldValue.serverTimestamp() : Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      _snack(isResubmission ? 'Application updated & resubmitted!' : 'Application submitted successfully!', Colors.green);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => isSubmitting = false);
      _snack('Error: $e', Colors.red);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00695C);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isResubmission ? 'Update Application' : 'Become a Seller',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Admin feedback banner ──────────────────────────
          if (isResubmission && adminComments.isNotEmpty)
            _FeedbackBanner(comment: adminComments),

          // ── Status pill ────────────────────────────────────
          if (isResubmission) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sellerStatus == 'approved' ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sellerStatus == 'approved' ? '✓  Approved' : '⏳  Under Review',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: sellerStatus == 'approved' ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
          ],

          // ── Section: Your Info ─────────────────────────────
          _sectionLabel('Your Information'),
          const SizedBox(height: 12),
          _readOnlyField('First Name',   firstName,    Icons.person_outline),
          const SizedBox(height: 10),
          _readOnlyField('Last Name',    lastName,     Icons.badge_outlined),
          const SizedBox(height: 10),
          _readOnlyField('Phone Number', mobileNumber, Icons.phone_outlined),
          const SizedBox(height: 24),

          // ── Section: CNIC ──────────────────────────────────
          _sectionLabel('CNIC Documents'),
          const SizedBox(height: 4),
          Text('Upload clear photos of both sides of your CNIC.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _CnicUploadCard(
              label: 'CNIC Front', icon: Icons.credit_card_outlined,
              imageFile: cnicFrontImage, uploadedUrl: _cnicFrontUrl,
              uploading: _uploadingFront,
              onTap: () => _pickAndUpload(isFront: true),
            )),
            const SizedBox(width: 12),
            Expanded(child: _CnicUploadCard(
              label: 'CNIC Back', icon: Icons.credit_card,
              imageFile: cnicBackImage, uploadedUrl: _cnicBackUrl,
              uploading: _uploadingBack,
              onTap: () => _pickAndUpload(isFront: false),
            )),
          ]),
          const SizedBox(height: 28),

          // ── Section: Skills ────────────────────────────────
          Row(children: [
            Expanded(child: _sectionLabel('Select Your Skills')),
            if (selectedSkills.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(16)),
              child: Text('${selectedSkills.length} selected',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('Choose all services you can provide.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8, runSpacing: 8,
            children: allSkills.map((skill) {
              final selected = selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () => _toggleSkill(skill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color:  selected ? teal : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: selected ? teal : Colors.grey.shade300),
                    boxShadow: selected ? [BoxShadow(color: teal.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))] : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (selected) const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(Icons.check_rounded, size: 13, color: Colors.white),
                    ),
                    Text(skill, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : Colors.black87,
                    )),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          // ── Submit ─────────────────────────────────────────
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitSellerForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isSubmitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    isResubmission ? 'Update & Resubmit Application' : 'Submit Application',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
  );

  Widget _readOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enabled: false,
      style: const TextStyle(fontSize: 14, color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        suffixIcon: Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[400]),
        filled: true, fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }
}

// ── CNIC Upload Card ──────────────────────────────────────────
class _CnicUploadCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final XFile? imageFile;
  final String? uploadedUrl;
  final bool uploading;
  final VoidCallback onTap;
  const _CnicUploadCard({
    required this.label, required this.icon, required this.onTap,
    this.imageFile, this.uploadedUrl, this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF00695C);
    final isDone = uploadedUrl != null && uploadedUrl!.isNotEmpty;

    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 130,
        decoration: BoxDecoration(
          color: isDone ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? Colors.green.shade400 : (uploading ? teal : Colors.grey.shade300),
            width: isDone || uploading ? 2 : 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: uploading
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircularProgressIndicator(color: Color(0xFF00695C), strokeWidth: 2.5),
                SizedBox(height: 10),
                Text('Uploading…', style: TextStyle(fontSize: 12, color: Color(0xFF00695C), fontWeight: FontWeight.w600)),
              ]))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green.shade100 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.check_circle_rounded : icon,
                    size: 26,
                    color: isDone ? Colors.green.shade600 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 3),
                Text(
                  isDone ? '✓ Uploaded' : 'Tap to upload',
                  style: TextStyle(fontSize: 11.5, color: isDone ? Colors.green.shade600 : Colors.grey[500]),
                ),
              ]),
      ),
    );
  }
}

// ── Admin Feedback Banner ─────────────────────────────────────
class _FeedbackBanner extends StatelessWidget {
  final String comment;
  const _FeedbackBanner({required this.comment});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.blue.shade200, width: 1.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.admin_panel_settings_outlined, color: Colors.blue.shade600, size: 18),
        const SizedBox(width: 8),
        Text('Admin Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue.shade800)),
      ]),
      const SizedBox(height: 8),
      Text(comment, style: TextStyle(fontSize: 13.5, color: Colors.grey[800], height: 1.5)),
      const SizedBox(height: 8),
      Text('Please address the feedback above and resubmit your application.',
        style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontStyle: FontStyle.italic)),
    ]),
  );
}