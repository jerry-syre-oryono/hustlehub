// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isVerified;
  final double rating;
  final int totalJobs;
  final int totalGigs;
  final String? avatarUrl;
  final bool isBanned;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isVerified,
    required this.rating,
    required this.totalJobs,
    required this.totalGigs,
    this.avatarUrl,
    required this.isBanned,
    required this.createdAt,
  });
  
  bool get canPostJobs => role == 'client' || role == 'admin';
  bool get canPostGigs => role == 'worker' || role == 'admin';
  bool get isAdmin => role == 'admin';
  
  @override
  List<Object?> get props => [
    id, email, name, role, isVerified, rating, totalJobs, totalGigs, avatarUrl, isBanned, createdAt
  ];
}
