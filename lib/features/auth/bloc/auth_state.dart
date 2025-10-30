import 'package:equatable/equatable.dart';

import '../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user = UserModel.empty,
    this.token = '',
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final UserModel user;
  final String token;
  final String? errorMessage;
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, token, errorMessage, infoMessage];
}
