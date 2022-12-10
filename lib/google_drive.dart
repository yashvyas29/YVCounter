import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:yv_counter/mala.dart';
import 'package:yv_counter/secure_storage.dart';
import 'package:yv_counter/shared_pref.dart';

const _scopes = [ga.DriveApi.driveAppdataScope];

class GoogleDrive {
  final storage = SecureStorage();
  final _googleSignIn = GoogleSignIn.standard(scopes: _scopes);
  GoogleSignInAccount? _account;

  static const folderMimeType = "application/vnd.google-apps.folder";
  static const folderName = "YVCounter";
  static const appDataFolderId = "appDataFolder";

  // static const fileMimeType =
  //     "application/octet-stream";
  static const fileName = "malas";

  Future<void> signIn() async {
    try {
      var account = _googleSignIn.currentUser;
      if (account == null) {
        account = await _googleSignIn.signInSilently();
        if (account == null) {
          _account = await _googleSignIn.signIn();
        } else {
          _account = account;
        }
      } else {
        _account = account;
      }
      debugPrint("Account: $_account");
    } catch (error) {
      debugPrint("signIn error: $error");
    }
  }

  Future<void> signOut() => _googleSignIn.disconnect();

  // Get Drive Api
  Future<ga.DriveApi?> _getDriveApi() async {
    await signIn();
    debugPrint("_getDriveApi isSignedIn: ${await _googleSignIn.isSignedIn()}");
    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient != null) {
      return ga.DriveApi(authClient);
    } else {
      return null;
    }
  }

  // check if the directory forlder is already available in drive , if available return its id
  // if not available create a folder in drive and return id
  //   if not able to create id then it means user authetication has failed
  Future<String?> getFolderId(ga.DriveApi driveApi) async {
    try {
      final folderId = await _getFolderIdIfExists(driveApi);
      if (folderId != null) {
        return folderId;
      }
      // Create a folder
      ga.File folder = ga.File();
      folder.name = folderName;
      folder.mimeType = folderMimeType;
      final folderCreation = await driveApi.files.create(folder);
      debugPrint("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<String?> _getFolderIdIfExists(ga.DriveApi driveApi) async {
    final found = await driveApi.files.list(
      q: "mimeType = '$folderMimeType' and name = '$folderName'",
      $fields: "files(id)",
    );
    final files = found.files;
    if (files == null || files.isEmpty) {
      return null;
    } else {
      return files.first.id;
    }
  }

  Future<String?> _getFileId(ga.DriveApi driveApi) async {
    try {
      final found = await driveApi.files.list(
        q: "'$appDataFolderId' in parents and name = '$fileName'",
        spaces: appDataFolderId,
        $fields: "files(id)",
      );
      final files = found.files;
      if (files == null || files.isEmpty) {
        debugPrint("File not found.");
        return null;
      } else {
        return files.first.id;
      }
    } catch (e) {
      debugPrint("_getFileId error: $e.toString()");
      return null;
    }
  }

  void getAppDataFolderFileList(ga.DriveApi driveApi) async {
    final filesList = await driveApi.files.list(spaces: appDataFolderId);
    final files = filesList.files;
    if (files != null) {
      for (final file in files) {
        _printFileMetaData(file);
      }
    }
  }

  void deleteAppDataFolderFiles() async {
    ga.DriveApi? driveApi = await _getDriveApi();
    if (driveApi != null) {
      final filesList = await driveApi.files.list(spaces: appDataFolderId);
      final files = filesList.files;
      if (files != null) {
        for (final file in files) {
          final fileId = file.id;
          if (fileId != null) {
            driveApi.files.delete(fileId);
          }
        }
        debugPrint("App data deleted successfully.");
      } else {
        debugPrint("App data not available.");
      }
    } else {
      debugPrint("User not logged in.");
    }
  }

  Future<void> uploadFileToGoogleDrive(File file) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      debugPrint("Sign-in upload client Error");
    } else {
      ga.File fileToUpload = ga.File();
      final fileId = await _getFileId(driveApi);
      if (fileId != null) {
        debugPrint("Update file");
        final uploadedFile = await driveApi.files.update(
          fileToUpload,
          fileId,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
        );
        _printFileMetaData(uploadedFile);
      } else {
        fileToUpload.parents = [appDataFolderId];
        fileToUpload.name = fileName;
        debugPrint("Create file");
        final uploadedFile = await driveApi.files.create(fileToUpload,
            uploadMedia: ga.Media(file.openRead(), file.lengthSync()));
        _printFileMetaData(uploadedFile);
      }
    }
  }

  void _printFileMetaData(ga.File file) {
    debugPrint(file.id);
    debugPrint(file.name);
    debugPrint(file.mimeType);
  }

  Future<List<Mala>?> downloadGoogleDriveFile() async {
    var driveApi = await _getDriveApi();
    if (driveApi == null) {
      debugPrint("Sign-in download first Error");
    } else {
      final fileId = await _getFileId(driveApi);
      if (fileId != null) {
        ga.Media file = await driveApi.files.get(fileId,
            downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media;
        List<int> dataStore = [];
        final completer = Completer<List<Mala>>();
        file.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () async {
          debugPrint("File downloaded.");
          final file = MemoryFileSystem().file(fileName);
          await file.writeAsBytes(dataStore);
          final malasString = await file.readAsString();
          debugPrint(malasString);
          final malasJson = json.decode(malasString) as List;
          debugPrint(malasJson.toString());
          final malas = malasJson.map((value) => Mala.fromJson(value)).toList();
          debugPrint(malas.toString());
          SharedPref().saveList(Mala.key, malas);
          completer.complete(malas);
        }, onError: (error) {
          debugPrint("downloadGoogleDriveFile Error: $error");
          completer.completeError(error);
        });
        return completer.future;
      }
    }
    return null;
  }
}
