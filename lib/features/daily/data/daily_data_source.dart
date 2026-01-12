import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/firebase/firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyDataSource {
  DailyDataSource(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  DocumentSnapshot<Map<String, dynamic>>? user;

  Future<void> getUserData() async {
    user = await _db.collection('users').doc(_auth.currentUser!.uid).get();
  }

  Future<double> getUserWeight() async {
    if (user != null) {
      return user!.data()!['startWeight'].toDouble();
    } else {
      return 0.0;
    }
  }

  Future<String> getUserLevel() async {
    if (user != null) {
      return user!.data()!['level'];
    } else {
      return "Beginner";
    }
  }

  Future<int> getUserTier() async {
    if (user != null) {
      return user!.data()!['tier'];
    } else {
      return 1;
    }
  }

  Future<void> updateDailyCalories(double calories) async {
    if (user != null) {
      await _db.collection('users').doc(_auth.currentUser!.uid).update({
        'dailyCalories': calories,
      });
    }
  }

  String _changeLevel(String level) {
    switch (level) {
      case 'Beginner':
        return 'Intermediate';
      case 'Intermediate':
        return 'Advanced';
      default:
        return level;
    }
  }

  Future<void> updateLevelAndTier(String level, int tier) async {
    tier += 1;
    if (tier > 5) {
      tier = 1;
      level = _changeLevel(level);
    }
    if (user != null) {
      await _db.collection('users').doc(_auth.currentUser!.uid).update({
        'level': level,
        'tier': tier,
      });
    }
  }

  Future<void> updateLastDoneDaily() async {
    if (user != null) {
      await _db.collection('users').doc(_auth.currentUser!.uid).update({
        'lastDoneDaily': DateTime.now(),
      });
    }
  }
}

final dailyDataSourceProvider = Provider<DailyDataSource>((ref) {
  return DailyDataSource(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});
