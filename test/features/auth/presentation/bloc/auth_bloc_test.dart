import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/usecases/login_user.dart';
import 'package:task_manager/features/auth/domain/usecases/register_user.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_user.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUser extends Mock implements LoginUser {}
class MockRegisterUser extends Mock implements RegisterUser {}
class MockLogoutUser extends Mock implements LogoutUser {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogoutUser mockLogoutUser;

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockLogoutUser = MockLogoutUser();
    authBloc = AuthBloc(
      loginUser: mockLoginUser,
      registerUser: mockRegisterUser,
      logoutUser: mockLogoutUser,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const testUser = UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockLoginUser('test@example.com', 'password'))
            .thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginEvent(
        email: 'test@example.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUser('test@example.com', 'password'))
            .thenAnswer((_) async => Left(ServerFailure()));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginEvent(
        email: 'test@example.com',
        password: 'password',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Login failed. Please try again.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout is called',
      build: () {
        when(() => mockLogoutUser()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        AuthUnauthenticated(),
      ],
    );
  });
}