// lib/features/gigs/data/repositories/gig_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/core/services/storage_service.dart';
import 'package:hustlehub/features/gigs/data/datasources/gig_remote_datasource.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/gigs/domain/repositories/gig_repository.dart';
import 'package:hustlehub/features/gigs/domain/usecases/create_gig_usecase.dart';

class GigRepositoryImpl implements GigRepository {
  final GigRemoteDataSource remoteDataSource;
  final Box _gigsCache;
  
  GigRepositoryImpl(this.remoteDataSource, this._gigsCache);
  
  @override
  Future<Either<Failure, Gig>> createGig(CreateGigParams params) async {
    try {
      // Upload portfolio images
      List<String> imageUrls = [];
      if (params.portfolioImages.isNotEmpty) {
        final tempGigId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrls = await StorageService.uploadMultipleFiles(
          filePaths: params.portfolioImages,
          type: StorageService.typeGigImage,
          ownerId: tempGigId,
        );
      }
      
      final gigData = {
        'title': params.title,
        'description': params.description,
        'category': params.category,
        'price': params.price,
        'deliveryTime': params.deliveryTime,
        'portfolioImages': imageUrls,
        'rating': 0.0,
        'totalSales': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final gigDoc = await remoteDataSource.createGig(gigData);
      
      final gig = Gig(
        id: gigDoc['\$id'],
        workerId: gigDoc['workerId'] ?? '',
        workerName: '',
        workerAvatar: '',
        title: gigDoc['title'],
        description: gigDoc['description'],
        category: gigDoc['category'],
        price: (gigDoc['price'] ?? 0).toDouble(),
        deliveryTime: gigDoc['deliveryTime'],
        portfolioImages: List<String>.from(gigDoc['portfolioImages'] ?? []),
        rating: (gigDoc['rating'] ?? 0).toDouble(),
        totalSales: gigDoc['totalSales'] ?? 0,
        createdAt: DateTime.parse(gigDoc['createdAt']),
      );
      
      // Cache
      final List<Gig> cachedGigs = List<Gig>.from(_gigsCache.get('my_gigs') ?? <Gig>[]);
      cachedGigs.add(gig);
      await _gigsCache.put('my_gigs', cachedGigs);
      
      return Right(gig);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Gig>>> getGigs({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final gigsData = await remoteDataSource.getGigs(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        limit: limit,
        offset: offset,
      );
      
      final gigs = gigsData.map((data) => Gig(
        id: data['\$id'],
        workerId: data['workerId'] ?? '',
        workerName: data['workerName'] ?? '',
        workerAvatar: data['workerAvatar'] ?? '',
        title: data['title'],
        description: data['description'],
        category: data['category'],
        price: (data['price'] ?? 0).toDouble(),
        deliveryTime: data['deliveryTime'],
        portfolioImages: List<String>.from(data['portfolioImages'] ?? []),
        rating: (data['rating'] ?? 0).toDouble(),
        totalSales: data['totalSales'] ?? 0,
        createdAt: DateTime.parse(data['createdAt']),
      )).toList();
      
      // Cache for offline
      await _gigsCache.put('gigs_feed', gigs);
      
      return Right(gigs);
    } catch (e) {
      final cachedGigs = _gigsCache.get('gigs_feed');
      if (cachedGigs != null) {
        return Right(List<Gig>.from(cachedGigs));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Gig>> getGig(String gigId) async {
    try {
      final gigData = await remoteDataSource.getGig(gigId);
      final gig = Gig(
        id: gigData['\$id'],
        workerId: gigData['workerId'] ?? '',
        workerName: gigData['workerName'] ?? '',
        workerAvatar: gigData['workerAvatar'] ?? '',
        title: gigData['title'],
        description: gigData['description'],
        category: gigData['category'],
        price: (gigData['price'] ?? 0).toDouble(),
        deliveryTime: gigData['deliveryTime'],
        portfolioImages: List<String>.from(gigData['portfolioImages'] ?? []),
        rating: (gigData['rating'] ?? 0).toDouble(),
        totalSales: gigData['totalSales'] ?? 0,
        createdAt: DateTime.parse(gigData['createdAt']),
      );
      
      await _gigsCache.put('gig_$gigId', gig);
      return Right(gig);
    } catch (e) {
      final cachedGig = _gigsCache.get('gig_$gigId');
      if (cachedGig != null) {
        return Right(cachedGig as Gig);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteGig(String gigId) async {
    try {
      await remoteDataSource.deleteGig(gigId);
      await _gigsCache.delete('gig_$gigId');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGig(String gigId, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateGig(gigId, data);
      await _gigsCache.delete('gig_$gigId');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
