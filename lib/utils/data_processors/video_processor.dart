import 'dart:convert';
import 'dart:io';
import 'package:fitness_app/utils/data_processors/processor.dart';
import 'package:flutter/services.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path/path.dart' as p;

class VideoProcessor extends Processor {
  final int frameRate;


  late final String _localVideoPath;

  VideoProcessor({
    required super.sourcePath,
    super.isAsset = false,
    this.frameRate = 5,
  });

  /// Main entry point
  @override
  Future<void> process() async {
    await prepareOutputDir();

    if (isAsset) {
      _localVideoPath = await copyAssetToFile(sourcePath);
    } else {
      _localVideoPath = sourcePath;
    }

    print("Using video file: $_localVideoPath");

    await _extractFrames();
    await detectPosesAndSave();
    await deleteData();

    print("✅ Done! Pose data saved to: $outputJsonPath");
  }

  /// Run FFmpeg to extract frames
  Future<void> _extractFrames() async {
    final outputPath = p.join(outputDir.path, "frame_%04d.jpg");
    final cmd = "-i $_localVideoPath -vf fps=$frameRate $outputPath";
    await FFmpegKit.execute(cmd);
  }

  /// Detect pose landmarks for each frame and save JSON
  @override
  Future<void> detectPosesAndSave() async {
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single, model: PoseDetectionModel.accurate),
    );

    final frameFiles =
        outputDir.listSync().where((f) => f.path.endsWith(".jpg")).toList()
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


}
