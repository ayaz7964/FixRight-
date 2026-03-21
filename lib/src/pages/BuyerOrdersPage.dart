

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/user_session.dart';
import './cloudinary_service.dart';
import 'notification_service.dart';
import 'tts_translation_service.dart';
import 'rating_feedback_widget.dart';
import 'commission_service.dart';
import 'ChatDetailScreen.dart';

const int kFreeOrderLimit = 3;
const double kInsuranceRate = 0.20;
const double kSellerMinBalance = 500.0;

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
    _tabController = TabController(length: 4, vsync: this);
    _uid = _resolveUid();
    TtsTranslationService().init();
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          const GlobalLanguageButton(color: Colors.teal),
          if (_uid.isNotEmpty)
            NotificationBell(
              uid: _uid,
              color: Colors.teal,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationsPage(uid: _uid))),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _uid.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text('Could not identify user',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Please log out and log in again.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ]),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _JobsList(uid: _uid, status: 'open'),
                _InProgressList(uid: _uid),
                _CompletedList(uid: _uid),
                _BuyerHistoryTab(uid: _uid),
              ],
            ),
    );
  }
}

// ── Lists ──────────────────────────────────────────────────────
class _JobsList extends StatelessWidget {
  final String uid, status;
  const _JobsList({required this.uid, required this.status});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('postedBy', isEqualTo: uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        if (snap.hasError)
          return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
        final docs = (snap.data?.docs ?? [])
          ..sort((a, b) {
            final aT = (a.data() as Map)['postedAt'] as Timestamp?;
            final bT = (b.data() as Map)['postedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        if (docs.isEmpty) return _EmptyState(status: status);
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return _JobCard(jobData: d, jobId: docs[i].id, buyerUid: uid);
          },
        );
      },
    );
  }
}

class _InProgressList extends StatelessWidget {
  final String uid;
  const _InProgressList({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        final docs = (snap.data?.docs ?? []).where((d) {
          final s = (d.data() as Map)['status'];
          return s == 'in_progress' ||
              s == 'pending_payment' ||
              s == 'payment_submitted' ||
              s == 'claim_pending' ||
              s == 'expert_assigned';
        }).toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['updatedAt'] as Timestamp?;
            final bT = (b.data() as Map)['updatedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        if (docs.isEmpty) return const _EmptyState(status: 'in_progress');
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return _JobCard(jobData: d, jobId: docs[i].id, buyerUid: uid);
          },
        );
      },
    );
  }
}

class _CompletedList extends StatelessWidget {
  final String uid;
  const _CompletedList({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('postedBy', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        final docs = (snap.data?.docs ?? []).where((d) {
          final s = (d.data() as Map)['status'];
          return s == 'completed' || s == 'expert_completed';
        }).toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['completedAt'] as Timestamp?;
            final bT = (b.data() as Map)['completedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        if (docs.isEmpty) return const _EmptyState(status: 'completed');
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return _JobCard(jobData: d, jobId: docs[i].id, buyerUid: uid);
          },
        );
      },
    );
  }
}

// ── Job Card ──────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId, buyerUid;
  const _JobCard({required this.jobData, required this.jobId, required this.buyerUid});

  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] as String? ?? 'Untitled Job';
    final budget = (jobData['budget'] ?? 0).toDouble();
    final location = jobData['location'] as String? ?? 'No location';
    final timing = jobData['timing'] as String? ?? '';
    final status = jobData['status'] as String? ?? 'open';
    final bidsCount = jobData['bidsCount'] ?? 0;
    final skills = List<String>.from(jobData['skills'] ?? []);
    final postedAt = jobData['postedAt'] as Timestamp?;
    final dateStr = postedAt != null
        ? DateFormat('dd MMM yyyy').format(postedAt.toDate())
        : 'Just now';
    final description = jobData['description'] as String? ?? '';
    final city = jobData['city'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid))),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (city.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.location_city, size: 12, color: Colors.teal.shade400),
                    const SizedBox(width: 2),
                    Text(city, style: TextStyle(fontSize: 11, color: Colors.teal.shade600, fontWeight: FontWeight.w600)),
                  ],
                ]),
              ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('PKR ${budget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                _StatusBadge(status: status),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(child: Text(timing, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: skills.take(4).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.teal.shade200)),
                  child: Text(s, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                )).toList(),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                JobListenRow(title: title, description: description, location: location, timing: timing, jobId: jobId),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bidsCount > 0 ? Colors.orange.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: bidsCount > 0 ? Colors.orange.shade300 : Colors.grey.shade300),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.gavel, size: 14, color: bidsCount > 0 ? Colors.orange : Colors.grey),
                    const SizedBox(width: 6),
                    Text('$bidsCount ${bidsCount == 1 ? 'Bid' : 'Bids'}', style: TextStyle(fontWeight: FontWeight.bold, color: bidsCount > 0 ? Colors.orange : Colors.grey, fontSize: 13)),
                  ]),
                ),
                const Spacer(),
                if (status == 'open')
                  Flexible(child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid))),
                    icon: const Icon(Icons.visibility, size: 16), label: const Text('View Bids'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )),
                if (status == 'pending_payment' || status == 'payment_submitted')
                  Flexible(child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid))),
                    icon: const Icon(Icons.payment, size: 16),
                    label: Text(status == 'payment_submitted' ? 'Pending Review' : 'Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'payment_submitted' ? Colors.purple : Colors.orange,
                      foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )),
                if (status == 'completed' || status == 'expert_completed')
                  Flexible(child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _JobDetailPage(jobId: jobId, jobData: jobData, buyerUid: buyerUid))),
                    icon: const Icon(Icons.rate_review, size: 16), label: const Text('View'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Job Detail Page ───────────────────────────────────────────
class _JobDetailPage extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;
  final String buyerUid;
  const _JobDetailPage({required this.jobId, required this.jobData, required this.buyerUid});
  @override
  State<_JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<_JobDetailPage> {
  late Map<String, dynamic> _jobData;
  @override
  void initState() {
    super.initState();
    _jobData = Map<String, dynamic>.from(widget.jobData);
    FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).snapshots().listen((doc) {
      if (mounted && doc.exists) setState(() => _jobData = doc.data() as Map<String, dynamic>);
    });
  }

  void _showEditDialog() {
    final tCtrl = TextEditingController(text: _jobData['title'] as String? ?? '');
    final dCtrl = TextEditingController(text: _jobData['description'] as String? ?? '');
    final bCtrl = TextEditingController(text: (_jobData['budget'] ?? 0).toStringAsFixed(0));
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Edit Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: tCtrl, decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: dCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: bCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Maximum Budget (PKR)', prefixText: 'PKR ', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({'title': tCtrl.text.trim(), 'description': dCtrl.text.trim(), 'budget': double.tryParse(bCtrl.text.trim()) ?? 0, 'updatedAt': FieldValue.serverTimestamp()});
              if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job updated'), backgroundColor: Colors.green)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
          )),
        ])),
      ),
    );
  }

  void _confirmCancel() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Cancel Job?'), content: const Text('This will remove the job and all bids.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({'status': 'cancelled'});
            Navigator.pop(context); Navigator.pop(context);
          },
          child: const Text('Yes, Cancel')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final status = _jobData['status'] as String? ?? 'open';
    final isInsured = (_jobData['orderType'] as String? ?? 'simple') == 'insured';
    final title = _jobData['title'] as String? ?? 'Job Detail';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(title), backgroundColor: Colors.teal, foregroundColor: Colors.white,
        actions: [
          const GlobalLanguageButton(color: Colors.white),
          if (status == 'open')
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit Job', onPressed: _showEditDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _JobSummaryCard(jobData: _jobData, jobId: widget.jobId),
          const SizedBox(height: 20),
          if (status == 'open') ...[
            Row(children: [
              const Text('Bids Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).collection('bids').snapshots(),
                builder: (ctx, s) {
                  final count = s.data?.docs.length ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: count > 0 ? Colors.orange.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: count > 0 ? Colors.orange.shade300 : Colors.grey.shade300)),
                    child: Text('$count bids', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: count > 0 ? Colors.orange : Colors.grey)),
                  );
                },
              ),
            ]),
            const SizedBox(height: 12),
            _BidsList(jobId: widget.jobId, buyerUid: widget.buyerUid, jobData: _jobData),
          ],
          if (status == 'pending_payment')
            _InsurancePaymentSection(jobId: widget.jobId, jobData: _jobData, buyerUid: widget.buyerUid, onUploaded: () => setState(() {})),
          if (status == 'payment_submitted')
            _PaymentSubmittedBanner(jobData: _jobData),
          if (status == 'in_progress') ...[
            const Text('Active Worker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _AcceptedSellerCard(jobId: widget.jobId, acceptedBidder: _jobData['acceptedBidder'] as String?),
            if (isInsured) ...[const SizedBox(height: 12), _InsuranceActiveBanner()],
          ],
          if (status == 'completed' || status == 'expert_completed')
            _CompletedJobSection(jobId: widget.jobId, jobData: _jobData, buyerUid: widget.buyerUid),
          if (status == 'expert_assigned') _ExpertAssignedBanner(),
          if (status == 'claim_pending') _ClaimPendingBanner(),
          if (status == 'open') ...[
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _confirmCancel,
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Cancel Job', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// ── Insurance Payment Section ─────────────────────────────────
class _InsurancePaymentSection extends StatefulWidget {
  final String jobId, buyerUid;
  final Map<String, dynamic> jobData;
  final VoidCallback onUploaded;
  const _InsurancePaymentSection({required this.jobId, required this.jobData, required this.buyerUid, required this.onUploaded});
  @override
  State<_InsurancePaymentSection> createState() => _InsurancePaymentSectionState();
}

class _InsurancePaymentSectionState extends State<_InsurancePaymentSection> {
  bool _uploading = false;
  File? _receiptFile;

  Future<void> _pickAndUploadReceipt() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() { _uploading = true; _receiptFile = File(picked.path); });
    try {
      final url = await CloudinaryService.uploadImage(_receiptFile!, folder: 'fixright/receipts/${widget.buyerUid}');
      if (url != null && url.isNotEmpty) {
        final sellerId = widget.jobData['acceptedBidder'] as String? ?? '';
        await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
          'status': 'payment_submitted',
          'paymentReceiptUrl': url,
          'paymentSubmittedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // ✅ Clear previous rejection reason on new submission
          'paymentRejectionReason': FieldValue.delete(),
        });
        await FirebaseFirestore.instance.collection('admin_notifications').add({'type': 'payment_receipt', 'jobId': widget.jobId, 'buyerUid': widget.buyerUid, 'receiptUrl': url, 'createdAt': FieldValue.serverTimestamp()});
        if (sellerId.isNotEmpty) await NotificationService.send(toUid: sellerId, title: 'Payment Submitted', body: 'Buyer submitted receipt. Waiting admin verification.', type: 'payment_verified', jobId: widget.jobId);
        if (mounted) { widget.onUploaded(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Receipt uploaded! Admin will verify and activate your order.'), backgroundColor: Colors.green, duration: Duration(seconds: 5))); }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _uploading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = (widget.jobData['totalAmount'] ?? 0).toDouble();
    // ✅ Read rejection reason set by admin
    final rejectionReason = widget.jobData['paymentRejectionReason'] as String? ?? '';
    final isResubmit = rejectionReason.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ✅ Rejection reason banner
      if (isResubmit) ...[
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.shade300, width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Receipt Rejected by Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 14))),
            ]),
            const SizedBox(height: 10),
            const Text('Reason from admin:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
              child: Text(rejectionReason, style: TextStyle(fontSize: 13, color: Colors.red.shade900, height: 1.4)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.info_outline, size: 13, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Expanded(child: Text('Please fix the issue above and upload a new, clear receipt.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontStyle: FontStyle.italic))),
            ]),
          ]),
        ),
      ],
      // Main payment container
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isResubmit ? Colors.orange.shade400 : Colors.orange.shade300, width: isResubmit ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.pending_actions, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(child: Text(isResubmit ? 'Upload New Payment Receipt' : 'Payment Required to Activate Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 15))),
          ]),
          const SizedBox(height: 10),
          Text('Transfer PKR ${totalAmount.toStringAsFixed(0)} to the company account, then upload your receipt below.', style: TextStyle(fontSize: 13, color: Colors.orange.shade800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: Column(children: [
              _bRow('Bank', 'HBL Bank'),
              _bRow('Account Title', 'FixRight Pvt Ltd'),
              _bRow('Account Number', '0123456789101112'),
              _bRow('Amount', 'PKR ${totalAmount.toStringAsFixed(0)}'),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.upload_file, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Text(isResubmit ? 'Upload New Receipt' : 'Upload Payment Receipt', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14)),
              ]),
              const SizedBox(height: 8),
              Text(isResubmit ? 'Address the rejection reason and upload a clear, correct receipt.' : 'After transferring, upload your bank receipt/screenshot here.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
              const SizedBox(height: 10),
              if (_receiptFile != null) ...[
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_receiptFile!, height: 120, width: double.infinity, fit: BoxFit.cover)),
                const SizedBox(height: 8),
              ],
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _uploading ? null : _pickAndUploadReceipt,
                icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.photo_library),
                label: Text(_uploading ? 'Uploading...' : (_receiptFile != null ? 'Change Receipt' : 'Select Receipt Photo')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _bRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Payment Submitted Banner ──────────────────────────────────
class _PaymentSubmittedBanner extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const _PaymentSubmittedBanner({required this.jobData});
  @override
  Widget build(BuildContext context) {
    final r = jobData['paymentReceiptUrl'] as String?;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple.shade300)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.hourglass_top, color: Colors.purple.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text('Receipt Submitted — Awaiting Verification', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade800, fontSize: 15))),
        ]),
        const SizedBox(height: 10),
        Text('Your receipt has been submitted. Admin will verify and activate your order within a few hours.', style: TextStyle(fontSize: 13, color: Colors.purple.shade800)),
        if (r != null && r.isNotEmpty) ...[const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(r, height: 120, width: double.infinity, fit: BoxFit.cover))],
      ]),
    );
  }
}

class _InsuranceActiveBanner extends StatelessWidget {
  const _InsuranceActiveBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade200)),
    child: Row(children: [
      Icon(Icons.shield, color: Colors.blue.shade700, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text('Insured Order — Your payment is held by company until the admin releases it after job completion.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800))),
    ]),
  );
}

// ── Completed Job Section ─────────────────────────────────────
class _CompletedJobSection extends StatefulWidget {
  final String jobId, buyerUid;
  final Map<String, dynamic> jobData;
  const _CompletedJobSection({required this.jobId, required this.jobData, required this.buyerUid});
  @override
  State<_CompletedJobSection> createState() => _CompletedJobSectionState();
}

class _CompletedJobSectionState extends State<_CompletedJobSection> {
  bool _loading = false;
  bool get _isInsured => (widget.jobData['orderType'] as String? ?? 'simple') == 'insured';
  bool get _canClaim {
    if (!_isInsured) return false;
    if (widget.jobData['insuranceClaimed'] == true) return false;
    final d = widget.jobData['claimDeadline'] as Timestamp?;
    if (d == null) return false;
    return DateTime.now().isBefore(d.toDate());
  }
  bool get _claimed  => widget.jobData['insuranceClaimed'] == true;
  bool get _accepted => widget.jobData['buyerAccepted'] == true;
  bool get _released => widget.jobData['paymentStatus'] == 'released';
  String get _sellerUid => widget.jobData['acceptedBidder'] as String? ?? '';

  Future<void> _confirmSatisfaction() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({'buyerAccepted': true, 'buyerAcceptedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      if (_sellerUid.isNotEmpty) await NotificationService.send(toUid: _sellerUid, title: '✅ Buyer Accepted Job!', body: 'Buyer is satisfied. Admin will release your earnings soon.', type: 'job_completed', jobId: widget.jobId);
      if (mounted) { setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Confirmed! Admin will release payment to the seller.'), backgroundColor: Colors.green)); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _fileClaim() async {
    setState(() => _loading = true);
    try {
      final claimCount = (widget.jobData['insuranceClaimCount'] ?? 0) as int;
      await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({'status': 'claim_pending', 'insuranceClaimed': true, 'insuranceClaimCount': claimCount + 1, 'claimFiledAt': FieldValue.serverTimestamp(), 'claimStatus': 'pending_review', 'updatedAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance.collection('admin_notifications').add({'type': 'insurance_claim', 'jobId': widget.jobId, 'buyerUid': widget.buyerUid, 'claimCount': claimCount + 1, 'createdAt': FieldValue.serverTimestamp()});
      if (_sellerUid.isNotEmpty) await NotificationService.send(toUid: _sellerUid, title: '⚠️ Insurance Claim Filed', body: 'Buyer filed a claim. You must revisit the job.', type: 'claim_filed', jobId: widget.jobId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Claim filed. Seller will revisit.'), backgroundColor: Colors.orange, duration: Duration(seconds: 5)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Widget _ratingSection() {
    if (_sellerUid.isEmpty) return const SizedBox();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('sellers').doc(_sellerUid).get(),
      builder: (ctx, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final name = '${data['firstName'] as String? ?? ''} ${data['lastName'] as String? ?? ''}'.trim();
        return Column(children: [
          const SizedBox(height: 12),
          RatingFeedbackSection(jobId: widget.jobId, sellerUid: _sellerUid, sellerName: name.isEmpty ? 'Worker' : name, jobData: widget.jobData),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_claimed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
        child: Row(children: [Icon(Icons.verified, color: Colors.blue.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Text('Insurance claim filed. Admin will review and resolve.', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800, fontSize: 13)))]),
      );
    }
    if (!_isInsured) {
      return Column(children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.task_alt, color: Colors.green.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Text('Job completed. Cash payment should have been made to the worker.', style: TextStyle(color: Colors.green.shade800, fontSize: 13)))])),
        _ratingSection(),
      ]);
    }
    final deadline = widget.jobData['claimDeadline'] as Timestamp?;
    final daysLeft = deadline != null ? deadline.toDate().difference(DateTime.now()).inDays : 0;
    return Column(children: [
      if (_released) ...[
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Text('Payment released to seller by admin. Job is fully complete!', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800, fontSize: 13)))])),
        _ratingSection(),
      ] else ...[
        if (!_accepted) Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.task_alt, color: Colors.green.shade700, size: 18), const SizedBox(width: 8), Text('Job marked complete by seller', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700))]),
            const SizedBox(height: 8),
            Text('Are you satisfied? Confirm to notify admin to release payment.', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
            const SizedBox(height: 4),
            Text('Admin will decide the final payment split and release it to the seller.', style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _loading ? null : _confirmSatisfaction,
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.thumb_up_outlined),
              label: const Text('Confirm Satisfaction'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            )),
          ]),
        ),
        if (_accepted && !_released) Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
          child: Row(children: [Icon(Icons.hourglass_top, color: Colors.blue.shade700, size: 20), const SizedBox(width: 10), Expanded(child: Text('You confirmed satisfaction. Admin will release payment to the seller shortly.', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800, fontSize: 13)))]),
        ),
        if (_canClaim) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade300)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.shield_outlined, color: Colors.orange.shade700, size: 18), const SizedBox(width: 8), Text('Insurance Window — $daysLeft day(s) left', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))]),
              const SizedBox(height: 8),
              Text('Not satisfied? File an insurance claim. The seller will revisit. If they fail again, an expert is sent.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: _loading ? null : _fileClaim,
                icon: const Icon(Icons.policy_outlined, color: Colors.orange),
                label: const Text('Claim Insurance', style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
            ]),
          ),
        ],
        if (_accepted || _released) _ratingSection(),
      ],
    ]);
  }
}

class _ExpertAssignedBanner extends StatelessWidget {
  const _ExpertAssignedBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple.shade300)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.star, color: Colors.purple.shade700), const SizedBox(width: 8), Expanded(child: Text('Expert Assigned', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade800, fontSize: 15)))]),
      const SizedBox(height: 10),
      Text('A top-rated expert has been assigned alongside the seller to complete your job.', style: TextStyle(fontSize: 13, color: Colors.purple.shade800)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Text('The expert and seller will coordinate to deliver the best results. You will be notified when completed.', style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]),
  );
}

class _ClaimPendingBanner extends StatelessWidget {
  const _ClaimPendingBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade300)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.policy, color: Colors.red.shade700), const SizedBox(width: 8), Expanded(child: Text('Insurance Claim Filed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 15)))]),
      const SizedBox(height: 10),
      Text('Your claim has been filed. The seller is revisiting the job. If they fail to deliver, a top expert will be dispatched.', style: TextStyle(fontSize: 13, color: Colors.red.shade800)),
    ]),
  );
}

// ── History Tab ───────────────────────────────────────────────
class _BuyerHistoryTab extends StatelessWidget {
  final String uid;
  const _BuyerHistoryTab({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').where('postedBy', isEqualTo: uid).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.teal));
        final docs = (snap.data?.docs ?? []).toList()
          ..sort((a, b) {
            final aT = (a.data() as Map)['postedAt'] as Timestamp?;
            final bT = (b.data() as Map)['postedAt'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });
        if (docs.isEmpty) return const _EmptyState(status: 'history');
        final totalJobs   = docs.length;
        final completed   = docs.where((d) { final s = (d.data() as Map)['status']; return s == 'completed' || s == 'expert_completed'; }).length;
        final inProgress  = docs.where((d) => (d.data() as Map)['status'] == 'in_progress').length;
        final cancelled   = docs.where((d) => (d.data() as Map)['status'] == 'cancelled').length;
        final totalSpent  = docs.fold<double>(0, (sum, d) {
          final data = d.data() as Map;
          if (data['status'] == 'completed' || data['status'] == 'expert_completed') return sum + (data['acceptedAmount'] ?? 0).toDouble();
          return sum;
        });
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Order Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                Row(children: [
                  _sTile('Total Jobs', '$totalJobs', Icons.work_outline),
                  _sTile('Completed', '$completed', Icons.check_circle_outline),
                  _sTile('In Progress', '$inProgress', Icons.autorenew),
                  _sTile('Cancelled', '$cancelled', Icons.cancel_outlined),
                ]),
                const Divider(color: Colors.white24, height: 20),
                Row(children: [const Icon(Icons.payments_outlined, color: Colors.white70, size: 16), const SizedBox(width: 8), Text('Total Spent: PKR ${totalSpent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13))]),
              ]),
            ),
            ...docs.map((doc) { final d = doc.data() as Map<String, dynamic>; return _HistoryJobCard(jobData: d, jobId: doc.id); }),
          ],
        );
      },
    );
  }
  Widget _sTile(String l, String v, IconData i) => Expanded(child: Column(children: [Icon(i, color: Colors.white70, size: 20), const SizedBox(height: 4), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text(l, style: const TextStyle(color: Colors.white60, fontSize: 10))]));
}

class _HistoryJobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  const _HistoryJobCard({required this.jobData, required this.jobId});
  @override
  Widget build(BuildContext context) {
    final title           = jobData['title']         as String? ?? 'Untitled';
    final status          = jobData['status']        as String? ?? 'open';
    final orderType       = jobData['orderType']     as String? ?? 'simple';
    final acceptedAmount  = (jobData['acceptedAmount'] ?? jobData['budget'] ?? 0).toDouble();
    final postedAt        = jobData['postedAt']      as Timestamp?;
    final completedAt     = jobData['completedAt']   as Timestamp?;
    final acceptedBidder  = jobData['acceptedBidder'];
    final location        = jobData['location']      as String? ?? '';
    final city            = jobData['city']          as String? ?? '';   // ✅ Fixed null cast
    final buyerRating     = (jobData['buyerRating']  ?? 0) as int;
    final buyerFeedback   = jobData['buyerFeedback'] as String? ?? '';   // ✅ Fixed null cast

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _sc(status).withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))), _StatusBadge(status: status)]),
        const SizedBox(height: 6),
        if (city.isNotEmpty) Row(children: [Icon(Icons.location_city, size: 12, color: Colors.teal.shade400), const SizedBox(width: 3), Text(city, style: TextStyle(fontSize: 12, color: Colors.teal.shade600, fontWeight: FontWeight.w600))]),
        if (location.isNotEmpty) Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(location, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis))]),
        const Divider(height: 14),
        Row(children: [
          _ic(Icons.category, orderType == 'insured' ? 'Insured' : 'Simple', orderType == 'insured' ? Colors.blue : Colors.teal),
          const SizedBox(width: 8),
          _ic(Icons.payments, 'PKR ${acceptedAmount.toStringAsFixed(0)}', Colors.green),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          if (postedAt != null) _dc('Posted', postedAt.toDate()),
          if (completedAt != null) ...[const SizedBox(width: 8), _dc('Completed', completedAt.toDate())],
        ]),
        if (acceptedBidder != null) ...[
          const SizedBox(height: 8),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('sellers').doc(acceptedBidder as String).get(),
            builder: (ctx, snap) {
              final data = snap.data?.data() as Map<String, dynamic>? ?? {};
              final name = '${data['firstName'] as String? ?? ''} ${data['lastName'] as String? ?? ''}'.trim();
              if (name.isEmpty) return const SizedBox();
              return Row(children: [const Icon(Icons.person_outline, size: 13, color: Colors.grey), const SizedBox(width: 4), Text('Worker: $name', style: const TextStyle(fontSize: 12, color: Colors.black54))]);
            },
          ),
        ],
        if (buyerRating > 0) ...[
          const Divider(height: 14),
          Row(children: [
            ...List.generate(5, (i) => Icon(i < buyerRating ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: Colors.amber)),
            const SizedBox(width: 8),
            Text('Your rating: $buyerRating/5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
          ]),
          if (buyerFeedback.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('"$buyerFeedback"', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ])),
    );
  }
  Widget _ic(IconData icon, String l, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: c), const SizedBox(width: 4), Text(l, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600))]));
  Widget _dc(String l, DateTime dt) => Row(children: [Icon(Icons.calendar_today, size: 11, color: Colors.grey[500]), const SizedBox(width: 3), Text('$l: ${DateFormat('dd MMM yy').format(dt)}', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]);
  Color _sc(String s) { switch (s) { case 'completed': case 'expert_completed': return Colors.green; case 'in_progress': return Colors.blue; case 'cancelled': return Colors.red; case 'pending_payment': case 'payment_submitted': return Colors.orange; default: return Colors.grey; } }
}

// ── Bids List ─────────────────────────────────────────────────
class _BidsList extends StatelessWidget {
  final String jobId, buyerUid;
  final Map<String, dynamic> jobData;
  const _BidsList({required this.jobId, required this.buyerUid, required this.jobData});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('bids').orderBy('createdAt', descending: false).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.teal));
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [Icon(Icons.gavel, size: 48, color: Colors.grey[300]), const SizedBox(height: 12), const Text('No bids yet', style: TextStyle(color: Colors.grey, fontSize: 16)), const SizedBox(height: 4), Text('Sellers will bid shortly', style: TextStyle(color: Colors.grey[400], fontSize: 12), textAlign: TextAlign.center)]),
          );
        }
        return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: snap.data!.docs.length, itemBuilder: (ctx, i) { final bid = snap.data!.docs[i].data() as Map<String, dynamic>; return _BidCard(bid: bid, jobId: jobId, buyerUid: buyerUid, jobData: jobData); });
      },
    );
  }
}

// ── Bid Card ──────────────────────────────────────────────────
class _BidCard extends StatefulWidget {
  final Map<String, dynamic> bid, jobData;
  final String jobId, buyerUid;
  const _BidCard({required this.bid, required this.jobId, required this.buyerUid, required this.jobData});
  @override
  State<_BidCard> createState() => _BidCardState();
}

class _BidCardState extends State<_BidCard> {
  bool _isAccepting = false;

  Future<Map<String, dynamic>> _getSellerInfo(String sellerId) async {
    final doc = await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();
    final data = doc.data() ?? {};
    final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
    final availableBalance = (data['Available_Balance'] ?? 0).toDouble();
    final reservedCommission = (data['Reserved_Commission'] ?? 0).toDouble();
    final freeBalance = availableBalance - reservedCommission;
    final bool isFreeOrder = jobsCompleted < kFreeOrderLimit;
    final double proposedAmount = (widget.bid['proposedAmount'] ?? 0).toDouble();
    double rate = 0.10;
    try {
      final cfgDoc = await FirebaseFirestore.instance.collection('config').doc('commission').get();
      if (cfgDoc.exists) rate = (cfgDoc.data()?['rate'] ?? 0.10).toDouble();
    } catch (_) {}
    final double commissionAmount = isFreeOrder ? 0 : proposedAmount * rate;
    final bool isEligible = isFreeOrder || freeBalance >= commissionAmount;
    return {'isFreeOrder': isFreeOrder, 'jobsCompleted': jobsCompleted, 'freeOrdersLeft': isFreeOrder ? kFreeOrderLimit - jobsCompleted : 0, 'availableBalance': availableBalance, 'reservedCommission': reservedCommission, 'freeBalance': freeBalance, 'commissionAmount': commissionAmount, 'rate': rate, 'isEligible': isEligible};
  }

  void _showOrderConfirmationSheet(Map<String, dynamic> sellerInfo) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => _OrderConfirmationSheet(bid: widget.bid, jobId: widget.jobId, jobData: widget.jobData, buyerUid: widget.buyerUid, sellerInfo: sellerInfo));
  }

  // Future<void> _openConversation(BuildContext ctx) async {
  //   final sellerId = widget.bid['sellerId'] as String;
  //   final sellerName = widget.bid['sellerName'] as String? ?? '';
  //   final sellerImage = widget.bid['sellerImage'] as String? ?? '';
  //   final db = FirebaseFirestore.instance;
  //   final phones = [widget.buyerUid, sellerId]..sort();
  //   final convId = '${phones[0]}_${phones[1]}';
  //   if (!(await db.collection('conversations').doc(convId).get()).exists) {
  //     final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
  //     final buyerData = buyerDoc.data() ?? {};
  //     final buyerName = '${buyerData['firstName'] as String? ?? ''} ${buyerData['lastName'] as String? ?? ''}'.trim();
  //     await db.collection('conversations').doc(convId).set({'participantIds': [widget.buyerUid, sellerId], 'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName}, 'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'}, 'participantProfileImages': {widget.buyerUid: buyerData['profileImage'] as String? ?? '', sellerId: sellerImage}, 'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(), 'unreadCounts': {widget.buyerUid: 0, sellerId: 0}, 'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] as String? ?? ''});
  //   }
  //   if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Chat opened with $sellerName')));
  // }

  Future<void> _openConversation(BuildContext ctx) async {
  final sellerId    = widget.bid['sellerId']    as String;
  final sellerName  = widget.bid['sellerName']  as String? ?? '';
  final sellerImage = widget.bid['sellerImage'] as String? ?? '';
  final db = FirebaseFirestore.instance;
  final phones = [widget.buyerUid, sellerId]..sort();
  final convId = '${phones[0]}_${phones[1]}';

  if (!(await db.collection('conversations').doc(convId).get()).exists) {
    final buyerDoc  = await db.collection('users').doc(widget.buyerUid).get();
    final buyerData = buyerDoc.data() ?? {};
    final buyerName = '${buyerData['firstName'] as String? ?? ''} ${buyerData['lastName'] as String? ?? ''}'.trim();
    await db.collection('conversations').doc(convId).set({
      'participantIds': [widget.buyerUid, sellerId],
      'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName},
      'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'},
      'participantProfileImages': {widget.buyerUid: buyerData['profileImage'] as String? ?? '', sellerId: sellerImage},
      'lastMessage': '', 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(),
      'unreadCounts': {widget.buyerUid: 0, sellerId: 0},
      'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] as String? ?? '',
    });
  }

  // ✅ Navigate instead of SnackBar
  if (mounted) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => ChatDetailScreen(
      convId:     convId,
      myUid:      widget.buyerUid,
      otherUid:   sellerId,
      otherName:  sellerName,
      otherImage: sellerImage,
      otherRole:  'seller',
      jobTitle:   widget.jobData['title'] as String? ?? '',
    )));
  }
}

  @override
  Widget build(BuildContext context) {
    final sellerName    = widget.bid['sellerName']    as String? ?? 'Unknown';
    final sellerImage   = widget.bid['sellerImage']   as String?;
    final proposedAmount = (widget.bid['proposedAmount'] ?? 0).toDouble();
    final proposal      = widget.bid['proposal']      as String? ?? '';
    final rating        = (widget.bid['rating']       ?? 0.0).toDouble();
    final skills        = List<String>.from(widget.bid['skills'] ?? []);
    final bidStatus     = widget.bid['status']        as String? ?? 'pending';
    final createdAt     = widget.bid['createdAt']     as Timestamp?;
    final sellerId      = widget.bid['sellerId']      as String? ?? '';
    final isAccepted    = bidStatus == 'accepted';
    final isRejected    = bidStatus == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isAccepted ? Colors.green.shade300 : isRejected ? Colors.red.shade100 : Colors.grey.shade200, width: isAccepted ? 2 : 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 26, backgroundColor: Colors.teal.shade100, backgroundImage: sellerImage != null && sellerImage.isNotEmpty ? NetworkImage(sellerImage) : null, child: sellerImage == null || sellerImage.isEmpty ? Text(sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 18)) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (rating > 0) Row(children: [Icon(Icons.star, size: 13, color: Colors.amber[600]), const SizedBox(width: 3), Text('$rating', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('PKR ${proposedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            if (createdAt != null) Text(DateFormat('dd MMM, hh:mm a').format(createdAt.toDate()), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ]),
        ]),
        const SizedBox(height: 10),
        FutureBuilder<Map<String, dynamic>>(
          future: _getSellerInfo(sellerId),
          builder: (ctx, snap) {
            if (!snap.hasData) return const LinearProgressIndicator(minHeight: 2, color: Colors.teal);
            final info = snap.data!;
            if (!info['isEligible']) return _ic('⚠️ Balance too low (PKR ${(info['freeBalance'] as double).toStringAsFixed(0)} free)', Colors.red);
            if (info['isFreeOrder'] as bool) return _ic('🎁 Free order — ${info['freeOrdersLeft']} free left', Colors.green);
            return _ic('${((info['rate'] as double) * 100).toStringAsFixed(0)}% commission (PKR ${(info['commissionAmount'] as double).toStringAsFixed(0)}) from seller', Colors.orange);
          },
        ),
        const SizedBox(height: 10),
        if (proposal.isNotEmpty) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: TranslatedText(text: proposal, contentId: 'proposal_${widget.jobId}_$sellerId', style: const TextStyle(fontSize: 13, height: 1.4), showListenButton: true)),
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: skills.take(4).map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.teal.shade200)), child: Text(s, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)))).toList()),
        ],
        const SizedBox(height: 14),
        if (isAccepted) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green.shade600, size: 18), const SizedBox(width: 8), Text('Bid Accepted — Order Placed', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))]))
        else if (!isRejected) FutureBuilder<Map<String, dynamic>>(
          future: _getSellerInfo(sellerId),
          builder: (ctx, snap) {
            final info = snap.data;
            final isEligible = info?['isEligible'] as bool? ?? true;
            return Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _openConversation(context), icon: const Icon(Icons.message_outlined, size: 16), label: const Text('Contact'), style: OutlinedButton.styleFrom(foregroundColor: Colors.teal, side: const BorderSide(color: Colors.teal), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(
                onPressed: (!isEligible || _isAccepting) ? null : () => _showOrderConfirmationSheet(info!),
                icon: _isAccepting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 16),
                label: Text(_isAccepting ? 'Placing...' : 'Place Order'),
                style: ElevatedButton.styleFrom(backgroundColor: isEligible ? Colors.teal : Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey.shade300),
              )),
            ]);
          },
        ),
      ])),
    );
  }
  Widget _ic(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.3))), child: Text(t, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)));
}

// ── Order Confirmation Sheet ──────────────────────────────────
class _OrderConfirmationSheet extends StatefulWidget {
  final Map<String, dynamic> bid, jobData, sellerInfo;
  final String jobId, buyerUid;
  const _OrderConfirmationSheet({required this.bid, required this.jobId, required this.jobData, required this.buyerUid, required this.sellerInfo});
  @override
  State<_OrderConfirmationSheet> createState() => _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState extends State<_OrderConfirmationSheet> {
  bool _wantsInsurance = false, _isPlacing = false;
  double get _proposedAmount => (widget.bid['proposedAmount'] ?? 0).toDouble();
  double get _insuranceAmount => _wantsInsurance ? (_proposedAmount * kInsuranceRate) : 0;
  double get _totalAmount => _proposedAmount + _insuranceAmount;

  Future<void> _placeOrder() async {
    setState(() => _isPlacing = true);
    try {
      final db         = FirebaseFirestore.instance;
      final sellerId   = widget.bid['sellerId']   as String;
      final sellerName = widget.bid['sellerName'] as String? ?? '';
      final sellerImage = widget.bid['sellerImage'] as String? ?? '';
      final bidIsFree  = widget.bid['isFreeOrder'] as bool? ?? widget.sellerInfo['isFreeOrder'] as bool;
      final storedCommission = (widget.bid['commissionReserved'] ?? widget.sellerInfo['commissionAmount'] ?? 0).toDouble();
      final storedRate = (widget.bid['commissionRate'] ?? widget.sellerInfo['rate'] ?? 0.10).toDouble();
      final batch = db.batch();
      final jobRef = db.collection('jobs').doc(widget.jobId);
      final newStatus = _wantsInsurance ? 'pending_payment' : 'in_progress';
      final claimDeadline = DateTime.now().add(const Duration(days: 3));
      final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
      final buyerData = buyerDoc.data() ?? {};
      final buyerCity = buyerData['city'] as String? ?? '';
      batch.update(jobRef, {'status': newStatus, 'acceptedBidder': sellerId, 'acceptedAmount': _proposedAmount, 'orderType': _wantsInsurance ? 'insured' : 'simple', 'insuranceAmount': _insuranceAmount, 'totalAmount': _totalAmount, 'paymentStatus': _wantsInsurance ? 'pending_payment' : 'cash_on_delivery', 'insuranceClaimed': false, 'insuranceClaimCount': 0, 'claimDeadline': _wantsInsurance ? null : Timestamp.fromDate(claimDeadline), 'city': buyerCity, 'commissionRate': storedRate, 'commissionAmount': storedCommission, 'updatedAt': FieldValue.serverTimestamp()});
      batch.update(jobRef.collection('bids').doc(sellerId), {'status': 'accepted'});
      final otherBids = await jobRef.collection('bids').where('sellerId', isNotEqualTo: sellerId).get();
      for (final d in otherBids.docs) { batch.update(d.reference, {'status': 'rejected'}); }
      if (!bidIsFree && storedCommission > 0) {
        batch.update(db.collection('sellers').doc(sellerId), {'Available_Balance': FieldValue.increment(-storedCommission), 'Reserved_Commission': FieldValue.increment(-storedCommission), 'Pending_Jobs': FieldValue.increment(1)});
      } else {
        batch.update(db.collection('sellers').doc(sellerId), {'Pending_Jobs': FieldValue.increment(1)});
      }
      final orderRef = db.collection('sellers').doc(sellerId).collection('orders').doc(widget.jobId);
      batch.set(orderRef, {'orderId': widget.jobId, 'jobId': widget.jobId, 'jobTitle': widget.jobData['title'] as String? ?? '', 'jobDescription': widget.jobData['description'] as String? ?? '', 'jobLocation': widget.jobData['location'] as String? ?? '', 'skills': widget.jobData['skills'] ?? [], 'buyerId': widget.buyerUid, 'buyerName': '', 'sellerId': sellerId, 'sellerName': sellerName, 'proposedAmount': _proposedAmount, 'commissionDeducted': bidIsFree ? 0 : storedCommission, 'commissionRate': storedRate, 'isFreeOrder': bidIsFree, 'orderType': _wantsInsurance ? 'insured' : 'simple', 'insuranceAmount': _insuranceAmount, 'totalAmount': _totalAmount, 'status': newStatus, 'paymentStatus': _wantsInsurance ? 'pending_payment' : 'cash_on_delivery', 'insuranceClaimed': false, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
      await batch.commit();
      await CommissionService.releaseRejectedBidsReservations(jobId: widget.jobId, acceptedSellerId: sellerId, otherBids: otherBids.docs, rate: storedRate, isFree: bidIsFree);
      final buyerName = '${buyerData['firstName'] as String? ?? ''} ${buyerData['lastName'] as String? ?? ''}'.trim();
      final buyerImage = buyerData['profileImage'] as String? ?? '';
      await orderRef.update({'buyerName': buyerName});
      final phones = [widget.buyerUid, sellerId]..sort();
      final convId = '${phones[0]}_${phones[1]}';
      if (!(await db.collection('conversations').doc(convId).get()).exists) {
        await db.collection('conversations').doc(convId).set({'participantIds': [widget.buyerUid, sellerId], 'participantNames': {widget.buyerUid: buyerName, sellerId: sellerName}, 'participantRoles': {widget.buyerUid: 'buyer', sellerId: 'seller'}, 'participantProfileImages': {widget.buyerUid: buyerImage, sellerId: sellerImage}, 'lastMessage': "Order placed! Let's get started.", 'lastMessageAt': Timestamp.now(), 'createdAt': Timestamp.now(), 'unreadCounts': {widget.buyerUid: 0, sellerId: 1}, 'relatedJobId': widget.jobId, 'relatedJobTitle': widget.jobData['title'] as String? ?? ''});
      }
      await NotificationService.send(toUid: sellerId, title: '🎉 Bid Accepted!', body: 'Your bid for "${widget.jobData['title']}" was accepted. ${_wantsInsurance ? 'Insured order — wait for buyer payment.' : 'Cash on delivery.'}', type: 'bid_accepted', jobId: widget.jobId, relatedUserName: buyerName);
      for (final d in otherBids.docs) {
        final rId = (d.data() as Map)['sellerId'] as String? ?? '';   // ✅ Fixed null cast
        if (rId.isNotEmpty) await NotificationService.send(toUid: rId, title: 'Bid Not Selected', body: 'The buyer selected another seller.', type: 'bid_rejected', jobId: widget.jobId);
      }
      if (!mounted) return;
      Navigator.pop(context); Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_wantsInsurance ? '✅ Order placed! Transfer PKR ${_totalAmount.toStringAsFixed(0)} and upload receipt to activate.' : '✅ Order placed! Pay PKR ${_proposedAmount.toStringAsFixed(0)} cash on completion.'), backgroundColor: Colors.green, duration: const Duration(seconds: 6)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _isPlacing = false); }
  }

  @override
  Widget build(BuildContext context) {
    final sellerName  = widget.bid['sellerName']  as String? ?? 'Seller';
    final isFreeOrder = widget.sellerInfo['isFreeOrder'] as bool;
    final commission  = (widget.sellerInfo['commissionAmount'] as double);
    final rate        = widget.sellerInfo['rate'] as double? ?? 0.10;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('Confirm Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Placing order with $sellerName', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 16),
        _row('Worker\'s Bid', 'PKR ${_proposedAmount.toStringAsFixed(0)}'),
        if (isFreeOrder) _row('Commission', 'FREE (${widget.sellerInfo['freeOrdersLeft']} left)', color: Colors.green)
        else _row('Commission (${(rate * 100).toStringAsFixed(0)}%)', 'PKR ${commission.toStringAsFixed(0)} from seller', color: Colors.orange),
        const Divider(height: 20),
        Container(
          decoration: BoxDecoration(color: _wantsInsurance ? Colors.blue.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: _wantsInsurance ? Colors.blue.shade300 : Colors.grey.shade300)),
          child: Column(children: [
            SwitchListTile(value: _wantsInsurance, onChanged: (v) => setState(() => _wantsInsurance = v), activeThumbColor: Colors.blue, title: const Text('Add Insurance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: const Text('+20% — Guaranteed completion & 3-day claim window', style: TextStyle(fontSize: 11)), secondary: Icon(Icons.shield_outlined, color: _wantsInsurance ? Colors.blue : Colors.grey)),
            if (_wantsInsurance) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(children: [
              const Divider(height: 1), const SizedBox(height: 8),
              _row('Insurance (20%)', 'PKR ${_insuranceAmount.toStringAsFixed(0)}', color: Colors.blue),
              _row('Total You Pay', 'PKR ${_totalAmount.toStringAsFixed(0)}', bold: true, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Text('⚠️ After payment, upload your receipt. Order activates after admin verification. Admin releases payment to seller after job completion.', style: TextStyle(fontSize: 11, color: Colors.orange.shade800))),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        if (!_wantsInsurance) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Icon(Icons.payments_outlined, color: Colors.green.shade700, size: 16), const SizedBox(width: 8), Expanded(child: Text('💵 Cash on Delivery — Pay PKR ${_proposedAmount.toStringAsFixed(0)} in cash directly to the worker after job completion.', style: TextStyle(fontSize: 11, color: Colors.green.shade800)))])),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _isPlacing ? null : _placeOrder,
          icon: _isPlacing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline),
          label: Text(_isPlacing ? 'Placing Order...' : _wantsInsurance ? 'Place Insured Order (PKR ${_totalAmount.toStringAsFixed(0)})' : 'Place Order (Cash on Delivery)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: _wantsInsurance ? Colors.blue : Colors.teal, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        )),
      ])),
    );
  }
  Widget _row(String l, String v, {Color? color, bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 13, color: color ?? Colors.black87, fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Flexible(child: Text(v, textAlign: TextAlign.end, style: TextStyle(fontSize: 13, color: color ?? Colors.black87, fontWeight: bold ? FontWeight.bold : FontWeight.normal)))]));
}

// ── Job Summary Card ──────────────────────────────────────────
class _JobSummaryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  final String jobId;
  const _JobSummaryCard({required this.jobData, required this.jobId});
  @override
  Widget build(BuildContext context) {
    final skills      = List<String>.from(jobData['skills'] ?? []);
    final budget      = (jobData['budget'] ?? 0).toDouble();
    final description = jobData['description'] as String? ?? '';  // ✅ Fixed
    final location    = jobData['location']    as String? ?? '';  // ✅ Fixed
    final timing      = jobData['timing']      as String? ?? '';  // ✅ Fixed
    final city        = jobData['city']        as String? ?? '';  // ✅ Fixed
    return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(jobData['title'] as String? ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        Text('PKR ${budget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
      ]),
      if (city.isNotEmpty) ...[
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_city, size: 13, color: Colors.teal.shade700), const SizedBox(width: 4), Text(city, style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600))])),
      ],
      const SizedBox(height: 8),
      if (description.isNotEmpty) ...[TranslatedText(text: description, contentId: 'summary_$jobId', style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4), showListenButton: false), const SizedBox(height: 8)],
      JobListenRow(title: jobData['title'] as String? ?? '', description: description, location: location, timing: timing, jobId: jobId),
      const SizedBox(height: 12),
      Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey[500]), const SizedBox(width: 6), Expanded(child: Text(location.isNotEmpty ? location : 'No location', style: TextStyle(fontSize: 13, color: Colors.grey[600])))]),
      const SizedBox(height: 6),
      Row(children: [Icon(Icons.schedule, size: 14, color: Colors.grey[500]), const SizedBox(width: 6), Expanded(child: Text(timing, style: TextStyle(fontSize: 13, color: Colors.grey[600])))]),
      const SizedBox(height: 12),
      Wrap(spacing: 6, runSpacing: 4, children: skills.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 11)), backgroundColor: Colors.teal.shade50, side: BorderSide(color: Colors.teal.shade200), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: const EdgeInsets.symmetric(horizontal: 4))).toList()),
    ])));
  }
}

class _AcceptedSellerCard extends StatelessWidget {
  final String jobId;
  final String? acceptedBidder;
  const _AcceptedSellerCard({required this.jobId, this.acceptedBidder});
  @override
  Widget build(BuildContext context) {
    if (acceptedBidder == null) return const SizedBox();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('sellers').doc(acceptedBidder).get(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.teal));
        final data   = snap.data?.data() as Map<String, dynamic>? ?? {};
        final name   = '${data['firstName'] as String? ?? ''} ${data['lastName'] as String? ?? ''}'.trim();
        final rating = (data['Rating'] ?? 0).toDouble();
        final image  = data['profileImage'] as String?;
        return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.teal.shade100, backgroundImage: image != null && image.isNotEmpty ? NetworkImage(image) : null, child: image == null || image.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal)) : null),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [Icon(Icons.star, size: 14, color: Colors.amber[600]), const SizedBox(width: 4), Text('$rating', style: TextStyle(color: Colors.grey[600]))])])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Text('In Progress', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12))),
        ])));
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color c; String l;
    switch (status) {
      case 'open': c = Colors.orange; l = 'Open'; break;
      case 'in_progress': c = Colors.blue; l = 'In Progress'; break;
      case 'pending_payment': c = Colors.deepOrange; l = 'Pay Now'; break;
      case 'payment_submitted': c = Colors.purple; l = 'Under Review'; break;
      case 'completed': c = Colors.green; l = 'Completed'; break;
      case 'expert_completed': c = Colors.green; l = 'Completed'; break;
      case 'claim_pending': c = Colors.red; l = 'Claim Filed'; break;
      case 'expert_assigned': c = Colors.purple; l = 'Expert Sent'; break;
      case 'cancelled': c = Colors.red; l = 'Cancelled'; break;
      default: c = Colors.grey; l = status;
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text(l, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11)));
  }
}

class _EmptyState extends StatelessWidget {
  final String status;
  const _EmptyState({required this.status});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.work_off_outlined, size: 64, color: Colors.grey[300]),
    const SizedBox(height: 12),
    Text(status == 'open' ? 'No open jobs' : status == 'in_progress' ? 'No jobs in progress' : status == 'history' ? 'No job history yet' : 'No completed jobs', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
    const SizedBox(height: 6),
    Text(status == 'open' ? 'Post a job to get competitive bids' : 'Place an order to get started', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
  ]));
}
