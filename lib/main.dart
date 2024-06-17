import 'package:flutter/material.dart';
import 'package:flutter_document_recognition/vision_detector_views/object_detector_view.dart';
import 'package:identity_document_detection/identity_document_detection.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: SplashPage(),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  void toRealTime(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectorView()));

  void toViewQR(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => IDView()));

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => toRealTime(context),
          child: const Text('Object Detection'),
        ),
        ElevatedButton(
          onPressed: () => toViewQR(context),
          child: const Text('ID Detection'),
        )
      ],
    ));
  }
}
