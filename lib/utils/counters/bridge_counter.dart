import '../../models/counter_data.dart';
import 'counter.dart';

class BridgeCounter extends Counter {
  BridgeCounter({required super.userWeight}) {
    state = CounterState.down;
  }

  bool isBackStraight = true;


  void _update(double angle) {
    double minAngle = 125;
    double maxAngle = 150;
    if (state == CounterState.up && angle < minAngle) {
      state = CounterState.down;
      count++;
      caloriesBurnt += caloriesPerRep;
    } else if (state == CounterState.down &&
        angle > maxAngle &&
        isBackStraight) {
      state = CounterState.up;
    }
  }


  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear();
      return;
    }

    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    final currentDetectedView = determineViewType(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (currentDetectedView != ViewType.undetermined) {
      viewType = currentDetectedView;
    }

    isBackStraight = checkBackStraightness(
      smoothedLandmarks,
      landmarkLikelihoods,
    );


    Point3D? a, b, c;
    if ((landmarkLikelihoods['leftShoulder'] ?? 0) <
            (landmarkLikelihoods['rightShoulder'] ?? 0) ||
        (landmarkLikelihoods['leftHip'] ?? 0) <
            (landmarkLikelihoods['rightHip'] ?? 0) ||
        (landmarkLikelihoods['leftKnee'] ?? 0) <
            (landmarkLikelihoods['rightKnee'] ?? 0)) {
      a = smoothedLandmarks['rightShoulder'];
      b = smoothedLandmarks['rightHip'];
      c = smoothedLandmarks['rightKnee'];
    } else {
      a = smoothedLandmarks['leftShoulder'];
      b = smoothedLandmarks['leftHip'];
      c = smoothedLandmarks['leftKnee'];
    }
    if (a != null && b != null && c != null) {
      final angle = calculateAngle3D(a, b, c);
      print("angle: $angle");
      _update(angle);
    }
  }
}
