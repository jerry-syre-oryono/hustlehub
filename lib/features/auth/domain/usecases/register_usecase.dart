import 'package:dartz/dartz.dart';
import 'package:hustlehub/core/errors/failures.dart';
import 'package:hustlehub/features/auth/domain/entities/user.dart';
import 'package:hustlehub/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String email, String password, String name, String role) async {
    return await repository.register(email, password, name, role);
  }
}
