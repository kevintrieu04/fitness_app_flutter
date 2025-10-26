import 'package:fitness_app/models/counter_data.dart';
import 'package:fitness_app/utils/counters/counter.dart';

class LungeCounter extends Counter {
  LungeCounter({required super.userWeight});

  CounterState _state = CounterState.up;
  LungeLastStep _lastStep = LungeLastStep.left;

  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      return;
    }

    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Existing lunge angle calculation logic
    Point3D? rightHip = smoothedLandmarks['rightHip'];
    Point3D? rightKnee = smoothedLandmarks['rightKnee'];
    Point3D? rightAnkle = smoothedLandmarks['rightAnkle'];
    Point3D? leftHip = smoothedLandmarks['leftHip'];
    Point3D? leftKnee = smoothedLandmarks['leftKnee'];
    Point3D? leftAnkle = smoothedLandmarks['leftAnkle'];

    if (rightHip != null &&
        rightKnee != null &&
        rightAnkle != null &&
        leftHip != null &&
        leftKnee != null &&
        leftAnkle != null) {
      final leftAngle = calculateAngle3D(leftHip, leftKnee, leftAnkle);
      final rightAngle = calculateAngle3D(rightHip, rightKnee, rightAnkle);
      print("Lunge Left Angle: $leftAngle");
      print("Lunge Right Angle: $rightAngle");
      //_update(leftAngle, rightAngle);
    }

  }

  /*void _update(double leftAngle, rightAngle) {
    double minAngle = 100;
    double maxAngle = 160;

    if (state == SquatState.up && angle < minAngle) {
      state = SquatState.down;
    } else if (state == SquatState.down && angle > maxAngle) {
      state = SquatState.up;
      count++;
      caloriesBurnt += caloriesPerRep;
    }
  }*/
}
