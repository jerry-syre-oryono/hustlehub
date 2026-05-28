// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hustlehub/features/auth/domain/entities/user.dart';
import 'package:hustlehub/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Box _userCache;
  
  AuthRepositoryImpl(this.remoteDataSource, this._userCache);
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userData = await remoteDataSource.login(email, password);
      final user = User(
        id: userData['userId'] ?? userData['$id'] ?? '',
        email: userData['email'] ?? email,
        name: userData['name'] ?? '',
        role: userData['role'] ?? 'worker',
        isVerified: userData['verified'] ?? false,
        rating: (userData['rating'] ?? 0.0).toDouble(),
        totalJobs: userData['totalJobs'] ?? 0,
        totalGigs: userData['totalGigs'] ?? 0,
        avatarUrl: userData['avatarUrl'],
        isBanned: userData['isBanned'] ?? false,
        createdAt: userData['createdAt'] != null 
            ? DateTime.parse(userData['createdAt']) 
            : DateTime.now(),
      );
      
      // Cache user as JSON string - Sanitize first to prevent Closure errors
      final userJson = _sanitizeMap(user.toJson());
      await _userCache.put('current_user', jsonEncode(userJson));
      
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper to ensure map only contains JSON-encodable types
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      if (value is num || value is String || value is bool || value == null) {
        return MapEntry(key, value);
      }
      return MapEntry(key, value.toString());
    });
  }
  
  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final userData = await remoteDataSource.register(email, password, name, role);
      final user = User(
        id: userData['userId'] ?? userData['$id'] ?? '',
        email: userData['email'] ?? email,
        name: userData['name'] ?? name,
        role: userData['role'] ?? role,
        isVerified: false,
        rating: 0.0,
        totalJobs: 0,
        totalGigs: 0,
        avatarUrl: null,
        isBanned: false,
        createdAt: DateTime.now(),
      );

      // Cache user as JSON string - Sanitize first
      final userJson = _sanitizeMap(user.toJson());
      await _userCache.put('current_user', jsonEncode(userJson));

      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await _userCache.delete('current_user');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Check cache first
      final cachedData = _userCache.get('current_user');
      if (cachedData != null) {
        try {
          Map<String, dynamic> userMap;
          if (cachedData is String) {
            userMap = jsonDecode(cachedData);
          } else if (cachedData is Map) {
            userMap = Map<String, dynamic>.from(cachedData);
          } else {
            throw Exception('Invalid cache format');
          }
          
          if (userMap.isNotEmpty) {
            return Right(UserJson.fromJson(userMap));
          }
        } catch (_) {
          await _userCache.delete('current_user');
        }
      }
      
      final userData = await remoteDataSource.getCurrentUser();
      final user = User(
        id: userData['userId'] ?? userData['$id'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        role: userData['role'] ?? 'worker',
        isVerified: userData['verified'] ?? false,
        rating: (userData['rating'] ?? 0.0).toDouble(),
        totalJobs: userData['totalJobs'] ?? 0,
        totalGigs: userData['totalGigs'] ?? 0,
        avatarUrl: userData['avatarUrl'],
        isBanned: userData['isBanned'] ?? false,
        createdAt: userData['createdAt'] != null 
            ? DateTime.parse(userData['createdAt']) 
            : DateTime.now(),
      );
      
      // Cache user as JSON string - Sanitize first
      final userJson = _sanitizeMap(user.toJson());
      await _userCache.put('current_user', jsonEncode(userJson));
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> verifyEmail(String userId, String secret) async {
    try {
      await remoteDataSource.verifyEmail(userId, secret);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// Extension methods for JSON conversion
extension UserJson on User {
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'isVerified': isVerified,
    'rating': rating,
    'totalJobs': totalJobs,
    'totalGigs': totalGigs,
    'avatarUrl': avatarUrl,
    'isBanned': isBanned,
    'createdAt': createdAt.toIso8601String(),
  };
  
  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    role: json['role'],
    isVerified: json['isVerified'],
    rating: json['rating'],
    totalJobs: json['totalJobs'],
    totalGigs: json['totalGigs'],
    avatarUrl: json['avatarUrl'],
    isBanned: json['isBanned'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
