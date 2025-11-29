import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitness_app/services/api_client.dart';

class EstimatorService {
  Future<dynamic> estimateCalories(File imageFile) async {
    try {
      return await ApiClient.instance.apiService.estimateCalories(imageFile);
    } catch (e) {
      // Handle exceptions
      print(e);
      return null;
    }
  }
}
