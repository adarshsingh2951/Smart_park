import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ImageUploadProvider with ChangeNotifier {
  final String serverIp = 'http://192.168.29.48:3000';

  List<File> _images = [];
  List<String> _uploadedImages = [];
  List<String> _selectedImages = [];

  List<File> get images => _images;
  List<String> get selectedImages => _selectedImages;

  List<String> get uploadedImages => _uploadedImages;

  ImageUploadProvider() {
    _fetchExistingImages();
  }

  void addImage(File image) {
    _images.add(image);
  }

  void clearImages() {
    _images.clear();
    notifyListeners();
  }

  Future<void> _fetchExistingImages() async {
    final url = Uri.parse('$serverIp/images');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> imageList = json.decode(response.body);
        _uploadedImages = List<String>.from(imageList);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    }
  }

  Future<void> pickMultipleImages() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        for(var _image in pickedFiles){
          addImage(File(_image.path));
        }
        //_images = pickedFiles.map((e) => File(e.path)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> captureImageFromCamera() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> uploadImages({
    required String uid,
    required String subfolder,
  }) async {
    if (_images.isEmpty) return;

    for (var image in _images) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$serverIp/upload?uid=$uid&subfolder=$subfolder'),
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: basename(image.path),
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseData = json.decode(responseBody);
          final filePath = responseData['filePath'];
          print("✅ Upload successful: ${responseData['filePath']}");
          if (filePath != null) {
            print('🚀');
            final fileName = filePath.split('/').last;
            final fullUrl = '$serverIp/owners/$uid/$subfolder/$fileName';
            _uploadedImages.add(fullUrl);
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Upload error: $e');
      }
    }

    clearImages();
  }

  Future<void> deleteImage(int index) async {
  //   try {
  //     final filename = file.path.split('/').last;
  //     // Assuming you know the uid and subfolder
  //     final uid = 'your-uid';
  //     final subfolder = 'your-subfolder';
  //     final deleteUri = Uri.parse('$serverIp/delete/$uid/$subfolder/$filename');
  //
  //     final res = await http.delete(deleteUri);
  //     print('Deleting file: $filename');
  //     if (res.statusCode == 200) {
  //       _images.remove(file);
  //       notifyListeners();
  //     } else {
  //       print('Delete failed: ${res.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Delete error: $e');
  //   }
    _images.removeAt(index);
    notifyListeners();
   }

}
