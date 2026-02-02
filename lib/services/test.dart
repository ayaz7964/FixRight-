import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

// Replace with your Cloudinary cloud name and unsigned upload preset name
const String CLOUD_NAME = 'drimurck6';
const String UNSIGNED_UPLOAD_PRESET = 'fixright_profile';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadImageToCloudinary() async {
    if (_image == null) return null;

    final url = Uri.parse('https://api.cloudinary.com');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = UNSIGNED_UPLOAD_PRESET
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonMap = json.decode(responseData);
      final String imageUrl = jsonMap['secure_url'];
      print("Uploaded Image URL: $imageUrl");
      return imageUrl;
    } else {
      print("Upload failed with status: ${response.statusCode}");
      return null;
    }
  }
  
  // Add UI for picking and uploading image
  @override
  Widget build(BuildContext context) {
    // ... UI implementation ...
    return Scaffold(
      appBar: AppBar(title: Text("Cloudinary Upload")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadImageToCloudinary,
              child: Text('Upload to Cloudinary'),
            ),
          ],
        ),
      ),
    );
  }
}