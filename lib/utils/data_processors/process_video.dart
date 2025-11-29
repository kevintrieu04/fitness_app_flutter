import 'dart:convert';
import 'dart:io';
import 'package:fitness_app/data/counter_data.dart';
import 'package:flutter/services.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FramePreprocessor {
  final String videoSourcePath;
  final bool isAsset;
  final int frameRate;

  late final Directory _outputDir;
  late final String _localVideoPath;

  FramePreprocessor({
    required this.videoSourcePath,
    this.isAsset = false,
    this.frameRate = 5,
  });

  /// Main entry point
  Future<void> processVideo({required ExerciseType type}) async {
    await _prepareOutputDir();

    if (isAsset) {
      _localVideoPath = await _copyAssetToFile(videoSourcePath);
    } else {
      _localVideoPath = videoSourcePath;
    }

    print("Using video file: $_localVideoPath");

    await _extractFrames();
    await _detectPosesAndSave(type: type);
    await _deleteExtractedFrames();

    print("✅ Done! Pose data saved to: $outputJsonPath");
  }

  /// Prepare output directory
  Future<void> _prepareOutputDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _outputDir = Directory(p.join(appDocDir.path, "pose_data"));

    if (_outputDir.existsSync()) {
      _outputDir.deleteSync(recursive: true);
    }
    _outputDir.createSync(recursive: true);
  }

  /// Copy asset to local file so FFmpeg can access it
  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getApplicationDocumentsDirectory();
    final localFile = File(p.join(tempDir.path, p.basename(assetPath)));

    await localFile.writeAsBytes(byteData.buffer.asUint8List());
    return localFile.path;
  }

  /// Run FFmpeg to extract frames
  Future<void> _extractFrames() async {
    final outputPath = p.join(_outputDir.path, "frame_%04d.jpg");
    final cmd = "-i $_localVideoPath -vf fps=$frameRate $outputPath";
    await FFmpegKit.execute(cmd);
  }

  /// Detect pose landmarks for each frame and save JSON
  Future<void> _detectPosesAndSave({required ExerciseType type}) async {
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single, model: PoseDetectionModel.accurate),
    );

    final frameFiles =
        _outputDir.listSync().where((f) => f.path.endsWith(".jpg")).toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final List<Map<String, dynamic>> poseSequence = [];

    for (int i = 0; i < frameFiles.length; i++) {
      final file = frameFiles[i];
      final timestamp = (i * (1000 / frameRate)).round();

      final inputImage = InputImage.fromFilePath(file.path);
      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final frameLandmarks = poses.first.landmarks.entries.map((entry) {
          final l = entry.value;
          return {
            "type": entry.key.name,
            "x": l.x,
            "y": l.y,
            "z": l.z,
            "inFrameLikelihood": l.likelihood,
          };
        }).toList();
        poseSequence.add({"timestamp": timestamp, "landmarks": frameLandmarks});
      }
    }

    await poseDetector.close();

    final outputJson = File(outputJsonPath);
    outputJson.writeAsStringSync(jsonEncode(poseSequence));
  }

  // 🔥 Clean up frames after saving JSON
  Future<void> _deleteExtractedFrames() async {
    final files = _outputDir.listSync().where((f) => f.path.endsWith('.jpg'));
    for (final file in files) {
      try {
        file.deleteSync();
      } catch (e) {
        print("Failed to delete ${file.path}: $e");
      }
    }
  }

  String get outputJsonPath => p.join(_outputDir.path, "reference_pose.json");
}
