import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/user_session.dart';
import 'notification_service.dart';

const double kOfferInsuranceRate = 0.20;

// ═══════════════════════════════════════════════════════════════
//  OFFER PLACE ORDER SHEET
//  Full order placement sheet — same logic as bid-based orders.
//  Insurance / simple, commission, same job schema.
// ═══════════════════════════════════════════════════════════════
class OfferPlaceOrderSheet extends StatefulWidget {
  final Map<String, dynamic> offerData;
  final String offerId, buyerUid, buyerCity;
  const OfferPlaceOrderSheet({
    super.key,
    required this.offerData,
    required this.offerId,
    required this.buyerUid,
    required this.buyerCity,
  });
  @override
  State<OfferPlaceOrderSheet> createState() => _OfferPlaceOrderSheetState();
}

class _OfferPlaceOrderSheetState extends State<OfferPlaceOrderSheet> {
  static const _teal = Color(0xFF00695C);

  final _formKey = GlobalKey<FormState>();
  final _addrCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _timingCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _wantsInsurance = false;
  bool _isPlacing = false;
  bool _loadingInfo = true;

  // Seller commission info
  double _commissionRate = 0.10;
  bool _isFreeOrder = false;
  int _freeLeft = 0;

  String get _sellerId => widget.offerData['sellerId'] as String? ?? '';
  double get _price => (widget.offerData['price'] ?? 0).toDouble();
  double get _insuranceAmt =>
      _wantsInsurance ? (_price * kOfferInsuranceRate) : 0;
  double get _totalAmt => _price + _insuranceAmt;
  double get _commission => _isFreeOrder ? 0 : _price * _commissionRate;

  @override
  void initState() {
    super.initState();
    _cityCtrl.text = widget.buyerCity;
    _loadSellerInfo();
  }

  Future<void> _loadSellerInfo() async {
    try {
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(_sellerId)
          .get();
      final data = sellerDoc.data() ?? {};
      final done = (data['Jobs_Completed'] ?? 0) as int;
      _isFreeOrder = done < 3;
      _freeLeft = _isFreeOrder ? 3 - done : 0;
      try {
        final cfg = await FirebaseFirestore.instance
            .collection('config')
            .doc('commission')
            .get();
        if (cfg.exists)
          _commissionRate = (cfg.data()?['rate'] ?? 0.10).toDouble();
      } catch (_) {}
    } catch (_) {}
    if (mounted) setState(() => _loadingInfo = false);
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    _cityCtrl.dispose();
    _timingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── PLACE ORDER ─────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPlacing = true);
    try {
      final db = FirebaseFirestore.instance;
      final sellerName = widget.offerData['sellerName'] as String? ?? '';
      final sellerImg = widget.offerData['sellerImage'] as String? ?? '';
      final title = widget.offerData['title'] as String? ?? 'Service Order';
      final desc = widget.offerData['description'] as String? ?? '';
      final skills = List<String>.from(widget.offerData['skills'] ?? []);

      // Load buyer
      final buyerDoc = await db.collection('users').doc(widget.buyerUid).get();
      final buyerData = buyerDoc.data() ?? {};
      final buyerName =
          '${buyerData['firstName'] ?? ''} ${buyerData['lastName'] ?? ''}'
              .trim();
      final buyerImg = buyerData['profileImage'] as String? ?? '';

      final newStatus = _wantsInsurance ? 'pending_payment' : 'in_progress';
      final claimDeadline = DateTime.now().add(const Duration(days: 3));

      final jobRef = db.collection('jobs').doc();
      final batch = db.batch();

      // ── Job document (same schema as bid-based orders) ──────
      batch.set(jobRef, {
        'title': title,
        'description': desc,
        'skills': skills,
        'budget': _price,
        'acceptedAmount': _price,
        'orderType': _wantsInsurance ? 'insured' : 'simple',
        'insuranceAmount': _insuranceAmt,
        'totalAmount': _totalAmt,
        'status': newStatus,
        'paymentStatus': _wantsInsurance
            ? 'pending_payment'
            : 'cash_on_delivery',
        'postedBy': widget.buyerUid,
        'posterName': buyerName,
        'posterImage': buyerImg,
        'acceptedBidder': _sellerId,
        'sellerName': sellerName,
        'location': _addrCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'timing': _timingCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'bidsCount': 0,
        'insuranceClaimed': false,
        'insuranceClaimCount': 0,
        'claimDeadline': _wantsInsurance
            ? null
            : Timestamp.fromDate(claimDeadline),
        'commissionRate': _commissionRate,
        'commissionAmount': _commission,
        'isFreeOrder': _isFreeOrder,
        'orderSource': 'offer',
        'sourceOfferId': widget.offerId,
        'postedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ── Seller stats ────────────────────────────────────────
      // if (!_isFreeOrder && _commission > 0) {
      //   batch.update(db.collection('sellers').doc(_sellerId), {
      //     'Available_Balance': FieldValue.increment(-_commission),
      //     'Pending_Jobs': FieldValue.increment(1),
      //   });
      // } else {
      //   batch.update(db.collection('sellers').doc(_sellerId), {
      //     'Pending_Jobs': FieldValue.increment(1),
      //   });
      // }


// ── Seller stats ────────────────────────────────────────
if (!_isFreeOrder && _commission > 0) {
  batch.update(db.collection('sellers').doc(_sellerId), {
    'Available_Balance': FieldValue.increment(-_commission),
    'Pending_Jobs': FieldValue.increment(1),
  });

  // ── Admin commission tracking ──────────────────────────
  final commRef = db.collection('admin_earnings').doc();
  batch.set(commRef, {
    'type': 'commission',
    'source': 'offer_order',
    'orderId': jobRef.id,
    'jobTitle': title,
    'sellerId': _sellerId,
    'sellerName': sellerName,
    'commissionAmount': _commission,
    'commissionRate': _commissionRate,
    'orderAmount': _price,
    'orderType': _wantsInsurance ? 'insured' : 'simple',
    'city': _cityCtrl.text.trim(),
    'createdAt': FieldValue.serverTimestamp(),
  });
  batch.set(
    db.collection('admin_earnings').doc('summary'),
    {
      'totalCommission': FieldValue.increment(_commission),
      'totalOrders': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
  // ───────────────────────────────────────────────────────
} else {
  batch.update(db.collection('sellers').doc(_sellerId), {'Pending_Jobs': FieldValue.increment(1)});
}

      // ── Seller order mirror ─────────────────────────────────
      batch.set(
        db
            .collection('sellers')
            .doc(_sellerId)
            .collection('orders')
            .doc(jobRef.id),
        {
          'orderId': jobRef.id,
          'jobId': jobRef.id,
          'jobTitle': title,
          'description': desc,
          'skills': skills,
          'buyerId': widget.buyerUid,
          'buyerName': buyerName,
          'sellerId': _sellerId,
          'sellerName': sellerName,
          'proposedAmount': _price,
          'commissionDeducted': _commission,
          'commissionRate': _commissionRate,
          'isFreeOrder': _isFreeOrder,
          'orderType': _wantsInsurance ? 'insured' : 'simple',
          'insuranceAmount': _insuranceAmt,
          'totalAmount': _totalAmt,
          'status': newStatus,
          'paymentStatus': _wantsInsurance
              ? 'pending_payment'
              : 'cash_on_delivery',
          'insuranceClaimed': false,
          'orderSource': 'offer',
          'sourceOfferId': widget.offerId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // ── Increment offer orders count ────────────────────────
      batch.update(
        db
            .collection('sellers')
            .doc(_sellerId)
            .collection('offers')
            .doc(widget.offerId),
        {'ordersCount': FieldValue.increment(1)},
      );

      await batch.commit();
      // buyerName already included in the batch.set above — no update needed.

      // ── Conversation ────────────────────────────────────────
      final phones = [widget.buyerUid, _sellerId]..sort();
      final convId = '${phones[0]}_${phones[1]}';
      if (!(await db.collection('conversations').doc(convId).get()).exists) {
        await db.collection('conversations').doc(convId).set({
          'participantIds': [widget.buyerUid, _sellerId],
          'participantNames': {
            widget.buyerUid: buyerName,
            _sellerId: sellerName,
          },
          'participantRoles': {widget.buyerUid: 'buyer', _sellerId: 'seller'},
          'participantProfileImages': {
            widget.buyerUid: buyerImg,
            _sellerId: sellerImg,
          },
          'lastMessage': "Order placed! Let's get started.",
          'lastMessageAt': Timestamp.now(),
          'createdAt': Timestamp.now(),
          'unreadCounts': {widget.buyerUid: 0, _sellerId: 1},
          'relatedJobId': jobRef.id,
          'relatedJobTitle': title,
        });
      }

      // ── Notify seller ───────────────────────────────────────
      await NotificationService.send(
        toUid: _sellerId,
        title: '🎉 New Order Received!',
        body:
            '$buyerName placed an order for "$title". ${_wantsInsurance ? 'Insured — awaiting payment.' : 'Cash on delivery.'}',
        type: 'bid_accepted',
        jobId: jobRef.id,
        relatedUserName: buyerName,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _wantsInsurance
                ? '✅ Order placed! Transfer PKR ${_totalAmt.toStringAsFixed(0)} and upload receipt to activate.'
                : '✅ Order placed! Pay PKR ${_price.toStringAsFixed(0)} in cash when the job is done.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  // ── BUILD ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final title = widget.offerData['title'] as String? ?? 'Service';
    final sellerName = widget.offerData['sellerName'] as String? ?? 'Worker';
    final sellerImg = widget.offerData['sellerImage'] as String? ?? '';
    final rating = (widget.offerData['rating'] ?? 0.0).toDouble();
    final skills = List<String>.from(widget.offerData['skills'] ?? []);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (ctx, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Offer summary ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _teal.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _teal.withOpacity(0.12),
                      backgroundImage: sellerImg.isNotEmpty
                          ? NetworkImage(sellerImg)
                          : null,
                      child: sellerImg.isEmpty
                          ? Text(
                              sellerName[0].toUpperCase(),
                              style: const TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'by $sellerName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$rating',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PKR ${_price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _teal,
                          ),
                        ),
                        Text(
                          'base price',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (skills.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: skills
                      .take(4)
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _teal.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _teal.withOpacity(0.15)),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),

              // ── Commission info ──────────────────────────────────
              if (_loadingInfo)
                const LinearProgressIndicator(color: _teal, minHeight: 2)
              else
                _infoBanner(
                  _isFreeOrder
                      ? '🎁 Free order — $_freeLeft free orders left. No commission charged!'
                      : '${(_commissionRate * 100).toStringAsFixed(0)}% service fee (PKR ${_commission.toStringAsFixed(0)}) will be deducted from the seller.',
                  _isFreeOrder ? Colors.green : Colors.orange,
                ),
              const SizedBox(height: 20),

              // ── Location fields ──────────────────────────────────
              _sectionLabel('📍 Service Location'),
              const SizedBox(height: 8),
              _textField(
                _addrCtrl,
                'Full address (street, area)',
                Icons.location_on_outlined,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _cityCtrl,
                      'City',
                      Icons.location_city_outlined,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'City required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Timing ──────────────────────────────────────────
              _sectionLabel('🕐 Preferred Timing'),
              const SizedBox(height: 8),
              _textField(
                _timingCtrl,
                'e.g. Tomorrow 10am, Any weekday morning',
                Icons.schedule_outlined,
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Please enter preferred timing'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── Notes ───────────────────────────────────────────
              _sectionLabel('📝 Additional Notes (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: _inputDeco(
                  'Any special requirements, access info…',
                  Icons.notes_outlined,
                ),
              ),
              const SizedBox(height: 24),

              // ── Insurance toggle ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: _wantsInsurance
                      ? Colors.blue.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _wantsInsurance
                        ? Colors.blue.shade300
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _wantsInsurance,
                      onChanged: (v) => setState(() => _wantsInsurance = v),
                      activeThumbColor: Colors.blue,
                      title: const Text(
                        'Add Insurance Protection',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        '+20% of price — Guaranteed completion + 3-day claim window',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      secondary: Icon(
                        Icons.shield_rounded,
                        color: _wantsInsurance ? Colors.blue : Colors.grey,
                        size: 26,
                      ),
                    ),
                    if (_wantsInsurance)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            _summaryRow(
                              'Insurance Fee (20%)',
                              'PKR ${_insuranceAmt.toStringAsFixed(0)}',
                              Colors.blue,
                            ),
                            const SizedBox(height: 4),
                            _summaryRow(
                              'Total to Transfer',
                              'PKR ${_totalAmt.toStringAsFixed(0)}',
                              Colors.blue.shade700,
                              bold: true,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                '⚠️ After placing the order, transfer PKR ${_totalAmt.toStringAsFixed(0)} to the company account and upload your payment receipt. The order activates after admin verification. Payment is released to the worker after job completion.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.orange.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Cash note
              if (!_wantsInsurance)
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '💵 Cash on Delivery — Pay PKR ${_price.toStringAsFixed(0)} directly to the worker after job completion.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.green.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 22),

              // ── Order summary ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      'Service Price',
                      'PKR ${_price.toStringAsFixed(0)}',
                      Colors.black87,
                    ),
                    const SizedBox(height: 6),
                    _summaryRow(
                      _isFreeOrder
                          ? 'Commission'
                          : 'Commission (${(_commissionRate * 100).toStringAsFixed(0)}%)',
                      _isFreeOrder
                          ? 'FREE ($_freeLeft left)'
                          : 'PKR ${_commission.toStringAsFixed(0)} from seller',
                      _isFreeOrder ? Colors.green : Colors.orange,
                    ),
                    if (_wantsInsurance) ...[
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Insurance (20%)',
                        'PKR ${_insuranceAmt.toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                    ],
                    const Divider(height: 18),
                    _summaryRow(
                      _wantsInsurance ? 'Total to Transfer' : 'You Pay (Cash)',
                      'PKR ${_totalAmt.toStringAsFixed(0)}',
                      _teal,
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Place order button ───────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPlacing ? null : _placeOrder,
                  icon: _isPlacing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 22,
                        ),
                  label: Text(
                    _isPlacing
                        ? 'Placing Order…'
                        : _wantsInsurance
                        ? 'Place Insured Order  •  PKR ${_totalAmt.toStringAsFixed(0)}'
                        : 'Place Order  •  Cash on Delivery',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _wantsInsurance
                        ? Colors.blue.shade700
                        : _teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      decoration: _inputDeco(hint, icon),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.5),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _teal, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );

  Widget _infoBanner(String text, Color color) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, color: color, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5, color: color, height: 1.4),
          ),
        ),
      ],
    ),
  );

  Widget _summaryRow(String l, String v, Color color, {bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(
            v,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      );
}
