import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pages/counter_pages/counter_option_page.dart';
import 'package:fitness_app/pages/daily_exercises_pages/daily_test_page.dart';
import 'package:fitness_app/pages/sub_features_pages/image_evaluator_test_page.dart';
import 'package:fitness_app/pages/user_profile_page.dart';
import 'package:fitness_app/widgets/fitness_counter_alert_box.dart';
import 'package:fitness_app/widgets/move_evaluator_alert_box.dart';
import 'package:flutter/material.dart';

import '../../data/counter_data.dart';
import '../../data/evaluator_data.dart';
import '../../pages/daily_exercises_pages/daily_exercises_page.dart';
import '../../pages/sub_features_pages/calories_estimation_page.dart';
import '../../pages/counter_pages/camera_page.dart';
import '../../pages/sub_features_pages/exercise_planner_page.dart';
import '../../pages/counter_pages/counter_test_page.dart';
import '../../pages/login_page.dart';

class AppNavigator {
  static void onOpenCamera(BuildContext context, ExerciseType type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraPage(exerciseType: type)),
    );
  }

  static void onOpenCounterTestPage(
    BuildContext context,
    String link,
    ExerciseType type,
    double userWeight,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CounterTestPage(
          link: link,
          exerciseType: type,
          userWeight: userWeight,
        ),
      ),
    );
  }

  static void onOpenEvaluatorTestPage(
    BuildContext context,
    String link,
    EvaluateExerciseType type,
    Moves move,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImageEvaluatorTestPage(evaluatorType: type, moveType: move),
      ),
    );
  }

  static Future<void> _openCounterAlertDialogue(
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
    _openCounterAlertDialogue(
      context,
      "assets/videos/pushups/pushup_test.mp4",
      ExerciseType.Pushup,
    );
  }

  static void squatOnTap(BuildContext context) {
    _openCounterAlertDialogue(
      context,
      "assets/videos/squats/squat_360_test.mp4",
      //"assets/videos/back_view_test.mp4",
      ExerciseType.Squat,
    );
  }

  static void lungeOnTap(BuildContext context) {
    _openCounterAlertDialogue(
      context,
      "assets/videos/lunges/lunge_front_test.mp4",
      ExerciseType.Lunge,
    );
  }

  static void bridgeOnTap(BuildContext context) {
    _openCounterAlertDialogue(
      context,
      "assets/videos/bridges/bridge_test.mp4",
      ExerciseType.Bridge,
    );
  }

  static void pullUpOnTap(BuildContext context) {
    _openCounterAlertDialogue(
      context,
      "assets/videos/pullups/pull_up_front_view.mp4",
      ExerciseType.Pullup,
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

  static Future<void> _openEvaluatorAlertDialogue(
    BuildContext context,
    String link,
    EvaluateExerciseType type,
    List<DropdownMenuEntry<Moves>> entries,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: MoveEvaluatorAlertBox(link: link, type: type, entries: entries),
      ),
    );
  }

  static void volleyballOnTap(BuildContext context) {
    _openEvaluatorAlertDialogue(
      context,
      "assets/videos/volleyball/passing_test.mp4",
      EvaluateExerciseType.volleyball,
      volleyballMoves,
    );
  }

  static void userProfileOnTap(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UserProfilePage(user: user)),
    );
  }

  static void logInPageOnTap(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  static dynamic doDailyExercise(
    BuildContext context,
    String level,
    int tier,
  ) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyExercisesPage(level: level, tier: tier),
      ),
    );
  }

  static dynamic onOpenDailyTestPage(
    BuildContext context,
    String link,
    ExerciseType type,
    double userWeight,
    int targetReps,
    int timeLimit,
  ) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyTestPage(
          link: link,
          exerciseType: type,
          userWeight: userWeight,
          targetReps: targetReps,
          timeLimit: timeLimit,
        ),
      ),
    );
  }
}
