class UserLeaderboardInfo {
  const UserLeaderboardInfo(this.name, this.level, this.counts);

  final String name;
  final String level;
  final int counts;
}

class ChallengeInfo {
  const ChallengeInfo(this.id, this.name, this.exerciseType, this.reps, this.time);

  final String id;
  final String name;
  final String exerciseType;
  final int reps;
  final int time;
}
