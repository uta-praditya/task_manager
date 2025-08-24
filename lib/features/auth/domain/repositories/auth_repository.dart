import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(String email, String password, String name);
  Future<Either<Failure, void>> logout();
}