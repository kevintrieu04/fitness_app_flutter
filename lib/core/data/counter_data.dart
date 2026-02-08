import 'dart:math';
import 'dart:ui';

import 'carousel_data/carousel_item.dart';


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
  double dot3D(Point3D other) => x * other.x + y * other.y + z * other.z;

  // Magnitude of the vector
  double get distance3D => sqrt(x * x + y * y + z * z);

  // Dot product (2D)
  double dot2D(Point3D other) => x * other.x + y * other.y;

  // Magnitude of the vector (2D)
  double get distance2D => sqrt(x * x + y * y);
}

enum CounterState { up, down }
enum ViewType { front, side, back, undetermined }
enum ExerciseType { Pushup, Squat, Lunge, Bridge, Pullup }

enum LungeLastStep {left, right}

final List<CarouselItem> counterCarouselItemList = [
  CarouselItem(
    title: "Push Up",
    description: "Count the number of push ups you have done",
    icon: "assets/images/push_up.jpg",
    onTap: (context) {},
  ),
  CarouselItem(
    title: "Squat",
    description: "Count the number of squats you have done",
    icon: "assets/images/squat.jpg",
    onTap: (context) {},
  ),
  CarouselItem(
    title: "Bridge",
    description: "Count the number of bridges you have done",
    icon: "assets/images/bridge.webp",
    onTap: (context) {},
  ),
  CarouselItem(
    title: "Lunge",
    description: "Count the number of lunges you have done",
    icon: "assets/images/lunge.webp",
    onTap: (context) {},
  ),
  CarouselItem(
    title: "Pull Up",
    description: "Count the number of pull ups you have done",
    icon: "assets/images/pullup.webp",
    onTap: (context) {},
  ),
];



