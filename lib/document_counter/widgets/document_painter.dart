import 'package:flutter/material.dart';
import 'package:identity_document_detection/identity_document_detection.dart';
import 'dart:ui' as ui;

class DocumentCountPainter extends CustomPainter {
  DocumentCountPainter(this._objects);

  final List<IdentityDocument> _objects;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    for (final IdentityDocument detectedObject in _objects) {
      final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      final rect = detectedObject.renderLocation;

      final left = rect.left;
      final top = rect.top;
      final right = rect.right;
      final bottom = rect.bottom;

      final leftT = left - 24;
      final topT = top - 24;
      final rightT = right - 24;
      final bottomT = bottom - 24;

      final rectT = Rect.fromLTRB(leftT, topT, rightT, bottomT);
      canvas.drawRect(rectT, paint);
      canvas.drawParagraph(
        builder.build()
          ..layout(ui.ParagraphConstraints(
            width: (right - left).abs(),
          )),
        Offset(right, top),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
