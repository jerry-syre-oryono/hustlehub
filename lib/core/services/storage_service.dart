// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:hustlehub/core/services/appwrite_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class StorageService {
  static final Storage _storage = AppwriteService.storage;
  static const String bucketId = 'hustlehub-storage';
  
  // File type constants
  static const String typeJobImage = 'jobs';
  static const String typeGigImage = 'gigs';
  static const String typeUserAvatar = 'avatars';
  static const String typeVerification = 'verification';
  
  // Maximum file sizes per type (bytes)
  static const Map<String, int> maxFileSizes = {
    typeJobImage: 2 * 1024 * 1024,      // 2MB
    typeGigImage: 2 * 1024 * 1024,      // 2MB
    typeUserAvatar: 1 * 1024 * 1024,    // 1MB
    typeVerification: 5 * 1024 * 1024,  // 5MB
  };
  
  static Future<void> init() async {
    // Service initialization logic if needed
  }

  /// Generate file path for organized storage
  static String _generateFilePath(String type, String ownerId, String fileName) {
    return '$type/$ownerId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
  }
  
  /// Upload file with type validation
  static Future<String> uploadFile({
    required String filePath,
    required String type,
    required String ownerId,
    String? customFileName,
  }) async {
    try {
      // Validate file size
      final file = File(filePath);
      final fileSize = await file.length();
      final maxSize = maxFileSizes[type] ?? 2 * 1024 * 1024;
      
      if (fileSize > maxSize) {
        throw Exception('File size exceeds ${maxSize ~/ 1024 ~/ 1024}MB limit for $type');
      }
      
      // Compress image if it's an image file
      String uploadPath = filePath;
      if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.png')) {
        uploadPath = await _compressImage(filePath, type);
      }
      
      final fileName = customFileName ?? filePath.split('/').last;
      final fileId = _generateFilePath(type, ownerId, fileName);
      
      final result = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: uploadPath),
      );
      
      // Store metadata in a separate collection for tracking
      await _storeFileMetadata(
        fileId: result.$id,
        filePath: fileId,
        type: type,
        ownerId: ownerId,
        size: fileSize,
      );
      
      return _storage.getFileView(
        bucketId: bucketId,
        fileId: result.$id,
      ).toString();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  /// Upload multiple files
  static Future<List<String>> uploadMultipleFiles({
    required List<String> filePaths,
    required String type,
    required String ownerId,
  }) async {
    final List<String> urls = [];
    for (final path in filePaths) {
      final url = await uploadFile(
        filePath: path,
        type: type,
        ownerId: ownerId,
      );
      urls.add(url);
    }
    return urls;
  }
  
  /// Compress image before upload
  static Future<String> _compressImage(String imagePath, String type) async {
    final bytes = await File(imagePath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) return imagePath;
    
    // Determine quality based on type
    int quality = 85;
    if (type == typeUserAvatar) quality = 75;
    if (type == typeVerification) quality = 90;
    
    // Resize if too large
    const maxDimension = 1920;
    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(image, width: maxDimension);
    }
    
    final compressedBytes = img.encodeJpg(image, quality: quality);
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    
    return compressedFile.path;
  }
  
  /// Store file metadata for ownership tracking
  static Future<void> _storeFileMetadata({
    required String fileId,
    required String filePath,
    required String type,
    required String ownerId,
    required int size,
  }) async {
    final databases = AppwriteService.databases;
    await databases.createDocument(
      databaseId: AppwriteService.databaseId,
      collectionId: 'file_metadata',
      documentId: ID.unique(),
      data: {
        'fileId': fileId,
        'filePath': filePath,
        'type': type,
        'ownerId': ownerId,
        'size': size,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Delete file with ownership verification
  static Future<bool> deleteFile(String fileId, String userId, bool isAdmin) async {
    try {
      // Verify ownership
      final metadata = await _getFileMetadata(fileId);
      if (metadata == null) return false;
      
      if (metadata['ownerId'] != userId && !isAdmin) {
        throw Exception('You can only delete your own files');
      }
      
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      
      // Delete metadata
      await _deleteFileMetadata(fileId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
  
  /// Get file metadata
  static Future<Map<String, dynamic>?> _getFileMetadata(String fileId) async {
    try {
      final databases = AppwriteService.databases;
      final result = await databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: 'file_metadata',
        queries: [Query.equal('fileId', fileId)],
      );
      
      if (result.documents.isNotEmpty) {
        return result.documents.first.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Delete file metadata
  static Future<void> _deleteFileMetadata(String fileId) async {
    try {
      final databases = AppwriteService.databases;
      final result = await databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: 'file_metadata',
        queries: [Query.equal('fileId', fileId)],
      );
      
      for (final doc in result.documents) {
        await databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: 'file_metadata',
          documentId: doc.$id,
        );
      }
    } catch (e) {
      // Log but don't throw
      print('Failed to delete metadata: $e');
    }
  }
  
  /// Get file URL
  static String getFileUrl(String fileId) {
    return _storage.getFileView(
      bucketId: bucketId,
      fileId: fileId,
    ).toString();
  }
  
  /// Specific upload methods for convenience
  static Future<String> uploadJobImage(String jobId, String imagePath) async {
    return await uploadFile(
      filePath: imagePath,
      type: typeJobImage,
      ownerId: jobId,
    );
  }
  
  static Future<List<String>> uploadJobImages(String jobId, List<String> imagePaths) async {
    return await uploadMultipleFiles(
      filePaths: imagePaths,
      type: typeJobImage,
      ownerId: jobId,
    );
  }
  
  static Future<String> uploadGigImage(String gigId, String imagePath) async {
    return await uploadFile(
      filePath: imagePath,
      type: typeGigImage,
      ownerId: gigId,
    );
  }
  
  static Future<String> uploadAvatar(String userId, String imagePath) async {
    return await uploadFile(
      filePath: imagePath,
      type: typeUserAvatar,
      ownerId: userId,
      customFileName: 'avatar.jpg',
    );
  }
  
  static Future<Map<String, String>> uploadVerificationDocs(
    String userId,
    String idFrontPath,
    String idBackPath,
  ) async {
    final frontUrl = await uploadFile(
      filePath: idFrontPath,
      type: typeVerification,
      ownerId: userId,
      customFileName: 'id_front.jpg',
    );
    
    final backUrl = await uploadFile(
      filePath: idBackPath,
      type: typeVerification,
      ownerId: userId,
      customFileName: 'id_back.jpg',
    );
    
    return {
      'idFront': frontUrl,
      'idBack': backUrl,
    };
  }
}
