import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await loginUser(event.email, event.password);
    
    result.fold(
      (failure) => emit(const AuthError(message: 'Login failed. Please try again.')),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await registerUser(event.email, event.password, event.name);
    
    result.fold(
      (failure) => emit(const AuthError(message: 'Registration failed. Please try again.')),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUser();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final userData = await TokenStorage.getUserData();
    if (userData != null) {
      final user = UserModel.fromJson(userData);
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}