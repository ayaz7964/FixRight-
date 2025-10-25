// lib/pages/ClientMainScreen.dart

import 'package:flutter/material.dart';
import './home_page.dart'; // YOUR EXISTING HomePage
// Import all new feature screens
import "./JobPostingScreen.dart";


// import 'package:flutter/material.dart';
// import './home_page.dart'; 
// // Import all necessary pages (assuming you keep the placeholders for now)
// import 'MessageChatBotScreen.dart'; 
// import 'ManageOrdersScreen.dart';
// import 'TutorialsScreen.dart';
// import 'ProfileScreen.dart';
// import 'JobPostingScreen.dart'; // FAB target

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

// class _ClientMainScreenState extends State<ClientMainScreen> {
//   int _selectedIndex = 0;

//   // List of all pages for the Bottom Navigation Bar
//   final List<Widget> _widgetOptions = <Widget>[
//     const HomePage(), // 0. Home (Your existing code)
//     const MessageChatBotScreen(), // 1. Message (Chatbot)
//     const ManageOrdersScreen(), // 2. Manage Orders
//     const TutorialsScreen(), // 3. Tutorials
//     const SearchFiltersScreen(), // 4. Search
//     const ProfileScreen(), // 5. Profile
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   void _postJob(BuildContext context) {
//     // Navigate to the job posting screen (where clients can set a budget and allow bidding)
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => const JobPostingScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The current selected page content
//       body: _widgetOptions.elementAt(_selectedIndex),

//       // 1. FLOATING ACTION BUTTON (Post Job) - Reworked for better visual blending
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _postJob(context),
//         // Use a simple Icon for a cleaner look when docked
//         child: const Icon(Icons.add_task), // Changed icon for action relevance
//         backgroundColor: Colors.teal.shade700,
//         foregroundColor: Colors.white,
//         elevation: 6.0,
//         shape: const CircleBorder(), // Use standard circular shape
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//       // 2. BOTTOM NAVIGATION BAR - Reworked to fix overflow and improve style
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.white, // Explicitly set white for clean look
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 6.0, // Reduced notch margin for better flow
//         clipBehavior: Clip.antiAlias,
//         child: SizedBox(
//           height: 60, // Standard height for bottom bar
//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround, // Distribute items evenly
//             children: <Widget>[
//               // Left Tabs (Home, Message, Orders)
//               _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
//               _buildNavItem(
//                 1,
//                 Icons.chat_bubble_outline,
//                 Icons.chat_bubble,
//                 'Message',
//               ),
//               _buildNavItem(
//                 2,
//                 Icons.assignment_outlined,
//                 Icons.assignment,
//                 'Orders',
//               ),

//               // Spacer for the centrally-placed FAB
//               const Spacer(),

//               // Right Tabs (Tutorials, Search, Profile)
//               _buildNavItem(
//                 3,
//                 Icons.video_library_outlined,
//                 Icons.video_library,
//                 'Tutorials',
//               ),
//               _buildNavItem(4, Icons.search_outlined, Icons.search, 'Search'),
//               _buildNavItem(5, Icons.person_outline, Icons.person, 'Profile'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function for nav bar items - Use Flexible size to fix overflow
//   Widget _buildNavItem(
//     int index,
//     IconData unselectedIcon,
//     IconData selectedIcon,
//     String label,
//   ) {
//     bool isSelected = _selectedIndex == index;
//     return Flexible(
//       // FIX: Use Flexible to allow items to shrink and fit
//       child: InkWell(
//         onTap: () => _onItemTapped(index),
//         child: Container(
//           // Removed fixed width for Flexible control
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 isSelected ? selectedIcon : unselectedIcon,
//                 color: isSelected ? Colors.teal.shade700 : Colors.grey[600],
//                 size: 26, // Slightly larger icon size for emphasis
//               ),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: isSelected ? Colors.teal.shade700 : Colors.grey[600],
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//                 maxLines: 1,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// }



// lib/pages/ClientMainScreen.dart (Reworked for Integrated Button)

 // Target screen


class _ClientMainScreenState extends State<ClientMainScreen> {
  // Use -1 for the central 'Post Job' action index since it's not a view
  int _selectedIndex = 0;
  final int _postJobIndex = 2; // Position for the central button (between 1 and 3)

  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(), // 0. Home
    const MessageChatBotScreen(), // 1. Message (Chatbot)
    // Index 2 is the post job button
    const ManageOrdersScreen(), // 3. Manage Orders (Actual Index 2)
    const TutorialsScreen(), // 4. Tutorials (Actual Index 3)
    const ProfileScreen(), // 5. Profile (Actual Index 4)
  ];

  void _onItemTapped(int index) {
    if (index == _postJobIndex) {
      _postJob(context); // If the center button is tapped, launch job post
    } else {
      // Adjust the content index: if tapped index is 3 or greater, subtract 1
      int contentIndex = index > _postJobIndex ? index - 1 : index;
      setState(() {
        _selectedIndex = contentIndex;
      });
    }
  }

  void _postJob(BuildContext context) {
    // Navigate to the job posting screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JobPostingScreen(),
      ),
    );
  }

  // Helper function for building the central action button
  Widget _buildPostJobItem() {
    return Container(
      width: MediaQuery.of(context).size.width / 5.5,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: () => _onItemTapped(_postJobIndex),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade700, // Prominent color
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Post',
              style: TextStyle(
                fontSize: 10,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }


  // Helper function for regular nav bar items
  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    // Logic needs to map tab indices (0, 1, 3, 4, 5) to content indices (0, 1, 2, 3, 4)
    int contentIndex = index > _postJobIndex ? index - 1 : index;
    bool isSelected = _selectedIndex == contentIndex;
    
    return Flexible( // Use Flexible to ensure stable spacing
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Colors.teal.shade700 : Colors.grey[600],
                size: 26,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.teal.shade700 : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
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
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),

      // Bottom Navigation Bar (No FAB, No BottomAppBar notch needed)
      bottomNavigationBar: Container(
        height: 60, // Standard height
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1), // slight shadow for elevation
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tab 0: Home
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            
            // Tab 1: Message
            _buildNavItem(1, Icons.chat_bubble_outline, Icons.chat_bubble, 'Message'),
            
            // Center Action: Post Job
            _buildPostJobItem(),

            // Tab 3 (Content Index 2): Orders
            _buildNavItem(3, Icons.assignment_outlined, Icons.assignment, 'Orders'),
            
            // Tab 4 (Content Index 3): Tutorials
            _buildNavItem(4, Icons.video_library_outlined, Icons.video_library, 'Tutorials'),
            
            // Tab 5 (Content Index 4): Profile
            _buildNavItem(5, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}

// lib/pages/MessageChatBotScreen.dart

class MessageChatBotScreen extends StatelessWidget {
  const MessageChatBotScreen({super.key});
  // Real-time chat and Chatbot Service [cite: 155, 193]
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chat & Support Bot')),
    body: const Center(child: Text('Real-time Chat and AI Chatbot Interface')),
  );
}

// lib/pages/ManageOrdersScreen.dart

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});
  // Manage bids, track job history, and manage payments [cite: 200, 223, 224]
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manage Orders (Bids & Status)')),
    body: const Center(child: Text('List of Posted Jobs and Received Bids')),
  );
}

// lib/pages/TutorialsScreen.dart

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});
  // Multilanguage tutorials for local domestic workers [cite: 158, 226]
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Multilanguage Tutorials')),
    body: const Center(
      child: Text('Educational Videos for Workers (Multilanguage)'),
    ),
  );
}

// lib/pages/SearchFiltersScreen.dart

class SearchFiltersScreen extends StatelessWidget {
  const SearchFiltersScreen({super.key});
  // Advanced search with filters, distance, bidding options, and fixed services [cite: 154, 230]
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Advanced Search & Filters')),
    body: const Center(
      child: Text('Distance, Urgency, Bidding Range, and Category Filters'),
    ),
  );
}

// lib/pages/ProfileScreen.dart

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  // Fiverr-style profile options (Switch to Seller Mode, Settings, etc.)
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Profile')),
    body: const Center(
      child: Text('Profile Settings, Notifications, Switch to Worker Mode'),
    ),
  );
}
