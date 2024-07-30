import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_recognition/document_counter/widgets/document_painter.dart';
import 'package:flutter_document_recognition/widgets/layout.dart';
import 'package:identity_document_detection/identity_document_detection.dart';

/// [DocumentCounterView] sends each frame for inference
class DocumentCounterView extends StatefulWidget {
  /// Constructor
  const DocumentCounterView({super.key});

  @override
  State<DocumentCounterView> createState() => _DocumentCounterViewState();
}

class _DocumentCounterViewState extends State<DocumentCounterView>
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
  String text = "0";

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
      text = values.length.toString();
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

        /// previewSize is size of each image frame captured by controller
        ///
        /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
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
          SafeArea(
            child: Text(
              'Number of documents: \n$text',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
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
