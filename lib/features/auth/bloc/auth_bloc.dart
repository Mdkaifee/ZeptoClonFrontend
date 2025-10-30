import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthStatusRequested>(_onStatusRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegistrationSubmitted>(_onRegistrationSubmitted);
    on<AuthProfileUpdated>(_onProfileUpdated);
  }

  final AuthRepository _authRepository;

  Future<void> _onStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (!isLoggedIn) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    final user = await _authRepository.getStoredUser();
    final token = await _authRepository.getStoredToken() ?? '';
    if (user == null || user.isEmpty) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
        infoMessage: null,
      ),
    );
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
          token: result.token,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        user: UserModel.empty,
        token: '',
      ),
    );
  }

  Future<void> _onRegistrationSubmitted(
    AuthRegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      await _authRepository.register(
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.registrationSuccess,
          infoMessage: 'Registration successful. Please login.',
        ),
      );

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      final updatedUser = await _authRepository.updateProfile(
        userId: event.userId,
        name: event.name,
        mobile: event.mobile,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          infoMessage: 'Profile updated successfully.',
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ),
      );
    }
  }
}
