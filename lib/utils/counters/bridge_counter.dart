import '../../core/data/counter_data.dart';
import '../abstract_classes/counter.dart';
import 'dart:async';

class BridgeCounter extends Counter {
  BridgeCounter({required super.userWeight}) {
    state = CounterState.down;
  }

  bool isBackStraight = true;
  Timer? _inactivityTimer;
  ViewType? _targetViewType;

  void _update(double angle) {
    double minAngle = 90;
    double maxAngle = 160;

    if (isUsing3D) {
      double minAngle = 125;
      double maxAngle = 150;
    }

    if (state == CounterState.up && angle < minAngle) {
      state = CounterState.down;
      totalCount++;
      caloriesBurnt += caloriesPerRep;
    } else if (state == CounterState.down &&
        angle > maxAngle &&
        isBackStraight) {
      state = CounterState.up;
    }
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
        _inactivityTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
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
      final angle = isUsing3D? calculateAngle3D(a, b, c) : calculateAngle2D(a, b, c);
      print("angle: $angle");
      _update(angle);
    }
  }
}
