import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/domain/usecases/login_user.dart';
import 'package:task_manager/features/auth/domain/usecases/register_user.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_user.dart';

class MockLoginUser extends Mock implements LoginUser {}
class MockRegisterUser extends Mock implements RegisterUser {}
class MockLogoutUser extends Mock implements LogoutUser {}

void main() {
  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    final mockAuthBloc = AuthBloc(
      loginUser: MockLoginUser(),
      registerUser: MockRegisterUser(),
      logoutUser: MockLogoutUser(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    
    mockAuthBloc.close();
  });

  testWidgets('Register page displays correctly', (WidgetTester tester) async {
    final mockAuthBloc = AuthBloc(
      loginUser: MockLoginUser(),
      registerUser: MockRegisterUser(),
      logoutUser: MockLogoutUser(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockAuthBloc,
          child: const RegisterPage(),
        ),
      ),
    );

    expect(find.text('Create Account'), findsAtLeastNWidgets(1));
    expect(find.text('Full Name'), findsOneWidget);
    
    mockAuthBloc.close();
  });
}