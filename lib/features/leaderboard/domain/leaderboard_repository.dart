import 'package:fitness_app/features/leaderboard/data/leaderboard_data_source.dart';
import 'package:fitness_app/features/leaderboard/data/user_leaderboard_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class LeaderboardRepository {
  Stream<List<ChallengeInfo>> getChallenges();
  Stream<List<UserLeaderboardInfo>> getLeaderboardInfo(String id);
  Stream<double> getUserWeight();
  Future<void> addScore(String challengeId, int score);
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl(this._dataSource);

  final LeaderboardDataSource _dataSource;

  @override
  Stream<List<ChallengeInfo>> getChallenges() {
    return _dataSource.getChallenges();
  }

  @override
  Stream<List<UserLeaderboardInfo>> getLeaderboardInfo(String id) {
    return _dataSource.getLeaderboardInfo(id);
  }

  @override
  Stream<double> getUserWeight() {
    return _dataSource.getUserWeight();
  }

  @override
  Future<void> addScore(String challengeId, int score) {
    return _dataSource.addScore(challengeId, score);
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dataSource = ref.read(leaderboardDataSourceProvider);
  return LeaderboardRepositoryImpl(dataSource);
});

final challengesProvider = StreamProvider<List<ChallengeInfo>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getChallenges();
});

final leaderboardInfoProvider =
    StreamProvider.family<List<UserLeaderboardInfo>, String>((ref, id) {
  return ref.watch(leaderboardRepositoryProvider).getLeaderboardInfo(id);
});

final userWeightProvider = StreamProvider<double>((ref) {
  return ref.watch(leaderboardRepositoryProvider).getUserWeight();
});
