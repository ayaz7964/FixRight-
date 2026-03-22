import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatDetailScreen.dart';

// ═══════════════════════════════════════════════════════════════
//  HELP & SUPPORT SCREEN
//  - FAQs (expandable)
//  - Contact Us (opens chat with admin)
// ═══════════════════════════════════════════════════════════════

// ── Admin phone UID — change to your actual admin Firestore doc ID ──
const kAdminUid = '+923163797857'; // replace with real admin phone uid

class HelpSupportScreen extends StatefulWidget {
  final String uid; // logged-in user uid
  const HelpSupportScreen({super.key, required this.uid});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const List<Map<String, dynamic>> _faqs = [
    {
      'cat': 'Getting Started',
      'q': 'How do I create an account on FixRight?',
      'a': 'Download the FixRight app, tap "Sign Up", and enter your phone number. You\'ll receive a verification code via SMS. Once verified, fill in your name, city, and address to complete your profile.',
    },
    {
      'cat': 'Getting Started',
      'q': 'What is the difference between a Buyer and a Seller?',
      'a': 'A Buyer posts jobs and hires workers for tasks like plumbing, electrical work, cleaning, etc. A Seller (Worker) offers their skills and bids on jobs posted by buyers. The same account can be both — just toggle "Seller Mode" in your profile.',
    },
    {
      'cat': 'Getting Started',
      'q': 'How do I become a Seller/Worker?',
      'a': 'Go to your Profile → tap "Become a Seller" → fill in the seller registration form with your CNIC, skills, and bank details. Our admin team reviews your application within 1–2 business days.',
    },
    {
      'cat': 'Jobs & Orders',
      'q': 'How do I post a job?',
      'a': 'As a buyer, tap the "+" (Post Job) button in the bottom navigation bar. Fill in the job title, description, location, budget, and timing. Once posted, sellers will start bidding on your job.',
    },
    {
      'cat': 'Jobs & Orders',
      'q': 'How do I accept a bid and start a job?',
      'a': 'Go to My Orders → Open → tap on your job → review all bids → tap "Accept" on the bid you like. The seller will be notified and the job moves to "In Progress" status.',
    },
    {
      'cat': 'Jobs & Orders',
      'q': 'How do I pay for a completed job?',
      'a': 'When a seller marks a job complete, you\'ll receive a notification. Go to My Orders → Pending Payment → upload your payment receipt (bank transfer or JazzCash/EasyPaisa). Admin verifies and releases payment to the seller.',
    },
    {
      'cat': 'Offers',
      'q': 'What are Service Offers?',
      'a': 'Offers are pre-packaged services that sellers list (like a freelance gig). As a buyer, you can browse offers by category, see the price, delivery time, and directly place an order without going through the bidding process.',
    },
    {
      'cat': 'Offers',
      'q': 'How do I post a service offer as a seller?',
      'a': 'In Seller Mode, tap the "+" (Post Offer) button in the bottom navigation. Add a title, description, price, delivery time, skills, and optionally an image. Your offer will be visible to all buyers.',
    },
    {
      'cat': 'Payments & Wallet',
      'q': 'How does the wallet work?',
      'a': 'As a seller, your earnings are credited to your FixRight wallet after admin verifies buyer payments. You can then withdraw your balance to your registered bank account or mobile wallet (JazzCash/EasyPaisa).',
    },
    {
      'cat': 'Payments & Wallet',
      'q': 'What is Reserved Commission?',
      'a': 'When you place a bid or accept a job, FixRight reserves a small commission from your wallet as security. This is returned if the job is cancelled, or deducted upon successful completion.',
    },
    {
      'cat': 'Payments & Wallet',
      'q': 'How long does withdrawal take?',
      'a': 'Withdrawals are processed within 1–3 business days after admin approval. You\'ll receive a notification once your withdrawal is processed.',
    },
    {
      'cat': 'Insurance & Claims',
      'q': 'What is the insurance feature?',
      'a': 'Buyers can optionally purchase insurance (20% of job value) for added protection. If a job has issues, you can file a claim within 3 days of completion. An expert may be assigned to investigate.',
    },
    {
      'cat': 'Insurance & Claims',
      'q': 'How do I file an insurance claim?',
      'a': 'Go to My Orders → Completed → tap the job → tap "File Claim". Provide a description of the issue. Admin will review and may assign an expert to assess the situation.',
    },
    {
      'cat': 'Account & Profile',
      'q': 'How do I update my profile photo?',
      'a': 'Go to Profile → Edit Profile → tap the camera icon on your avatar → choose from Gallery or Camera. Your new photo will be uploaded when you tap "Save Changes".',
    },
    {
      'cat': 'Account & Profile',
      'q': 'Can I delete my account?',
      'a': 'Yes. Contact our support team through the "Contact Us" section in this screen. Our team will process your account deletion request within 7 business days.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_query.isEmpty) return _faqs;
    return _faqs.where((f) =>
        (f['q'] as String).toLowerCase().contains(_query) ||
        (f['a'] as String).toLowerCase().contains(_query) ||
        (f['cat'] as String).toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _teal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildFaqTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  // ── FAQs tab ──────────────────────────────────────────────
  Widget _buildFaqTab() {
    final faqs = _filteredFaqs;
    final categories = faqs.map((f) => f['cat'] as String).toSet().toList();

    return Column(children: [
      // Search bar
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200)),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search questions…',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: _searchCtrl.clear)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),

      Expanded(child: faqs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off_rounded, size: 52, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('No results for "$_query"', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            ]))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: categories.map((cat) {
                final catFaqs = faqs.where((f) => f['cat'] == cat).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: Colors.grey[500], letterSpacing: 0.8))),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                    child: Column(children: [
                      for (int i = 0; i < catFaqs.length; i++) ...[
                        _FaqTile(q: catFaqs[i]['q'], a: catFaqs[i]['a']),
                        if (i < catFaqs.length - 1)
                          Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),
                ]);
              }).toList(),
            )),
    ]);
  }

  // ── Contact Us tab ────────────────────────────────────────
  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Intro card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_teal, _tealDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text('We\'re here to help', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            SizedBox(height: 8),
            Text('Our support team is available 9 AM – 9 PM, Monday to Saturday. Chat with us directly for the fastest response.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          ]),
        ),

        const SizedBox(height: 24),

        // Chat with Support — opens real chat with admin
        _contactCard(
          icon: Icons.chat_bubble_outline_rounded,
          color: _teal,
          title: 'Chat with Support',
          subtitle: 'Start a real-time chat with our support team. Fastest response.',
          badge: 'Recommended',
          badgeColor: Colors.green,
          onTap: () => _openAdminChat(context),
        ),

        const SizedBox(height: 12),

        _contactCard(
          icon: Icons.email_outlined,
          color: const Color(0xFF1565C0),
          title: 'Email Support',
          subtitle: 'support@fixright.app\nTypically replies within 24 hours.',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _contactCard(
          icon: Icons.phone_outlined,
          color: Colors.orange.shade700,
          title: 'Call Support',
          subtitle: '+92 300 000 0000\nAvailable 9 AM – 9 PM, Mon–Sat.',
          onTap: () {},
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200)),
          child: Row(children: [
            Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade700, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text('Before contacting support, check our FAQs tab — most common questions are answered there.',
                style: TextStyle(fontSize: 13, color: Colors.amber.shade800, height: 1.4))),
          ]),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.black87)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: (badgeColor ?? Colors.teal).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor ?? Colors.teal)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4)),
            ])),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ]),
        ),
      );

  Future<void> _openAdminChat(BuildContext context) async {
    if (widget.uid.isEmpty) return;

    final db     = FirebaseFirestore.instance;
    final phones = [widget.uid, kAdminUid]..sort();
    final convId = '${phones[0]}_${phones[1]}';

    // Create conversation if needed
    final convDoc = await db.collection('conversations').doc(convId).get();
    if (!convDoc.exists) {
      final ud = (await db.collection('users').doc(widget.uid).get()).data() ?? {};
      final userName = '${ud['firstName'] ?? ''} ${ud['lastName'] ?? ''}'.trim();
      await db.collection('conversations').doc(convId).set({
        'participantIds':           [widget.uid, kAdminUid],
        'participantNames':         {widget.uid: userName, kAdminUid: 'FixRight Support'},
        'participantRoles':         {widget.uid: 'user', kAdminUid: 'admin'},
        'participantProfileImages': {widget.uid: ud['profileImage'] ?? '', kAdminUid: ''},
        'lastMessage':              '',
        'lastMessageAt':            Timestamp.now(),
        'createdAt':                Timestamp.now(),
        'unreadCounts':             {widget.uid: 0, kAdminUid: 0},
        'isSupport':                true,
      });
    }

    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            convId:    convId,
            myUid:     widget.uid,
            otherUid:  kAdminUid,
            otherName: 'FixRight Support',
            otherImage: '',
            otherRole: 'admin',
          )));
    }
  }
}

// ── Expandable FAQ tile ───────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final String q, a;
  const _FaqTile({required this.q, required this.a});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;

  static const _teal = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _open = !_open);
        _open ? _ctrl.forward() : _ctrl.reverse();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(widget.q,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: _open ? _teal : Colors.black87))),
            const SizedBox(width: 8),
            RotationTransition(turns: _rotateAnim,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _open ? _teal : Colors.grey[400], size: 22)),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _open ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(widget.a, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.55)),
            ) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}