import 'package:flutter/material.dart';
import './home_page.dart';
// Import all necessary pages
import './MessageChatBotScreen.dart';
// import 'TutorialsScreen.dart';
import './orders_page.dart';
// import 'ProfileScreen.dart';
import 'JobPostingScreen.dart'; // Target for the Post Job button

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  // We use this to track the currently active content screen (0 to 4)
  int _selectedIndex = 0;
  // Index 2 is reserved for the 'Post Job' button within the 6-item navigation bar
  final int _postJobIndex = 2;

  // List of all pages for the content area (Total 5 screens)
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // 0. Home
    const MessageChatBotScreen(), // 1. Message
    const OrdersPage(), // 2. Orders (Originally Index 3)
    // const TutorialsScreen(), // 3. Tutorials (Originally Index 4)
    const ProfileScreen(), // 4. Profile (Originally Index 5)
  ];

  // --- Navigation Logic ---
  void _onItemTapped(int index) {
    if (index == _postJobIndex) {
      // If the center 'Post Job' button is tapped, navigate to the posting screen
      _postJob(context);
    } else {
      // Otherwise, update the content screen
      // If the tapped index is AFTER the 'Post Job' button (index 3, 4, 5),
      // we must subtract 1 to get the correct content index (2, 3, 4).
      int contentIndex = index > _postJobIndex ? index - 1 : index;

      setState(() {
        _selectedIndex = contentIndex;
      });
    }
  }

  void _postJob(BuildContext context) {
    // Navigate to the job posting screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const JobPostingScreen()));
  }

  // --- Helper for Custom Nav Item Design ---
  Widget _buildNavItem(int navIndex, IconData icon, String label) {
    final Color primaryColor = Colors.teal.shade700;
    final Color unselectedColor = Colors.grey.shade600;

    // Check if the current navIndex corresponds to the currently selected content screen
    int contentIndex = navIndex > _postJobIndex ? navIndex - 1 : navIndex;
    bool isSelected =
        _selectedIndex == contentIndex && navIndex != _postJobIndex;

    // For the central 'Post Job' button (unique styling)
    if (navIndex == _postJobIndex) {
      return Expanded(
        child: InkWell(
          onTap: () => _onItemTapped(navIndex),
          child: SizedBox(
            height: 60, // Ensure it fills the height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prominent Circular Container for the 'Post' button
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: primaryColor, // Use primary color
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
                // Text label below the button
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

    // For all other standard navigation items
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

  // --- FINAL BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Note: We avoid using BottomNavigationBar directly because it only supports
    // up to 5 items and doesn't allow the level of custom styling needed for
    // the central "Post" button. We use a custom Row within a Container instead.

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 70, // Slightly increased height for the central button and text
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
            // Tab 0: Home
            _buildNavItem(0, Icons.home, 'Home'),

            // Tab 1: Message
            _buildNavItem(1, Icons.chat_bubble, 'Message'),

            // Tab 2: Post Job (Center Action)
            _buildNavItem(_postJobIndex, Icons.add, 'Post'),

            // Tab 3 (Content Index 2): Orders
            _buildNavItem(3, Icons.assignment, 'Services'),

            // Tab 4 (Content Index 3): Tutorials
            // _buildNavItem(4, Icons.video_library, 'Tutorials'),

            // Tab 5 (Content Index 4): Profile
            _buildNavItem(4, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}

// Placeholder Screens (Assuming these are defined elsewhere or are placeholders)

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Multilanguage Tutorials')),
    body: const Center(
      child: Text('Educational Videos for Workers (Multilanguage)'),
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Profile')),
    body: Center(
      child: Column(
        children: [
          Text('Profile Settings, Notifications, Switch to Worker Mode'),
          ElevatedButton(onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
           child: Text('Logout') )
        ],
      )

    ),
  );
}
