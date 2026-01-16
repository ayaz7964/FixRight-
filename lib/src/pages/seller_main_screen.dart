// lib/src/pages/seller_main_screen.dart

import 'package:flutter/material.dart';
import 'MessageChatBotScreen.dart'; // Reuse chat screen
import 'ProfileScreen.dart'; // Reuse profile screen
import 'JobPostingScreen.dart'; // Reuse job posting/gig creation screen (for Post Services)
import 'ManageOrdersScreen.dart'; // Orders management screen
import 'seller_dashboard_page.dart'; // Dashboard content

class SellerMainScreen extends StatefulWidget {
  final bool isSellerMode;
  final ValueChanged<bool> onToggleMode;
  final String phoneUID;

  const SellerMainScreen({
    super.key,
    required this.isSellerMode,
    required this.onToggleMode,
    required this.phoneUID,
  });

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _selectedIndex = 0;
  // There are 4 visible items, so the 'Post Services' button (which is not a content page)
  // must sit between index 1 and index 2. Let's make it nav index 2.
  final int _postGigIndex = 2;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Content screens for the Seller flow (Total 4 Screens: 0, 1, 2, 3)
    _widgetOptions = <Widget>[
      SellerDashboardPage(
        phoneUID: widget.phoneUID,
      ), // 0. Dashboard (Home screen replacement)
      MessageChatBotScreen(phoneUID: widget.phoneUID), // 1. Messages
      ManageOrdersScreen(
        phoneUID: widget.phoneUID,
      ), // 2. Manage Orders/Gigs (Used as "Services")
      ProfileScreen(
        isSellerMode: widget.isSellerMode,
        onToggleMode: widget.onToggleMode,
        phoneUID: widget.phoneUID,
      ), // 3. Profile
    ];
  }

  // --- Navigation Logic ---
  void _onItemTapped(int index) {
    if (index == _postGigIndex) {
      // If the center button is tapped, perform the action
      _postGig(context);
    } else {
      // The content list has 4 items. The navigation bar has 5 slots.
      // If index is 3 or 4 (after the post button at 2), subtract 1.
      int contentIndex = index > _postGigIndex ? index - 1 : index;

      setState(() {
        _selectedIndex = contentIndex;
      });
    }
  }

  void _postGig(BuildContext context) {
    // Re-use JobPostingScreen for creating a new Gig/Service
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const JobPostingScreen()));
  }

  // --- Helper for Custom Nav Item Design ---
  Widget _buildNavItem(int navIndex, IconData icon, String label) {
    final Color primaryColor = Colors.green.shade700;
    final Color unselectedColor = Colors.grey.shade600;

    // Logic to map nav index to content index (used for selection highlight)
    int contentIndex = navIndex > _postGigIndex ? navIndex - 1 : navIndex;
    bool isSelected =
        _selectedIndex == contentIndex && navIndex != _postGigIndex;

    // Center Post Services button styling
    if (navIndex == _postGigIndex) {
      return Expanded(
        child: InkWell(
          onTap: () => _onItemTapped(navIndex),
          child: SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.2,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Standard navigation items
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(navIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : unselectedColor,
                size: 24,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  color: isSelected ? primaryColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tab 0 (Content Index 0): Dashboard
            _buildNavItem(0, Icons.dashboard, 'Dashboard'),

            // Tab 1 (Content Index 1): Messages
            _buildNavItem(1, Icons.mail_outline, 'Messages'),

            // Tab 2: Post Gig (Center Action, No content screen)
            _buildNavItem(
              _postGigIndex,
              Icons.add,
              'Post Services',
            ), // _postGigIndex = 2
            // Tab 3 (Content Index 2): Manage Services (Orders)
            _buildNavItem(3, Icons.assignment, 'Services'),

            // Tab 4 (Content Index 3): Profile
            _buildNavItem(4, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}
// The placeholder SellerDashboardPage remains the same if you want to use it