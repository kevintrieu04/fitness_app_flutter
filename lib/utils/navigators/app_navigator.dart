import 'package:fitness_app/widgets/fitness_counter_alert_box.dart';
import 'package:flutter/material.dart';

import '../../models/counter_data.dart';
import '../../pages/camera_page.dart';
import '../../pages/video_player_test_page.dart';

class AppNavigator {
  static void onOpenCamera(BuildContext context, ExerciseType type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraPage(exerciseType: type)),
    );
  }

  static void onOpenVideoPlayer(
    BuildContext context,
    String link,
    ExerciseType type,
    double userWeight,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerTestPage(
          link: link,
          exerciseType: type,
          userWeight: userWeight,
        ),
      ),
    );
  }

  static Future<void> _openAlertDialogue(
    BuildContext context,
    String link,
    ExerciseType type,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: FitnessCounterAlertBox(link: link, type: type),
      ),
    );
  }

  static void pushUpOnTap(BuildContext context) {
    _openAlertDialogue(
      context,
      "assets/videos/pushups/pushup_test.mp4",
      ExerciseType.pushup,
    );
  }

  static void squatOnTap(BuildContext context) {
    _openAlertDialogue(
      context,
      "assets/videos/squats/squat_360_test.mp4",
      //"assets/videos/back_view_test.mp4",
      ExerciseType.squat,
    );
  }

  static void lungeOnTap(BuildContext context) {
    _openAlertDialogue(
      context,
      "assets/videos/lunges/lunge_front_test.mp4",
      ExerciseType.lunge,
    );
  }

  static void bridgeOnTap(BuildContext context) {
    _openAlertDialogue(
      context,
      "assets/videos/bridges/bridge_test.mp4",
      ExerciseType.bridge,
    );
  }
}
