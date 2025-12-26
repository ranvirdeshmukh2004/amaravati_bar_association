import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class MemberPhotoService {
  static const String _photoDirName = 'member_photos';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final photoDir = Directory(path.join(directory.path, _photoDirName));
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    return photoDir.path;
  }

  Future<String> savePhoto(File file, String regNo) async {
    final dirPath = await _localPath;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(file.path);
    final fileName = 'member_${regNo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_$timestamp$extension';
    final savedPath = path.join(dirPath, fileName);

    // Read and resize image to save space (Max 800px width)
    final imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image != null) {
      if (image.width > 800) {
        image = img.copyResize(image, width: 800);
      }
      // Encode as JPG with 85% quality
      final resizedBytes = img.encodeJpg(image, quality: 85);
      final savedFile = File(savedPath);
      await savedFile.writeAsBytes(resizedBytes);
      return savedPath;
    } else {
      // Fallback: just copy original if decoding fails
      await file.copy(savedPath);
      return savedPath;
    }
  }

  Future<void> deletePhoto(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> getPhoto(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }
}
