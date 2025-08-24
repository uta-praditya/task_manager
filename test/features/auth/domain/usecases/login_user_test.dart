import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUser(mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testUser = UserModel(
    id: '1',
    email: testEmail,
    name: 'Test User',
  );

  test('should login user from repository', () async {
    when(() => mockRepository.login(testEmail, testPassword))
        .thenAnswer((_) async => const Right(testUser));

    final result = await usecase(testEmail, testPassword);

    expect(result, const Right(testUser));
    verify(() => mockRepository.login(testEmail, testPassword));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.login(testEmail, testPassword))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(testEmail, testPassword);

    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.login(testEmail, testPassword));
  });
}