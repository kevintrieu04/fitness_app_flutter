import 'package:fitness_app/data/counter_data.dart';
import 'package:fitness_app/utils/abstract_classes/counter.dart';

class LungeCounter extends Counter {
  LungeCounter({required super.userWeight});

  LungeLastStep _step = LungeLastStep.left;

  bool _verifyStep(
    Map<dynamic, Point3D> smoothedLandmarks,
    Map<dynamic, dynamic> likelihood,
  ) {
    bool isLeft =
        (likelihood['leftShoulder'] ?? 0) > (likelihood['rightShoulder'] ?? 0);
    bool isRight =
        (likelihood['leftShoulder'] ?? 0) < (likelihood['rightShoulder'] ?? 0);

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
      //print("Lunge Left Angle: $leftAngle");
      //print("Lunge Right Angle: $rightAngle");
      _update(leftAngle, rightAngle, landmarkLikelihoods);
    }
  }


  void _update(double leftAngle, rightAngle, Map<dynamic, dynamic> likelihood) {
    double minAngle = 120;
    double maxAngle = 165;

    if (viewType == ViewType.front) {
      minAngle = 80;
      maxAngle = 115;
    } else if (viewType == ViewType.back) {
      minAngle = 85;
      maxAngle = 115;
    }

    bool verify = _verifyStep(smoothedLandmarks, likelihood);
    //print("verify: $verify");
    //print("_step: $_step");
    if (state == CounterState.up &&
        leftAngle < minAngle &&
        rightAngle < minAngle &&
        verify) {
      state = CounterState.down;
      if (_step == LungeLastStep.left) {
        _step = LungeLastStep.right;
      } else if (_step == LungeLastStep.right) {
        _step = LungeLastStep.left;
      }
    } else if (state == CounterState.down &&
        leftAngle > maxAngle &&
        rightAngle > maxAngle) {
      state = CounterState.up;
      count++;
      caloriesBurnt += caloriesPerRep;
    }
    print("state: $state");
  }
}
