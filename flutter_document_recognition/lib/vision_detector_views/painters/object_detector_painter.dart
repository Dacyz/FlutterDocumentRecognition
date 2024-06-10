import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'coordinates_translator.dart';
class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
    this._objects,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<DetectedObject> _objects;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = const Color(0x99000000);
    Paint currentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.grey;

    final verticalTopPoint = size.height * .10;
    final verticalBottomPoint = size.height * .90;
    final horizontalLeftPoint = size.width * .10;
    final horizontalRightPoint = size.width * .90;
    const augment = 32;

    for (final DetectedObject detectedObject in _objects) {
      final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.left, fontSize: 16, textDirection: TextDirection.ltr),
      );
      builder.pushStyle(ui.TextStyle(color: Colors.lightGreenAccent, background: background));
      if (detectedObject.labels.isNotEmpty) {
        final label = detectedObject.labels.reduce((a, b) => a.confidence > b.confidence ? a : b);
        builder.addText('${label.text} ${label.confidence}');
      }
      builder.pop();

      final left = translateX(
        detectedObject.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        detectedObject.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        detectedObject.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        detectedObject.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      bool isLeftCentered = left > size.width * .05 && left < size.width * .25;
      bool isRightCentered = right > size.width * .75 && right < size.width * 1.05;
      currentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = isLeftCentered && isRightCentered ? Colors.lightGreenAccent : Colors.grey;

      canvas.drawParagraph(
        builder.build()
          ..layout(ui.ParagraphConstraints(
            width: (right - left).abs(),
          )),
        Offset(Platform.isAndroid && cameraLensDirection == CameraLensDirection.front ? right : left, top),
      );
    }

    // Primer esquina
    canvas.drawLine(
      Offset(
        horizontalLeftPoint + augment,
        verticalTopPoint,
      ),
      Offset(
        horizontalLeftPoint,
        verticalTopPoint,
      ),
      currentPaint,
    );
    canvas.drawLine(
      Offset(
        horizontalLeftPoint,
        verticalTopPoint,
      ),
      Offset(
        horizontalLeftPoint,
        verticalTopPoint + augment,
      ),
      currentPaint,
    );

    // Segunda esquina
    canvas.drawLine(
      Offset(
        horizontalLeftPoint,
        verticalBottomPoint - augment,
      ),
      Offset(
        horizontalLeftPoint,
        verticalBottomPoint,
      ),
      currentPaint,
    );
    canvas.drawLine(
      Offset(
        horizontalLeftPoint,
        verticalBottomPoint,
      ),
      Offset(
        horizontalLeftPoint + augment,
        verticalBottomPoint,
      ),
      currentPaint,
    );
    // Tercera esquina
    canvas.drawLine(
      Offset(
        horizontalRightPoint - augment,
        verticalBottomPoint,
      ),
      Offset(
        horizontalRightPoint,
        verticalBottomPoint,
      ),
      currentPaint,
    );
    canvas.drawLine(
      Offset(
        horizontalRightPoint,
        verticalBottomPoint,
      ),
      Offset(
        horizontalRightPoint,
        verticalBottomPoint - augment,
      ),
      currentPaint,
    );
    // Cuarta esquina
    canvas.drawLine(
      Offset(
        horizontalRightPoint,
        verticalTopPoint + augment,
      ),
      Offset(
        horizontalRightPoint,
        verticalTopPoint,
      ),
      currentPaint,
    );
    canvas.drawLine(
      Offset(
        horizontalRightPoint,
        verticalTopPoint,
      ),
      Offset(
        horizontalRightPoint - augment,
        verticalTopPoint,
      ),
      currentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}