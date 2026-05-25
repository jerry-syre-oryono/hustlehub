// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/auth/domain/entities/user.dart';
import 'package:hustlehub/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(ValidationFailure('Email and password are required'));
    }
    if (!email.contains('@')) {
      return Left(ValidationFailure('Invalid email format'));
    }
    return await repository.login(email, password);
  }
}
