import 'package:cloud_firestore/cloud_firestore.dart';

class DbFirebaseDataSource {
  DbFirebaseDataSource(this._db);

  final FirebaseFirestore _db;


  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String password,
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
    });
  }

  Future<Map<String, dynamic>> getUser({required String uid}) async {
    final user = await _db.collection('users').doc(uid).get();
    if (user.exists) {
      return user.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Future<void> updateLevelTierAndStreak({
    required String uid,
    required String level,
    required int tier,
    required int streak,
  }) async {
    await _db.collection('users').doc(uid).update({
      'level': level,
      'tier': tier,
      'streak': streak,
    });
  }
}
