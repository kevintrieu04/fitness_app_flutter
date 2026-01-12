import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_provider.dart';

class AuthDataSource {
  AuthDataSource(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String uid,
    required double currentWeight,
    required double goalWeight,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'lastDoneDaily': Timestamp.fromDate(DateTime(2017, 9, 7, 17, 30)),
      'level': 'Beginner',
      'tier': 1,
      'streak': 0,
      "startWeight": currentWeight,
      "goalWeight": goalWeight,
      "dailyCalories": 0,
      "bestLevel": "Beginner Tier 1",
    });
  }

  Future<void> signOut() => _auth.signOut();
}

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});
