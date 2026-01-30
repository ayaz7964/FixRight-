import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

/// Service for uploading images to Cloudinary
class ImageUploadService {
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String _uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  /// Upload image to Cloudinary using unsigned upload
  /// Returns the secure_url of the uploaded image
  Future<String> uploadImage(File imageFile) async {
    if (_cloudName.isEmpty) {
      throw Exception('CLOUDINARY_CLOUD_NAME not set in .env');
    }
    if (_uploadPreset.isEmpty) {
      throw Exception('CLOUDINARY_UPLOAD_PRESET not set in .env');
    }

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final secureUrl = data['secure_url'] as String?;
        if (secureUrl == null || secureUrl.isEmpty) {
          throw Exception('No secure_url in response');
        }
        return secureUrl;
      } else {
        final errorBody = jsonDecode(responseBody);
        throw Exception(
          'Upload failed: ${errorBody['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Image upload error: $e');
      rethrow;
    }
  }

  /// Validate image before upload (size and format)
  static String? validateImage(File imageFile) {
    try {
      final sizeInMB = imageFile.lengthSync() / (1024 * 1024);
      if (sizeInMB > 5) {
        return 'Image must be less than 5MB';
      }

      final ext = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        return 'Only JPG, PNG, WebP supported';
      }

      return null; // Valid
    } catch (e) {
      return 'Error validating image';
    }
  }
}
