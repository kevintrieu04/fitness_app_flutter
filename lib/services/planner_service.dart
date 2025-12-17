import 'api_client.dart';

class PlannerService {
  Future<dynamic> generateWorkoutPlan(double bmi, String experience, int frequency) async {
    try {
      return await ApiClient.instance.apiService.generateWorkoutPlan(bmi, experience, frequency);
    } catch (e) {
      // Handle exceptions
      print(e);
      return null;
    }
  }
}