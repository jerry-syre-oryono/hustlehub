// lib/core/utils/image_utils.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> compressImage(
    String imagePath, {
    int quality = 80,
    int maxSizeMB = 2,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    // Check if compression is needed
    if (bytes.length <= maxSizeMB * 1024 * 1024 && quality >= 80) {
      return imagePath;
    }
    
    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imagePath;
    
    // Resize if too large (max 1920px)
    const maxDimension = 1920;
    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(
        image,
        width: image.width > maxDimension ? maxDimension : (image.width * (maxDimension / image.height)).round(),
        height: image.height > maxDimension ? maxDimension : (image.height * (maxDimension / image.width)).round(),
      );
    }
    
    // Adjust quality based on size
    int finalQuality = quality;
    int compressionAttempts = 0;
    List<int> compressedBytes = [];
    
    do {
      compressedBytes = img.encodeJpg(image, quality: finalQuality);
      compressionAttempts++;
      
      if (compressedBytes.length > maxSizeMB * 1024 * 1024) {
        finalQuality -= 10;
      } else {
        break;
      }
      
      if (compressionAttempts > 5 || finalQuality < 10) break;
    } while (compressedBytes.length > maxSizeMB * 1024 * 1024);
    
    // Save to temp directory
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File(
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await compressedFile.writeAsBytes(compressedBytes);
    
    return compressedFile.path;
  }
  
  static Future<int> getFileSizeInKB(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return bytes.length ~/ 1024;
  }
  
  static Future<bool> isValidImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
}
