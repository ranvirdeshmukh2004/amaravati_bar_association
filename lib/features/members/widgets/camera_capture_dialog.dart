import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureDialog extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraCaptureDialog({super.key, required this.cameras});

  @override
  State<CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<CameraCaptureDialog> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.cameras.first);
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Camera Error: ${e.description}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null) return;

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      setState(() => _error = 'Capture Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Capture Photo', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                 color: Colors.black,
                 child: Center(
                   child: _isInitialized
                       ? CameraPreview(_controller!)
                       : _error != null
                           ? Text(_error!, style: const TextStyle(color: Colors.red))
                           : const CircularProgressIndicator(),
                 ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isInitialized ? _takePicture : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
