import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, UserModel>> call(String email, String password, String name) async {
    return await repository.register(email, password, name);
  }
}