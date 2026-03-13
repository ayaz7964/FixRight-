// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class CloudinaryService {
//   // 🔴 Replace with your actual Cloudinary credentials
//   static const String _cloudName = 'drimucrk6';
//   static const String _uploadPreset = 'fixright'; // unsigned preset

//   /// Uploads an image file to Cloudinary and returns the secure URL
//   static Future<String?> uploadImage(File imageFile, {String folder = 'fixright/payments'}) async {
//     try {
//       final uri = Uri.parse(
//         'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
//       );

//       final request = http.MultipartRequest('POST', uri)
//         ..fields['upload_preset'] = _uploadPreset
//         ..fields['folder'] = folder
//         ..files.add(
//           await http.MultipartFile.fromPath('file', imageFile.path),
//         );

//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         final json = jsonDecode(responseBody);
//         return json['secure_url'] as String?;
//       } else {
//         print('Cloudinary upload failed: $responseBody');
        
//         return null;
//       }
//     } catch (e) {
//       print('Cloudinary error: $e');
//       return null;
//     }
//   }
// }




import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // add this import
import 'package:flutter/material.dart';           // add this import

class CloudinaryService {
  // 🔴 Replace with your actual Cloudinary credentials
  static const String _cloudName = 'drimucrk6';
  static const String _uploadPreset = 'fixright'; // unsigned preset

  /// Uploads an image file to Cloudinary and returns the secure URL
  /// ⚠️ DO NOT TOUCH — already working with deposit flow
  static Future<String?> uploadImage(File imageFile, {String folder = 'fixright/payments'}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);
        return json['secure_url'] as String?;
      } else {
        print('Cloudinary upload failed: $responseBody');
        return null;
      }
    } catch (e) {
      print('Cloudinary error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  🆕 NEW — Pick image from anywhere and get URL back
  // ─────────────────────────────────────────────────────────────

  static final ImagePicker _picker = ImagePicker();

  /// Pick from Gallery → upload → return URL
  /// Usage: final url = await CloudinaryService.pickAndUpload(folder: 'fixright/profiles');
  static Future<String?> pickAndUpload({
    String folder = 'fixright/general',
    int imageQuality = 85,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    if (picked == null) return null; // user cancelled

    return await uploadImage(File(picked.path), folder: folder);
  }

  /// Pick from Camera → upload → return URL
  /// Usage: final url = await CloudinaryService.captureAndUpload(folder: 'fixright/selfies');
  static Future<String?> captureAndUpload({
    String folder = 'fixright/general',
    int imageQuality = 85,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;

    return await uploadImage(File(picked.path), folder: folder);
  }

  /// Shows bottom sheet → user picks Gallery or Camera → uploads → returns URL
  /// Usage: final url = await CloudinaryService.pickWithSheet(context, folder: 'fixright/cnic');
  static Future<String?> pickWithSheet(
    BuildContext context, {
    String folder = 'fixright/general',
    int imageQuality = 85,
  }) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Image Source',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _sheetOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      color: Colors.blue,
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sheetOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      color: Colors.green,
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;

    return await uploadImage(File(picked.path), folder: folder);
  }

  /// Helper widget for bottom sheet option button
  static Widget _sheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}