import "package:flutter/material.dart";
import '../widgets//featured_carousel.dart';
import "../widgets/image_carousel.dart";
import '../components/HomeSearchBar.dart';
import '../components/ServiceCategoryChips.dart';
import '../components/TrustBanners.dart';
import '../components/LocalWorkerHighlight.dart';
import '../components/TopOffersList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScveQjNICyRHtR47TCOLdv_W5nYr6jNVjMgw&s",
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome ,", style: TextStyle(fontSize: 14)),
                  Text(
                    "Ayaz Hussain",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("New Notification")));
              },
              icon: Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Google Map Loading")));
              },
              icon: Icon(Icons.location_on_outlined),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HomeSearchBar(),
                    ServiceCategoryChips(),
                    ImageCarousel(),
                    SizedBox(height: 12),
                    FeaturedCarousel(),
                    TrustBanners(),
                    LocalWorkerHighlight(),
                    TopOffersList()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

