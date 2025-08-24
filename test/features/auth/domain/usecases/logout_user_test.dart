import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUser(mockRepository);
  });

  test('should logout user from repository', () async {
    when(() => mockRepository.logout())
        .thenAnswer((_) async => const Right(null));

    final result = await usecase();

    expect(result, const Right(null));
    verify(() => mockRepository.logout());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.logout())
        .thenAnswer((_) async => Left(CacheFailure()));

    final result = await usecase();

    expect(result, Left(CacheFailure()));
    verify(() => mockRepository.logout());
  });
}