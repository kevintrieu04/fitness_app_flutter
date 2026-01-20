import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/core/firebase/firebase_provider.dart';
import 'package:fitness_app/features/leaderboard/data/user_leaderboard_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardDataSource {
  LeaderboardDataSource(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Stream<List<ChallengeInfo>> getChallenges() {
    return _db
        .collection('custom_challenges')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return ChallengeInfo(
              data['leaderboard_id'] as String,
              data['name'] as String,
              data['exerciseType'] as String,
              data['reps'] as int,
              data['time'] as int,
            );
          }).toList(),
        );
  }

  Stream<List<UserLeaderboardInfo>> getLeaderboardInfo(String id) async* {
    await for (final snapshot
        in _db.collection('leaderboards').doc(id).snapshots()) {
      final data = snapshot.data();
      if (data == null) {
        yield [];
        continue;
      }
      final userFutures = data.entries.map((entry) async {
        final userSnapshot = await _db.collection('users').doc(entry.key).get();
        final userData = userSnapshot.data();
        if (userData != null) {
          return UserLeaderboardInfo(
            userData['name'] as String? ?? 'Unknown User',
            userData['level'] as String? ?? 'Beginner',
            entry.value as int,
          );
        }
        return null;
      });

      final userInfos = await Future.wait(userFutures);
      final leaderboardInfo = userInfos
          .whereType<UserLeaderboardInfo>()
          .toList();
      leaderboardInfo.sort((a, b) => b.counts.compareTo(a.counts));
      yield leaderboardInfo;
    }
  }

  Stream<double> getUserWeight() async* {
    await for (final snapshot
        in _db.collection('users').doc(_auth.currentUser!.uid).snapshots()) {
      final userData = snapshot.data();
      if (userData != null && userData['startWeight'] != null) {
        yield (userData['startWeight'] as num).toDouble();
      } else {
        yield 0.0;
      }
    }
  }
  
  Future<void> addScore(String challengeId, int score) async {
    final userId = _auth.currentUser!.uid;
    await _db.collection('leaderboards').doc(challengeId).set({
      userId: score,
    }, SetOptions(merge: true));
  }
}

final leaderboardDataSourceProvider = Provider<LeaderboardDataSource>((ref) {
  return LeaderboardDataSource(ref.read(firestoreProvider), ref.read(firebaseAuthProvider));
});
