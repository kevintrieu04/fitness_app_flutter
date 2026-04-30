import '../../core/data/counter_data.dart';
import '../abstract_classes/counter.dart';
import 'dart:async';

class SquatCounter extends Counter {
  SquatCounter({required super.userWeight});

  bool areHipsCorrect = true;
  Timer? _inactivityTimer;
  ViewType? _targetViewType;

  bool _checkHipsAngle(
    Map<dynamic, Point3D> smoothedLandmarks,
    Map<dynamic, dynamic> likelihood,
  ) {
    final leftShoulder = smoothedLandmarks['leftShoulder'];
    final rightShoulder = smoothedLandmarks['rightShoulder'];
    final leftHip = smoothedLandmarks['leftHip'];
    final rightHip = smoothedLandmarks['rightHip'];
    final leftKnee = smoothedLandmarks['leftKnee'];
    final rightKnee = smoothedLandmarks['rightKnee'];

    bool isLeft =
        (likelihood['leftShoulder'] ?? 0) > (likelihood['rightShoulder'] ?? 0);
    bool isRight =
        (likelihood['leftShoulder'] ?? 0) < (likelihood['rightShoulder'] ?? 0);

    if (leftKnee != null &&
        rightKnee != null &&
        leftHip != null &&
        rightHip != null &&
        leftShoulder != null &&
        rightShoulder != null) {
      if (viewType == ViewType.side) {
        if (isLeft) {
          return isUsing3D
              ? calculateAngle3D(leftShoulder, leftHip, leftKnee) < 130
              : calculateAngle2D(leftShoulder, leftHip, leftKnee) < 130;
        } else if (isRight) {
          return isUsing3D
              ? calculateAngle3D(rightShoulder, rightHip, rightKnee) < 130
              : calculateAngle2D(rightShoulder, rightHip, rightKnee) < 130;
        }
      } else {
        return isUsing3D
            ? calculateAngle3D(rightShoulder, rightHip, rightKnee) < 130
            : calculateAngle2D(rightShoulder, rightHip, rightKnee) < 130;
      }
    }
    return false;
  }

  @override
  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      _inactivityTimer?.cancel();
      _inactivityTimer = null;
      _targetViewType = null;
      isUsing3D = false; // Also reset isUsing3D
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
    print(currentDetectedView);
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
      final angle = isUsing3D
          ? calculateAngle3D(a, b, c)
          : calculateAngle2D(a, b, c);
      print("Squat Angle: $angle");
      _update(angle, landmarkLikelihoods);
    }
  }

  void _update(double angle, Map<dynamic, dynamic> landmarkLikelihoods) {
    double minAngle = 110;
    double maxAngle = 165;

    if (isUsing3D) {
      if (viewType == ViewType.front) {
        minAngle = 30;
        maxAngle = 100;
      } else if (viewType == ViewType.side) {
        minAngle = 114;
        maxAngle = 150;
      } else if (viewType == ViewType.back) {
        minAngle = 135;
        maxAngle = 155;
      }
    }

    if (state == CounterState.up && angle < minAngle) {
      //print("Squat Down");
      state = CounterState.down;

      if (!isUsing3D) {
        areHipsCorrect = _checkHipsAngle(
          smoothedLandmarks,
          landmarkLikelihoods,
        );
      }

      if (!areHipsCorrect) {
        errors.addAll({totalCount + 1: "Not in correct knee position"});
      }
    } else if (state == CounterState.down && angle > maxAngle) {
      //print("Squat Up");
      state = CounterState.up;
      totalCount++;
      areHipsCorrect = true;
      if (!errors.containsKey(totalCount)) {
        correctReps++;
        caloriesBurnt += caloriesPerRep;
      }
    }
  }
}
