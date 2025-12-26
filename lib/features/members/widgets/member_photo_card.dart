import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Still useful for picking file
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:camera_windows/camera_windows.dart'; // Windows implementation
import 'camera_capture_dialog.dart';

class MemberPhotoCard extends StatefulWidget {
  final String? initialPhotoPath;
  final Function(File?) onPhotoChanged;

  const MemberPhotoCard({
    super.key,
    this.initialPhotoPath,
    required this.onPhotoChanged,
  });

  @override
  State<MemberPhotoCard> createState() => _MemberPhotoCardState();
}

class _MemberPhotoCardState extends State<MemberPhotoCard> {
  File? _currentPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotoPath != null) {
      _currentPhoto = File(widget.initialPhotoPath!);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _currentPhoto = File(result.files.single.path!);
      });
      widget.onPhotoChanged(_currentPhoto);
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cameras found')));
        return;
      }

      if (!mounted) return;
      final XFile? captured = await showDialog<XFile>(
        context: context,
        builder: (context) => CameraCaptureDialog(cameras: cameras),
      );

      if (captured != null) {
        setState(() {
          _currentPhoto = File(captured.path);
        });
        widget.onPhotoChanged(_currentPhoto);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching camera: $e')));
    }
  }

  void _removePhoto() {
    setState(() {
      _currentPhoto = null;
    });
    widget.onPhotoChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 2),
                image: _currentPhoto != null
                    ? DecorationImage(
                        image: FileImage(_currentPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _currentPhoto == null
                  ? const Icon(Icons.person, size: 80, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            if (_currentPhoto == null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Capture'),
                  ),
                ],
              )
            ] else
              TextButton.icon(
                onPressed: _removePhoto,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
