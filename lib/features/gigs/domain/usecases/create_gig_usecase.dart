// lib/features/gigs/domain/usecases/create_gig_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/gigs/domain/repositories/gig_repository.dart';

class CreateGigUseCase {
  final GigRepository repository;
  
  CreateGigUseCase(this.repository);
  
  Future<Either<Failure, Gig>> call(CreateGigParams params) async {
    // Validation
    if (params.title.isEmpty) {
      return Left(ValidationFailure('Title is required'));
    }
    if (params.description.isEmpty) {
      return Left(ValidationFailure('Description is required'));
    }
    if (params.description.length < 20) {
      return Left(ValidationFailure('Description must be at least 20 characters'));
    }
    if (params.category.isEmpty) {
      return Left(ValidationFailure('Category is required'));
    }
    if (params.price <= 0) {
      return Left(ValidationFailure('Price must be greater than 0'));
    }
    if (params.deliveryTime.isEmpty) {
      return Left(ValidationFailure('Delivery time is required'));
    }
    if (params.portfolioImages.isEmpty) {
      return Left(ValidationFailure('Please add at least one portfolio image'));
    }
    
    return await repository.createGig(params);
  }
}

class CreateGigParams {
  final String title;
  final String description;
  final String category;
  final double price;
  final String deliveryTime;
  final List<String> portfolioImages;
  
  const CreateGigParams({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.deliveryTime,
    this.portfolioImages = const [],
  });
}
