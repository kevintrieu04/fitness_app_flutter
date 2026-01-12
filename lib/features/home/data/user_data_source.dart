import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_provider.dart';

class UserDataSource {
  UserDataSource(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Stream<dynamic> getUserInfo() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Stream<bool> checkUserDaily() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null || data['lastDoneDaily'] == null) {
        return true; // Daily task is available if no record
      }
      final lastDone = (data['lastDoneDaily'] as Timestamp).toDate();
      final now = DateTime.now();

      // Check if the last completion was on a different day
      final lastDoneDate = DateTime(lastDone.year, lastDone.month, lastDone.day);
      final todayDate = DateTime(now.year, now.month, now.day);

      return todayDate.isAfter(lastDoneDate);
    });
  }
}

final userDataSourceProvider = Provider<UserDataSource>((ref) {
  return UserDataSource(ref.read(firestoreProvider), ref.read(firebaseAuthProvider));
});
