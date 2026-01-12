import 'package:fitness_app/utils/abstract_classes/evaluator.dart';
import 'dart:developer';

import '../../core/data/counter_data.dart';
import '../../core/data/evaluator_data.dart';


class VolleyballMovesEvaluator extends Evaluator {
  VolleyballMovesEvaluator({required this.moveName});

  final Moves moveName;

  List<String> _evaluatePassing(Map<dynamic, dynamic> landmarkLikelihoods) {
    log("Evaluating passing");
    final feedback = <String>[];
    mistakeCount = 0;

    final leftShoulder = smoothedLandmarks['leftShoulder'];
    final rightShoulder = smoothedLandmarks['rightShoulder'];
    final leftAnkle = smoothedLandmarks['leftAnkle'];
    final rightAnkle = smoothedLandmarks['rightAnkle'];
    final leftHip = smoothedLandmarks['leftHip'];
    final rightHip = smoothedLandmarks['rightHip'];
    final leftKnee = smoothedLandmarks['leftKnee'];
    final rightKnee = smoothedLandmarks['rightKnee'];
    final leftWrist = smoothedLandmarks['leftWrist'];
    final rightWrist = smoothedLandmarks['rightWrist'];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftWrist == null ||
        rightWrist == null) {
      feedback.add("Not all body parts are visible.");
      mistakeCount++;
      return feedback;
    }

    /*
    double shoulderWidth = 0;
    double ankleWidth = 0;
    // 1. Feet must be shoulder width
    if (viewType == ViewType.front || viewType == ViewType.back) {
      shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
      ankleWidth = (leftAnkle.x - rightAnkle.x).abs();
    } else if (viewType == ViewType.side) {
      shoulderWidth = (leftShoulder.z - rightShoulder.z).abs();
      ankleWidth = (leftAnkle.z - rightAnkle.z).abs();
    }
    print("Shoulder width: $shoulderWidth");
    print("Ankle width: $ankleWidth");
    if (ankleWidth < shoulderWidth * 0.8 || ankleWidth > shoulderWidth * 1.2) {
      feedback.add("Feet must be shoulder width.");
      mistakeCount++;
    }*/

    // 2. Knees are bent
    final leftKneeAngle = calculateAngle3D(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = calculateAngle3D(rightHip, rightKnee, rightAnkle);
    print("Left knee angle: $leftKneeAngle");
    print("Right knee angle: $rightKneeAngle");
    if (leftKneeAngle > 140 && rightKneeAngle > 140) {
      feedback.add("Bend your knees more.");
      mistakeCount++;
    }
    if (leftKneeAngle < 60 || rightKneeAngle < 60) {
      feedback.add("Don't bend your knees too much.");
      mistakeCount++;
    }

    // 3. Shoulders forward
    if (viewType == ViewType.front || viewType == ViewType.back) {
      if (leftShoulder.z >= leftHip.z) {
        feedback.add("Keep your back straight and lean forward.");
        mistakeCount++;
      }
    } else if (viewType == ViewType.side) {
      final chosenShoulder =
          landmarkLikelihoods["leftShoulder"] >
              landmarkLikelihoods["rightShoulder"]
          ? "left"
          : "right";
      if (chosenShoulder == "left") {
        if (leftShoulder.x < leftHip.x) {
          feedback.add("Keep your back straight and lean forward.");
          mistakeCount++;
        }
      } else {
        if (rightShoulder.x > rightHip.x) {
          feedback.add("Keep your back straight and lean forward.");
          mistakeCount++;
        }
      }
    }

    // 4. Arms are front
    if (viewType == ViewType.front || viewType == ViewType.back) {
      if (leftWrist.z > leftShoulder.z || rightWrist.z > rightShoulder.z) {
        feedback.add("Keep your arms in front of you.");
        mistakeCount++;
      }
    } else if (viewType == ViewType.side) {
      final chosenShoulder =
          landmarkLikelihoods["leftShoulder"] >
              landmarkLikelihoods["rightShoulder"]
          ? "left"
          : "right";
      print("Chosen shoulder: $chosenShoulder");
      if (chosenShoulder == "left") {
        if (leftWrist.x < leftShoulder.x) {
          feedback.add("Keep your arms in front of you.");
          mistakeCount++;
        }
      } else {
        if (rightWrist.x > rightShoulder.x) {
          feedback.add("Keep your arms in front of you.");
          mistakeCount++;
        }
      }
    }

    return feedback;
  }

  List<String> _evaluateSetting() {
    log("Evaluating setting");
    // TODO: Implement setting evaluation logic
    final feedback = <String>[];
    mistakeCount = 0;
    return feedback;
  }

  List<String> _evaluateServing() {
    log("Evaluating serving");
    // TODO: Implement serving evaluation logic
    final feedback = <String>[];
    mistakeCount = 0;
    return feedback;
  }

  @override
  void evaluateFromLandmarks(
    List<Map<String, dynamic>> landmarks,
    void Function(List<String>) updateUI,
    int timestamp,
  ) {
    if (landmarks.isEmpty) {
      smoothedLandmarks.clear(); // Clear smoothed data on reset
      return;
    }

    // Apply EMA smoothing
    applySmoothing(landmarks);

    final landmarkLikelihoods = {
      for (var lm in landmarks) lm['type']: lm['inFrameLikelihood'],
    };

    // Determine view type dynamically
    final currentDetectedView = determineViewType(
      smoothedLandmarks,
      landmarkLikelihoods,
    );
    if (currentDetectedView != ViewType.undetermined) {
      viewType = currentDetectedView;
    }

    switch (moveName) {
      case Moves.passing:
        updateUI(_evaluatePassing(landmarkLikelihoods));
        break;
      case Moves.setting:
        updateUI(_evaluateSetting());
        break;
      case Moves.serving:
        updateUI(_evaluateServing());
        break;
    }
  }
}
