import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../core/data/counter_data.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final bool isFrontCamera;
  final bool condition;
  final ExerciseType? exerciseType;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.isFrontCamera,
    required this.exerciseType,
    required this.condition,
  });

  Offset _transform(PoseLandmark landmark, double scaleX, double scaleY) {
    final double x = isFrontCamera ? imageSize.width - landmark.x : landmark.x;
    final double y = landmark.y;
    return Offset(x * scaleX, y * scaleY);
  }

  // Define useful joints
  Offset? _joint(
    PoseLandmarkType type,
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    double scaleX,
    double scaleY,
  ) => landmarks[type] != null
      ? _transform(landmarks[type]!, scaleX, scaleY)
      : null;

  // Draw connections
  void _connect(
    String a,
    String b,
    Map<String, Offset?> joints,
    Canvas canvas,
    Paint paint,
  ) {
    final p1 = joints[a];
    final p2 = joints[b];
    if (p1 != null && p2 != null) {
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawBody(
    Map<String, Offset?> joints,
    Canvas canvas,
    Paint connectionPaint,
    Paint errorPaint,
  ) {
    switch (exerciseType) {
      case ExerciseType.Pushup:
      case ExerciseType.Bridge:
        // Upper body
        _connect(
          "leftShoulder",
          "rightShoulder",
          joints,
          canvas,
          connectionPaint,
        );
        _connect("leftShoulder", "leftElbow", joints, canvas, connectionPaint);
        _connect("leftElbow", "leftWrist", joints, canvas, connectionPaint);
        _connect(
          "rightShoulder",
          "rightElbow",
          joints,
          canvas,
          connectionPaint,
        );
        _connect("rightElbow", "rightWrist", joints, canvas, connectionPaint);

        // Torso and lower body
        final bodyPaint = condition ? connectionPaint : errorPaint;
        _connect("leftShoulder", "leftHip", joints, canvas, bodyPaint);
        _connect("rightShoulder", "rightHip", joints, canvas, bodyPaint);

        _connect("leftHip", "leftKnee", joints, canvas, bodyPaint);
        _connect("leftKnee", "leftAnkle", joints, canvas, bodyPaint);
        _connect("rightHip", "rightKnee", joints, canvas, bodyPaint);
        _connect("rightKnee", "rightAnkle", joints, canvas, bodyPaint);

        _connect("leftHip", "rightHip", joints, canvas, connectionPaint);
        break;

      case ExerciseType.Squat:
      case ExerciseType.Lunge:
        // Upper body
        _connect("leftShoulder", "rightShoulder", joints, canvas, connectionPaint);
        _connect("leftShoulder", "leftElbow", joints, canvas, connectionPaint);
        _connect("leftElbow", "leftWrist", joints, canvas, connectionPaint);
        _connect("rightShoulder", "rightElbow", joints, canvas, connectionPaint);
        _connect("rightElbow", "rightWrist", joints, canvas, connectionPaint);
        _connect("leftShoulder", "leftHip", joints, canvas, connectionPaint);
        _connect("rightShoulder", "rightHip", joints, canvas, connectionPaint);
        _connect("leftHip", "rightHip", joints, canvas, connectionPaint);

        // Highlight hip to ankle area
        final lowerBodyPaint = condition ? connectionPaint : errorPaint;
        _connect("leftHip", "leftKnee", joints, canvas, lowerBodyPaint);
        _connect("leftKnee", "leftAnkle", joints, canvas, lowerBodyPaint);
        _connect("rightHip", "rightKnee", joints, canvas, lowerBodyPaint);
        _connect("rightKnee", "rightAnkle", joints, canvas, lowerBodyPaint);
        break;

      case ExerciseType.Pullup:
        // Highlight shoulders to wrists area
        final upperBodyPaint = condition ? connectionPaint : errorPaint;
        _connect("leftShoulder", "leftElbow", joints, canvas, upperBodyPaint);
        _connect("leftElbow", "leftWrist", joints, canvas, upperBodyPaint);
        _connect("rightShoulder", "rightElbow", joints, canvas, upperBodyPaint);
        _connect("rightElbow", "rightWrist", joints, canvas, upperBodyPaint);

        // Rest of body
        _connect("leftShoulder", "rightShoulder", joints, canvas, connectionPaint);
        _connect("leftShoulder", "leftHip", joints, canvas, connectionPaint);
        _connect("rightShoulder", "rightHip", joints, canvas, connectionPaint);
        _connect("leftHip", "rightHip", joints, canvas, connectionPaint);
        _connect("leftHip", "leftKnee", joints, canvas, connectionPaint);
        _connect("leftKnee", "leftAnkle", joints, canvas, connectionPaint);
        _connect("rightHip", "rightKnee", joints, canvas, connectionPaint);
        _connect("rightKnee", "rightAnkle", joints, canvas, connectionPaint);
        break;

      case null:
        _connect("leftShoulder", "rightShoulder", joints, canvas, connectionPaint);
        _connect("leftShoulder", "leftElbow", joints, canvas, connectionPaint);
        _connect("leftElbow", "leftWrist", joints, canvas, connectionPaint);
        _connect("rightShoulder", "rightElbow", joints, canvas, connectionPaint);
        _connect("rightElbow", "rightWrist", joints, canvas, connectionPaint);
        _connect("leftShoulder", "leftHip", joints, canvas, connectionPaint);
        _connect("rightShoulder", "rightHip", joints, canvas, connectionPaint);
        _connect("leftHip", "rightHip", joints, canvas, connectionPaint);
        _connect("leftHip", "leftKnee", joints, canvas, connectionPaint);
        _connect("leftKnee", "leftAnkle", joints, canvas, connectionPaint);
        _connect("rightHip", "rightKnee", joints, canvas, connectionPaint);
        _connect("rightKnee", "rightAnkle", joints, canvas, connectionPaint);
        break;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final Paint landmarkPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    final Paint connectionPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final Paint errorPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    for (final pose in poses) {
      final landmarks = pose.landmarks;

      final joints = {
        "leftShoulder": _joint(
          PoseLandmarkType.leftShoulder,
          landmarks,
          scaleX,
          scaleY,
        ),
        "rightShoulder": _joint(
          PoseLandmarkType.rightShoulder,
          landmarks,
          scaleX,
          scaleY,
        ),
        "leftElbow": _joint(
          PoseLandmarkType.leftElbow,
          landmarks,
          scaleX,
          scaleY,
        ),
        "rightElbow": _joint(
          PoseLandmarkType.rightElbow,
          landmarks,
          scaleX,
          scaleY,
        ),
        "leftWrist": _joint(
          PoseLandmarkType.leftWrist,
          landmarks,
          scaleX,
          scaleY,
        ),
        "rightWrist": _joint(
          PoseLandmarkType.rightWrist,
          landmarks,
          scaleX,
          scaleY,
        ),
        "leftHip": _joint(PoseLandmarkType.leftHip, landmarks, scaleX, scaleY),
        "rightHip": _joint(
          PoseLandmarkType.rightHip,
          landmarks,
          scaleX,
          scaleY,
        ),
        "leftKnee": _joint(
          PoseLandmarkType.leftKnee,
          landmarks,
          scaleX,
          scaleY,
        ),
        "rightKnee": _joint(
          PoseLandmarkType.rightKnee,
          landmarks,
          scaleX,
          scaleY,
        ),
        "leftAnkle": _joint(
          PoseLandmarkType.leftAnkle,
          landmarks,
          scaleX,
          scaleY,
        ),
        "rightAnkle": _joint(
          PoseLandmarkType.rightAnkle,
          landmarks,
          scaleX,
          scaleY,
        ),
        "nose": _joint(PoseLandmarkType.nose, landmarks, scaleX, scaleY),
      };

      // Draw body connections
      _drawBody(joints, canvas, connectionPaint, errorPaint);

      // Draw points
      for (final offset in joints.values) {
        if (offset != null) {
          canvas.drawCircle(offset, 5.0, landmarkPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses || oldDelegate.condition != condition;
  }
}
