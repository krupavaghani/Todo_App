import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  AuthBloc() : super(_getInitialState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  static AuthState _getInitialState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthState(
        status: AuthStatus.authenticated,
        userId: user.uid,
        email: user.email,
        userName: user.displayName,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;
        String? uName = credential.user!.displayName;
        if (uName == null || uName.isEmpty) {
          final userModel = await _userService.getUser(uid);
          uName = userModel?.displayName;
        }
        emit(
          AuthState(
            status: AuthStatus.authenticated,
            userId: uid,
            email: credential.user!.email,
            userName: uName,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: e.message ?? 'Login failed',
        ),
      );
    } catch (e) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        final user = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          displayName: event.userName,
          createdAt: DateTime.now(),
        );

        try {
          await _userService.saveUser(user);
        } catch (e) {
          print('Failed to save user to Firestore: $e');
        }

        emit(
          AuthState(
            status: AuthStatus.authenticated,
            userId: credential.user!.uid,
            email: credential.user!.email,
            userName: event.userName,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(
        AuthState(
          status: AuthStatus.error,
          errorMessage: e.message ?? 'Sign up failed',
        ),
      );
    } catch (e) {
      emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
