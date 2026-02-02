// // import 'dart:convert';
// // import 'dart:io';
// // import 'dart:typed_data';

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class ProfileImageUploader extends StatefulWidget {
// //   final String uid;
// //   final String? imageUrl;
// //   final double radius;

// //   const ProfileImageUploader({
// //     super.key,
// //     required this.uid,
// //     this.imageUrl,
// //     this.radius = 55,
// //   });

// //   @override
// //   State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
// // }

// // class _ProfileImageUploaderState extends State<ProfileImageUploader> {
// //   File? _selectedImage;
// //   bool _isUploading = false;

// //   final ImagePicker _picker = ImagePicker();

// //   // ✅ Cloudinary config (ONLY these two)
// //   static const String _cloudName = "drimurck6";
// //   static const String _uploadPreset = "fixright_profile";

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Stack(
// //         children: [
// //           GestureDetector(
// //             onTap: _isUploading ? null : _pickAndUploadImage,
// //             child: CircleAvatar(
// //               radius: widget.radius,
// //               backgroundColor: Colors.grey.shade300,
// //               backgroundImage: _getImageProvider(),
// //               child: _isUploading
// //                   ? const CircularProgressIndicator(
// //                       strokeWidth: 2,
// //                       color: Colors.white,
// //                     )
// //                   : null,
// //             ),
// //           ),

// //           // Camera icon
// //           Positioned(
// //             bottom: 2,
// //             right: 2,
// //             child: CircleAvatar(
// //               radius: widget.radius * 0.28,
// //               backgroundColor: Theme.of(context).primaryColor,
// //               child: const Icon(
// //                 Icons.camera_alt,
// //                 size: 18,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// ✅ Image source resolver
// //   ImageProvider _getImageProvider() {
// //     if (_selectedImage != null) {
// //       return FileImage(_selectedImage!);
// //     }
// //     if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
// //       return NetworkImage(widget.imageUrl!);
// //     }
// //     return const AssetImage('assets/images/avatar_placeholder.png');
// //   }

// //   /// ✅ Pick → Upload → Save
// //   Future<void> _pickAndUploadImage() async {
// //     final XFile? picked = await _picker.pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 70,
// //     );

// //     if (picked == null) return;

// //     setState(() => _isUploading = true);

// //     String? imageUrl;

// //     try {
// //       if (kIsWeb) {
// //         final Uint8List bytes = await picked.readAsBytes();
// //         imageUrl = await _uploadToCloudinary(bytes: bytes);
// //       } else {
// //         final File file = File(picked.path);
// //         setState(() => _selectedImage = file);
// //         imageUrl = await _uploadToCloudinary(file: file);
// //       }

// //       if (imageUrl != null) {
// //         await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(widget.uid)
// //             .update({
// //           'profileImage': imageUrl,
// //           'updatedAt': FieldValue.serverTimestamp(),
// //         });

// //         _showSnackBar("Profile image updated");
// //       } else {
// //         _showSnackBar("Upload failed");
// //       }
// //     } catch (e) {
// //       _showSnackBar("Error: $e");
// //     } finally {
// //       setState(() => _isUploading = false);
// //     }
// //   }

// //   /// ✅ Cloudinary upload (Web + Mobile)
// //   // Future<String?> _uploadToCloudinary({
// //   //   File? file,
// //   //   Uint8List? bytes,
// //   // }) async {
// //   //   final uri = Uri.parse(
// //   //     "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
// //   //   );

// //   //   final request = http.MultipartRequest("POST", uri)
// //   //     ..fields['upload_preset'] = _uploadPreset;

// //   //   if (kIsWeb && bytes != null) {
// //   //     request.files.add(
// //   //       http.MultipartFile.fromBytes(
// //   //         'file',
// //   //         bytes,
// //   //         filename: 'profile.jpg',
// //   //         contentType: MediaType('image', 'jpeg'),
// //   //       ),
// //   //     );
// //   //   } else if (file != null) {
// //   //     request.files.add(
// //   //       await http.MultipartFile.fromPath('file', file.path),
// //   //     );
// //   //   } else {
// //   //     return null;
// //   //   }

// //   //   final response = await request.send();
// //   //   final body = await response.stream.bytesToString();

// //   //   debugPrint("Cloudinary response: $body");

// //   //   if (response.statusCode == 200) {
// //   //     return jsonDecode(body)['secure_url'];
// //   //   }
// //   //   return null;
// //   // }


// //   Future<String?> _uploadToCloudinary({
// //   File? file,
// //   Uint8List? bytes,
// // }) async {
// //   const cloudName = "drimurck6";
// //   const uploadPreset = "fixright_profile";

// //   final uri = Uri.parse(
// //     "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
// //   );

// //   final request = http.MultipartRequest("POST", uri)
// //     ..fields['upload_preset'] = uploadPreset
// //     ..fields['resource_type'] = 'image'; // 🔴 REQUIRED

// //   if (kIsWeb && bytes != null) {
// //     request.files.add(
// //       http.MultipartFile.fromBytes(
// //         'file',
// //         bytes,
// //         filename: 'profile.jpg',
// //         contentType: MediaType('image', 'jpeg'),
// //       ),
// //     );
// //   } else if (file != null) {
// //     request.files.add(
// //       await http.MultipartFile.fromPath(
// //         'file',
// //         file.path,
// //       ),
// //     );
// //   } else {
// //     return null;
// //   }

// //   final response = await request.send();
// //   final responseBody = await response.stream.bytesToString();

// //   debugPrint("Cloudinary status: ${response.statusCode}");
// //   debugPrint("Cloudinary response: $responseBody");

// //   if (response.statusCode == 200) {
// //     return jsonDecode(responseBody)['secure_url'];
// //   }

// //   return null;
// // }


// //   void _showSnackBar(String message) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(SnackBar(content: Text(message)));
// //   }
// // }



// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

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

//   // 🔐 Cloudinary config
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

//   /// 📸 Image provider resolver
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

//   /// ☁️ Cloudinary upload (Web + Mobile)
//   Future<String> _uploadToCloudinary({
//     File? file,
//     Uint8List? bytes,
//   }) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
//     );

//     final request = http.MultipartRequest("POST", uri)
//       ..fields['upload_preset'] = _uploadPreset
//       ..fields['public_id'] = "profiles/${widget.uid}";

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




import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // ✅ Cloudinary config (ONLY THESE)
  static const String _cloudName = "drimurck6";
  static const String _uploadPreset = "fixright_profile";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadImage,
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _getImageProvider(),
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

  /// 🖼️ Resolve image source
  ImageProvider _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return NetworkImage(widget.imageUrl!);
    }
    return const AssetImage('assets/images/avatar_placeholder.png');
  }

  /// 📸 Pick → ☁️ Upload → 💾 Save
  Future<void> _pickAndUploadImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      String imageUrl;

      if (kIsWeb) {
        final Uint8List bytes = await picked.readAsBytes();
        imageUrl = await _uploadToCloudinary(bytes: bytes);
      } else {
        final File file = File(picked.path);
        setState(() => _selectedImage = file);
        imageUrl = await _uploadToCloudinary(file: file);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnackBar("Profile image updated successfully");
    } catch (e) {
      debugPrint("Upload error: $e");
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// ☁️ Cloudinary upload (UNSIGNED)
  Future<String> _uploadToCloudinary({
    File? file,
    Uint8List? bytes,
  }) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = _uploadPreset;

    if (kIsWeb && bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
    } else {
      throw Exception("No image selected");
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("Cloudinary status: ${response.statusCode}");
    debugPrint("Cloudinary response: $responseBody");

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['secure_url'];
    } else {
      final decoded = jsonDecode(responseBody);
      throw Exception(decoded['error']['message']);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
