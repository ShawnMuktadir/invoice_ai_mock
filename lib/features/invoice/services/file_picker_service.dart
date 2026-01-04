import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum FileSource {
  camera,
  gallery,
  files,
}

class PickedFileInfo {
  final String path;
  final String name;
  final int size;
  final String extension;
  final FileSource source;

  PickedFileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
    required this.source,
  });

  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension.toLowerCase());
  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isValid => isImage || isPdf;
}

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick invoice file from camera
  Future<PickedFileInfo?> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      final fileSize = await file.length();

      return PickedFileInfo(
        path: image.path,
        name: image.name,
        size: fileSize,
        extension: image.path.split('.').last,
        source: FileSource.camera,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Pick invoice file from gallery
  Future<PickedFileInfo?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      final fileSize = await file.length();

      return PickedFileInfo(
        path: image.path,
        name: image.name,
        size: fileSize,
        extension: image.path.split('.').last,
        source: FileSource.gallery,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Pick invoice file from file system (PDF or images)
  Future<PickedFileInfo?> pickFromFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final pickedFile = result.files.first;

      if (pickedFile.path == null) return null;

      return PickedFileInfo(
        path: pickedFile.path!,
        name: pickedFile.name,
        size: pickedFile.size,
        extension: pickedFile.extension ?? '',
        source: FileSource.files,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Show picker options and return selected file
  Future<PickedFileInfo?> pickInvoiceFile(FileSource source) async {
    switch (source) {
      case FileSource.camera:
        return await pickFromCamera();
      case FileSource.gallery:
        return await pickFromGallery();
      case FileSource.files:
        return await pickFromFiles();
    }
  }
}
