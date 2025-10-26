import 'package:fitness_app/models/counter_data.dart';

import 'counter.dart';

class SquatCounter extends Counter {
  SquatCounter({required super.userWeight});


  bool _isTransitioning = false;

  @override
  ViewType determineViewType(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
  ) {
    final currentViewType = super.determineViewType(landmarkPoints, likelihood);
    if (currentViewType != ViewType.undetermined) {
      return currentViewType;
    }

    // Front/Back view detection for squats
    final noseLandmark = landmarkPoints['nose'];
    final leftShoulderLikelihood = likelihood['leftShoulder'] ?? 0.0;
    final rightShoulderLikelihood = likelihood['rightShoulder'] ?? 0.0;

    if (leftShoulderLikelihood < 0.5 && rightShoulderLikelihood < 0.5) {
      return ViewType.undetermined;
    }
    if (noseLandmark != null && noseLandmark.z <= 0) {
      return ViewType.front;
    } else if (noseLandmark != null && noseLandmark.z > 0) {
      return ViewType.back;
    }

    return ViewType.undetermined;
  }

  bool _checkKneesPosition(
    Map<dynamic, Point3D> smoothedLandmarks,
    Map<dynamic, dynamic> likelihood,
  ) {
    final leftKnee = smoothedLandmarks['leftKnee'];
    final rightKnee = smoothedLandmarks['rightKnee'];
    final leftFootIndex = smoothedLandmarks['leftFootIndex'];
    final rightFootIndex = smoothedLandmarks['rightFootIndex'];

    bool isLeft =
        (likelihood['leftKnee'] ?? 0) > (likelihood['rightKnee'] ?? 0) &&
        (likelihood['leftAnkle'] ?? 0) > (likelihood['rightAnkle'] ?? 0);
    bool isRight =
        (likelihood['leftKnee'] ?? 0) < (likelihood['rightKnee'] ?? 0) &&
        (likelihood['leftAnkle'] ?? 0) < (likelihood['rightAnkle'] ?? 0);

    if (leftKnee != null &&
        rightKnee != null &&
        leftFootIndex != null &&
        rightFootIndex != null) {
      //print("leftKnee.z: ${leftKnee.z}");
      //print("leftFootIndex.z: ${leftFootIndex.z}");
      if (viewType == ViewType.front) {
        return leftKnee.z <= leftFootIndex.z;
      } else if (viewType == ViewType.back) {
        return rightKnee.z >= rightFootIndex.z;
      } else if (viewType == ViewType.side) {
        if (isLeft) {
          print("leftKnee.x: ${leftKnee.x}");
          print("leftFootIndex.x: ${leftFootIndex.x}");
          return leftKnee.x >= leftFootIndex.x;
        } else if (isRight) {
          print("rightKnee.x: ${rightKnee.x}");
          print("rightFootIndex.x: ${rightFootIndex.x}");
          return rightKnee.x <= rightFootIndex.x;
        }
      }
    }
    return false;
  }

  void updateFromLandmarks(List<Map<String, dynamic>> landmarks) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      return;
    }

    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Determine view type dynamically
    final currentDetectedView = determineViewType(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    //print(currentDetectedView);
    if (currentDetectedView != ViewType.undetermined) {
      viewType = currentDetectedView;
    }
    final isKneesCorrect = _checkKneesPosition(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (!isKneesCorrect && !_isTransitioning) {
      //print("Incorrect Knees");
      state = CounterState.up;
      return;
    }


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
      //print("Squat Angle: $angle");
      _update(angle);
    }
  }

  void _update(double angle) {
    double minAngle = 30;
    double maxAngle = 100;

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

    if (state == CounterState.up && angle < minAngle) {
      //print("Squat Down");
      state = CounterState.down;
      _isTransitioning = true;
    } else if (state == CounterState.down && angle > maxAngle) {
      //print("Squat Up");
      state = CounterState.up;
      _isTransitioning = false;
      count++;
      caloriesBurnt += caloriesPerRep;
    }
  }
}
