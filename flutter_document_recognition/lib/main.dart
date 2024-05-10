import 'package:flutter/material.dart';
import 'package:flutter_document_recognition/vision_detector_views/object_detector_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ObjectDetectorView(),
      ),
    );
  }
}
