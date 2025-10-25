// // lib/pages/HomePageContent.dart
// // NOTE: Rename your existing HomePage.dart file to HomePageContent.dart

// import "package:flutter/material.dart";
// import '../widgets//featured_carousel.dart';
// import "../widgets/image_carousel.dart";
// import '../components/HomeSearchBar.dart';
// import '../components/ServiceCategoryChips.dart';
// import '../components/TrustBanners.dart';
// import '../components/LocalWorkerHighlight.dart';

// // This is now the content for the Home Tab
// class HomePageContent extends StatelessWidget {
//   const HomePageContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Note: Removed the Scaffold and AppBar here, as they are handled by ClientMainScreen

//     return SafeArea(
//       child: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // Custom Header (If you want to keep it in the scroll)
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildCustomHeader(context),
//             ),
//           ),
          
//           // Main Scrollable Content
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // All your existing components
//                 HomeSearchBar(),
//                 ServiceCategoryChips(),
//                 ImageCarousel(),
//                 const SizedBox(height: 12),
//                 // Assuming FeaturedCarousel is similar to ImageCarousel, ensure it's imported
//                 // FeaturedCarousel(), 
//                 TrustBanners(),
//                 LocalWorkerHighlight(),
//                 const SizedBox(height: 80), // Space for the FAB at the bottom
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Extracted the AppBar content into a reusable header
//   Widget _buildCustomHeader(BuildContext context) {
//     return Row(
//       children: [
//         const CircleAvatar(
//           radius: 25,
//           backgroundImage: NetworkImage(
//             "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScveQjNICyRHtR47TCOLdv_W5nYr6jNVjMgw&s",
//           ),
//         ),
//         const SizedBox(width: 10),
//         const Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Welcome ,", style: TextStyle(fontSize: 14)),
//               Text(
//                 "Ayaz Hussain",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             // This button is already handled by the Profile tab/Notifications
//           },
//           icon: const Icon(Icons.notifications),
//         ),
//         IconButton(
//           onPressed: () {
//             [cite_start]// Location is key for FixRight [cite: 154]
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Google Map Loading")));
//           },
//           icon: const Icon(Icons.location_on_outlined),
//         ),
//       ],
//     );
//   }
// }