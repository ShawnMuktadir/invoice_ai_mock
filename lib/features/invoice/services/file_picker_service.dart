import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum FileSource {
  camera,
  gallery,
  files,
}

class PickedFileInfo {
  final String? path;
  final Uint8List? bytes;
  final String name;
  final int size;
  final String extension;
  final FileSource source;

  PickedFileInfo({
    this.path,
    this.bytes,
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

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return PickedFileInfo(
          bytes: bytes,
          name: image.name,
          size: bytes.length,
          extension: image.name.split('.').last,
          source: FileSource.camera,
        );
      } else {
        final file = File(image.path);
        final fileSize = await file.length();
        return PickedFileInfo(
          path: image.path,
          name: image.name,
          size: fileSize,
          extension: image.path.split('.').last,
          source: FileSource.camera,
        );
      }
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

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return PickedFileInfo(
          bytes: bytes,
          name: image.name,
          size: bytes.length,
          extension: image.name.split('.').last,
          source: FileSource.gallery,
        );
      } else {
        final file = File(image.path);
        final fileSize = await file.length();
        return PickedFileInfo(
          path: image.path,
          name: image.name,
          size: fileSize,
          extension: image.path.split('.').last,
          source: FileSource.gallery,
        );
      }
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
        withData: kIsWeb, // Load bytes on web
      );

      if (result == null || result.files.isEmpty) return null;

      final pickedFile = result.files.first;

      if (kIsWeb) {
        // On web, use bytes
        if (pickedFile.bytes == null) return null;

        return PickedFileInfo(
          bytes: pickedFile.bytes,
          name: pickedFile.name,
          size: pickedFile.size,
          extension: pickedFile.extension ?? '',
          source: FileSource.files,
        );
      } else {
        // On mobile/desktop, use path
        if (pickedFile.path == null) return null;

        return PickedFileInfo(
          path: pickedFile.path,
          name: pickedFile.name,
          size: pickedFile.size,
          extension: pickedFile.extension ?? '',
          source: FileSource.files,
        );
      }
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
