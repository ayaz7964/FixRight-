
// lib/src/pages/ClientMainScreen.dart

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'MessengerHomeScreen.dart';
import 'orders_page.dart';
import 'ProfileScreen.dart';
import 'JobPostingScreen.dart';
import '../../services/unread_message_service.dart';

class ClientMainScreen extends StatefulWidget {
  // NEW: Add parameters to receive mode state and callback
  final bool isSellerMode;
  final ValueChanged<bool> onToggleMode;
  final String phoneUID;

  const ClientMainScreen({
    super.key,
    required this.isSellerMode,
    required this.onToggleMode,
    required this.phoneUID,
  });

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _selectedIndex = 0;
  final int _postJobIndex = 2;
  final UnreadMessageService _unreadService = UnreadMessageService();

  // NOTE: _widgetOptions must be defined AFTER initState to access widget properties
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize _widgetOptions with 4 screens: Home, Messages, Orders, Profile
    _widgetOptions = <Widget>[
      HomePage(phoneUID: widget.phoneUID),
      const MessengerHomeScreen(), // Messages screen at content index 1
      OrdersPage(phoneUID: widget.phoneUID),
      ProfileScreen(
        isSellerMode: widget.isSellerMode,
        onToggleMode: widget.onToggleMode,
        phoneUID: widget.phoneUID,
      ), // Profile screen is at content index 3
    ];
  }

  // --- Navigation Logic --- (remains the same)

  void _onItemTapped(int index) {
    if (index == _postJobIndex) {
      _postJob(context);
    } else {
      // Map navigation indices to content indices
      // Nav: 0→0 (Home), 1→1 (Messages), 2→Post, 3→2 (Orders), 4→3 (Profile)
      int contentIndex;
      if (index > _postJobIndex) {
        contentIndex = index - 1; // 3→2, 4→3
      } else {
        contentIndex = index; // 0→0, 1→1
      }

      setState(() {
        _selectedIndex = contentIndex;
      });
    }
  }

  void _postJob(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const JobPostingScreen()));
  }

  // --- Helper for Custom Nav Item Design --- (remains the same)

  Widget _buildNavItem(int navIndex, IconData icon, String label) {
    final Color primaryColor = Colors.teal.shade700;
    final Color unselectedColor = Colors.grey.shade600;

    // Map navigation indices to content indices
    // Nav: 0→0 (Home), 1→1 (Messages), 2→Post, 3→2 (Orders), 4→3 (Profile)
    int contentIndex;
    if (navIndex > _postJobIndex) {
      contentIndex = navIndex - 1; // 3→2, 4→3
    } else {
      contentIndex = navIndex; // 0→0, 1→1
    }

    bool isSelected =
        _selectedIndex == contentIndex && navIndex != _postJobIndex;

    // ... (rest of _buildNavItem logic remains the same) ...

    if (navIndex == _postJobIndex) {
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

    // Check if this is the Message tab (navIndex == 1)
    final isMessageTab = navIndex == 1;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(navIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? primaryColor : unselectedColor,
                    size: 24,
                  ),
                  // Unread message badge (only for Message tab)
                  if (isMessageTab)
                    StreamBuilder<int>(
                      stream: _unreadService.getTotalUnreadCount(),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        if (unreadCount == 0) return const SizedBox.shrink();

                        return Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                ],
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
            // Tab 0 (Content Index 0): Home
            _buildNavItem(0, Icons.home, 'Home'),

            // Tab 1 (Content Index 1): Message
            _buildNavItem(1, Icons.chat_bubble, 'Message'),

            // Tab 2: Post Job (Center Action)
            _buildNavItem(_postJobIndex, Icons.add, 'Post'),

            // Tab 3 (Content Index 2): Orders
            _buildNavItem(3, Icons.assignment, 'Services'),

            // Tab 4 (Content Index 3): Profile
            _buildNavItem(4, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}
