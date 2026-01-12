import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/counter_data_source.dart';

abstract class CounterDataRepository {
  Future<double> getUserWeight();
}

class CounterDataRepositoryImpl implements CounterDataRepository {
  CounterDataRepositoryImpl(this._dataSource);

  final CounterDataSource _dataSource;

  @override
  Future<double> getUserWeight() {
    return _dataSource.getUserWeight();
  }
}

final counterDataRepositoryProvider = Provider<CounterDataRepository>((ref) {
  return CounterDataRepositoryImpl(ref.read(counterDataSourceProvider));
});
