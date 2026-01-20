import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/daily_data_source.dart';

abstract class DailyRepository {
  Future<double> getUserWeight();

  Future<void> updateDailyCalories(double calories);

  Future<String> getUserLevel();

  Future<int> getUserTier();

  Future<void> updateLevelAndTier(String level, int tier, String bestLevel, int bestTier);

  Future<void> updateLastDoneDaily();
}

class DailyRepositoryImpl implements DailyRepository {
  DailyRepositoryImpl(this._dataSource);

  final DailyDataSource _dataSource;

  @override
  Future<double> getUserWeight() async {
    if (_dataSource.user == null) await _dataSource.getUserData();
    return _dataSource.getUserWeight();
  }

  @override
  Future<void> updateDailyCalories(double calories) async {
    if (_dataSource.user == null) await _dataSource.getUserData();
    return _dataSource.updateDailyCalories(calories);
  }

  @override
  Future<String> getUserLevel() async {
    if (_dataSource.user == null) await _dataSource.getUserData();
    return _dataSource.getUserLevel();
  }

  @override
  Future<int> getUserTier() async {
    if (_dataSource.user == null) await _dataSource.getUserData();
    return _dataSource.getUserTier();
  }

  @override
  Future<void> updateLevelAndTier(String level, int tier, String bestLevel, int bestTier) {
    return _dataSource.updateLevelAndTier(level, tier, bestLevel, bestTier);
  }

  @override
  Future<void> updateLastDoneDaily() {
    return _dataSource.updateLastDoneDaily();
  }
}

final dailyRepositoryProvider = Provider<DailyRepository>((ref) {
  return DailyRepositoryImpl(ref.read(dailyDataSourceProvider));
});
