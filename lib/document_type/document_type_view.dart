import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_recognition/document_counter/widgets/document_painter.dart';
import 'package:flutter_document_recognition/widgets/layout.dart';
import 'package:identity_document_detection/identity_document_detection.dart';

/// [DocumentTypeView] sends each frame for inference
class DocumentTypeView extends StatefulWidget {
  /// Constructor
  const DocumentTypeView({super.key});

  @override
  State<DocumentTypeView> createState() => _DocumentTypeViewState();
}

class _DocumentTypeViewState extends State<DocumentTypeView>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;

  // use only when initialized, so - not null
  CameraController get _controller => _cameraController!;

  /// Object Detector is running on a background [Isolate]. This is nullable
  /// because acquiring a [IDController] is an asynchronous operation. This
  /// value is `null` until the detector is initialized.
  IDController? _detector;
  StreamSubscription? _subscription;
  CustomPaint? _customPaint;
  String text = "Not identified";
  String textSide = "Not identified";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    // initialize preview and CameraImage stream
    _initializeCamera();
    // Spawn a new isolate
    final detector = await IDController.initialize();
    _detector = detector;
    _subscription = detector.stream.listen((values) {
      final painter = DocumentCountPainter(values);
      _customPaint = CustomPaint(painter: painter);
      if (values.isEmpty) {
        text = 'Not identified';
        textSide = 'Not identified';
      } else {
        text = values.first.typeString.toString();
        textSide = values.first.sideString.toString();
      }
      setState(() {});
    });
  }

  /// Initializes the camera by setting [_cameraController]
  void _initializeCamera() async {
    cameras = await availableCameras();
    // cameras[0] for back-camera
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Layout(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AspectRatio(
                aspectRatio: aspect,
                child: CameraPreview(
                  _controller,
                  child: _customPaint,
                ),
              ),
            ),
          ),
          Text(
            'Document type: \n$text',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          Text(
            'Document side: \n$textSide',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
