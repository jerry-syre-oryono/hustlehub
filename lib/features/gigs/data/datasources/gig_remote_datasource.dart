// lib/features/gigs/data/datasources/gig_remote_datasource.dart
import 'package:appwrite/appwrite.dart';
import 'package:hustlehub/core/services/appwrite_service.dart';

class GigRemoteDataSource {
  final Databases _databases = AppwriteService.databases;
  
  Future<Map<String, dynamic>> createGig(Map<String, dynamic> gigData) async {
    try {
      final document = await _databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'gigs',
        documentId: ID.unique(),
        data: gigData,
      );
      return document.data;
    } catch (e) {
      throw Exception('Failed to create gig: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getGigs({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      List<String> queries = [
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('rating'),
      ];
      
      if (category != null && category.isNotEmpty) {
        queries.add(Query.equal('category', category));
      }
      if (minPrice != null) {
        queries.add(Query.greaterThanEqual('price', minPrice));
      }
      if (maxPrice != null) {
        queries.add(Query.lessThanEqual('price', maxPrice));
      }
      if (minRating != null) {
        queries.add(Query.greaterThanEqual('rating', minRating));
      }
      
      final result = await _databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: 'gigs',
        queries: queries,
      );
      
      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      throw Exception('Failed to get gigs: $e');
    }
  }
  
  Future<Map<String, dynamic>> getGig(String gigId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'gigs',
        documentId: gigId,
      );
      return document.data;
    } catch (e) {
      throw Exception('Failed to get gig: $e');
    }
  }
  
  Future<void> updateGig(String gigId, Map<String, dynamic> data) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'gigs',
        documentId: gigId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update gig: $e');
    }
  }
  
  Future<void> deleteGig(String gigId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'gigs',
        documentId: gigId,
      );
    } catch (e) {
      throw Exception('Failed to delete gig: $e');
    }
  }
}
