import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageFileHandler {
  final String prefix;
  const ImageFileHandler({required this.prefix});

  Future<String> getImagePath(int id) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${prefix}_$id.png';
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
    return newFile;
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

  Future<void> deleteImage(int id) async {
    final path = await getImagePath(id);
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
}
