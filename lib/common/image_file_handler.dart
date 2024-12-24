import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageFileHandler {
  final String prefix;
  const ImageFileHandler({required this.prefix});

  Future<String> localPath() async {
    final directory = await imagesDirectory();
    return directory.path;
  }

  Future<String> getImagePath(int id) async {
    final path = await localPath();
    return '$path/${prefix}_$id.jpg';
  }

  Future<String> getThumbnailImagePath(int id) async {
    final path = await localPath();
    return '$path/${prefix}_${id}_thumb.jpg';
  }

  Future<File> saveImageData(Uint8List data, int id) async {
    final path = await getImagePath(id);
    final prevFile = File(path);
    if (await prevFile.exists()) {
      await FileImage(prevFile).evict();
    }
    File newFile = await File(path).create();
    await newFile.writeAsBytes(data);
    await saveThumbnail(id);
    return newFile;
  }

  Future<File> saveImage(String pickedPath, int id) async {
    final tempFile = File(pickedPath);
    final path = await getImagePath(id);
    final prevFile = File(path);
    if (await prevFile.exists()) {
      await FileImage(prevFile).evict();
    }
    final newFile = await tempFile.copy(path);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    await saveThumbnail(id);
    return newFile;
  }

  Future<void> saveThumbnail(int id, [int side = 100]) async {
    final fromPath = await getImagePath(id);
    final toPath = await getThumbnailImagePath(id);
    final prevFile = File(toPath);
    if (await prevFile.exists()) {
      await FileImage(prevFile).evict();
    }
    await FlutterImageCompress.compressAndGetFile(
      fromPath,
      toPath,
      minWidth: side,
      minHeight: side,
    );
  }

  Future<File> loadImage(int id) async {
    final path = await getImagePath(id);
    final imageFile = File(path);
    if (await imageFile.exists()) {
      return imageFile;
    } else {
      return Future.error(FileSystemException("File Not Found", path));
    }
  }

  Future<File> loadThumbnail(int id) async {
    final path = await getThumbnailImagePath(id);
    final imageFile = File(path);
    if (await imageFile.exists()) {
      return imageFile;
    } else {
      return Future.error(FileSystemException("File Not Found", path));
    }
  }

  Future<void> deleteImage(int id) async {
    final path = await getImagePath(id);
    deleteFile(path);
    await deleteThumbnail(id);
  }

  Future<void> deleteThumbnail(int id) async {
    final path = await getThumbnailImagePath(id);
    deleteFile(path);
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    } else {
      return Future.error(FileSystemException("File Not Found", path));
    }
  }

  static Future<Directory> imagesDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = await Directory(join(directory.path, 'images')).create();
    return imagesDir;
  }

  static Future<void> deleteFiles(String name) async {
    final directory = await imagesDirectory();
    if (await directory.exists()) {
      directory.list().forEach((file) async {
        String fileName = file.path.split('/').last;
        if (fileName.contains("${name}_")) {
          await file.delete();
        }
      });
    }
  }
}
