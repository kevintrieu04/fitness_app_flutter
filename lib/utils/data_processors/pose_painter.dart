import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final bool isFrontCamera;
  final bool isBackStraight;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.isFrontCamera,
    required this.isBackStraight,
  });

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

    Offset transform(PoseLandmark landmark) {
      final double x =
          isFrontCamera ? imageSize.width - landmark.x : landmark.x;
      final double y = landmark.y;
      return Offset(x * scaleX, y * scaleY);
    }

    for (final pose in poses) {
      final landmarks = pose.landmarks;

      // Define useful joints
      final joint = (PoseLandmarkType type) =>
          landmarks[type] != null ? transform(landmarks[type]!) : null;

      final joints = {
        "leftShoulder": joint(PoseLandmarkType.leftShoulder),
        "rightShoulder": joint(PoseLandmarkType.rightShoulder),
        "leftElbow": joint(PoseLandmarkType.leftElbow),
        "rightElbow": joint(PoseLandmarkType.rightElbow),
        "leftWrist": joint(PoseLandmarkType.leftWrist),
        "rightWrist": joint(PoseLandmarkType.rightWrist),
        "leftHip": joint(PoseLandmarkType.leftHip),
        "rightHip": joint(PoseLandmarkType.rightHip),
        "leftKnee": joint(PoseLandmarkType.leftKnee),
        "rightKnee": joint(PoseLandmarkType.rightKnee),
        "leftAnkle": joint(PoseLandmarkType.leftAnkle),
        "rightAnkle": joint(PoseLandmarkType.rightAnkle),
        "nose": joint(PoseLandmarkType.nose),
      };

      // Draw connections
      void connect(String a, String b, {Paint? paint}) {
        final p1 = joints[a];
        final p2 = joints[b];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, paint ?? connectionPaint);
        }
      }

      // Upper body
      connect("leftShoulder", "rightShoulder");
      connect("leftShoulder", "leftElbow");
      connect("leftElbow", "leftWrist");
      connect("rightShoulder", "rightElbow");
      connect("rightElbow", "rightWrist");

      // Torso and lower body
      final torsoPaint = isBackStraight ? connectionPaint : errorPaint;
      connect("leftShoulder", "leftHip", paint: torsoPaint);
      connect("rightShoulder", "rightHip", paint: torsoPaint);

      connect("leftHip", "leftKnee", paint: torsoPaint);
      connect("leftKnee", "leftAnkle", paint: torsoPaint);
      connect("rightHip", "rightKnee", paint: torsoPaint);
      connect("rightKnee", "rightAnkle" , paint: torsoPaint);

      connect("leftHip", "rightHip");

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
    return oldDelegate.poses != poses ||
        oldDelegate.isBackStraight != isBackStraight;
  }
}
