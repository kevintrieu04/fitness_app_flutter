import '../../core/data/counter_data.dart';
import 'detector.dart';

abstract class Evaluator extends Detector {
  int mistakeCount = 0;
  ViewType viewType = ViewType.undetermined;

  String giveRating() {
    if (mistakeCount == 0) {
      return "Excellent";
    } else if (mistakeCount <= 2) {
      return "Good";
    } else {
      return "Poor";
    }
  }

  void evaluateFromLandmarks(
    List<Map<String, dynamic>> landmarks,
    void Function(List<String>) updateUI,
    int timestamp,
  );
}
