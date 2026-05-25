// lib/core/utils/image_picker_utils.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hustlehub/core/utils/image_utils.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();
  
  static Future<List<XFile>> pickImages({int maxCount = 3}) async {
    final List<XFile> images = [];
    
    for (int i = 0; i < maxCount; i++) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress at source
      );
      
      if (image != null) {
        images.add(image);
      } else {
        break; // User cancelled
      }
    }
    
    return images;
  }
  
  static Future<XFile?> pickSingleImage({int quality = 80}) async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: quality,
    );
  }
  
  static Future<XFile?> takePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }
  
  static Future<File> prepareForUpload(XFile image) async {
    // Compress to ensure under 2MB
    final compressedPath = await ImageUtils.compressImage(
      image.path,
      quality: 80,
      maxSizeMB: 2,
    );
    return File(compressedPath);
  }
}
