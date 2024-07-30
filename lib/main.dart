import 'package:flutter/material.dart';
import 'package:flutter_document_recognition/document_counter/document_counter_view.dart';
import 'package:flutter_document_recognition/document_type/document_type_view.dart';
import 'package:flutter_document_recognition/vision_detector_views/object_detector_view.dart';
import 'package:flutter_document_recognition/widgets/layout.dart';
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
  void toRealTime(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => ObjectDetectorView()));

  void toViewQR(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Layout(child: IdentityDetector())));

  void toCounter(BuildContext context) => Navigator.push(context,
      MaterialPageRoute(builder: (context) => const DocumentCounterView()));

  void toType(BuildContext context) => Navigator.push(context,
      MaterialPageRoute(builder: (context) => const DocumentTypeView()));

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
        ),
        ElevatedButton(
          onPressed: () => toCounter(context),
          child: const Text('Document Counter'),
        ),
        ElevatedButton(
          onPressed: () => toType(context),
          child: const Text('Document Type'),
        )
      ],
    ));
  }
}
