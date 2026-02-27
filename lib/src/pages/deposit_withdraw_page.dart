import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'cloudinary_service.dart';

// ─────────────────────────────────────────────────────────────
//  COMPANY BANK DETAILS  (Edit these with your real details)
// ─────────────────────────────────────────────────────────────
const Map<String, String> kCompanyBankDetails = {
  'Bank Name': 'HBL Bank',
  'Account Title': 'FixRight Pvt Ltd',
  'Account Number': '0123456789101112',
  'IBAN': 'PK36HABB0000000123456702',
  'Branch Code': '0123',
};

class DepositWithdrawPage extends StatefulWidget {
  final String phoneUID;

  const DepositWithdrawPage({super.key, required this.phoneUID});

  @override
  State<DepositWithdrawPage> createState() => _DepositWithdrawPageState();
}

class _DepositWithdrawPageState extends State<DepositWithdrawPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward), text: 'Deposit'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Withdraw'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DepositTab(phoneUID: widget.phoneUID),
          _WithdrawTab(phoneUID: widget.phoneUID),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DEPOSIT TAB
// ═══════════════════════════════════════════════════════════════
class _DepositTab extends StatefulWidget {
  final String phoneUID;
  const _DepositTab({required this.phoneUID});

  @override
  State<_DepositTab> createState() => _DepositTabState();
}

class _DepositTabState extends State<_DepositTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _screenshotFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _screenshotFile = File(image.path));
    }
  }

  Future<void> _submitDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_screenshotFile == null) {
      _showSnack('Please attach payment screenshot', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Upload screenshot to Cloudinary
      final String? screenshotUrl = await CloudinaryService.uploadImage(
        _screenshotFile!,
        folder: 'fixright/deposits/${widget.phoneUID}',
      );

      if (screenshotUrl == null) {
        _showSnack('Image upload failed. Try again.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final double amount = double.parse(_amountController.text.trim());

      // 2️⃣ Save deposit request to Firestore subcollection
      await _firestore
          .collection('sellers')
          .doc(widget.phoneUID)
          .collection('deposits')
          .add({
        'uid': widget.phoneUID,
        'amount': amount,
        'screenshotUrl': screenshotUrl,
        'note': _noteController.text.trim(),
        'status': 'pending', // pending | approved | rejected
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'adminNote': '',
      });

      // 3️⃣ Reset form
      _amountController.clear();
      _noteController.clear();
      setState(() => _screenshotFile = null);

      _showSnack(
        'Deposit request submitted! It will be approved within 24 hours.',
        Colors.green,
      );
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Balance Card ────────────────────────────────────
          _BalanceCard(phoneUID: widget.phoneUID),
          const SizedBox(height: 20),

          // ── Company Bank Details ────────────────────────────
          _CompanyBankDetailsCard(),
          const SizedBox(height: 20),

          // ── Deposit Form ────────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submit Deposit Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transfer money to above account, attach screenshot below.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        'Amount (Rs)',
                        Icons.payments_outlined,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter amount';
                        if (double.parse(val) < 100) return 'Minimum Rs 100';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Note Field
                    TextFormField(
                      controller: _noteController,
                      decoration: _inputDecoration(
                        'Note (optional)',
                        Icons.note_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Screenshot Picker
                    const Text(
                      'Payment Screenshot *',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickScreenshot,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _screenshotFile != null
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade50,
                        ),
                        child: _screenshotFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _screenshotFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to attach screenshot',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitDeposit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isLoading ? 'Submitting...' : 'Submit Deposit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ── Deposit History ─────────────────────────────────
          _HistorySection(
            phoneUID: widget.phoneUID,
            collection: 'deposits',
            emptyText: 'No deposit history yet.',
            accentColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  WITHDRAW TAB
// ═══════════════════════════════════════════════════════════════
class _WithdrawTab extends StatefulWidget {
  final String phoneUID;
  const _WithdrawTab({required this.phoneUID});

  @override
  State<_WithdrawTab> createState() => _WithdrawTabState();
}

class _WithdrawTabState extends State<_WithdrawTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<double> _getAvailableBalance() async {
    final doc = await _firestore
        .collection('sellers')
        .doc(widget.phoneUID)
        .get();
    return (doc.data()?['Available_Balance'] ?? 0).toDouble();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final double amount = double.parse(_amountController.text.trim());

      // 1️⃣ Check available balance
      final double balance = await _getAvailableBalance();
      if (amount > balance) {
        _showSnack(
          'Insufficient balance. Available: Rs ${balance.toStringAsFixed(0)}',
          Colors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2️⃣ Deduct from Available_Balance immediately (holds the amount)
      await _firestore.collection('sellers').doc(widget.phoneUID).update({
        'Available_Balance': FieldValue.increment(-amount),
      });

      // 3️⃣ Create withdrawal request in subcollection
      await _firestore
          .collection('sellers')
          .doc(widget.phoneUID)
          .collection('withdrawals')
          .add({
        'uid': widget.phoneUID,
        'amount': amount,
        'accountName': _accountNameController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'status': 'pending', // pending | processing | completed | rejected
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'adminNote': '',
      });

      // 4️⃣ Reset form
      _amountController.clear();
      _accountNameController.clear();
      _bankNameController.clear();
      _accountNumberController.clear();

      _showSnack(
        'Withdrawal request submitted! Processing within 24 hours.',
        Colors.green,
      );
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Balance Card ────────────────────────────────────
          _BalanceCard(phoneUID: widget.phoneUID),
          const SizedBox(height: 20),

          // ── Withdrawal Form ─────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Withdrawal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Funds will be transferred within 24 hours.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration('Amount (Rs)', Icons.payments_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter amount';
                        if (double.parse(val) < 500) return 'Minimum Rs 500';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Your Bank Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    // Account Name
                    TextFormField(
                      controller: _accountNameController,
                      decoration: _inputDecoration('Account Title', Icons.person_outline),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter account title' : null,
                    ),
                    const SizedBox(height: 14),

                    // Bank Name
                    TextFormField(
                      controller: _bankNameController,
                      decoration: _inputDecoration('Bank Name', Icons.account_balance_outlined),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter bank name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Account Number
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration('Account / IBAN Number', Icons.credit_card),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter account number' : null,
                    ),
                    const SizedBox(height: 20),

                    // Warning Banner
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The amount will be deducted from your available balance immediately and transferred within 24 hours.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitWithdrawal,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_upward),
                        label: Text(_isLoading ? 'Processing...' : 'Request Withdrawal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ── Withdrawal History ──────────────────────────────
          _HistorySection(
            phoneUID: widget.phoneUID,
            collection: 'withdrawals',
            emptyText: 'No withdrawal history yet.',
            accentColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

/// Real-time balance card using StreamBuilder
class _BalanceCard extends StatelessWidget {
  final String phoneUID;
  const _BalanceCard({required this.phoneUID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sellers')
          .doc(phoneUID)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final available = data?['Available_Balance'] ?? 0;
        final earning = data?['Earning'] ?? 0;
        final deposit = data?['Deposit'] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${available.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _miniStat('Total Earned', 'Rs $earning', Colors.greenAccent),
                  const SizedBox(width: 24),
                  _miniStat('Total Deposited', 'Rs $deposit', Colors.lightGreenAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// Company bank details card with copy buttons
class _CompanyBankDetailsCard extends StatelessWidget {
  const _CompanyBankDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Send Money To',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...kCompanyBankDetails.entries.map(
              (entry) => _BankDetailRow(label: entry.key, value: entry.value),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'After transfer, attach screenshot below and submit.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
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

class _BankDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _BankDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied!'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Icon(Icons.copy, size: 16, color: Colors.blue.shade400),
          ),
        ],
      ),
    );
  }
}

/// Reusable history section for deposits and withdrawals
class _HistorySection extends StatelessWidget {
  final String phoneUID;
  final String collection; // 'deposits' or 'withdrawals'
  final String emptyText;
  final Color accentColor;

  const _HistorySection({
    required this.phoneUID,
    required this.collection,
    required this.emptyText,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${collection == 'deposits' ? 'Deposit' : 'Withdrawal'} History',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sellers')
              .doc(phoneUID)
              .collection(collection)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    emptyText,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _HistoryCard(
                  data: data,
                  collection: collection,
                  accentColor: accentColor,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String collection;
  final Color accentColor;

  const _HistoryCard({
    required this.data,
    required this.collection,
    required this.accentColor,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.orange; // pending
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'processing':
        return Icons.sync;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final amount = data['amount'] ?? 0;
    final timestamp = data['createdAt'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
        : 'Processing...';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (collection == 'deposits' && data['screenshotUrl'] != null) {
            _showScreenshot(context, data['screenshotUrl']);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Amount circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    collection == 'deposits'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs ${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    if (collection == 'withdrawals' && data['bankName'] != null)
                      Text(
                        '${data['bankName']} • ${data['accountNumber'] ?? ''}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    if (data['adminNote'] != null &&
                        (data['adminNote'] as String).isNotEmpty)
                      Text(
                        'Note: ${data['adminNote']}',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              // Status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(status),
                          size: 12,
                          color: _statusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (collection == 'deposits')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(Icons.image, size: 14, color: Colors.grey[400]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScreenshot(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Payment Screenshot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Image.network(url, fit: BoxFit.contain),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────────────────────
InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}