import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class Processor {


  Processor({required this.sourcePath, this.isAsset = false});
  final String sourcePath;
  final bool isAsset;
  late final Directory outputDir;

  /// Prepare output directory
  Future<void> prepareOutputDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    outputDir = Directory(p.join(appDocDir.path, "pose_data"));

    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
    }
    outputDir.createSync(recursive: true);
  }

  /// Copy asset to local file so FFmpeg can access it
  Future<String> copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getApplicationDocumentsDirectory();
    final localFile = File(p.join(tempDir.path, p.basename(assetPath)));

    await localFile.writeAsBytes(byteData.buffer.asUint8List());
    return localFile.path;
  }

  // 🔥 Clean up frames after saving JSON
  Future<void> deleteData() async {
    final files = outputDir.listSync().where((f) => f.path.endsWith('.jpg'));
    for (final file in files) {
      try {
        file.deleteSync();
      } catch (e) {
        print("Failed to delete ${file.path}: $e");
      }
    }
  }

  Future<void> process();
  Future<void> detectPosesAndSave();

  String get outputJsonPath => p.join(outputDir.path, "reference_pose.json");
}