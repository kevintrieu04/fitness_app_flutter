import 'dart:math';

import '../../models/counter_data.dart';

abstract class Counter {
  CounterState state = CounterState.up;
  ViewType viewType = ViewType.undetermined;
  final double userWeight;
  late final double caloriesPerRep;
  double caloriesBurnt = 0;
  int count = 0;

  // EMA smoothing factor
  final double _smoothingFactor = 0.2;

  get smoothingFactor => _smoothingFactor;

  // Smoothed landmarks
  Map<dynamic, Point3D> smoothedLandmarks = {};

  Counter({required this.userWeight}) {
    caloriesPerRep = 8 * userWeight * 3.5 / 200 * (1 / 20);
  }

  // Calculates angle between three 3D points.
  double calculateAngle3D(Point3D a, Point3D b, Point3D c) {
    final ab = a - b;
    final cb = c - b;

    final dot = ab.dot(cb);
    final abLen = ab.distance;
    final cbLen = cb.distance;

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

    // Front/Back view check: small Z-difference between shoulders
    // Varies between counters
    // Override this method in subclasses if needed

    //print(landmarkPoints['nose']!.z);
    return ViewType.undetermined;
  }
}
