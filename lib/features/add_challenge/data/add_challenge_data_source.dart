import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/data/counter_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_provider.dart';

class AddChallengeDataSource {
  AddChallengeDataSource(this._db);

  final FirebaseFirestore _db;

  Future<void> addChallenge(
    String name,
    ExerciseType exerciseType,
    int reps,
    int time,
  ) async {
    final leaderboard = await _db.collection('leaderboards').add({});

    await _db.collection('custom_challenges').add({
      'name': name,
      'exerciseType': exerciseType.name,
      'reps': reps,
      'time': time,
      'leaderboard_id': leaderboard.id,
    });
  }
}

final addChallengeDataSourceProvider = Provider<AddChallengeDataSource>((ref) {
  return AddChallengeDataSource(ref.read(firestoreProvider));
});
