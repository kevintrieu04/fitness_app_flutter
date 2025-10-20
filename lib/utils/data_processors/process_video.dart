import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VideoPosePreprocessor {
  final String videoSourcePath;
  final bool isAsset;
  final int frameRate;

  late final Directory _outputDir;
  late final String _localVideoPath;

  VideoPosePreprocessor({
    required this.videoSourcePath,
    this.isAsset = false,
    this.frameRate = 5,
  });

  /// Entry point
  Future<void> processVideo({bool isTesting = false}) async {
    await _prepareOutputDir();

    _localVideoPath = isAsset
        ? await _copyAssetToFile(videoSourcePath)
        : videoSourcePath;

    await _extractFrames();
    await _detectAndSavePoseData();
    if (!isTesting) {
      await deleteExtractedFrames();
    }

    print("✅ Pose data saved to: $outputJsonPath");
  }

  /// Create pose_data/ folder
  Future<void> _prepareOutputDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _outputDir = Directory(p.join(appDocDir.path, "pose_data"));

    if (_outputDir.existsSync()) {
      _outputDir.deleteSync(recursive: true);
    }
    _outputDir.createSync(recursive: true);
  }

  /// Copy asset to file so FFmpeg can read
  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getApplicationDocumentsDirectory();
    final localFile = File(p.join(tempDir.path, p.basename(assetPath)));

    await localFile.writeAsBytes(byteData.buffer.asUint8List());
    return localFile.path;
  }

  /// Extract images using FFmpeg
  Future<void> _extractFrames() async {
    final outputPath = p.join(_outputDir.path, "frame_%04d.jpg");
    final cmd = "-i $_localVideoPath -vf fps=$frameRate $outputPath";
    await FFmpegKit.execute(cmd);
  }

  /// Detect pose and save landmark data
  Future<void> _detectAndSavePoseData() async {
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );

    final frameFiles = _outputDir
        .listSync()
        .where((f) => f.path.endsWith(".jpg"))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    List<Map<String, dynamic>> poseSequence = [];

    for (final file in frameFiles) {
      final inputImage = InputImage.fromFilePath(file.path);
      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final landmarks = poses.first.landmarks;
        final landmarkMap = landmarks.map((key, value) {
          return MapEntry(key.name, {
            'x': value.x,
            'y': value.y,
            'z': value.z,
            'likelihood': value.likelihood,
          });
        });
        poseSequence.add(landmarkMap);
      } else {
        poseSequence.add({});
      }
    }

    await poseDetector.close();

    final outputFile = File(outputJsonPath);
    outputFile.writeAsStringSync(jsonEncode(poseSequence));
  }

  /// Delete temp frames
  Future<void> deleteExtractedFrames() async {
    final files = _outputDir.listSync().where((f) => f.path.endsWith('.jpg'));
    for (final file in files) {
      try {
        file.deleteSync();
      } catch (_) {}
    }
  }

  /// Path to final output
  String get outputJsonPath => p.join(_outputDir.path, "reference_pose.json");
}
