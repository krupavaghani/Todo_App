part of 'auth_bloc.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? userName;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.userId,
    this.email,
    this.userName,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, userId, email, userName, errorMessage];
}
