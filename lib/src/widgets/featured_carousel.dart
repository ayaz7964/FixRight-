// lib/src/widgets/featured_carousel.dart
import 'package:flutter/material.dart';

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});
  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _page = 0;
  final List<Map<String, String>> items = const [
    {'title': 'Top rated electricians', 'subtitle': 'Trusted pros near you', 'cta': 'Explore'},
    {'title': 'Urgent jobs', 'subtitle': 'Post and receive bids quickly', 'cta': 'Post Job'},
    {'title': 'Insurance', 'subtitle': 'Optional rework guarantee', 'cta': 'Learn More'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 120,
        child: PageView.builder(
          controller: _controller,
          itemCount: items.length,
          onPageChanged: (p) => setState(() => _page = p),
          itemBuilder: (context, index) {
            final it = items[index];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(it['subtitle']!),
                  ]),
                ),
                ElevatedButton(onPressed: () {}, child: Text(it['cta']!))
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      // Dots indicator
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(items.length, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _page == i ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(color: _page == i ? Colors.indigo : Colors.grey[300], borderRadius: BorderRadius.circular(8)),
        );
      })),
    ]);
  }
}
