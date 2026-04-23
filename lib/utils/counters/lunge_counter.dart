import 'package:fitness_app/utils/abstract_classes/counter.dart';
import 'dart:async';

import '../../core/data/counter_data.dart';

class LungeCounter extends Counter {
  LungeCounter({required super.userWeight});

  bool verify = true;
  LungeLastStep _step = LungeLastStep.left;
  Timer? _inactivityTimer;
  ViewType? _targetViewType;

  bool _verifyStep(
    Map<dynamic, Point3D> smoothedLandmarks,
    Map<dynamic, dynamic> likelihood,
  ) {
    bool isLeft =
        smoothedLandmarks['leftShoulder']!.z < smoothedLandmarks['rightShoulder']!.z;
    bool isRight =
        smoothedLandmarks['leftShoulder']!.z > smoothedLandmarks['rightShoulder']!.z;

    if (viewType == ViewType.side) {
      //print("Left x: ${smoothedLandmarks['leftFootIndex']!.x}");
      //print("Right x: ${smoothedLandmarks['rightFootIndex']!.x}");
      if (isLeft) {
        if (_step == LungeLastStep.right &&
            smoothedLandmarks['leftFootIndex']!.x <
                smoothedLandmarks['rightFootIndex']!.x) {
          return true;
        } else if (_step == LungeLastStep.left &&
            smoothedLandmarks['leftFootIndex']!.x >
                smoothedLandmarks['rightFootIndex']!.x) {
          return true;
        }
      }
      if (isRight) {
        if (_step == LungeLastStep.right &&
            smoothedLandmarks['leftFootIndex']!.x >
                smoothedLandmarks['rightFootIndex']!.x) {
          return true;
        } else if (_step == LungeLastStep.left &&
            smoothedLandmarks['leftFootIndex']!.x <
                smoothedLandmarks['rightFootIndex']!.x) {
          return true;
        }
      }
    } else if (viewType == ViewType.front) {
      //print("Left z: ${smoothedLandmarks['leftFootIndex']!.z}");
      //print("Right z: ${smoothedLandmarks['rightFootIndex']!.z}");
      if (_step == LungeLastStep.right &&
          smoothedLandmarks['leftFootIndex']!.z <
              smoothedLandmarks['rightFootIndex']!.z) {
        return true;
      } else if (_step == LungeLastStep.left &&
          smoothedLandmarks['leftFootIndex']!.z >
              smoothedLandmarks['rightFootIndex']!.z) {
        return true;
      }
    } else if (viewType == ViewType.back) {
      if (_step == LungeLastStep.right &&
          smoothedLandmarks['leftFootIndex']!.z >
              smoothedLandmarks['rightFootIndex']!.z) {
        return true;
      } else if (_step == LungeLastStep.left &&
          smoothedLandmarks['leftFootIndex']!.z <
              smoothedLandmarks['rightFootIndex']!.z) {
        return true;
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
      final leftAngle = isUsing3D
          ? calculateAngle3D(leftHip, leftKnee, leftAnkle)
          : calculateAngle2D(leftHip, leftKnee, leftAnkle);
      final rightAngle = isUsing3D
          ? calculateAngle3D(rightHip, rightKnee, rightAnkle)
          : calculateAngle2D(rightHip, rightKnee, rightAnkle);
      //print("Lunge Left Angle: $leftAngle");
      //print("Lunge Right Angle: $rightAngle");
      _update(leftAngle, rightAngle, landmarkLikelihoods);
    }
  }

  void _update(double leftAngle, rightAngle, Map<dynamic, dynamic> likelihood) {
    double minAngle = 90;
    double maxAngle = 160;

    if (isUsing3D) {
      if (viewType == ViewType.side) {
        minAngle = 120;
        maxAngle = 165;
      } else if (viewType == ViewType.front) {
        minAngle = 80;
        maxAngle = 115;
      } else if (viewType == ViewType.back) {
        minAngle = 85;
        maxAngle = 115;
      }
    }

    //print("verify: $verify");
    //print("_step: $_step");
    if (state == CounterState.up &&
        (leftAngle < minAngle || rightAngle < minAngle)) {
      state = CounterState.down;
      verify = _verifyStep(smoothedLandmarks, likelihood);
      if (!verify) {
        errors.addAll({totalCount + 1: "Not in correct step"});
        return;
      }
      if (_step == LungeLastStep.left) {
        _step = LungeLastStep.right;
      } else if (_step == LungeLastStep.right) {
        _step = LungeLastStep.left;
      }
    } else if (state == CounterState.down &&
        (leftAngle > maxAngle && rightAngle > maxAngle)) {
      state = CounterState.up;
      totalCount++;
      if (!errors.containsKey(totalCount)) {
        correctReps++;
        print("correctReps: $correctReps");
        caloriesBurnt += caloriesPerRep;
      }
    }
    print("state: $state");
  }
}
