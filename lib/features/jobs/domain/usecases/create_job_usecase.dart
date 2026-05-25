// lib/features/jobs/domain/usecases/create_job_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/jobs/domain/repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository repository;
  
  CreateJobUseCase(this.repository);
  
  Future<Either<Failure, Job>> call(CreateJobParams params) async {
    // Validate
    if (params.title.isEmpty) {
      return Left(ValidationFailure('Title is required'));
    }
    if (params.description.isEmpty) {
      return Left(ValidationFailure('Description is required'));
    }
    if (params.category.isEmpty) {
      return Left(ValidationFailure('Category is required'));
    }
    if (params.budget <= 0) {
      return Left(ValidationFailure('Budget must be greater than 0'));
    }
    if (params.locationText.isEmpty) {
      return Left(ValidationFailure('Location is required'));
    }
    
    return await repository.createJob(params);
  }
}

class CreateJobParams {
  final String title;
  final String description;
  final String category;
  final double budget;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  
  const CreateJobParams({
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.locationText,
    this.latitude,
    this.longitude,
    this.images = const [],
  });
}
