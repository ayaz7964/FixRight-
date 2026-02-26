import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  // Form fields
  late String firstName;
  late String lastName;
  late String mobileNumber;

  // Image selections
  XFile? cnicFrontImage;
  XFile? cnicBackImage;

  // Skills
  List<String> selectedSkills = [];
  bool isSubmitting = false;

  // Seller status and comments
  String sellerStatus = ''; // 'none', 'submitted', 'approved'
  String adminComments = '';
  bool isResubmission = false;
  String? existingSellerDocId;

  // All available skills (50+ common domestic services)
  final List<String> allSkills = [
    'Carpenter',
    'Electrician',
    'Plumber',
    'Mechanic',
    'Painter',
    'AC Technician',
    'Cleaner',
    'Driver',
    'Gardener',
    'Mason',
    'Welder',
    'CCTV Installer',
    'Appliance Repair',
    'Roofer',
    'Locksmith',
    'Solar Technician',
    'Plumbing Repair',
    'Electrical Wiring',
    'Door Repair',
    'Window Repair',
    'Furniture Repair',
    'Refrigerator Repair',
    'Washing Machine Repair',
    'Microwave Repair',
    'TV Repair',
    'Mobile Repair',
    'Computer Repair',
    'Laptop Repair',
    'Printer Repair',
    'Pest Control',
    'Tile Installer',
    'Concrete Worker',
    'Glass Installer',
    'Steel Fabricator',
    'Upholsterer',
    'Tailor',
    'Shoe Repair',
    'Jewelry Repair',
    'Watch Repair',
    'Electrical Panel Installation',
    'Safety Auditor',
    'Fire Safety Inspector',
    'Water Purification Technician',
    'Solar Panel Installer',
    'Heat Pump Technician',
    'HVAC Technician',
    'Gas Line Installation',
    'Valve Installation',
    'Pipe Fitting',
    'Water Tank Cleaning',
    'Septic Tank Cleaning',
    'Drain Cleaning',
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _checkExistingSellerDocument();
  }

  void _initializeUserData() {
    if (widget.userData is Map) {
      firstName = widget.userData['firstName'] ?? '';
      lastName = widget.userData['lastName'] ?? '';
      mobileNumber =
          widget.userData['phoneNumber'] ?? widget.userData['mobile'] ?? '';
    } else {
      firstName = '';
      lastName = '';
      mobileNumber = '';
    }
  }

  /// Check if seller document already exists and load its data
  Future<void> _checkExistingSellerDocument() async {
    try {
      final sellerDoc = await _firestore
          .collection('sellers')
          .doc(widget.uid)
          .get();
      if (sellerDoc.exists) {
        final data = sellerDoc.data();
        setState(() {
          sellerStatus = data?['status'] ?? '';
          adminComments = data?['comments'] ?? '';
          isResubmission = true;
          existingSellerDocId = widget.uid;

          // Pre-populate skills if resubmitting
          final skills = data?['skills'] as List?;
          if (skills != null) {
            selectedSkills = List<String>.from(skills);
          }
        });
      }
    } catch (e) {
      print('Error checking existing seller document: $e');
    }
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            cnicFrontImage = pickedFile;
          } else {
            cnicBackImage = pickedFile;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.add(skill);
      }
    });
  }

  Future<void> _submitSellerForm() async {
    // Validation
    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    if (cnicFrontImage == null || cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both CNIC images')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Create or update seller document in Firestore
      await _firestore.collection('sellers').doc(widget.uid).set({
        'uid': widget.uid,
        'firstName': firstName,
        'lastName': lastName,
        'mobileNumber': mobileNumber,
        'Available_Balance':0,
        'Deposit':0,
        'Earning':0,
        'Jobs_Completed':0,
        'Pending_Jobs':0,
        'Rating':5,
        'withdrawal_amount':0,
        'Total_Jobs':0,
        'cnicFrontUrl':
            'https://i.dawn.com/primary/2015/12/566683b21750f.jpg', // Dummy URL
        'cnicBackUrl':
            'https://i.dawn.com/primary/2015/12/566683b21750f.jpg', // Dummy URL
        'skills': selectedSkills,
        'status': 'submitted',
        'comments': '', // Clear previous comments when resubmitting
        'createdAt': isResubmission
            ? FieldValue.serverTimestamp()
            : Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isResubmission
                ? 'Form updated and resubmitted successfully'
                : 'Seller form submitted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting form: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isResubmission ? 'Update Your Application' : 'Become a Seller',
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Admin Comments Section (if resubmitting) ---
            if (isResubmission && adminComments.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Admin Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminComments,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please address the feedback and resubmit your application.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // --- Status Badge ---
            if (isResubmission)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sellerStatus == 'approved'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sellerStatus == 'approved' ? 'Approved ✓' : 'Under Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: sellerStatus == 'approved'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),

            // --- User Information Section ---
            const Text(
              'Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // First Name (Read-only)
            _buildReadOnlyField(
              label: 'First Name',
              value: firstName,
              icon: Icons.person,
            ),
            const SizedBox(height: 12),

            // Last Name (Read-only)
            _buildReadOnlyField(
              label: 'Last Name',
              value: lastName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),

            // Mobile Number (Read-only)
            _buildReadOnlyField(
              label: 'Mobile Number',
              value: mobileNumber,
              icon: Icons.phone,
            ),
            const SizedBox(height: 24),

            // --- CNIC Documents Section ---
            const Text(
              'CNIC Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // CNIC Front
            _buildImagePicker(
              title: 'CNIC Front',
              isSelected: cnicFrontImage != null,
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 12),

            // CNIC Back
            _buildImagePicker(
              title: 'CNIC Back',
              isSelected: cnicBackImage != null,
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 24),

            // --- Skills Section ---
            const Text(
              'Select Your Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selected: ${selectedSkills.length}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            // Skills Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: allSkills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return GestureDetector(
                  onTap: () => _toggleSkill(skill),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade600
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          else
                            Icon(
                              Icons.add,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              skill,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitSellerForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isResubmission
                            ? 'Update & Resubmit Application'
                            : 'Submit Seller Application',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: Icon(Icons.lock, color: Colors.grey.shade400, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.shade300,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 40,
                    )
                  : Icon(Icons.image, color: Colors.grey.shade600, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? 'Image selected ✓' : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.green.shade600
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
