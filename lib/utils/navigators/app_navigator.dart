import 'package:fitness_app/pages/counter_option_page.dart';
import 'package:fitness_app/widgets/fitness_counter_alert_box.dart';
import 'package:flutter/material.dart';

import '../../data/counter_data.dart';
import '../../pages/calories_estimation_page.dart';
import '../../pages/camera_page.dart';
import '../../pages/exercise_planner_page.dart';
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

  static void expandCounterList(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CounterOptionPage()));
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

  static void pullUpOnTap(BuildContext context) {
    _openAlertDialogue(
      context,
      "assets/videos/pullups/pull_up_front_view.mp4",
      ExerciseType.pullup,
    );
  }

  static void calorieEstimatorOnTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CaloriesEstimationPage()),
    );
  }

  static void exercisePlannerOnTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ExercisePlannerPage()),
    );
  }
}
