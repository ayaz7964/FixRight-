// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../services/user_session.dart';
// import './cloudinary_service.dart';

// class PostOfferScreen extends StatefulWidget {
//   const PostOfferScreen({super.key});

//   @override
//   State<PostOfferScreen> createState() => _PostOfferScreenState();
// }

// class _PostOfferScreenState extends State<PostOfferScreen> {
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

//   // ── Helpers defined inside the class ──────────────────────
//   InputDecoration _inputDeco(String label, IconData icon,
//       {String? prefix}) =>
//       InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 20),
//         prefixText: prefix,
//         border: const OutlineInputBorder(),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       );

//   Widget _sectionLabel(String text) => Text(
//         text,
//         style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87),
//       );

//   Widget _infoBanner(String text, Color color) => Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, color: color),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(text,
//                   style: TextStyle(fontSize: 13, color: color)),
//             ),
//           ],
//         ),
//       );

//   // ── Image Picker ───────────────────────────────────────────
//   Future<void> _pickImage() async {
//     final XFile? picked = await ImagePicker()
//         .pickImage(source: ImageSource.gallery, imageQuality: 85);
//     if (picked != null) {
//       setState(() => _offerImageFile = File(picked.path));
//     }
//   }

//   // ── Skills ─────────────────────────────────────────────────
//   void _addSkill(String skill) {
//     final t = skill.trim();
//     if (t.isEmpty || _selectedSkills.contains(t)) return;
//     setState(() => _selectedSkills.add(t));
//     _skillInputController.clear();
//   }

//   void _removeSkill(String s) =>
//       setState(() => _selectedSkills.remove(s));

//   void _showSnack(String msg, Color color) =>
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(msg), backgroundColor: color));

//   // ── Submit ─────────────────────────────────────────────────
//   Future<void> _submitOffer() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedSkills.isEmpty) {
//       _showSnack('Add at least one skill', Colors.orange);
//       return;
//     }

//     setState(() => _isPosting = true);
//     try {
//       final uid = UserSession().phoneUID ?? 'unknown';

//       // Check seller approval
//       final sellerDoc = await FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(uid)
//           .get();
//       if (!sellerDoc.exists ||
//           (sellerDoc.data()?['status'] ?? '') != 'approved') {
//         _showSnack('Only approved sellers can post offers',
//             Colors.red);
//         setState(() => _isPosting = false);
//         return;
//       }

//       // Upload image if picked
//       String? imageUrl;
//       if (_offerImageFile != null) {
//         setState(() => _isUploadingImage = true);
//         imageUrl = await CloudinaryService.uploadImage(
//           _offerImageFile!,
//           folder: 'fixright/offers/$uid',
//         );
//         setState(() => _isUploadingImage = false);
//       }

//       final sellerData = sellerDoc.data() ?? {};
//       final sellerName =
//           '${sellerData['firstName'] ?? ''} ${sellerData['lastName'] ?? ''}'
//               .trim();

//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//       final sellerImage = userDoc.data()?['profileImage'] ?? '';

//       final offerId =
//           '${uid}_${DateTime.now().millisecondsSinceEpoch}';

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
//         'price':
//             double.tryParse(_priceController.text.trim()) ?? 0,
//         'deliveryTime': _deliveryTimeController.text.trim(),
//         'skills': _selectedSkills,
//         'imageUrl': imageUrl ?? '',
//         'status': 'active',
//         'ordersCount': 0,
//         'rating': sellerData['Rating'] ?? 5.0,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       Navigator.pop(context);
//       _showSnack(
//           '✅ Offer published! Buyers can now book you.',
//           Colors.green);
//     } catch (e) {
//       setState(() => _isPosting = false);
//       _showSnack('Error: $e', Colors.red);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post an Offer'),
//         backgroundColor: Colors.green.shade700,
//         foregroundColor: Colors.white,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _infoBanner(
//                 'Create a default service offer. Buyers can browse and book you directly.',
//                 Colors.green,
//               ),
//               const SizedBox(height: 20),

//               // ── Offer Image ────────────────────────────────
//               _sectionLabel('Offer Image (optional)'),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 150,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: _offerImageFile != null
//                           ? Colors.green
//                           : Colors.grey.shade300,
//                       width: 2,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.grey.shade50,
//                   ),
//                   child: _offerImageFile != null
//                       ? ClipRRect(
//                           borderRadius:
//                               BorderRadius.circular(8),
//                           child: Image.file(_offerImageFile!,
//                               fit: BoxFit.cover),
//                         )
//                       : Column(
//                           mainAxisAlignment:
//                               MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                                 Icons
//                                     .add_photo_alternate_outlined,
//                                 size: 36,
//                                 color: Colors.grey[400]),
//                             const SizedBox(height: 6),
//                             Text('Tap to add image',
//                                 style: TextStyle(
//                                     color: Colors.grey[500])),
//                           ],
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 14),

//               // ── Title ──────────────────────────────────────
//               TextFormField(
//                 controller: _titleController,
//                 decoration: _inputDeco(
//                     'Offer Title (e.g., Expert AC Repair)',
//                     Icons.title),
//                 validator: (v) =>
//                     v == null || v.trim().isEmpty
//                         ? 'Required'
//                         : null,
//               ),
//               const SizedBox(height: 14),

//               // ── Description ────────────────────────────────
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: _inputDeco(
//                     'Describe your service in detail',
//                     Icons.description),
//                 maxLines: 4,
//                 validator: (v) =>
//                     v == null || v.trim().isEmpty
//                         ? 'Required'
//                         : null,
//               ),
//               const SizedBox(height: 14),

//               // ── Price + Delivery Time ──────────────────────
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _priceController,
//                       decoration: _inputDeco(
//                           'Starting Price (PKR)',
//                           Icons.payments_outlined,
//                           prefix: 'PKR '),
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       validator: (v) =>
//                           v == null || v.trim().isEmpty
//                               ? 'Required'
//                               : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _deliveryTimeController,
//                       decoration: _inputDeco(
//                           'Delivery Time', Icons.schedule),
//                       validator: (v) =>
//                           v == null || v.trim().isEmpty
//                               ? 'Required'
//                               : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // ── Skills ─────────────────────────────────────
//               _sectionLabel('Skills / Services'),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _skillInputController,
//                       decoration: InputDecoration(
//                         hintText: 'Add a skill',
//                         border: const OutlineInputBorder(),
//                         contentPadding:
//                             const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 12),
//                       ),
//                       onFieldSubmitted: _addSkill,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () =>
//                         _addSkill(_skillInputController.text),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(48, 50),
//                       shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(8)),
//                     ),
//                     child: const Icon(Icons.add),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Suggested chips
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 4,
//                 children: _suggestedSkills
//                     .where((s) => !_selectedSkills.contains(s))
//                     .map((s) => ActionChip(
//                           label: Text(s,
//                               style: const TextStyle(
//                                   fontSize: 12)),
//                           avatar: const Icon(Icons.add,
//                               size: 14),
//                           backgroundColor:
//                               Colors.green.shade50,
//                           side: BorderSide(
//                               color: Colors.green.shade200),
//                           onPressed: () => _addSkill(s),
//                         ))
//                     .toList(),
//               ),
//               const SizedBox(height: 8),

//               // Selected skills
//               if (_selectedSkills.isNotEmpty)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border:
//                         Border.all(color: Colors.green.shade200),
//                   ),
//                   child: Wrap(
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: _selectedSkills
//                         .map((s) => Chip(
//                               label: Text(s),
//                               deleteIcon: const Icon(
//                                   Icons.close,
//                                   size: 16),
//                               onDeleted: () => _removeSkill(s),
//                               backgroundColor: Colors.green,
//                               labelStyle: const TextStyle(
//                                   color: Colors.white),
//                               deleteIconColor: Colors.white,
//                               side: BorderSide.none,
//                             ))
//                         .toList(),
//                   ),
//                 ),
//               const SizedBox(height: 30),

//               // ── Submit ─────────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _isPosting ? null : _submitOffer,
//                   icon: _isPosting
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white))
//                       : const Icon(Icons.local_offer),
//                   label: Text(
//                     _isPosting
//                         ? (_isUploadingImage
//                             ? 'Uploading image...'
//                             : 'Publishing...')
//                         : 'Publish Offer',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 15),
//                     backgroundColor: Colors.green.shade700,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor:
//                         Colors.grey.shade300,
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(10)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_session.dart';
import './cloudinary_service.dart';

// ═══════════════════════════════════════════════════════════════
//  POST OFFER SCREEN
//  KEY CHANGE: saves 'sellerCity' on the offer document
//  so AllOffersScreen can filter by city WITHOUT a composite index.
// ═══════════════════════════════════════════════════════════════
class PostOfferScreen extends StatefulWidget {
  const PostOfferScreen({super.key});
  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _priceCtrl       = TextEditingController();
  final _deliveryCtrl    = TextEditingController();
  final _skillInputCtrl  = TextEditingController();

  final List<String> _selectedSkills = [];
  File? _imageFile;
  bool _isPosting   = false;
  bool _uploading   = false;

  static const _teal = Color(0xFF00695C);

  static const List<String> _suggestedSkills = [
    'Plumbing', 'Electrical', 'Carpentry', 'Painting',
    'AC Repair', 'Tiling', 'Welding', 'Gas Fitting',
    'Masonry', 'Roof Repair', 'Gardening', 'Cleaning',
    'Washing Machine', 'Fridge Repair', 'Solar Panel', 'CCTV',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _deliveryCtrl.dispose(); _skillInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (f != null) setState(() => _imageFile = File(f.path));
  }

  void _addSkill(String s) {
    final t = s.trim();
    if (t.isEmpty || _selectedSkills.contains(t)) return;
    setState(() => _selectedSkills.add(t));
    _skillInputCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _selectedSkills.remove(s));

  void _snack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      _snack('Add at least one skill', Colors.orange);
      return;
    }
    setState(() => _isPosting = true);
    try {
      final uid = UserSession().phoneUID ?? 'unknown';
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers').doc(uid).get();
      if (!sellerDoc.exists ||
          (sellerDoc.data()?['status'] ?? '') != 'approved') {
        _snack('Only approved sellers can post offers', Colors.red);
        setState(() => _isPosting = false);
        return;
      }

      // Upload image
      String? imageUrl;
      if (_imageFile != null) {
        setState(() => _uploading = true);
        imageUrl = await CloudinaryService.uploadImage(
            _imageFile!, folder: 'fixright/offers/$uid');
        setState(() => _uploading = false);
      }

      final sData    = sellerDoc.data() ?? {};
      final sellerName = '${sData['firstName'] ?? ''} ${sData['lastName'] ?? ''}'.trim();
      // ✅ Key: store seller's city on the offer for city-based filtering
      final sellerCity = (sData['city'] as String? ?? '').trim();

      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      final sellerImage = userDoc.data()?['profileImage'] as String? ?? '';

      final offerId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('sellers').doc(uid)
          .collection('offers').doc(offerId)
          .set({
        'offerId':      offerId,
        'sellerId':     uid,
        'sellerName':   sellerName,
        'sellerImage':  sellerImage,
        'sellerCity':   sellerCity,   // ✅ stored for city filter
        'title':        _titleCtrl.text.trim(),
        'description':  _descCtrl.text.trim(),
        'price':        double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'deliveryTime': _deliveryCtrl.text.trim(),
        'skills':       _selectedSkills,
        'imageUrl':     imageUrl ?? '',
        'status':       'active',
        'ordersCount':  0,
        'rating':       (sData['Rating'] ?? 5.0).toDouble(),
        'createdAt':    FieldValue.serverTimestamp(),
        'updatedAt':    FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _snack('✅ Offer published! Buyers in $sellerCity can now find you.', Colors.green);
    } catch (e) {
      setState(() => _isPosting = false);
      _snack('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: _teal, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Post a Service Offer', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _infoBanner('Create a service offer. Buyers in your city can browse and hire you directly.', _teal),
            const SizedBox(height: 20),

            // Image picker
            _sectionLabel('Cover Image (optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: _imageFile != null ? _teal : Colors.grey.shade300,
                      width: _imageFile != null ? 2 : 1),
                  borderRadius: BorderRadius.circular(16)),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: Colors.grey[350]),
                        const SizedBox(height: 8),
                        Text('Tap to add cover image',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            _sectionLabel('Offer Title'),
            const SizedBox(height: 6),
            _field(_titleCtrl, 'e.g. Professional AC Repair & Cleaning', Icons.title,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            // Description
            _sectionLabel('Description'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl, maxLines: 4,
              decoration: _deco('Describe your service in detail — experience, tools, guarantee…', Icons.description_outlined),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            // Price + delivery
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Starting Price (PKR)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _deco('PKR', Icons.payments_outlined),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Delivery Time'),
                const SizedBox(height: 6),
                _field(_deliveryCtrl, 'e.g. Same day', Icons.schedule_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              ])),
            ]),
            const SizedBox(height: 20),

            // Skills
            _sectionLabel('Skills / Services'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _skillInputCtrl,
                decoration: _deco('Add a skill', Icons.add_circle_outline),
                onFieldSubmitted: _addSkill)),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addSkill(_skillInputCtrl.text),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _teal, foregroundColor: Colors.white,
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6,
                children: _suggestedSkills
                    .where((s) => !_selectedSkills.contains(s))
                    .map((s) => GestureDetector(
                      onTap: () => _addSkill(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _teal.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _teal.withOpacity(0.2))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add, size: 13, color: _teal),
                          const SizedBox(width: 4),
                          Text(s, style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w600)),
                        ])),
                    )).toList()),
            if (_selectedSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: _teal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _teal.withOpacity(0.15))),
                child: Wrap(spacing: 8, runSpacing: 6,
                    children: _selectedSkills.map((s) => Chip(
                      label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                      deleteIcon: const Icon(Icons.close, size: 15, color: Colors.white),
                      onDeleted: () => _removeSkill(s),
                      backgroundColor: _teal,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    )).toList()),
              ),
            ],
            const SizedBox(height: 32),

            // Submit
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _isPosting ? null : _submit,
              icon: _isPosting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.local_offer_rounded, size: 20),
              label: Text(
                _isPosting
                    ? (_uploading ? 'Uploading image…' : 'Publishing…')
                    : 'Publish Offer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87));

  Widget _field(TextEditingController c, String hint, IconData icon,
      {String? Function(String?)? validator}) =>
    TextFormField(controller: c, validator: validator, decoration: _deco(hint, icon));

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.5),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _teal, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Colors.red)),
  );

  Widget _infoBanner(String text, Color color) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: color, size: 18),
      const SizedBox(width: 9),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: color, height: 1.4))),
    ]));
}