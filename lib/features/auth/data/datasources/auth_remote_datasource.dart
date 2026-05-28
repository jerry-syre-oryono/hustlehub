// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:hustlehub/core/services/appwrite_service.dart';

class AuthRemoteDataSource {
  final Account _account = AppwriteService.account;
  final Databases _databases = AppwriteService.databases;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Ensure we are logged out first
      try {
        await logout();
      } catch (_) {}

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
      
      final userData = userDoc.toMap();
      // Sync verification status from Auth to the returned data
      userData['verified'] = user.emailVerification;
      
      // Also update the database if it's out of sync
      if (userDoc.data['verified'] != user.emailVerification) {
        await _databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: 'users',
          documentId: user.$id,
          data: {'verified': user.emailVerification},
        );
      }
      
      return userData;
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
      try {
        await logout();
      } catch (_) {}

      // 1. Try to create the account
      models.User? user;
      final String uniqueId = ID.unique(); // Execute and store as String immediately
      try {
        user = await _account.create(
          userId: uniqueId,
          email: email,
          password: password,
          name: name,
        );
      } catch (e) {
        // If user already exists in Auth, we'll try to log in instead of failing
        if (e.toString().contains('user_already_exists')) {
          // Successive steps will handle logging in
        } else {
          rethrow;
        }
      }
      
      // 2. Log in to get a session (Must be logged in to create/update document)
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await AppwriteService.setSession(session.$id.toString());

      if (user == null) {
        user = await _account.get();
      }

      final String userId = user.$id.toString();

      // 3. Create or Update user document
      Map<String, dynamic> docData;
      try {
        final userDoc = await _databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: 'users',
          documentId: userId,
          data: {
            'userId': userId,
            'email': email,
            'name': name,
            'role': role,
            'verified': user.emailVerification,
            'rating': 0.0,
            'totalJobs': 0,
            'totalGigs': 0,
            'isBanned': false,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
        docData = userDoc.toMap();
      } catch (e) {
        // If document already exists, just get it
        if (e.toString().contains('document_already_exists')) {
          final userDoc = await _databases.getDocument(
            databaseId: AppwriteService.databaseId,
            collectionId: 'users',
            documentId: userId,
          );
          docData = userDoc.toMap();
          // Update it to ensure role/name are correct
          await _databases.updateDocument(
            databaseId: AppwriteService.databaseId,
            collectionId: 'users',
            documentId: userId,
            data: {'name': name, 'role': role},
          );
        } else {
          rethrow;
        }
      }
      
      // Force convert Map to clean String types to avoid closure errors
      final Map<String, dynamic> cleanData = Map<String, dynamic>.from(docData);
      cleanData['verified'] = user.emailVerification;
      cleanData['userId'] = userId;
      
      return cleanData;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
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
      
      final userData = userDoc.toMap();
      userData['verified'] = user.emailVerification;
      
      // Sync verification status to DB if needed
      if (userDoc.data['verified'] != user.emailVerification) {
        await _databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: 'users',
          documentId: user.$id,
          data: {'verified': user.emailVerification},
        );
      }
      
      return userData;
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
