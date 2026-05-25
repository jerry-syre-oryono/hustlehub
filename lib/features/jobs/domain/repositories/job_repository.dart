import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/jobs/domain/usecases/create_job_usecase.dart';

abstract class JobRepository {
  Future<Either<Failure, Job>> createJob(CreateJobParams params);
  Future<Either<Failure, List<Job>>> getJobs({
    String? category,
    String? status,
    double? lat,
    double? lng,
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, Job>> getJob(String jobId);
  Future<Either<Failure, void>> updateJob(String jobId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteJob(String jobId);
}
