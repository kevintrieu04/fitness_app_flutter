import 'dart:math';

import '../../core/data/counter_data.dart';

abstract class Detector {
  // EMA smoothing factor
  final double _smoothingFactor = 0.2;

  get smoothingFactor => _smoothingFactor;

  // Smoothed landmarks
  Map<dynamic, Point3D> smoothedLandmarks = {};

  // Calculates angle between three 3D points.
  double calculateAngle3D(Point3D a, Point3D b, Point3D c) {
    final ab = a - b;
    final cb = c - b;

    final dot = ab.dot3D(cb);
    final abLen = ab.distance3D;
    final cbLen = cb.distance3D;

    if (abLen == 0 || cbLen == 0) return 0; // Avoid division by zero

    final cosine = dot / (abLen * cbLen);
    final angle = acos(cosine.clamp(-1.0, 1.0)) * 180 / pi;
    return angle;
  }

  double calculateAngle2D(Point3D a, Point3D b, Point3D c) {
    final ab = a - b;
    final cb = c - b;

    final dot = ab.dot2D(cb);
    final abLen = ab.distance2D;
    final cbLen = cb.distance2D;

    if (abLen == 0 || cbLen == 0) return 0; // Avoid division by zero

    final cosine = dot / (abLen * cbLen);
    final angle = acos(cosine.clamp(-1.0, 1.0)) * 180 / pi;
    return angle;
  }

  void applySmoothing(List<Map<String, dynamic>> landmarks) {
    final landmarkPoints = {
      for (var lm in landmarks)
        lm['type']: Point3D(lm['x'], lm['y'], lm['z'] ?? 0.0),
    };
    smoothedLandmarks = landmarkPoints;

    /*
    for (var entry in landmarkPoints.entries) {
      final key = entry.key;
      final currentPoint = entry.value;
      final smoothedPoint = smoothedLandmarks[key];

      if (smoothedPoint == null) {
        smoothedLandmarks[key] = currentPoint;
      } else {
        smoothedLandmarks[key] =
            (currentPoint * smoothingFactor) +
            (smoothedPoint * (1.0 - smoothingFactor));
      }
    }
     */
  }

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

  bool checkStraightness(
    Point3D? a,
    Point3D? b,
    Point3D? c,
    Point3D? d,
    Point3D? e,
    Point3D? f,
    dynamic aLikelihood,
    dynamic dLikelihood,
  ) {
    // A straight back in 3D space seems to be in the 120-190 degree range based on test data.
    const minAngle = 160;
    const maxAngle = 190;

    if (a != null &&
        b != null &&
        c != null &&
        (aLikelihood ?? 0) > dLikelihood) {
      final angle = calculateAngle2D(a, b, c);
      //print("angle: $angle");
      if (angle < minAngle || angle > maxAngle) {
        return false;
      }
    }
    if (d != null &&
        e != null &&
        f != null &&
        (dLikelihood ?? 0) > aLikelihood) {
      final angle = calculateAngle2D(d, e, f);
      //print("angle: $angle");
      if (angle < minAngle || angle > maxAngle) {
        return false;
      }
    }
    return true; // Assume straight if landmarks are missing or angles are within range
  }
}
