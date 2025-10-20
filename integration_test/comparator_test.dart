import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:fitness_app/utils/data_processors/process_video.dart';
import 'package:fitness_app/utils/data_processors/video_camera_comparator.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:integration_test/integration_test.dart';

Future<double> compareVideoAgainstReference({
  required String videoAssetPath,
}) async {
  final tempOutputDir = Directory(
    p.join((await getApplicationDocumentsDirectory()).path, 'pose_data'),
  );
  if (tempOutputDir.existsSync()) tempOutputDir.deleteSync(recursive: true);

  // Preprocess video into frames (but discard the reference JSON it writes)
  final processor = VideoPosePreprocessor(
    videoSourcePath: videoAssetPath,
    isAsset: true,
    frameRate: 5,
  );
  await processor.processVideo(isTesting: true);

  // Load reference JSON
  final comparator = AngleBasedLivePoseComparator(
    useJointDistances: true, // NEW: also consider distances
    distanceWeight: 0.3, // NEW: blend weight
    angleWeight: 0.7, // NEW: prioritize angles slightly
  );
  final String data = await rootBundle.loadString(
    "assets/video_landmark/reference_pose.json",
  );
  comparator.loadFromJsonString(data);

  final frameFiles =
      tempOutputDir.listSync().where((f) => f.path.endsWith(".jpg")).toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  print("Total frame files: ${frameFiles.length}");

  double totalError = 0.0;
  int valid = 0;

  for (final file in frameFiles) {
    final image = InputImage.fromFilePath(file.path);
    final err = await comparator.compareLivePose(image);
    if (err != null && err < 90) {
      totalError += err;
      valid++;
    }
  }

  processor.deleteExtractedFrames();
  comparator.dispose();
  return valid > 0 ? totalError / valid : double.infinity;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test calculations', (tester) async {
    // Preprocess and store both video references

    // === Test 1: test_video_1 vs. test_video_1 (match) ===
    final err1 = await compareVideoAgainstReference(
      videoAssetPath: "assets/videos/input_video.mp4",
    );
    print("📏 input_video vs. self: avg error = $err1°");
    expect(err1, greaterThanOrEqualTo(0)); // matching video should be low

    // === Test 2: test_video_1 vs. test_video_2 (mismatch) ===
    final err2 = await compareVideoAgainstReference(
      videoAssetPath: "assets/videos/comparator_test_video.mp4",
    );
    print("📏 input_video vs. omparator_test_video: avg error = $err2°");
    expect(err2, greaterThanOrEqualTo(0)); // mismatch should be high
  });
}
