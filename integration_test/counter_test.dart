import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/data/counter_data.dart';
import 'package:fitness_app/utils/counters/push_up_counter.dart';
import 'package:fitness_app/utils/counters/squat_counter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:fitness_app/utils/data_processors/video_processor.dart';
import 'package:integration_test/integration_test.dart';

Future<List<Map<String, dynamic>>> getPoseData({
  required String videoAssetPath,
  required ExerciseType type,
}) async {
  // Preprocess video to get pose data
  final processor = VideoProcessor(
    sourcePath: videoAssetPath,
    isAsset: true,
    frameRate: 5, // Matching the video_player_test_page
  );
  await processor.process();

  // Load the generated JSON
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'pose_data', 'reference_pose.json'));
  if (!await file.exists()) {
    throw Exception("reference_pose.json not found for $videoAssetPath");
  }

  final content = await file.readAsString();
  return List<Map<String, dynamic>>.from(
    jsonDecode(content).map((e) => Map<String, dynamic>.from(e)),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Push Up Test', (tester) async {
    final poseData = await getPoseData(
      videoAssetPath: "assets/videos/pushup_test.mp4",
      type: ExerciseType.pushup,
    );
    PushUpCounter counter = PushUpCounter(userWeight: 50);
    for (var frame in poseData) {
      final landmarks = frame['landmarks'] as List<dynamic>;
      counter.updateFromLandmarks(List<Map<String, dynamic>>.from(landmarks));
    }
    final count = counter.count;

    print("Push Up count: $count");
    expect(count, equals(11));
  });

  testWidgets('Squat Test', (tester) async {
    final poseData = await getPoseData(
      videoAssetPath: "assets/videos/squat_test.mp4",
      type: ExerciseType.squat,
    );
    SquatCounter counter = SquatCounter(userWeight: 50);
    for (var frame in poseData) {
      final landmarks = frame['landmarks'] as List<dynamic>;
      counter.updateFromLandmarks(List<Map<String, dynamic>>.from(landmarks));
    }
    final count = counter.count;

    print("Squat count: $count");
    expect(count, equals(13));
  });
}
