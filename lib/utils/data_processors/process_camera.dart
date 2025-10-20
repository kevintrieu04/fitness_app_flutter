import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../main.dart';

final _options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
final poseDetector = PoseDetector(options: _options);

final CameraDescription camera = cameras[1];
final controller = CameraController(
  camera,
  ResolutionPreset.medium,
  enableAudio: false,
  imageFormatGroup: Platform.isAndroid
      ? ImageFormatGroup.nv21 // for Android
      : ImageFormatGroup.bgra8888, // for iOS
);

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImage? inputImageFromCameraImage(CameraImage image) {
  // get image rotation
  // it is used in android to convert the InputImage from Dart to Java
  // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    var rotationCompensation =
    _orientations[controller.value.deviceOrientation];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;

  // get image format
  InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;
  if (Platform.isAndroid && format == InputImageFormat.yuv_420_888) {
    format = InputImageFormat.nv21;
    Uint8List nv21 = convertYUV420ToNV21(image);
    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: nv21.lengthInBytes, // used only in iOS
      ),
    );
  }

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

Uint8List convertYUV420ToNV21(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final uvRowStride = uPlane.bytesPerRow;
  final uvPixelStride = uPlane.bytesPerPixel!;

  // Prepare NV21 buffer: Y size + UV size
  final nv21 = Uint8List(width * height + (width * height) ~/ 2);

  // Copy Y plane
  int index = 0;
  for (int row = 0; row < height; row++) {
    final start = row * yPlane.bytesPerRow;
    nv21.setRange(index, index + width, yPlane.bytes.sublist(start, start + width));
    index += width;
  }

  // Interleave V and U planes into NV21 format
  for (int row = 0; row < height ~/ 2; row++) {
    for (int col = 0; col < width ~/ 2; col++) {
      final uvIndex = row * uvRowStride + col * uvPixelStride;
      nv21[index++] = vPlane.bytes[uvIndex]; // V
      nv21[index++] = uPlane.bytes[uvIndex]; // U
    }
  }

  return nv21;
}


