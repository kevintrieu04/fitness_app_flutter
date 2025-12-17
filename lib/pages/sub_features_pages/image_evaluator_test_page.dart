import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../data/evaluator_data.dart';
import '../../utils/data_processors/pose_painter.dart';
import '../../utils/abstract_classes/evaluator.dart';
import '../../utils/evaluators/volleyball_moves_evaluator.dart';
import '../../widgets/image_picker_button.dart';

class ImageEvaluatorTestPage extends StatefulWidget {
  const ImageEvaluatorTestPage({
    super.key,
    required this.evaluatorType,
    required this.moveType,
  });

  final EvaluateExerciseType evaluatorType;
  final Moves moveType;

  @override
  State<StatefulWidget> createState() {
    return _ImageEvaluatorTestPageState();
  }
}

class _ImageEvaluatorTestPageState extends State<ImageEvaluatorTestPage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  List<Pose> poses = [];
  late final Evaluator _evaluator;
  List<String> _logs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.evaluatorType) {
      case EvaluateExerciseType.volleyball:
        _evaluator = VolleyballMovesEvaluator(moveName: widget.moveType);
        break;
    }
  }

  Future<void> _getLandmarks(String imagePath) async {
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.single,
        model: PoseDetectionModel.accurate,
      ),
    );
    final List<Pose> poses = await poseDetector.processImage(
      InputImage.fromFilePath(imagePath),
    );
    await poseDetector.close();
    setState(() {
      this.poses = poses;
    });
  }

  void _renderMistakeLogs() {
    final landmarks = poses.first.landmarks.entries.map((entry) {
      final l = entry.value;
      return {
        "type": entry.key.name,
        "x": l.x,
        "y": l.y,
        "z": l.z,
        "inFrameLikelihood": l.likelihood,
      };
    }).toList();

    _evaluator.evaluateFromLandmarks(landmarks, _updateUI, 0);
  }

  void _updateUI(List<String> logs) {
    setState(() {
      _logs = logs;
    });
  }

  void _getImageFromCamera() async {
    final XFile? retrievedImage = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (retrievedImage == null) return;

    setState(() {
      image = retrievedImage;
    });

    await _getLandmarks(retrievedImage.path);
    if (poses.isNotEmpty) {
      _renderMistakeLogs();
    }
  }

  void _getImageFromGallery() async {
    final XFile? retrievedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (retrievedImage == null) return;

    setState(() {
      image = retrievedImage;
    });

    await _getLandmarks(retrievedImage.path);
    if (poses.isNotEmpty) {
      _renderMistakeLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises Evaluator')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Stack(
            children: [
              Column(
                children: [
                  Center(
                    child: Container(
                      width: 250,
                      height: 300,
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: image == null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ImagePickerButton(
                                  icon: Icons.camera_alt,
                                  text: "Take a photo",
                                  onTap: _getImageFromCamera,
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                SizedBox(height: 10),
                                ImagePickerButton(
                                  icon: Icons.image,
                                  text: "Choose from gallery",
                                  onTap: _getImageFromGallery,
                                ),
                              ],
                            )
                          : Image.file(File(image!.path), fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              if (poses.isNotEmpty)
                CustomPaint(
                  painter: PosePainter(
                    poses: poses,
                    imageSize: Size(250, 300),
                    isFrontCamera: true,
                    isBackStraight: true,
                  ),
                  child: Container(),
                ),
            ],
          ),
          SizedBox(height: 50),
          if (_logs.isNotEmpty)
            for (final mistake in _logs) Text(mistake),
          Text("Mistake count: ${_evaluator.mistakeCount}")
        ],
      ),
    );
  }
}
