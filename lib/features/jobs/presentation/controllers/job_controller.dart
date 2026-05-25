// lib/features/jobs/presentation/controllers/job_controller.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/jobs/data/datasources/job_remote_datasource.dart';
import 'package:hustlehub/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/jobs/domain/repositories/job_repository.dart';
import 'package:hustlehub/features/jobs/domain/usecases/create_job_usecase.dart';

// Providers
final jobControllerProvider = StateNotifierProvider<JobController, JobState>((ref) {
  final createJobUseCase = ref.watch(createJobUseCaseProvider);
  return JobController(createJobUseCase: createJobUseCase);
});

final createJobUseCaseProvider = Provider((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return CreateJobUseCase(repository);
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final remoteDataSource = JobRemoteDataSource();
  final jobsCache = Hive.box('jobs_cache');
  return JobRepositoryImpl(remoteDataSource, jobsCache);
});

// State
class JobState {
  final List<Job> jobs;
  final bool isLoading;
  final Failure? failure;

  const JobState({
    this.jobs = const [],
    this.isLoading = false,
    this.failure,
  });

  JobState copyWith({
    List<Job>? jobs,
    bool? isLoading,
    Failure? failure,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}

// Controller
class JobController extends StateNotifier<JobState> {
  final CreateJobUseCase createJobUseCase;

  JobController({required this.createJobUseCase}) : super(const JobState());

  Future<Either<Failure, Job>> createJob({
    required String title,
    required String description,
    required String category,
    required double budget,
    required String locationText,
    List<String> images = const [],
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await createJobUseCase(
      CreateJobParams(
        title: title,
        description: description,
        category: category,
        budget: budget,
        locationText: locationText,
        images: images,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (job) {
        state = state.copyWith(
          isLoading: false,
          jobs: [job, ...state.jobs],
        );
      },
    );

    return result;
  }
}
