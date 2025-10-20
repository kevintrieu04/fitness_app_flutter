import 'package:fitness_app/models/counter_data.dart';

import 'counter.dart';

class SquatCounter extends Counter {
  SquatCounter({required super.userWeight});

  SquatState state = SquatState.up;

  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      return;
    }

    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Existing squat angle calculation logic
    Point3D? a, b, c;
    if ((landmarkLikelihoods['leftHip'] ?? 0) < 0.5 ||
        (landmarkLikelihoods['leftKnee'] ?? 0) < 0.5 ||
        (landmarkLikelihoods['leftAnkle'] ?? 0) < 0.5) {
      a = smoothedLandmarks['rightHip'];
      b = smoothedLandmarks['rightKnee'];
      c = smoothedLandmarks['rightAnkle'];
    } else {
      a = smoothedLandmarks['leftHip'];
      b = smoothedLandmarks['leftKnee'];
      c = smoothedLandmarks['leftAnkle'];
    }
    if (a != null && b != null && c != null) {
      final angle = calculateAngle3D(a, b, c);
      print("Squat Angle: $angle");
      _update(angle);
    }
  }

  void _update(double angle) {
    double minAngle = 30;
    double maxAngle = 100;

    if (state == SquatState.up && angle < minAngle) {
      state = SquatState.down;
    } else if (state == SquatState.down && angle > maxAngle) {
      state = SquatState.up;
      count++;
      caloriesBurnt += caloriesPerRep;
    }
  }
}