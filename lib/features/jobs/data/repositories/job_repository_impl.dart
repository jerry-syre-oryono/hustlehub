// lib/features/jobs/data/repositories/job_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/core/services/storage_service.dart';
import 'package:hustlehub/features/jobs/data/datasources/job_remote_datasource.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/jobs/domain/repositories/job_repository.dart';
import 'package:hustlehub/features/jobs/domain/usecases/create_job_usecase.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;
  final Box _jobsCache;
  
  JobRepositoryImpl(this.remoteDataSource, this._jobsCache);
  
  @override
  Future<Either<Failure, Job>> createJob(CreateJobParams params) async {
    try {
      // Generate temporary ID for folder structure
      final tempJobId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload images to single bucket
      List<String> imageUrls = [];
      if (params.images.isNotEmpty) {
        imageUrls = await StorageService.uploadJobImages(tempJobId, params.images);
      }
      
      final jobData = {
        'title': params.title,
        'description': params.description,
        'category': params.category,
        'budget': params.budget,
        'locationText': params.locationText,
        'latitude': params.latitude,
        'longitude': params.longitude,
        'images': imageUrls,
        'status': 'open',
        'applicationsCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final jobDoc = await remoteDataSource.createJob(jobData);
      
      final job = Job(
        id: jobDoc['\$id'],
        clientId: jobDoc['clientId'] ?? '',
        clientName: '',
        clientAvatar: '',
        title: jobDoc['title'],
        description: jobDoc['description'],
        category: jobDoc['category'],
        budget: (jobDoc['budget'] ?? 0).toDouble(),
        locationText: jobDoc['locationText'],
        latitude: jobDoc['latitude']?.toDouble(),
        longitude: jobDoc['longitude']?.toDouble(),
        images: List<String>.from(jobDoc['images'] ?? []),
        status: jobDoc['status'],
        applicationsCount: jobDoc['applicationsCount'] ?? 0,
        createdAt: DateTime.parse(jobDoc['createdAt']),
      );
      
      // Cache the new job
      final List<Job> cachedJobs = List<Job>.from(_jobsCache.get('my_jobs') ?? <Job>[]);
      cachedJobs.add(job);
      await _jobsCache.put('my_jobs', cachedJobs);
      
      return Right(job);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Job>>> getJobs({
    String? category,
    String? status,
    double? lat,
    double? lng,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final jobsData = await remoteDataSource.getJobs(
        category: category,
        status: status,
        lat: lat,
        lng: lng,
        limit: limit,
        offset: offset,
      );
      
      final jobs = jobsData.map((data) => Job(
        id: data['\$id'],
        clientId: data['clientId'] ?? '',
        clientName: data['clientName'] ?? '',
        clientAvatar: data['clientAvatar'] ?? '',
        title: data['title'],
        description: data['description'],
        category: data['category'],
        budget: (data['budget'] ?? 0).toDouble(),
        locationText: data['locationText'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        images: List<String>.from(data['images'] ?? []),
        status: data['status'],
        applicationsCount: data['applicationsCount'] ?? 0,
        createdAt: DateTime.parse(data['createdAt']),
      )).toList();
      
      // Cache jobs for offline access
      await _jobsCache.put('jobs_feed', jobs);
      
      return Right(jobs);
    } catch (e) {
      // Try cache on error
      final cachedJobs = _jobsCache.get('jobs_feed');
      if (cachedJobs != null) {
        return Right(List<Job>.from(cachedJobs));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Job>> getJob(String jobId) async {
    try {
      final jobData = await remoteDataSource.getJob(jobId);
      final job = Job(
        id: jobData['\$id'],
        clientId: jobData['clientId'] ?? '',
        clientName: jobData['clientName'] ?? '',
        clientAvatar: jobData['clientAvatar'] ?? '',
        title: jobData['title'],
        description: jobData['description'],
        category: jobData['category'],
        budget: (jobData['budget'] ?? 0).toDouble(),
        locationText: jobData['locationText'],
        latitude: jobData['latitude']?.toDouble(),
        longitude: jobData['longitude']?.toDouble(),
        images: List<String>.from(jobData['images'] ?? []),
        status: jobData['status'],
        applicationsCount: jobData['applicationsCount'] ?? 0,
        createdAt: DateTime.parse(jobData['createdAt']),
      );
      
      // Cache individual job
      await _jobsCache.put('job_$jobId', job);
      
      return Right(job);
    } catch (e) {
      // Try cache
      final cachedJob = _jobsCache.get('job_$jobId');
      if (cachedJob != null) {
        return Right(cachedJob as Job);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteJob(String jobId) async {
    try {
      // Get job to find image URLs to delete
      final jobResult = await getJob(jobId);
      await jobResult.fold(
        (failure) async => throw Exception('Job not found'),
        (job) async {
          // Associated images deletion logic would go here
        },
      );
      
      await remoteDataSource.deleteJob(jobId);
      
      // Remove from cache
      await _jobsCache.delete('job_$jobId');
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateJob(jobId, data);
      
      // Update cache
      final cachedJob = _jobsCache.get('job_$jobId');
      if (cachedJob != null) {
        await _jobsCache.put('job_$jobId', cachedJob);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
