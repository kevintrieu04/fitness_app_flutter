import 'dart:convert';
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleBasedLivePoseComparator {
  final bool useJointDistances;
  final double angleWeight;
  final double distanceWeight;

  List<Map<String, dynamic>> referencePoses = [];

  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single),
  );

  AngleBasedLivePoseComparator({
    this.useJointDistances = false,
    this.angleWeight = 1.0,
    this.distanceWeight = 0.0,
  });

  Future<void> loadFromJsonString(String jsonStr) async {
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    referencePoses = decoded.cast<Map<String, dynamic>>().toList();
  }

  Future<double?> compareLivePose(InputImage image) async {
    final poses = await _detector.processImage(image);
    if (poses.isEmpty) return null;

    final currentPose = poses.first;
    final angles = _calculatePoseAngles(currentPose.landmarks);
    final distances = useJointDistances
        ? _calculateNormalizedDistances(currentPose.landmarks)
        : null;

    double minError = double.infinity;

    for (final refPoseData in referencePoses) {
      if (refPoseData.isEmpty) continue;
      
      final refLandmarks = _landmarksFromMap(refPoseData);
      final refAngles = _calculatePoseAngles(refLandmarks);
      final refDistances = useJointDistances
          ? _calculateNormalizedDistances(refLandmarks)
          : null;

      final angleError = _meanAngleDifference(angles, refAngles);

      double distError = 0;
      if (useJointDistances && refDistances != null) {
        distError = _meanDistanceDifference(distances!, refDistances);
      }
      
      final blended = angleWeight * angleError + distanceWeight * distError;
      if (blended < minError) minError = blended;
    }
    return minError;
  }

  Map<PoseLandmarkType, PoseLandmark> _landmarksFromMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      final type = PoseLandmarkType.values.firstWhere((e) => e.name == key);
      return MapEntry(
          type,
          PoseLandmark(
            type: type,
            x: (value['x'] as num).toDouble(),
            y: (value['y'] as num).toDouble(),
            z: (value['z'] as num).toDouble(),
            likelihood: (value['likelihood'] as num).toDouble(),
          ));
    });
  }

  double _getNormalizationScale(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    if (leftShoulder != null && rightShoulder != null) {
      return sqrt(pow(leftShoulder.x - rightShoulder.x, 2) +
          pow(leftShoulder.y - rightShoulder.y, 2) +
          pow(leftShoulder.z - rightShoulder.z, 2));
    }
    return 1.0;
  }

  Map<String, double> _calculatePoseAngles(Map<PoseLandmarkType, PoseLandmark> joints) {
    double angleBetween(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
      final ab = _vector(a, b);
      final cb = _vector(c, b);
      final dot = ab.dx * cb.dx + ab.dy * cb.dy + ab.dz * cb.dz;
      final norm = _length(ab) * _length(cb);
      return norm == 0 ? 0 : acos(dot / norm) * 180 / pi;
    }

    PoseLandmark? getJoint(PoseLandmarkType type) => joints[type];

    return {
      'left_elbow': angleBetween(
        getJoint(PoseLandmarkType.leftShoulder)!,
        getJoint(PoseLandmarkType.leftElbow)!,
        getJoint(PoseLandmarkType.leftWrist)!,
      ),
      'right_elbow': angleBetween(
        getJoint(PoseLandmarkType.rightShoulder)!,
        getJoint(PoseLandmarkType.rightElbow)!,
        getJoint(PoseLandmarkType.rightWrist)!,
      ),
      'left_knee': angleBetween(
        getJoint(PoseLandmarkType.leftHip)!,
        getJoint(PoseLandmarkType.leftKnee)!,
        getJoint(PoseLandmarkType.leftAnkle)!,
      ),
      'right_knee': angleBetween(
        getJoint(PoseLandmarkType.rightHip)!,
        getJoint(PoseLandmarkType.rightKnee)!,
        getJoint(PoseLandmarkType.rightAnkle)!,
      ),
    };
  }

  Map<String, double> _calculateNormalizedDistances(Map<PoseLandmarkType, PoseLandmark> joints) {
    final scale = _getNormalizationScale(joints);
    if (scale == 0) return {};

    double dist(PoseLandmark a, PoseLandmark b) {
      return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2)) / scale;
    }

    return {
      'left_upper_arm': dist(
        joints[PoseLandmarkType.leftShoulder]!,
        joints[PoseLandmarkType.leftElbow]!,
      ),
      'left_forearm': dist(
        joints[PoseLandmarkType.leftElbow]!,
        joints[PoseLandmarkType.leftWrist]!,
      ),
      'right_upper_arm': dist(
        joints[PoseLandmarkType.rightShoulder]!,
        joints[PoseLandmarkType.rightElbow]!,
      ),
      'right_forearm': dist(
        joints[PoseLandmarkType.rightElbow]!,
        joints[PoseLandmarkType.rightWrist]!,
      ),
    };
  }

  double _meanAngleDifference(Map<String, double> a, Map<String, double> b) {
    final keys = a.keys.toSet().intersection(b.keys.toSet());
    if (keys.isEmpty) return 90;

    return keys.map((k) => (a[k]! - b[k]!).abs()).reduce((x, y) => x + y) /
        keys.length;
  }

  double _meanDistanceDifference(Map<String, double> a, Map<String, double> b) {
    final keys = a.keys.toSet().intersection(b.keys.toSet());
    if (keys.isEmpty) return 1.0;

    return keys.map((k) => (a[k]! - b[k]!).abs()).reduce((x, y) => x + y) /
        keys.length;
  }

  Offset3D _vector(PoseLandmark a, PoseLandmark b) =>
      Offset3D(a.x - b.x, a.y - b.y, a.z - b.z);

  double _length(Offset3D v) => sqrt(v.dx * v.dx + v.dy * v.dy + v.dz * v.dz);

  void dispose() => _detector.close();
}

class Offset3D {
  final double dx, dy, dz;

  Offset3D(this.dx, this.dy, this.dz);
}
