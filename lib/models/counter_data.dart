import 'dart:math';
import 'dart:ui';


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

enum PushUpState { up, down }
enum PushUpViewType { front, side, back, undetermined }
enum ExerciseType { pushup, squat }

enum LungeState {up, down}
enum LungeLastStep {left, right}

enum SquatState {up, down}

