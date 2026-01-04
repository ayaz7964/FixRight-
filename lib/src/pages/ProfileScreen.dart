
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  // NEW: Must receive the current mode and the function to toggle it
  final bool isSellerMode;
  final ValueChanged<bool> onToggleMode;

  const ProfileScreen({
    super.key,
    required this.isSellerMode,
    required this.onToggleMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Profile Options Lists and Widgets for the Profile Screen Itself ---

  // Options for the BUYER/Client mode
  final List<Map<String, dynamic>> _buyerOptions = [
    {'icon': Icons.diamond, 'title': 'Get inspired'},
    {'icon': Icons.favorite_border, 'title': 'Saved lists'},
    {'icon': Icons.insights, 'title': 'My interests'},
    {'icon': Icons.send, 'title': 'Invite friends'},
  ];

  // Options for the SELLER/Worker mode
  final List<Map<String, dynamic>> _sellerOptions = [
    {'icon': Icons.account_balance_wallet, 'title': 'Earnings'},
    {'icon': Icons.description, 'title': 'Custom offer templates'},
    {'icon': Icons.text_snippet, 'title': 'Briefs'},
    {'icon': Icons.share, 'title': 'Share Gigs'},
    {'icon': Icons.person_outline, 'title': 'My profile'}, 
  ];

  Widget _buildProfileOption({required IconData icon, required String title, required Color color}) {
    // NOTE: For the Seller side, "My Profile" should probably navigate to a public profile view
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Here, you would navigate to the detailed mini-screen for each option
        debugPrint('Tapped: $title');
      },
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Determine which list of options to display based on the mode received
    final currentOptions = widget.isSellerMode ? _sellerOptions : _buyerOptions;
    final primaryColor = widget.isSellerMode ? Colors.green.shade700 : const Color(0xFF2B7CD3); // Use app theme blue
    final headerText = widget.isSellerMode ? 'Selling' : 'My FixRight';
    final Color optionColor = widget.isSellerMode ? Colors.green.shade700 : const Color(0xFF2B7CD3);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Profile'),
            const Icon(Icons.notifications),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Container (Dynamic Color)
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.only(
                top: 20, // Reduced top padding since AppBar is present
                bottom: 10,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Info Row (Avatar, Name, Balance)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stack for Avatar + Online Dot
                      Stack(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/Ahp.png'),
                            maxRadius: 35,
                          ),
                          // Online Status Dot
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      // User Name and Balance
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ayazengima',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            'Personal balance: \$4',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Seller Mode Switch Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seller Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Switch(
                          value: widget.isSellerMode,
                          activeThumbColor: primaryColor,
                          onChanged: (bool newValue) {
                            // Call the central function to change the entire application view
                            widget.onToggleMode(newValue);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Dynamic Options List
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                headerText,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const Divider(height: 15),
            
            // Generate the list of options
            ...currentOptions
                .map((option) => _buildProfileOption(
                    icon: option['icon'] as IconData,
                    title: option['title'] as String,
                    color: optionColor))
                ,

            // 3. General Settings (Visible in both modes)
            const Padding(
              padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Text(
                'Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const Divider(height: 15),
            _buildProfileOption(icon: Icons.settings, title: 'Preferences', color: Colors.grey.shade700),
            _buildProfileOption(icon: Icons.account_circle, title: 'Account', color: Colors.grey.shade700),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/'); // Navigate to Login
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}