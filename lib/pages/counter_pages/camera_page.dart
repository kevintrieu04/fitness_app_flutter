import 'package:camera/camera.dart';
import 'package:fitness_app/data/counter_data.dart';
import 'package:fitness_app/utils/counters/push_up_counter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../utils/data_processors/pose_painter.dart';
import '../../../utils/data_processors/process_camera.dart';

class CameraPage extends StatefulWidget {
  /// Default Constructor
  CameraPage({super.key, required this.exerciseType});

  final ExerciseType exerciseType;
  final PushUpCounter _counter = PushUpCounter(userWeight: 50);

  Map<String, dynamic> _convertLandmarks(PoseLandmark target) {
    return {
      "type": target.type.name,
      "x": target.x,
      "y": target.y,
      "z": target.z,
      "inFrameLikelihood": target.likelihood,
    };
  }

  void _processPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    if (leftShoulder == null ||
        leftElbow == null ||
        leftWrist == null ||
        rightShoulder == null ||
        rightElbow == null ||
        rightWrist == null) return;
    List<Map<String, dynamic>> joints = [];
    joints.add(_convertLandmarks(leftShoulder));
    joints.add(_convertLandmarks(leftElbow));
    joints.add(_convertLandmarks(leftWrist));
    joints.add(_convertLandmarks(rightShoulder));
    joints.add(_convertLandmarks(rightElbow));
    joints.add(_convertLandmarks(rightWrist));
    _counter.updateFromLandmarks(joints);
  }

  void _processSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    if (leftHip == null ||
        leftKnee == null ||
        leftAnkle == null ||
        rightHip == null ||
        rightKnee == null ||
        rightAnkle == null) return;
    List<Map<String, dynamic>> joints = [];
    joints.add(_convertLandmarks(leftHip));
    joints.add(_convertLandmarks(leftKnee));
    joints.add(_convertLandmarks(leftAnkle));
    joints.add(_convertLandmarks(rightHip));
    joints.add(_convertLandmarks(rightKnee));
    joints.add(_convertLandmarks(rightAnkle));
    //_counter.updateFromLandmarks(joints, type: exerciseType);
  }

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isDetecting = false;
  List<Pose> _poses = [];
  int count = 0;

  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
    controller
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
          controller.startImageStream((CameraImage image) {
            if (!isDetecting) {
              isDetecting = true;

              int startTime = DateTime.now().millisecondsSinceEpoch;

              InputImage? img = inputImageFromCameraImage(image);
              if (img != null) {
                poseDetector.processImage(img).then((value) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _poses = value;
                    if (_poses.isNotEmpty &&
                        widget.exerciseType == ExerciseType.Pushup) {
                      widget._processPushUp(value.first.landmarks);
                      if (widget._counter.count != count) {
                        count = widget._counter.count;
                      }
                    } else if (_poses.isNotEmpty &&
                        widget.exerciseType == ExerciseType.Squat) {
                      widget._processSquat(value.first.landmarks);
                      if (widget._counter.count != count) {
                        count = widget._counter.count;
                      }
                    }
                  });
                });
                int endTime = DateTime.now().millisecondsSinceEpoch;
                print("Time taken for pose estimation ${endTime - startTime}");
                print("There are ${_poses.length} poses");

                isDetecting = false;
              }
            }
          });
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
  }

  @override
  void deactivate() {
    controller.stopImageStream();
    super.deactivate();
  }

  @override
  void dispose() {
    widget._counter.count = 0;
    widget._counter.state = CounterState.up;
    WakelockPlus.disable();
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final previewSize = controller.value.previewSize!;
    final imageSize = Size(
      previewSize.height,
      previewSize.width,
    ); // camera rotated

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(controller)),
          CustomPaint(
            painter: PosePainter(
              poses: _poses,
              isBackStraight: widget._counter.isBackStraight,
              imageSize: imageSize,
              isFrontCamera:
                  controller.description.lensDirection ==
                  CameraLensDirection.front,
            ),
            child: Container(),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    //return CameraPreview(controller);
  }
}
