import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x * canvasSize.width / (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width - x * canvasSize.width / (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y * canvasSize.height / (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}

double calculateSharpness(Uint8List data) {
  final image = img.decodeImage( data);
  if (image == null) return -1;
  // Convert to grayscale
  final grayscale = img.grayscale(image);
  // Define Laplacian filter
  final laplacianFilter = [0, -1, 0, -1, 4, -1, 0, -1, 0];
  // Apply Laplacian filter
  final laplacian = img.convolution(grayscale, filter: laplacianFilter);

  // Calculate variance of the Laplacian
  final pixels = laplacian.getBytes();
  double mean = 0.0;
  double variance = 0.0;

  for (int i = 0; i < pixels.length; i += 4) {
    final pixelValue = pixels[i].toDouble();
    mean += pixelValue;
  }

  mean /= (pixels.length / 4);

  for (int i = 0; i < pixels.length; i += 4) {
    final pixelValue = pixels[i].toDouble();
    variance += pow((pixelValue - mean), 2);
  }

  variance /= (pixels.length / 4);

  return variance;
}
