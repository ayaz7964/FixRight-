// lib/components/ImageCarousel.dart

import 'package:flutter/material.dart';
// 1. ADD THE PREFIX 'as i_carousel' to resolve the name conflict
import 'package:carousel_slider/carousel_slider.dart' as i_carousel; 

class ImageCarousel extends StatelessWidget {
  // Example list of image paths or URLs
  final List<String> imgList = [
    'https://picsum.photos/id/237/800/400',
    'https://picsum.photos/id/238/800/400',
    'https://picsum.photos/id/239/800/400',
    'https://picsum.photos/id/240/800/400',
  ];

  ImageCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Use the prefix 'i_carousel' when calling the component
    return i_carousel.CarouselSlider( 
      // 3. Use the prefix 'i_carousel' for the options class
      options: i_carousel.CarouselOptions( 
        autoPlay: true, // Automatically slide images
        aspectRatio: 2.0, // Width divided by height
        enlargeCenterPage: true, // Make the central item slightly bigger
        viewportFraction: 0.9, // How much of the viewport the item should occupy
      ),
      items: imgList.map((item) => Container(
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    'No. ${imgList.indexOf(item) + 1} image',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}