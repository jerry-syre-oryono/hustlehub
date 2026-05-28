// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hustlehub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hustlehub/features/auth/domain/entities/user.dart';
import 'package:hustlehub/features/auth/domain/repositories/auth_repository.dart';
import 'package:hustlehub/features/auth/domain/usecases/login_usecase.dart';
import 'package:hustlehub/features/auth/domain/usecases/register_usecase.dart';
import 'package:hustlehub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hustlehub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:hustlehub/shared/enums/user_role.dart';

// Providers
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  
  return AuthController(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});

// UseCase providers
final loginUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = AuthRemoteDataSource();
  final userCache = Hive.box('user_cache');
  return AuthRepositoryImpl(remoteDataSource, userCache);
});

// State
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final Failure? failure;
  
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.failure,
  });
  
  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    Failure? failure,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      failure: failure ?? this.failure,
    );
  }
}

// Controller
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  
  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        if (failure is! AuthFailure) {
          state = state.copyWith(failure: failure);
        }
      },
      (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      },
    );
  }
  
  Future<Either<Failure, User>> login(String email, String password) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final result = await loginUseCase(email, password);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      ),
    );
    
    return result;
  }
  
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final result = await registerUseCase(email, password, name, role.name);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (user) => state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      ),
    );
    
    return result;
  }
  
  Future<Either<Failure, void>> logout() async {
    state = state.copyWith(isLoading: true);
    
    final result = await logoutUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (_) => state = const AuthState(),
    );
    
    return result;
  }
}
