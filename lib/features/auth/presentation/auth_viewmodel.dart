import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_repository.dart';

// Ensure you have your AuthState and Repository imports here
part 'auth_viewmodel.g.dart';

part 'auth_viewmodel.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauth;

  const factory AuthState.authenticated(User user) = _Auth;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.error(String message) = _Error;
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Stream<AuthState> build() {
    final repo = ref.watch(authRepositoryProvider);

    return repo.authStateChanges().map((user) {
      return user == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password, String name, double currentWeight, double goalWeight) async {
    state = const AsyncValue.data(AuthState.loading());

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(email, password, name, currentWeight, goalWeight);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
