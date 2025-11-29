import 'dart:math';
import 'dart:ui';

import '../models/counter_data_item.dart';
import '../utils/navigators/app_navigator.dart';


Map<String, Offset?> joints = {};

class Point3D {
  final double x;
  final double y;
  final double z;

  Point3D(this.x, this.y, this.z);

  // Vector subtraction
  Point3D operator -(Point3D other) =>
      Point3D(x - other.x, y - other.y, z - other.z);

  // Vector addition
  Point3D operator +(Point3D other) =>
      Point3D(x + other.x, y + other.y, z + other.z);

  // Scalar multiplication
  Point3D operator *(double scalar) =>
      Point3D(x * scalar, y * scalar, z * scalar);

  // Dot product
  double dot(Point3D other) => x * other.x + y * other.y + z * other.z;

  // Magnitude of the vector
  double get distance => sqrt(x * x + y * y + z * z);
}

enum CounterState { up, down }
enum ViewType { front, side, back, undetermined }
enum ExerciseType { pushup, squat, lunge, bridge, pullup }

enum LungeLastStep {left, right}

final List<CounterDataItem> counterDataItemList = [
  CounterDataItem(
    title: "Push Up",
    description: "Count the number of push ups you have done",
    icon: "assets/images/push_up.jpg",
    onTap: AppNavigator.pushUpOnTap,
  ),
  CounterDataItem(
    title: "Squat",
    description: "Count the number of squats you have done",
    icon: "assets/images/squat.jpg",
    onTap: AppNavigator.squatOnTap,
  ),
  CounterDataItem(
    title: "Bridge",
    description: "Count the number of bridges you have done",
    icon: "assets/images/bridge.webp",
    onTap: AppNavigator.bridgeOnTap,
  ),
  CounterDataItem(
    title: "Lunge",
    description: "Count the number of lunges you have done",
    icon: "assets/images/lunge.webp",
    onTap: AppNavigator.lungeOnTap,
  ),
  CounterDataItem(
    title: "Pull Up",
    description: "Count the number of pull ups you have done",
    icon: "assets/images/pullup.webp",
    onTap: AppNavigator.pullUpOnTap,
  ),
];



