import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ImageFileHandler {
  final String prefix;
  const ImageFileHandler({required this.prefix});

  Future<String> getImagePath(int id) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${prefix}_$id.png';
  }

  Future<String> saveImage(String pickedPath, int id) async {
    final imageFile = File(pickedPath);
    final path = await getImagePath(id);
    await imageFile.copy(path);
    return path;
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
    final imageFile = File(path);
    if (await imageFile.exists()) {
      await imageFile.delete();
    } else {
      return Future.error(FileSystemException("File Not Found", path));
    }
  }
}
