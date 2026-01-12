class DailyData {
  const DailyData({
    required this.level,
    required this.tier,
    required this.reps,
    required this.time,
  });

  final String level;
  final int tier;
  final int reps;
  final int time;
}

List<DailyData> beginnerData = [
  DailyData(level: 'Beginner', tier: 1, reps: 2, time: 10),
  DailyData(level: 'Beginner', tier: 2, reps: 5, time: 60),
  DailyData(level: 'Beginner', tier: 3, reps: 6, time: 90),
  DailyData(level: 'Beginner', tier: 4, reps: 7, time: 120),
  DailyData(level: 'Beginner', tier: 5, reps: 8, time: 150),
];

List<DailyData> intermediateData = [
  DailyData(level: 'Intermediate', tier: 1, reps: 2, time: 35),
  DailyData(level: 'Intermediate', tier: 2, reps: 5, time: 60),
  DailyData(level: 'Intermediate', tier: 3, reps: 6, time: 90),
  DailyData(level: 'Intermediate', tier: 4, reps: 7, time: 120),
  DailyData(level: 'Intermediate', tier: 5, reps: 8, time: 150),
];

List<DailyData> advancedData = [
  DailyData(level: 'Advanced', tier: 1, reps: 2, time: 35),
  DailyData(level: 'Advanced', tier: 2, reps: 5, time: 60),
  DailyData(level: 'Advanced', tier: 3, reps: 6, time: 90),
  DailyData(level: 'Advanced', tier: 4, reps: 7, time: 120),
  DailyData(level: 'Advanced', tier: 5, reps: 8, time: 150),
];
