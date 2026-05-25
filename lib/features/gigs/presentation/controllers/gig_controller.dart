// lib/features/gigs/presentation/controllers/gig_controller.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/gigs/data/datasources/gig_remote_datasource.dart';
import 'package:hustlehub/features/gigs/data/repositories/gig_repository_impl.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/gigs/domain/repositories/gig_repository.dart';
import 'package:hustlehub/features/gigs/domain/usecases/create_gig_usecase.dart';
import 'package:hustlehub/features/gigs/domain/usecases/get_gigs_usecase.dart';

// Providers
final gigControllerProvider = StateNotifierProvider<GigController, GigState>((ref) {
  final createGigUseCase = ref.watch(createGigUseCaseProvider);
  final getGigsUseCase = ref.watch(getGigsUseCaseProvider);
  return GigController(
    createGigUseCase: createGigUseCase,
    getGigsUseCase: getGigsUseCase,
  );
});

final createGigUseCaseProvider = Provider((ref) {
  final repository = ref.watch(gigRepositoryProvider);
  return CreateGigUseCase(repository);
});

final getGigsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(gigRepositoryProvider);
  return GetGigsUseCase(repository);
});

final gigRepositoryProvider = Provider<GigRepository>((ref) {
  final remoteDataSource = GigRemoteDataSource();
  final gigsCache = Hive.box('gigs_cache');
  return GigRepositoryImpl(remoteDataSource, gigsCache);
});

// State
class GigState {
  final List<Gig> gigs;
  final bool isLoading;
  final Failure? failure;

  const GigState({
    this.gigs = const [],
    this.isLoading = false,
    this.failure,
  });

  GigState copyWith({
    List<Gig>? gigs,
    bool? isLoading,
    Failure? failure,
  }) {
    return GigState(
      gigs: gigs ?? this.gigs,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}

// Controller
class GigController extends StateNotifier<GigState> {
  final CreateGigUseCase createGigUseCase;
  final GetGigsUseCase getGigsUseCase;

  GigController({
    required this.createGigUseCase,
    required this.getGigsUseCase,
  }) : super(const GigState());

  Future<Either<Failure, Gig>> createGig({
    required String title,
    required String description,
    required String category,
    required double price,
    required String deliveryTime,
    List<String> portfolioImages = const [],
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await createGigUseCase(
      CreateGigParams(
        title: title,
        description: description,
        category: category,
        price: price,
        deliveryTime: deliveryTime,
        portfolioImages: portfolioImages,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (gig) {
        state = state.copyWith(
          isLoading: false,
          gigs: [gig, ...state.gigs],
        );
      },
    );

    return result;
  }

  Future<void> fetchGigs({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await getGigsUseCase(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (gigs) => state = state.copyWith(isLoading: false, gigs: gigs),
    );
  }
}
