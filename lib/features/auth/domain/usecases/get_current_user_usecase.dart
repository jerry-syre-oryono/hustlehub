import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/auth/domain/entities/user.dart';
import 'package:hustlehub/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  
  GetCurrentUserUseCase(this.repository);
  
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}
