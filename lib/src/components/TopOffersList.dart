// lib/components/TopOffersList.dart

import 'package:flutter/material.dart';
import '../pages/OfferDetailPage.dart'; // Import the new detail page

// Define a simple Offer data structure (for type safety and clarity)
class Offer {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String price; // New field for the detail page
  final String description; // New field for the detail page
  final Map<String, dynamic> provider; // New field for the detail page

  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.price,
    required this.description,
    required this.provider,
  });
}

class TopOffersList extends StatelessWidget {
  // 5 Impactful Offers Data
  final List<Offer> offers = const [
    Offer(
      id: 'clean-1',
      title: 'Professional House Cleaning - 2 Hours',
      subtitle: 'Get 20% off on your first booking!',
      tag: 'Limited time offer',
      icon: Icons.cleaning_services_outlined,
      iconColor: Colors.red,
      bgColor: Color(0xFFFAE0E0),
      price: '\$60',
      description: "A thorough cleaning of your home including dusting all surfaces, vacuuming carpets and rugs, and mopping all hard floors. We'll also clean your kitchen and bathrooms, including wiping down countertops, sinks, and toilets.",
      provider: {'name': 'Maria S.', 'rating': 4.8, 'reviews': 50, 'quote': "Maria was fantastic! Punctual, professional, and left my house sparkling. Highly recommend!"},
    ),
    Offer(
      id: 'plumb-2',
      title: 'Plumbing Package: Faucet & Drain Combo',
      subtitle: 'Leaky faucet + clogged drain combo',
      tag: 'Special Deal',
      icon: Icons.plumbing,
      iconColor: Colors.blue,
      bgColor: Color(0xFFE0F3FA),
      price: '\$99',
      description: "A comprehensive plumbing service addressing two common issues: fixing one leaky faucet and clearing one clogged drain. Includes a free pressure check.",
      provider: {'name': 'Zain B.', 'rating': 4.7, 'reviews': 120, 'quote': "Zain fixed my kitchen sink and gave great advice. Very efficient!"},
    ),
    Offer(
      id: 'elect-3',
      title: 'Electrical Safety Audit & Maintenance',
      subtitle: 'Identify risks and save on energy bills.',
      tag: 'New Service',
      icon: Icons.lightbulb_outline,
      iconColor: Colors.orange,
      bgColor: Color(0xFFFFF7E0),
      price: '\$75',
      description: "Full inspection of your home's wiring, breaker box, and outlets. Includes replacement of up to 3 standard wall switches or sockets.",
      provider: {'name': 'Usman A.', 'rating': 4.9, 'reviews': 85, 'quote': "Usman was knowledgeable and thorough. Great peace of mind."},
    ),
    Offer(
      id: 'hvac-4',
      title: 'HVAC Seasonal Tune-Up',
      subtitle: 'Prepare your AC/Heater for the season.',
      tag: 'Winter Prep',
      icon: Icons.ac_unit,
      iconColor: Colors.teal,
      bgColor: Color(0xFFE0FAF5),
      price: '\$120',
      description: "Cleaning, inspection, and calibration of your central air or heating system to ensure peak performance and energy efficiency for the upcoming season.",
      provider: {'name': 'Ahmed R.', 'rating': 4.6, 'reviews': 92, 'quote': "My AC is running so much quieter now. Excellent service!"},
    ),
    Offer(
      id: 'carp-5',
      title: 'Custom Furniture Assembly - 3 Items',
      subtitle: 'Save time and frustration with expert assembly.',
      tag: 'Best Value',
      icon: Icons.carpenter_sharp,
      iconColor: Colors.brown,
      bgColor: Color(0xFFF0EAE5),
      price: '\$150',
      description: "Assembly of up to three pieces of flat-pack furniture (e.g., bookshelf, desk, dresser). Tools and expertise provided.",
      provider: {'name': 'Asif D.', 'rating': 4.5, 'reviews': 60, 'quote': "Asif was quick and everything looks perfect. Will hire again."},
    ),
  ];

  const TopOffersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text(
            'Top Offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 80,),
          TextButton(onPressed: (){}, child: Text("See All Offers" , style: TextStyle(fontSize: 12),))
          ],)
          ,
          const SizedBox(height: 12),
          Column(
            children: offers.map((offer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                // Wrap the card in a GestureDetector to make it tappable
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the detail page and pass the entire Offer object
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfferDetailPage(offer: offer),
                      ),
                    );
                  },
                  child: _buildOfferCard(offer),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    Color tagColor = Colors.green;
    if (offer.tag == 'Limited time offer') {
      tagColor = const Color(0xFFEB4034);
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: offer.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                offer.icon,
                color: offer.iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.subtitle,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.tag,
                    style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}