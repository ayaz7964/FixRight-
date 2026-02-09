// lib/pages/JobPostingScreen.dart

import 'package:flutter/material.dart';

class JobPostingScreen extends StatelessWidget {
  const JobPostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job Ayaz HUssain '),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Your Job for Bidding',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Workers will place competitive bids. Set your maximum budget to facilitate the bargaining process.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 30),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Job Title (e.g., Water Pump Repair)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Maximum Budget (PKR) - Workers will bid below this',
                border: OutlineInputBorder(),
                prefixText: 'PKR ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Location input uses Google Maps API [cite: 195]
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Job Location (Tap to use GPS)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
              ),
              readOnly: true,
              onTap: () { /* Launch map picker */ },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Final Action: Submit to Job & Bidding Service [cite: 213]
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Posted! Waiting for Competitive Bids...")));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Post Job & Start Bidding', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}