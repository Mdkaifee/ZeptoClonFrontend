import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRegistrationSubmitted extends AuthEvent {
  const AuthRegistrationSubmitted({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
  });

  final String name;
  final String email;
  final String mobile;
  final String password;

  @override
  List<Object?> get props => [name, email, mobile, password];
}

class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated({
    required this.userId,
    required this.name,
    required this.mobile,
  });

  final String userId;
  final String name;
  final String mobile;

  @override
  List<Object?> get props => [userId, name, mobile];
}
