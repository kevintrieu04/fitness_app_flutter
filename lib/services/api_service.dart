import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://10.0.2.2:5000/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/generate")
  @MultiPart()
  Future<dynamic> generateWorkoutPlan(
    @Part(name: "bmi") double bmi,
    @Part(name: "experience") String experience,
    @Part(name: "weekly_frequency") int frequency,
  );

  @POST("/predict")
  @MultiPart()
  Future<dynamic> estimateCalories(@Part(name: "image") File image);
}
