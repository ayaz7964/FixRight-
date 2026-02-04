import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

class Sellerform extends StatefulWidget {
  final String? uid;
  final Object userData; 

  const Sellerform({super.key,
   required this.uid,
   required this.userData,
  
  });

  @override
  State<Sellerform> createState() => _SellerformState();
}

class _SellerformState extends State<Sellerform> {
  String imageUrl = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller Form"  '${widget.uid }' '${ widget.userData}'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
              // Icon(
              //   Icons.person,
              //   size: 50,
              //   color: Colors.white,
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
