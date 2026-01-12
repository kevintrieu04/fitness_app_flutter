import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/estimator_data_source.dart';

abstract class EstimatorRepository {
  Future<dynamic> estimateCalories(File image);
}

class EstimatorRepositoryImpl implements EstimatorRepository {
  EstimatorRepositoryImpl(this._dataSource);

  final EstimatorDataSource _dataSource;

  @override
  Future<dynamic> estimateCalories(File image) {
    return _dataSource.estimateCalories(image);
  }
}

final estimatorRepositoryProvider = Provider<EstimatorRepository>((ref) {
  return EstimatorRepositoryImpl(ref.read(estimatorDataSourceProvider));
});
