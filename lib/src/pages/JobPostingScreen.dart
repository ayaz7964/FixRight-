import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_session.dart';
import './BuyerOrdersPage.dart'; // ← adjust import to your path

class PostJobScreen extends StatefulWidget {
  final String? phoneUID; 
  const PostJobScreen({super.key ,  this.phoneUID });

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

  // ── Skills ─────────────────────────────────────────────────
  void _addSkill(String skill) {
    final t = skill.trim();
    if (t.isEmpty || _selectedSkills.contains(t)) return;
    setState(() => _selectedSkills.add(t));
    _skillInputController.clear();
  }

  void _removeSkill(String s) =>
      setState(() => _selectedSkills.remove(s));

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

  // ── Submit ─────────────────────────────────────────────────
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
        'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
        'orderType': 'simple',
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
        'postedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ✅ Navigate to buyer orders page after posting
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerOrdersPage(phoneUID: widget.phoneUID),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Job posted! Waiting for bids...'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      setState(() => _isPosting = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color));

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
                'Sellers will place competitive bids. Set your maximum budget.',
                Colors.teal,
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: _inputDeco(
                    'Job Title (e.g., Water Pump Repair)', Icons.title),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDeco(
                    'Describe the job in detail', Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Skills
              _sectionLabel('Skills Required'),
              const SizedBox(height: 8),
              _skillInputRow(),
              const SizedBox(height: 8),
              _suggestedSkillsWrap(),
              const SizedBox(height: 8),
              _selectedSkillsBox(),
              const SizedBox(height: 20),

              // Timing
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

              // Budget
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
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Location
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
                      icon: const Icon(Icons.map_outlined, size: 16),
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
                          size: 14, color: Colors.green.shade600),
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
              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPosting ? null : _submitJob,
                  icon: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: Text(
                    _isPosting ? 'Posting...' : 'Post Job & Start Bidding',
                    style: const TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
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