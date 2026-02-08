import '../../core/data/counter_data.dart';
import '../abstract_classes/counter.dart';
import 'dart:async';

class SquatCounter extends Counter {
  SquatCounter({required super.userWeight});

  bool isKneesCorrect = true;
  Timer? _inactivityTimer;
  ViewType? _targetViewType;

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
        (likelihood['leftFootIndex'] ?? 0) > (likelihood['rightFootIndex'] ?? 0);
    bool isRight =
        (likelihood['leftKnee'] ?? 0) < (likelihood['rightKnee'] ?? 0) &&
        (likelihood['leftFootIndex'] ?? 0) < (likelihood['rightFootIndex'] ?? 0);

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
          //print("leftKnee.x: ${leftKnee.x}");
          //print("leftFootIndex.x: ${leftFootIndex.x}");
          return leftKnee.x >= leftFootIndex.x;
        } else if (isRight) {
          //print("rightKnee.x: ${rightKnee.x}");
          //print("rightFootIndex.x: ${rightFootIndex.x}");
          return rightKnee.x <= rightFootIndex.x;
        }
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
    isKneesCorrect = _checkKneesPosition(
      smoothedLandmarks,
      landmarkLikelihoods,
    );

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
      final angle = isUsing3D? calculateAngle3D(a, b, c) : calculateAngle2D(a, b, c);
      print("Squat Angle: $angle");
      _update(angle);
    }
  }

  void _update(double angle) {
    double minAngle = 90;
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
      /*
      if (!isKneesCorrect) {
        errors.addAll({totalCount+1: "Not in correct knee position"});
      }
       */
    } else if (state == CounterState.down && angle > maxAngle) {
      //print("Squat Up");
      state = CounterState.up;
      totalCount++;
      if (!errors.containsKey(totalCount)) {
        correctReps++;
        caloriesBurnt += caloriesPerRep;
      }
    }
  }
}
