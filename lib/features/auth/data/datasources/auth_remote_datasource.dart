// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:appwrite/appwrite.dart';
import 'package:hustlehub/core/services/appwrite_service.dart';

class AuthRemoteDataSource {
  final Account _account = AppwriteService.account;
  final Databases _databases = AppwriteService.databases;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await AppwriteService.setSession(session.$id);
      
      final user = await _account.get();
      final userDoc = await _databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'users',
        documentId: user.$id,
      );
      
      return userDoc.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      
      // Create user document
      final userDoc = await _databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'users',
        documentId: user.$id,
        data: {
          'userId': user.$id,
          'email': email,
          'name': name,
          'role': role,
          'verified': false,
          'rating': 0.0,
          'totalJobs': 0,
          'totalGigs': 0,
          'isBanned': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Create email verification
      await _account.createVerification(
        url: 'https://hustlehub.app/verify',
      );
      
      return userDoc.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
    await AppwriteService.clearSession();
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final user = await _account.get();
      final userDoc = await _databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: 'users',
        documentId: user.$id,
      );
      return userDoc.data;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await _account.updateVerification(userId: userId, secret: secret);
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'https://hustlehub.app/reset-password',
      );
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }
}
