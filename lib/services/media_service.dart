import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPickResult {
  const MediaPickResult({
    required this.relativePath,
    this.message,
    this.needsSettings = false,
  });

  final String? relativePath;
  final String? message;
  final bool needsSettings;
}

class MediaService {
  MediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<MediaPickResult?> pickAndStore({
    required ImageSource source,
    required String trackerUid,
    required DateTime effectiveDate,
  }) async {
    final permissionResult = await _ensurePermission(source);
    if (permissionResult != null) {
      return permissionResult;
    }

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1280,
      maxHeight: 1280,
      requestFullMetadata: false,
    );
    if (file == null) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final mediaDirectory = Directory(path.join(directory.path, 'media'));
    if (!mediaDirectory.existsSync()) {
      mediaDirectory.createSync(recursive: true);
    }

    final filename =
        '${trackerUid}_${DateFormat('yyyyMMdd').format(effectiveDate)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = path.join(mediaDirectory.path, filename);

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 85,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    final finalFile = compressed ?? XFile(file.path);
    if (compressed == null) {
      await File(file.path).copy(targetPath);
    }

    final relativePath = path.join('media', path.basename(finalFile.path));
    if (path.basename(finalFile.path) != filename) {
      await File(finalFile.path).copy(targetPath);
    }

    return MediaPickResult(relativePath: relativePath);
  }

  Future<File?> resolveFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, relativePath));
    if (!file.existsSync()) {
      return null;
    }
    return file;
  }

  Future<MediaPickResult?> _ensurePermission(ImageSource source) async {
    if (kIsWeb) {
      return null;
    }

    if (source == ImageSource.gallery && Platform.isAndroid) {
      // Android gallery selection goes through the platform picker, so we
      // should not block the flow on storage/photo permission upfront.
      return null;
    }

    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
      if (!status.isGranted && Platform.isAndroid) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted || status.isLimited) {
      return null;
    }
    if (status.isPermanentlyDenied) {
      return const MediaPickResult(
        relativePath: null,
        message: 'Permission required. Open settings to continue.',
        needsSettings: true,
      );
    }
    return const MediaPickResult(
      relativePath: null,
      message: 'Permission required for this media action.',
    );
  }
}
