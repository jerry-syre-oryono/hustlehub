// lib/features/jobs/data/datasources/job_remote_datasource.dart
import 'package:appwrite/appwrite.dart';
import 'package:hustlehub/core/services/appwrite_service.dart';

class JobRemoteDataSource {
  final Databases _databases = AppwriteService.databases;
  final Storage _storage = AppwriteService.storage;
  
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    try {
      final document = await _databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'jobs',
        documentId: ID.unique(),
        data: jobData,
      );
      return document.data;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getJobs({
    String? category,
    String? status,
    double? lat,
    double? lng,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      List<String> queries = [
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('createdAt'),
      ];
      
      if (category != null && category.isNotEmpty) {
        queries.add(Query.equal('category', category));
      }
      if (status != null && status.isNotEmpty) {
        queries.add(Query.equal('status', status));
      }
      
      final result = await _databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: 'jobs',
        queries: queries,
      );
      
      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }
  
  Future<Map<String, dynamic>> getJob(String jobId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'jobs',
        documentId: jobId,
      );
      return document.data;
    } catch (e) {
      throw Exception('Failed to get job: $e');
    }
  }
  
  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'jobs',
        documentId: jobId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }
  
  Future<void> deleteJob(String jobId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'jobs',
        documentId: jobId,
      );
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
  
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    final List<String> uploadedUrls = [];
    
    for (final path in imagePaths) {
      try {
        final result = await _storage.createFile(
          bucketId: 'job-images',
          fileId: ID.unique(),
          file: InputFile.fromPath(path: path),
        );
        final imageUrl = _storage.getFileView(
          bucketId: 'job-images',
          fileId: result.$id,
        ).toString();
        uploadedUrls.add(imageUrl);
      } catch (e) {
        throw Exception('Failed to upload image: $e');
      }
    }
    
    return uploadedUrls;
  }
}
