import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // 🔴 Replace with your actual Cloudinary credentials
  static const String _cloudName = 'drimucrk6';
  static const String _uploadPreset = 'fixright'; // unsigned preset

  /// Uploads an image file to Cloudinary and returns the secure URL
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
}