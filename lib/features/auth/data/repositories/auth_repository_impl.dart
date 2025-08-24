import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final user = UserModel.fromJson(response['user']);
      await TokenStorage.saveToken(response['token']);
      await TokenStorage.saveUserData(response['user']);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(String email, String password, String name) async {
    try {
      final response = await remoteDataSource.register(email, password, name);
      final user = UserModel.fromJson(response['user']);
      await TokenStorage.saveToken(response['token']);
      await TokenStorage.saveUserData(response['user']);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await TokenStorage.clearAuth();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}