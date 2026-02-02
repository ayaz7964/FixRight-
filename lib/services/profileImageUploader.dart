// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProfileImageUploader extends StatefulWidget {
//   final String uid;
//   final String? imageUrl;
//   final double radius;

//   const ProfileImageUploader({
//     super.key,
//     required this.uid,
//     this.imageUrl,
//     this.radius = 55,
//   });

//   @override
//   State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
// }

// class _ProfileImageUploaderState extends State<ProfileImageUploader> {
//   File? _selectedImage;
//   bool _isUploading = false;

//   final ImagePicker _picker = ImagePicker();

//   // ✅ Cloudinary config (ONLY THESE)
//   static const String _cloudName = "drimurck6";
//   static const String _uploadPreset = "fixright_profile";

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Stack(
//         children: [
//           GestureDetector(
//             onTap: _isUploading ? null : _pickAndUploadImage,
//             child: CircleAvatar(
//               radius: widget.radius,
//               backgroundColor: Colors.grey.shade300,
//               backgroundImage: _getImageProvider(),
//               child: _isUploading
//                   ? const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     )
//                   : null,
//             ),
//           ),
//           Positioned(
//             bottom: 2,
//             right: 2,
//             child: CircleAvatar(
//               radius: widget.radius * 0.28,
//               backgroundColor: Theme.of(context).primaryColor,
//               child: const Icon(
//                 Icons.camera_alt,
//                 size: 18,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 🖼️ Resolve image source
//   ImageProvider _getImageProvider() {
//     if (_selectedImage != null) {
//       return FileImage(_selectedImage!);
//     }
//     if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
//       return NetworkImage(widget.imageUrl!);
//     }
//     return const AssetImage('assets/images/avatar_placeholder.png');
//   }

//   /// 📸 Pick → ☁️ Upload → 💾 Save
//   Future<void> _pickAndUploadImage() async {
//     final XFile? picked = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (picked == null) return;

//     setState(() => _isUploading = true);

//     try {
//       String imageUrl;

//       if (kIsWeb) {
//         final Uint8List bytes = await picked.readAsBytes();
//         imageUrl = await _uploadToCloudinary(bytes: bytes);
//       } else {
//         final File file = File(picked.path);
//         setState(() => _selectedImage = file);
//         imageUrl = await _uploadToCloudinary(file: file);
//       }

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .set({
//         'profileImage': imageUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       _showSnackBar("Profile image updated successfully");
//     } catch (e) {
//       debugPrint("Upload error: $e");
//       _showSnackBar(e.toString());
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }

//   /// ☁️ Cloudinary upload (UNSIGNED)
//   Future<String> _uploadToCloudinary({
//     File? file,
//     Uint8List? bytes,
//   }) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
//     );

//     final request = http.MultipartRequest("POST", uri)
//       ..fields['upload_preset'] = _uploadPreset;

//     if (kIsWeb && bytes != null) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           bytes,
//           filename: 'profile.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       );
//     } else if (file != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'file',
//           file.path,
//         ),
//       );
//     } else {
//       throw Exception("No image selected");
//     }

//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();

//     debugPrint("Cloudinary status: ${response.statusCode}");
//     debugPrint("Cloudinary response: $responseBody");

//     if (response.statusCode == 200) {
//       return jsonDecode(responseBody)['secure_url'];
//     } else {
//       final decoded = jsonDecode(responseBody);
//       throw Exception(decoded['error']['message']);
//     }
//   }

//   void _showSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImageUploader extends StatefulWidget {
  final String uid;
  final String? imageUrl;
  final double radius;

  const ProfileImageUploader({
    super.key,
    required this.uid,
    this.imageUrl,
    this.radius = 55,
  });

  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  final bool _isUploading = false;
  File? _selectedImage;
  final String imageUrl =
      'https://images.pexels.com/photos/819530/pexels-photo-819530.jpeg?auto=compress&cs=tinysrgb&w=600';

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future <void> uploadImageToStorage(String imageFile) async {
   

    try {
      await _firestore.collection('users').doc(widget.uid).set({
        'profileImage': imageFile,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // _showSnackBar("Profile image updated successfully");
    } catch (e) {
      debugPrint("Upload error: $e");
      _showSnackBar(e.toString());
    }
    

    
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : () => {},
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: getImageProvider,
              child: _isUploading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: CircleAvatar(
              radius: widget.radius * 0.28,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  get getImageProvider {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      print('widget.imageUrl is returned ');
      return NetworkImage(widget.imageUrl!);
    }
    print('imageUrl is returned ');
    uploadImageToStorage(imageUrl);
    return NetworkImage(imageUrl);
  }

  String _showSnackBar(String message) {
    if (!mounted) return message;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    return message;
  }
}
