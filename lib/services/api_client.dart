import 'package:dio/dio.dart';
import 'package:fitness_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late ApiService _apiService;

  ApiClient._internal() {
    final dio = Dio();
    _apiService = ApiService(dio);
  }

  static ApiClient get instance => _instance;

  ApiService get apiService => _apiService;
}

Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});

Provider<ApiService> apiServiceProvider = Provider<ApiService>((ref) {
  return ref.watch(apiClientProvider).apiService;
});
