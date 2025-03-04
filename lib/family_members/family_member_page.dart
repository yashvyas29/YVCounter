import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart' as ic;
import 'package:crop_your_image/crop_your_image.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'package:yv_counter/common/image_file_handler.dart';
import 'package:yv_counter/common/snackbar_dialog.dart';
import 'package:yv_counter/l10n/app_localizations.dart';

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
  // Key? _imageKey;
  late ImageFileHandler imageFileHandler;
  Uint8List? _imageData;

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
        final imageData = await pickedFile.readAsBytes();
        setState(() {
          _imageData = imageData;
        });
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
    final croppedFile = await ic.ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        ic.AndroidUiSettings(
          // toolbarTitle: 'Cropper',
          toolbarColor: toolbarColor,
          toolbarWidgetColor: toolbarWidgetColor,
          initAspectRatio: ic.CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            ic.CropAspectRatioPreset.square,
          ],
        ),
        ic.IOSUiSettings(
          aspectRatioPickerButtonHidden: true,
          // title: 'Cropper',
          cropStyle: ic.CropStyle.circle,
          aspectRatioPresets: [
            ic.CropAspectRatioPreset.square,
          ],
        ),
        ic.WebUiSettings(
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
    await _saveImage(path: filePath);
  }

  Future<void> _saveImage({String? path, Uint8List? data}) async {
    final File? image;
    if (path != null) {
      image = await imageFileHandler.saveImage(path, widget.id);
    } else if (data != null) {
      image = await imageFileHandler.saveImageData(data, widget.id);
    } else {
      image = null;
      Future.error(Exception('Can not create image'));
    }
    setState(() {
      _image = image;
      // _imageKey = UniqueKey();
      _imageData = null;
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

  final _cropController = CropController();

  Widget _cropImageWidget(Uint8List imageData) {
    return Crop(
      image: imageData,
      controller: _cropController,
      onCropped: (result) async {
        switch (result) {
          case CropSuccess(:final croppedImage):
            await _saveImage(data: croppedImage);
          case CropFailure():
            debugPrint('Image crop error: $result');
        }
      },
      aspectRatio: 1,

      /*
    initialRectBuilder: InitialRectBuilder.withBuilder((viewportRect, imageRect) {
      return Rect.fromLTRB(
        viewportRect.left + 24,
        viewportRect.top + 32,
        viewportRect.right - 24,
        viewportRect.bottom - 32,
      );
    }),
    */
      /*
    initialRectBuilder: InitialRectBuilder.withArea(
      ImageBasedRect.fromLTWH(240, 212, 800, 600),
    ),
    */
      initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
        size: 1,
        aspectRatio: 1,
      ),

      /*
    withCircleUi: true,
    baseColor: Colors.blue.shade900,
    maskColor: Colors.white.withAlpha(100),
    overlayBuilder: (context, rect) {
      return CustomPaint(painter: MyPainter(rect));
    },
    */

      progressIndicator: const CircularProgressIndicator(),
      // radius: 20,

      /*
      onMoved: (oldRect, newRect) {
        // do something with current crop rect.
      },
      onImageMoved: (newImageRect) {
        // do something with current image rect.
      },
      onStatusChanged: (status) {
        // do something with current CropStatus
      },
      willUpdateScale: (newScale) {
        // if returning false, scaling will be canceled
        return newScale < 5;
      },
      cornerDotBuilder: (size, edgeAlignment) =>
          const DotControl(color: Colors.blue),
      */

      clipBehavior: Clip.none,
      interactive: true,
      fixCropRect: true,

      // formatDetector: (image) {},
      // imageCropper: myCustomImageCropper,
      // imageParser: (image, {format}) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = _names();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.familyMemberDetails),
        actions: [
          if (_imageData != null)
            IconButton(
              icon: Icon(Icons.done_outline),
              onPressed: () {
                _cropController.crop();
              },
            ),
        ],
      ),
      body: _imageData != null
          ? _cropImageWidget(_imageData!)
          : Center(
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
                            // key: _imageKey,
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
                      icon:
                          Icon(Icons.upload, size: _getMinFromWidthAndHeight()),
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
