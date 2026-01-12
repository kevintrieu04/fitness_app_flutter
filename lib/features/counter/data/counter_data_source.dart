import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_provider.dart';

class CounterDataSource {
  CounterDataSource(this._auth, this._db);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<double> getUserWeight() async {
    final user = await _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    return user.data()!['startWeight'].toDouble();
  }
}

final counterDataSourceProvider = Provider<CounterDataSource>((ref) {
  return CounterDataSource(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});
