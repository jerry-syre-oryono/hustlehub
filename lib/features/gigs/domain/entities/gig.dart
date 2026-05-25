// lib/features/gigs/domain/entities/gig.dart
import 'package:equatable/equatable.dart';

class Gig extends Equatable {
  final String id;
  final String workerId;
  final String workerName;
  final String workerAvatar;
  final String title;
  final String description;
  final String category;
  final double price;
  final String deliveryTime;
  final List<String> portfolioImages;
  final double rating;
  final int totalSales;
  final DateTime createdAt;
  
  const Gig({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerAvatar,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.deliveryTime,
    required this.portfolioImages,
    required this.rating,
    required this.totalSales,
    required this.createdAt,
  });
  
  bool get isHighlyRated => rating >= 4.5;
  String get formattedPrice => 'KES ${price.toStringAsFixed(0)}';
  
  @override
  List<Object?> get props => [
    id, workerId, title, description, category, price,
    deliveryTime, portfolioImages, rating, totalSales, createdAt
  ];
}
