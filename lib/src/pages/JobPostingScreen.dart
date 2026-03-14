// lib/pages/JobPostingScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/user_session.dart';

class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({super.key});

  @override
  State<JobPostingScreen> createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();

  // ── Job Timing dropdown ──────────────────────────────────────
  static const List<String> _timingOptions = [
    'Immediately',
    'Within 2 Hours',
    'Today',
    'Tomorrow',
    'This Week',
    'Flexible / Anytime',
  ];
  String? _selectedTiming;

  // ── Skills chip input ────────────────────────────────────────
  static const List<String> _suggestedSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'AC Repair',
    'Tiling',
    'Welding',
    'Gas Fitting',
    'Masonry',
    'Roof Repair',
  ];
  final List<String> _selectedSkills = [];
  final TextEditingController _skillInputController = TextEditingController();

  bool _isPosting = false; // shows loading while saving to Firestore

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    if (_selectedSkills.contains(trimmed)) return;
    setState(() => _selectedSkills.add(trimmed));
    _skillInputController.clear();
  }

  void _removeSkill(String skill) {
    setState(() => _selectedSkills.remove(skill));
  }

  /// Save job to Firestore and navigate back
  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final uid = UserSession().phoneUID ?? 'unknown';
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _titleController.text.trim(),
        'skills': _selectedSkills,
        'timing': _selectedTiming,
        'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
        'location': _locationController.text.trim(),
        'postedBy': uid,
        'status': 'open',
        'bidsCount': 0,
        'postedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Job Posted! Waiting for competitive bids...'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // ── Header ───────────────────────────────────────
              const Text(
                'Detail Your Job for Bidding',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Workers will place competitive bids. Set your maximum budget to facilitate the bargaining process.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Divider(height: 30),

              // ── Job Title ────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title (e.g., Water Pump Repair)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Please enter a job title' : null,
              ),
              const SizedBox(height: 20),

              // ── Skills Required ──────────────────────────────
              _sectionLabel('Skills Required'),
              const SizedBox(height: 8),

              // Input row
              Row(
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Suggested quick-add chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _suggestedSkills
                    .where((s) => !_selectedSkills.contains(s))
                    .map(
                      (skill) => ActionChip(
                        label: Text(skill, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(Icons.add, size: 14),
                        backgroundColor: Colors.teal.shade50,
                        side: BorderSide(color: Colors.teal.shade200),
                        onPressed: () => _addSkill(skill),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Selected skills display
              if (_selectedSkills.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Added Skills (${_selectedSkills.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _selectedSkills
                            .map(
                              (skill) => Chip(
                                label: Text(skill),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _removeSkill(skill),
                                backgroundColor: Colors.teal,
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                deleteIconColor: Colors.white,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text(
                      'No skills added yet — tap + or select from suggestions',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // ── Job Timing dropdown ──────────────────────────
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
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTiming = value),
                validator: (v) =>
                    v == null ? 'Please select when you need this done' : null,
              ),
              const SizedBox(height: 20),

              // ── Maximum Budget ───────────────────────────────
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Budget (PKR) — Workers will bid below this',
                  border: OutlineInputBorder(),
                  prefixText: 'PKR ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Please enter a budget' : null,
              ),
              const SizedBox(height: 20),

              // ── Location ─────────────────────────────────────
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Job Location (Tap to use GPS)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on, color: Colors.teal),
                ),
                readOnly: true,
                onTap: () {
                  /* TODO: Launch map picker */
                },
              ),
              const SizedBox(height: 30),

              // ── Submit Button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _submitJob,
                  // disabled while posting
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Post Job & Start Bidding',
                    style: TextStyle(fontSize: 18),
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

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      );
}
