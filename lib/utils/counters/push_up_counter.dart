import 'package:fitness_app/utils/abstract_classes/counter.dart';
import 'dart:async';

import '../../core/data/counter_data.dart';

class PushUpCounter extends Counter {
  bool isBackStraight = true; // New property for UI feedback
  bool _isDown = false; // New internal state for counting readiness
  Timer? _inactivityTimer; // Declare the timer
  ViewType? _targetViewType; // Store the target view type for stabilization check

  PushUpCounter({required super.userWeight});

  void _update(double angle) {
    double minAngle = 90;
    double maxAngle = 160;


    if (isUsing3D) {
      if (viewType == ViewType.side) {
        minAngle = 65; // Angle when arm is bent (down position)
        maxAngle = 105; // Angle when arm is straight (up position)
      } else if (viewType == ViewType.front) {
        // For front and back views, angles might be larger
        minAngle = 115; // Angle when arm is bent (down position)
        maxAngle = 160; // Angle when arm is straight (up position)
      } else {
        minAngle = 120; // Angle when arm is bent (down position)
        maxAngle = 160; // Angle when arm is straight (up position)
      }
    }


    if (!isBackStraight) {
      errors.addAll({totalCount+1: "Not in straight position"});
    }

    if (state == CounterState.up && angle < minAngle) {
      state = CounterState.down;
      if (!_isDown) {
        errors.addAll({totalCount+1: "Not in down position"});
      }
    } else if (state == CounterState.down && angle > maxAngle) {
      state = CounterState.up;
      totalCount++;
      caloriesBurnt += caloriesPerRep;
      if (!errors.containsKey(totalCount)) {
        correctReps++;
      }
    }
    print("state: $state");
    print("angle: $angle");
  }

  bool _checkDownPosition(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood
  ) {
    if (viewType == ViewType.back) {
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

  @override
  ViewType determineViewType(
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
      return ViewType
          .undetermined; // Cannot determine without core body landmarks
    }

    // Side view check: large Z-difference between shoulders
    //print(leftShoulder.z - rightShoulder.z);

    if ((leftShoulder.z - rightShoulder.z).abs() > 250) {
      // Threshold for side view
      return ViewType.side;
    }
    /*
    if ((leftShoulder.z < 0 && rightShoulder.z > 0) ||
        (leftShoulder.z > 0 && rightShoulder.z < 0)) {
      return ViewType.side;
    }
     */

    // Front/Back view check: small Z-difference between shoulders
    // Check ankles Z coordinates
    final leftAnkle = landmarkPoints['leftAnkle'];
    final rightAnkle = landmarkPoints['rightAnkle'];
    //print("leftAnkle: ${leftAnkle!.z}");
    //print("rightAnkle: ${rightAnkle!.z}");
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
        return ViewType.back;
      }
    } else {
      return ViewType.front;
    }

    return ViewType.undetermined;
  }

  @override
  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      _isDown = false; // Reset ready state if no landmarks
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      // Cancel timer if no landmarks are present
      _inactivityTimer?.cancel();
      _inactivityTimer = null;
      _targetViewType = null;
      isUsing3D = false; // Also reset isUsing3D
      return;
    }

    // Apply EMA smoothing
    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Determine view type dynamically
    final currentDetectedView = determineViewType(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (currentDetectedView != ViewType.undetermined) {
      if (currentDetectedView != viewType) {
        // View type has changed, so 3D processing might be needed
        isUsing3D = true;
        _targetViewType = currentDetectedView; // Store the new target view type

        // Cancel any existing timer to avoid multiple timers running
        _inactivityTimer?.cancel();

        // Start a new timer to check for stabilization
        _inactivityTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          // Check if the current viewType has stabilized to the target view type
          if (this.viewType == _targetViewType) {
            isUsing3D = false;
            timer.cancel();
            _inactivityTimer = null;
            _targetViewType = null; // Clear target once stabilized
          }
        });
      } else {
        // If currentDetectedView is the same as the current viewType,
        // it means the view is stable. So, isUsing3D should be false.
        // Also, cancel any running timer as it's no longer needed.
        if (isUsing3D) { // Only set to false if it's currently true
          isUsing3D = false;
        }
        _inactivityTimer?.cancel();
        _inactivityTimer = null;
        _targetViewType = null;
      }
      viewType = currentDetectedView; // Update the class member viewType
    }

    //print(viewType);

    // Check back straightness for all exercises, but mainly for pushups visually

    _isDown = _checkDownPosition(
      smoothedLandmarks,
      landmarkLikelihoods,
    ); // Pass viewType
    //print("_isDown: $_isDown");

    // No longer explicitly setting viewType here, handled by _determineViewType
    // print("viewType: $viewType");
    if (viewType != ViewType.front) {
      isBackStraight = checkBackStraightness(
        smoothedLandmarks,
        landmarkLikelihoods,
      );
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
      final angle = isUsing3D? calculateAngle3D(a, b, c) : calculateAngle2D(a, b, c);
      _update(angle);
    }
  }
}