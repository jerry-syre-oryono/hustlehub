// lib/features/gigs/domain/usecases/get_gigs_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/gigs/domain/repositories/gig_repository.dart';

class GetGigsUseCase {
  final GigRepository repository;
  
  GetGigsUseCase(this.repository);
  
  Future<Either<Failure, List<Gig>>> call({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    return await repository.getGigs(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      limit: limit,
      offset: offset,
    );
  }
}
