import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  PRIVACY & SECURITY SCREEN
// ═══════════════════════════════════════════════════════════════
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const _teal     = Color(0xFF00695C);
  static const _tealDark = Color(0xFF004D40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_teal, _tealDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32)),
              const SizedBox(width: 16),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your data is protected', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('FixRight uses industry-standard encryption to keep your information safe.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
              ])),
            ]),
          ),

          const SizedBox(height: 24),
          _sectionLabel('Account Security'),
          _card([
            _infoTile(Icons.lock_outline_rounded, 'Password Protection',
                'Your account is protected with a secure password. Contact support to reset.'),
            _divider(),
            _infoTile(Icons.phone_android_rounded, 'Phone Verification',
                'Your phone number is verified and used as your unique account identifier.'),
            _divider(),
            _infoTile(Icons.login_rounded, 'Session Management',
                'You are automatically logged out after periods of inactivity for your safety.'),
          ]),

          const SizedBox(height: 16),
          _sectionLabel('Data & Privacy'),
          _card([
            _infoTile(Icons.storage_rounded, 'What We Collect',
                'We collect your name, phone number, location, profile photo, job history, and messages to operate the platform.'),
            _divider(),
            _infoTile(Icons.share_outlined, 'How We Use It',
                'Your data is used to match you with workers/buyers, process payments, and improve the app. We never sell your data to third parties.'),
            _divider(),
            _infoTile(Icons.location_on_outlined, 'Location Data',
                'Your city and address are used to find nearby workers. Precise GPS is only accessed when you explicitly share it on the map screen.'),
            _divider(),
            _infoTile(Icons.message_outlined, 'Messages',
                'Chat messages are stored to provide the messaging service. They are not read by FixRight staff unless required for a dispute.'),
          ]),

          const SizedBox(height: 16),
          _sectionLabel('Your Rights'),
          _card([
            _infoTile(Icons.edit_outlined, 'Update Your Data',
                'You can update your name, photo, address, and city at any time from the Edit Profile screen.'),
            _divider(),
            _infoTile(Icons.delete_outline_rounded, 'Delete Your Account',
                'To permanently delete your account and all associated data, contact our support team via the Help & Support screen.'),
            _divider(),
            _infoTile(Icons.download_outlined, 'Export Your Data',
                'You may request a copy of your personal data by contacting our support team.'),
          ]),

          const SizedBox(height: 16),
          _sectionLabel('Payments & Financial Data'),
          _card([
            _infoTile(Icons.credit_card_outlined, 'Payment Security',
                'All financial transactions are processed securely. We store only transaction records, not full bank details.'),
            _divider(),
            _infoTile(Icons.receipt_long_outlined, 'Transaction History',
                'Your earnings, deposits, and withdrawals are securely stored and accessible only to you and FixRight administrators.'),
          ]),

          const SizedBox(height: 16),

          // Policy links
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: Column(children: [
              _linkTile(context, Icons.policy_outlined, 'Full Privacy Policy', _teal),
              _divider(),
              _linkTile(context, Icons.gavel_rounded, 'Terms of Service', _teal),
              _divider(),
              _linkTile(context, Icons.cookie_outlined, 'Cookie Policy', _teal),
            ]),
          ),

          const SizedBox(height: 20),
          Center(child: Text('Last updated: March 2026',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
        color: Colors.grey[500], letterSpacing: 0.8)));

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
    child: Column(children: children));

  Widget _divider() => Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey.shade100);

  Widget _infoTile(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF00695C), size: 18)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(body, style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.45)),
      ])),
    ]),
  );

  Widget _linkTile(BuildContext context, IconData icon, String title, Color color) =>
      InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87))),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ]),
        ),
      );
}