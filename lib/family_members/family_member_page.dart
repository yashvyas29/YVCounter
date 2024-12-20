import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'package:yv_counter/common/image_file_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';

class FamilyMemberPage extends StatefulWidget {
  final int id;
  final String name;
  final String familyFileName;

  const FamilyMemberPage(
      {super.key,
      required this.id,
      required this.name,
      required this.familyFileName});

  @override
  FamilyMemberPageState createState() => FamilyMemberPageState();
}

class FamilyMemberPageState extends State<FamilyMemberPage> {
  File? _image;
  Key? _imageKey;
  late ImageFileHandler imageFileHandler;

  @override
  void initState() {
    super.initState();
    imageFileHandler = ImageFileHandler(prefix: widget.familyFileName);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await imageFileHandler.loadImage(widget.id);
      setState(() {
        _image = image;
      });
    } catch (error) {
      // debugPrint(error.toString());
      setState(() {
        _image = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
      requestFullMetadata: false,
    );
    if (pickedFile != null) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // We can use crop_your_image package later for supporting crop for desktop platforms
        await _saveImage(pickedFile.path);
      } else {
        await _cropImage(pickedFile);
      }
    }
  }

  Future<void> _cropImage(XFile pickedFile) async {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final toolbarColor = theme.primaryColor;
    final toolbarWidgetColor = brightness == Brightness.light
        ? theme.primaryColorDark
        : theme.primaryColorLight;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          // toolbarTitle: 'Cropper',
          toolbarColor: toolbarColor,
          toolbarWidgetColor: toolbarWidgetColor,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          aspectRatioPickerButtonHidden: true,
          // title: 'Cropper',
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    String filePath;
    if (croppedFile != null) {
      await imageFileHandler.deleteFile(pickedFile.path);
      filePath = croppedFile.path;
    } else {
      filePath = pickedFile.path;
    }
    // debugPrint('File path: $filePath');
    await _saveImage(filePath);
  }

  Future<void> _saveImage(String path) async {
    final image = await imageFileHandler.saveImage(path, widget.id);
    setState(() {
      _image = image;
      _imageKey = UniqueKey();
    });
  }

  Future<void> _deleteImage(String message) async {
    showDeleteConfirmationDialog(context, message, () async {
      await imageFileHandler.deleteImage(widget.id);
      setState(() {
        _image = null;
      });
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  List<String> _names() {
    return widget.name.split('\n');
  }

  bool _isMarried() {
    final names = _names();
    return names.length > 1 && names.last.isNotEmpty;
  }

  /*
  String _getMarriedValue() {
    return _isMarried() ? 'Yes' : "No";
  }
  */

  double _getMinFromWidthAndHeight() {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final halfHeight = mediaQuery.size.height / 2;
    return width < halfHeight ? width : halfHeight;
  }

  @override
  Widget build(BuildContext context) {
    final names = _names();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.familyMemberDetails),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_image != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetZoom(
                    heroAnimationTag: 'tag',
                    zoomWidget: Image.file(
                      key: _imageKey,
                      _image!,
                      height: _getMinFromWidthAndHeight(),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteImage(localizations.deleteConfirmation(
                              name: localizations.image));
                        },
                        icon: Icon(Icons.delete),
                      )
                    ],
                  ),
                ],
              )
            else
              IconButton(
                onPressed: () => _pickImage(),
                icon: Icon(Icons.upload, size: _getMinFromWidthAndHeight()),
              ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations.memberName}: ${names.first}',
                  ),
                  if (_isMarried())
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          '${localizations.spouseName}: ${names.last}',
                        ),
                      ],
                    ),
                  /*
                  SizedBox(height: 10),
                  Text(
                    'Married: ${_getMarriedValue()}',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Id: ${widget.id}',
                  ),
                  */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
