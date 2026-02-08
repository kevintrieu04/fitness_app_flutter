import '../../core/data/counter_data.dart';
import 'detector.dart';

abstract class Counter extends Detector {
  CounterState state = CounterState.up;
  ViewType viewType = ViewType.undetermined;
  bool isUsing3D = false;
  final double userWeight;
  late final double caloriesPerRep;
  double caloriesBurnt = 0;
  int totalCount = 0;
  int correctReps = 0;
  Map<int, String> errors = <int, String>{};

  void updateFromLandmarks(List<Map<String, dynamic>> landmarks);

  Counter({required this.userWeight}) {
    caloriesPerRep = 8 * userWeight * 3.5 / 200 * (1 / 20);
  }

  bool checkBackStraightness(
    Map<dynamic, Point3D> landmarkPoints,
    Map<dynamic, dynamic> likelihood,
  ) {
    final leftShoulder = landmarkPoints['leftShoulder'];
    final leftHip = landmarkPoints['leftHip'];
    final leftAnkle = landmarkPoints['leftAnkle'];
    final rightShoulder = landmarkPoints['rightShoulder'];
    final rightHip = landmarkPoints['rightHip'];
    final rightAnkle = landmarkPoints['rightAnkle'];
    return checkStraightness(
      leftShoulder,
      leftHip,
      leftAnkle,
      rightShoulder,
      rightHip,
      rightAnkle,
      likelihood['leftShoulder'],
      likelihood['rightShoulder'],
    );
  }
}
