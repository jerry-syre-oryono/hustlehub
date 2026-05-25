// lib/features/jobs/domain/entities/job.dart
import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String clientAvatar;
  final String title;
  final String description;
  final String category;
  final double budget;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final String status;
  final int applicationsCount;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  const Job({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientAvatar,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.locationText,
    this.latitude,
    this.longitude,
    required this.images,
    required this.status,
    required this.applicationsCount,
    required this.createdAt,
    this.expiresAt,
  });
  
  bool get isOpen => status == 'open';
  bool get isUrgent => expiresAt != null && expiresAt!.isBefore(DateTime.now().add(const Duration(days: 2)));
  
  @override
  List<Object?> get props => [
    id, clientId, title, description, category, budget, locationText,
    latitude, longitude, images, status, applicationsCount, createdAt, expiresAt
  ];
}
