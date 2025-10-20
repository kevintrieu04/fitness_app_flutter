import 'package:fitness_app/models/counter_data.dart';
import 'package:fitness_app/utils/counters/counter.dart';

class PushUpCounter extends Counter{
  PushUpState state = PushUpState.up;
  PushUpViewType viewType = PushUpViewType.undetermined;
  bool isBackStraight = true; // New property for UI feedback
  bool _isDown = false; // New internal state for counting readiness


  PushUpCounter({required super.userWeight});

  void _update(double angle) {
    double minAngle = 0;
    double maxAngle = 0;

    if (viewType == PushUpViewType.side) {
      minAngle = 65; // Angle when arm is bent (down position)
      maxAngle = 105; // Angle when arm is straight (up position)
    } else if (viewType == PushUpViewType.front) {
      // For front and back views, angles might be larger
      minAngle = 95; // Angle when arm is bent (down position)
      maxAngle = 160; // Angle when arm is straight (up position)
    } else {
      minAngle = 120; // Angle when arm is bent (down position)
      maxAngle = 160; // Angle when arm is straight (up position)
    }

    if (state == PushUpState.up && angle < minAngle && _isDown) {
      state = PushUpState.down;
    } else if (!_isDown && state == PushUpState.down && angle > maxAngle) {
      state = PushUpState.up;
      count++;
      caloriesBurnt += caloriesPerRep;
    }
    print("state: $state");
    print("angle: $angle");
  }

  bool _checkBackStraightness(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
  ) {
    final leftShoulder = landmarkPoints['leftShoulder'];
    final leftHip = landmarkPoints['leftHip'];
    final leftAnkle = landmarkPoints['leftAnkle'];
    final rightShoulder = landmarkPoints['rightShoulder'];
    final rightHip = landmarkPoints['rightHip'];
    final rightAnkle = landmarkPoints['rightAnkle'];

    // A straight back in 3D space seems to be in the 120-190 degree range based on test data.
    const minBackAngle = 100;
    const maxBackAngle = 190;

    if (leftShoulder != null &&
        leftHip != null &&
        leftAnkle != null &&
        (likelihood['leftShoulder'] ?? 0) > 0.5) {
      final leftBackAngle = calculateAngle3D(leftShoulder, leftHip, leftAnkle);
      //print("leftBackAngle: $leftBackAngle");
      if (leftBackAngle < minBackAngle || leftBackAngle > maxBackAngle) {
        return false;
      }
    }
    if (rightShoulder != null &&
        rightHip != null &&
        rightAnkle != null &&
        (likelihood['rightShoulder'] ?? 0) > 0.5) {
      final rightBackAngle = calculateAngle3D(
        rightShoulder,
        rightHip,
        rightAnkle,
      );
      //print("rightBackAngle: $rightBackAngle");
      if (rightBackAngle < minBackAngle || rightBackAngle > maxBackAngle) {
        return false;
      }
    }
    return true; // Assume straight if landmarks are missing or angles are within range
  }

  bool _checkDownPosition(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
    PushUpViewType currentViewType, // Pass viewType to this function
  ) {
    if (currentViewType == PushUpViewType.back) {
      final leftShoulder = landmarkPoints['leftShoulder'];
      final rightShoulder = landmarkPoints['rightShoulder'];
      final leftElbow = landmarkPoints['leftElbow'];
      final rightElbow = landmarkPoints['rightElbow'];

      // From back view, check if shoulders are lower than elbows
      if (leftShoulder != null &&
          leftElbow != null &&
          (likelihood['leftShoulder'] ?? 0) > 0.5 &&
          (likelihood['leftElbow'] ?? 0) > 0.5) {
        if (leftShoulder.y < leftElbow.y) return true;
      }
      if (rightShoulder != null &&
          rightElbow != null &&
          (likelihood['rightShoulder'] ?? 0) > 0.5 &&
          (likelihood['rightElbow'] ?? 0) > 0.5) {
        if (rightShoulder.y < rightElbow.y) return true;
      }
      return false; // Not in down position from back view
    } else {
      // Front and Side view logic
      final nose = landmarkPoints['nose'];
      if (nose == null) return false;

      // Fallback to original elbow logic if wrists are not visible
      final leftElbow = landmarkPoints['leftElbow'];
      final rightElbow = landmarkPoints['rightElbow'];

      Point3D? elbowToCompare;

      bool leftElbowVisible = (likelihood['leftElbow'] ?? 0.0) > 0.5;
      bool rightElbowVisible = (likelihood['rightElbow'] ?? 0.0) > 0.5;

      if (leftElbowVisible && rightElbowVisible) {
        elbowToCompare = (leftElbow!.y < rightElbow!.y)
            ? leftElbow
            : rightElbow;
      } else if (leftElbowVisible) {
        elbowToCompare = leftElbow;
      } else if (rightElbowVisible) {
        elbowToCompare = rightElbow;
      }

      if (elbowToCompare != null) {
        return nose.y > elbowToCompare.y;
      }

      return false;
    }
  }

  PushUpViewType _determineViewType(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
  ) {
    final leftShoulder = landmarkPoints['leftShoulder'];
    final rightShoulder = landmarkPoints['rightShoulder'];
    final leftHip = landmarkPoints['leftHip'];
    final rightHip = landmarkPoints['rightHip'];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftHip == null ||
        rightHip == null) {
      return PushUpViewType
          .undetermined; // Cannot determine without core body landmarks
    }

    // Side view check: large Z-difference between shoulders
    //print(leftShoulder.z - rightShoulder.z);
    if ((leftShoulder.z - rightShoulder.z).abs() > 250) {
      // Threshold for side view
      return PushUpViewType.side;
    }

    // Front/Back view check: small Z-difference between shoulders
    // Check ankles Z coordinates
    final leftAnkle = landmarkPoints['leftAnkle'];
    final rightAnkle = landmarkPoints['rightAnkle'];
    print("leftAnkle: ${leftAnkle!.z}");
    print("rightAnkle: ${rightAnkle!.z}");
    Point3D? ankleToCompare;
    bool leftAnkleVisible = (likelihood['leftAnkle'] ?? 0.0) > 0.5;
    bool rightAnkleVisible = (likelihood['rightAnkle'] ?? 0.0) > 0.5;
    if (leftAnkleVisible && rightAnkleVisible) {
      ankleToCompare = (leftAnkle!.z < rightAnkle!.z) ? leftAnkle : rightAnkle;
    } else if (leftAnkleVisible) {
      ankleToCompare = leftAnkle;
    } else if (rightAnkleVisible) {
      ankleToCompare = rightAnkle;
    }

    if (ankleToCompare != null && ankleToCompare.z < -150) {
      // High confidence in facial landmarks
      // Ensure torso is visible to confirm it's a back view, not just missing person
      if ((likelihood['leftShoulder'] ?? 0) > 0.5 &&
          (likelihood['rightShoulder'] ?? 0) > 0.5 &&
          (likelihood['leftHip'] ?? 0) > 0.5 &&
          (likelihood['rightHip'] ?? 0) > 0.5) {
        return PushUpViewType.back;
      }
    } else {
      return PushUpViewType.front;
    }

    return PushUpViewType.undetermined;
  }

  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      _isDown = false; // Reset ready state if no landmarks
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      return;
    }

    // Apply EMA smoothing
    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Determine view type dynamically
    final currentDetectedView = _determineViewType(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (currentDetectedView != PushUpViewType.undetermined) {
      viewType = currentDetectedView;
    }
    print(viewType);

    // Check back straightness for all exercises, but mainly for pushups visually

    _isDown = _checkDownPosition(
      smoothedLandmarks,
      landmarkLikelihoods,
      viewType,
    ); // Pass viewType
    print("_isDown: $_isDown");

    // No longer explicitly setting viewType here, handled by _determineViewType
    // print("viewType: $viewType");
    isBackStraight = _checkBackStraightness(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (!isBackStraight) {
      state = PushUpState.up;
      return;
    }
    // Existing pushup angle calculation logic
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
      _update(angle);
    }
  }
}
