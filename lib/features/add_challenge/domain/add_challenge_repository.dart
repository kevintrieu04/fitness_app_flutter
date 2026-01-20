import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/counter_data.dart';
import '../data/add_challenge_data_source.dart';

abstract class AddChallengeRepository {
  Future<void> addChallenge(
    String name,
    ExerciseType exerciseType,
    int reps,
    int time,
  );
}

class AddChallengeRepositoryImpl implements AddChallengeRepository {
  AddChallengeRepositoryImpl(this._dataSource);

  final AddChallengeDataSource _dataSource;

  @override
  Future<void> addChallenge(
    String name,
    ExerciseType exerciseType,
    int reps,
    int time,
  ) {
    return _dataSource.addChallenge(name, exerciseType, reps, time);
  }
}

final addChallengeRepositoryProvider = Provider<AddChallengeRepository>((ref) {
  return AddChallengeRepositoryImpl(ref.read(addChallengeDataSourceProvider));
});

