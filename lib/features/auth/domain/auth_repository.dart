import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

import '../data/auth_firebase_data_source.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  Future<void> signIn(String email, String password);

  Future<void> signUp(String email, String password, String name, double currentWeight, double goalWeight);

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String password,
    required double currentWeight,
    required double goalWeight,
  });

  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Stream<User?> authStateChanges() => _dataSource.authStateChanges();

  @override
  Future<void> signIn(String email, String password) async {
    await _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password, String name, double currentWeight, double goalWeight) async {
    final uid = await _dataSource.signUp(email: email, password: password).then((value) => value.user!.uid);
    await _dataSource.createUser(uid: uid, name: name, email: email, password: password, currentWeight: currentWeight, goalWeight: goalWeight);
  }

  @override
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String password,
    required double currentWeight,
    required double goalWeight,
  }) async {
    await _dataSource.createUser(
      uid: uid,
      name: name,
      email: email,
      password: password,
      currentWeight: currentWeight,
      goalWeight: goalWeight,
    );
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}



final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDataSourceProvider));
});
