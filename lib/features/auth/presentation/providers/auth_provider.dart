import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/data/mock_data_service.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import 'firebase_providers.dart';

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth notifier — real Firebase Auth (replaces mock)
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthRepository _repository;
  final MockDataService _mockData;

  AuthNotifier(this._repository, this._mockData) : super(const AuthState());

  /// Real Firebase login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.login(email: email, password: password);

      // Build UserEntity from Firebase user
      final fbUser = _repository.currentUser;
      if (fbUser != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: UserEntity(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'User',
            email: fbUser.email ?? email,
            avatar: fbUser.photoURL,
            joinDate: fbUser.metadata.creationTime,
          ),
        );
        _mockData.setCurrentUser(state.user!);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _repository.mapError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Real Firebase signup
  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      // Build UserEntity from Firebase user
      final fbUser = _repository.currentUser;
      if (fbUser != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: UserEntity(
            id: fbUser.uid,
            name: name,
            email: email,
            avatar: fbUser.photoURL,
            joinDate: fbUser.metadata.creationTime,
          ),
        );
        _mockData.setCurrentUser(state.user!);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _repository.mapError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _repository.mapError(e));
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to send reset email');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  /// Update display name (Auth + Firestore)
  Future<bool> updateName(String name) async {
    try {
      await _repository.updateName(name);
      // Update local state
      if (state.user != null) {
        state = state.copyWith(
          user: UserEntity(
            id: state.user!.id,
            name: name,
            email: state.user!.email,
            avatar: state.user!.avatar,
            joinDate: state.user!.joinDate,
          ),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update name');
      return false;
    }
  }

  /// Check if user is logged in (now real — reads Firebase current user)
  void checkAuthStatus() {
    final fbUser = _repository.currentUser;
    if (fbUser != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: UserEntity(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
          avatar: fbUser.photoURL,
          joinDate: fbUser.metadata.creationTime,
        ),
      );
    } else {
      state = const AuthState(isAuthenticated: false);
    }
  }
}

/// Auth provider — uses real Firebase
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(firebaseAuthRepositoryProvider);
  return AuthNotifier(repository, MockDataService());
});

/// Current user provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});
