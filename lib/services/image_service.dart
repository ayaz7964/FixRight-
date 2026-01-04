import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageService {
  final String cloudName =  dotenv.env['cloudName']??'';
  final String uploadPreset = dotenv.env['uploadPreset']??'';

  Future<String> uploadToCloudinary(File file) async {
    // Compress image before upload
    final compressed = await _compressFile(file, 800);

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', compressed.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      return body['secure_url'];
    } else {
      throw Exception('Upload failed: ${res.body}');
    }
  }

  Future<File> _compressFile(File file, int maxDim) async {
    final targetPath = '${file.path}_cmp.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      minWidth: maxDim,
      minHeight: maxDim,
    );

    return result != null ? File(result.path) : file;
  }
}







