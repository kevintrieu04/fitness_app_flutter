import '../../data/counter_data.dart';
import 'detector.dart';

abstract class Counter extends Detector {
  CounterState state = CounterState.up;
  ViewType viewType = ViewType.undetermined;
  final double userWeight;
  late final double caloriesPerRep;
  double caloriesBurnt = 0;
  int count = 0;

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
