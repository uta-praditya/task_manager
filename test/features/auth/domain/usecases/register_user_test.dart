import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/register_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUser(mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testName = 'Test User';
  const testUser = UserModel(
    id: '1',
    email: testEmail,
    name: testName,
  );

  test('should register user from repository', () async {
    when(() => mockRepository.register(testEmail, testPassword, testName))
        .thenAnswer((_) async => const Right(testUser));

    final result = await usecase(testEmail, testPassword, testName);

    expect(result, const Right(testUser));
    verify(() => mockRepository.register(testEmail, testPassword, testName));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.register(testEmail, testPassword, testName))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(testEmail, testPassword, testName);

    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.register(testEmail, testPassword, testName));
  });
}