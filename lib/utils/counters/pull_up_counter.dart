import 'dart:math';

import 'package:fitness_app/utils/counters/counter.dart';

import '../../data/counter_data.dart';

class PullUpCounter extends Counter {
  PullUpCounter({required super.userWeight}) {
    state = CounterState.down;
  }

  bool _checkUpPosition(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
  ) {
    final nose = landmarkPoints['nose'];
    if (nose == null) return false;

    final rightWrist = landmarkPoints['rightWrist'];
    final leftWrist = landmarkPoints['leftWrist'];

    Point3D? wristToCompare;

    bool rightWristVisible = (likelihood['rightWrist'] ?? 0.0) > 0.5;
    bool leftWristVisible = (likelihood['leftWrist'] ?? 0.0) > 0.5;

    if (rightWristVisible && leftWristVisible) {
      wristToCompare = rightWrist!.y < leftWrist!.y ? leftWrist : rightWrist;
    } else if (rightWristVisible) {
      wristToCompare = rightWrist;
    } else if (leftWristVisible) {
      wristToCompare = leftWrist;
    }

    if (wristToCompare != null) {
      return nose.y < wristToCompare.y;
    }
    return false;
  }

  @override
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

    Point3D? a, b, c;
    if ((landmarkLikelihoods['leftShoulder'] ?? 0) <
            (landmarkLikelihoods['rightShoulder'] ?? 0) ||
        (landmarkLikelihoods['leftElbow'] ?? 0) <
            (landmarkLikelihoods['rightElbow'] ?? 0) ||
        (landmarkLikelihoods['leftWrist'] ?? 0) <
            (landmarkLikelihoods['rightWrist'] ?? 0)) {
      a = smoothedLandmarks['rightShoulder'];
      b = smoothedLandmarks['rightElbow'];
      c = smoothedLandmarks['rightWrist'];
    } else {
      a = smoothedLandmarks['leftShoulder'];
      b = smoothedLandmarks['leftElbow'];
      c = smoothedLandmarks['leftWrist'];
    }
    if (a != null && b != null && c != null) {
      final angle = calculateAngle3D(a, b, c);
      print("Angle: $angle");
      _update(angle, landmarkLikelihoods);
    }
    print("State: $state");
  }

  void _update(double angle, Map<dynamic, dynamic> likelihood) {
    double minAngle = 0;
    double maxAngle = 0;

    if (viewType == ViewType.side) {
      minAngle = 70;
      maxAngle = 125;
    } else if (viewType == ViewType.front) {
      minAngle = 135;
      maxAngle = 165;
    } else if (viewType == ViewType.back) {
      minAngle = 125;
      maxAngle = 155;
    }

    if (state == CounterState.up && angle > maxAngle) {
      state = CounterState.down;
      count++;
      caloriesBurnt += caloriesPerRep;
    } else if (state == CounterState.down &&
        angle < minAngle &&
        _checkUpPosition(smoothedLandmarks, likelihood)) {
      state = CounterState.up;
    }
  }
}
