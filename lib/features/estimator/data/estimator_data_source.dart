import 'dart:io';

import 'package:fitness_app/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EstimatorDataSource {
  EstimatorDataSource(this._client);

  late final ApiClient _client;

  Future<dynamic> estimateCalories(File image) {
    return _client.apiService.estimateCalories(image);
  }
}

final estimatorDataSourceProvider = Provider<EstimatorDataSource>((ref) {
  return EstimatorDataSource(ref.read(apiClientProvider));
});