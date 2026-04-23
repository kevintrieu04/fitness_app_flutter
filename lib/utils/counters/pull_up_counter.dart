import 'dart:math';

import 'package:fitness_app/utils/abstract_classes/counter.dart';
import 'dart:async';

import '../../core/data/counter_data.dart';

class PullUpCounter extends Counter {
  PullUpCounter({required super.userWeight}) {
    state = CounterState.down;
  }

  Timer? _inactivityTimer;
  ViewType? _targetViewType;
  bool isUp = true;

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
      _inactivityTimer?.cancel();
      _inactivityTimer = null;
      _targetViewType = null;
      isUsing3D = false;
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
      if (currentDetectedView != viewType) {
        isUsing3D = true;
        _targetViewType = currentDetectedView;
        _inactivityTimer?.cancel();
        _inactivityTimer = Timer.periodic(const Duration(milliseconds: 500), (
          timer,
        ) {
          if (this.viewType == _targetViewType) {
            isUsing3D = false;
            timer.cancel();
            _inactivityTimer = null;
            _targetViewType = null;
          }
        });
      } else {
        if (isUsing3D) {
          isUsing3D = false;
        }
        _inactivityTimer?.cancel();
        _inactivityTimer = null;
        _targetViewType = null;
      }
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
      final angle = isUsing3D
          ? calculateAngle3D(a, b, c)
          : calculateAngle2D(a, b, c);
      print("Angle: $angle");
      _update(angle, landmarkLikelihoods);
    }
    print("State: $state");
  }

  void _update(double angle, Map<dynamic, dynamic> likelihood) {
    double minAngle = 65;
    double maxAngle = 130;

    if (viewType == ViewType.side) {
      minAngle = 85;
      maxAngle = 160;
    }

    if (isUsing3D) {
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
    }

    if (state == CounterState.up && angle > maxAngle) {
      state = CounterState.down;
      totalCount++;
      isUp = true;
      if (!errors.containsKey(totalCount)) {
        correctReps++;
        caloriesBurnt += caloriesPerRep;
      }
    } else if (state == CounterState.down && angle < minAngle) {
      isUp = _checkUpPosition(smoothedLandmarks, likelihood);
      if (!isUp) {
        errors.addAll({totalCount + 1: "Not in correct position"});
      }
      state = CounterState.up;
    }
  }
}
