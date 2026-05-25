import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/gigs/domain/usecases/create_gig_usecase.dart';

abstract class GigRepository {
  Future<Either<Failure, Gig>> createGig(CreateGigParams params);
  Future<Either<Failure, List<Gig>>> getGigs({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, Gig>> getGig(String gigId);
  Future<Either<Failure, void>> updateGig(String gigId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteGig(String gigId);
}
