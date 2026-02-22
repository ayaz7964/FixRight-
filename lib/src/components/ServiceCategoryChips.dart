// lib/components/ServiceCategoryChips.dart

import 'package:flutter/material.dart';

class ServiceCategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Plumber', 'icon': Icons.plumbing},
    {'name': 'Electrician', 'icon': Icons.lightbulb_outline},
    {'name': 'Mechanic', 'icon': Icons.car_repair},
    {'name': 'Carpenter', 'icon': Icons.carpenter},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Tutor', 'icon': Icons.school}, // Example of a non-fix service
  ];

  ServiceCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Define height for the horizontal scroll
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0, right: 8.0),
            child: InkWell(
              onTap: () {
                // Action: Navigate to the category results page
                print('Tapped ${category['name']}');
              },
              child: FittedBox(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'],
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
          
          )
          ;
        },
      ),

      
    );
  }
}