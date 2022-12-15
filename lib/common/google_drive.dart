import 'dart:async';
import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:yv_counter/data_model/user.dart';

class GoogleDrive {
  static const _scopes = [ga.DriveApi.driveAppdataScope];
  static const _folderMimeType = "application/vnd.google-apps.folder";
  static const _appDataFolderId = "appDataFolder";
  static const _fileName = "malas";

  final _googleSignIn = GoogleSignIn.standard(scopes: _scopes);

  Future<void> signIn() async {
    try {
      debugPrint("signIn");
      var account = _googleSignIn.currentUser;
      account ??=
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    } catch (error) {
      debugPrint("signIn error: $error");
    }
  }

  Future<void> signInSilently() async {
    try {
      debugPrint("signInSilently");
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
    } catch (error) {
      debugPrint("signIn error: $error");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Future<User?> getUser() async {
    debugPrint("getUser");
    final user = _googleSignIn.currentUser;
    if (user != null) {
      await _printSignInMetaData(user);
      return User(user.displayName, user.email, user.id);
    } else {
      return null;
    }
  }

  // Get Drive Api
  Future<ga.DriveApi?> _getDriveApi() async {
    debugPrint("_getDriveApi");
    await signIn();
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
  Future<String?> getFolderId(ga.DriveApi driveApi, String folderName) async {
    try {
      final folderId = await _getFolderIdIfExists(driveApi, folderName);
      if (folderId != null) {
        return folderId;
      }
      // Create a folder
      ga.File folder = ga.File();
      folder.name = folderName;
      folder.mimeType = _folderMimeType;
      final folderCreation = await driveApi.files.create(folder);
      debugPrint("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> getAppDataFolderFileList(ga.DriveApi driveApi) async {
    final filesList = await driveApi.files.list(spaces: _appDataFolderId);
    final files = filesList.files;
    if (files != null) {
      for (final file in files) {
        _printFileMetaData(file);
      }
    }
  }

  Future<void> deleteAppDataFolderFiles() async {
    ga.DriveApi? driveApi = await _getDriveApi();
    if (driveApi != null) {
      final filesList = await driveApi.files.list(spaces: _appDataFolderId);
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
        fileToUpload.parents = [_appDataFolderId];
        fileToUpload.name = _fileName;
        debugPrint("Create file");
        final uploadedFile = await driveApi.files.create(fileToUpload,
            uploadMedia: ga.Media(file.openRead(), file.lengthSync()));
        _printFileMetaData(uploadedFile);
      }
    }
  }

  Future<File?> downloadGoogleDriveFile() async {
    var driveApi = await _getDriveApi();
    if (driveApi == null) {
      debugPrint("Sign-in download first Error");
    } else {
      final fileId = await _getFileId(driveApi);
      if (fileId != null) {
        ga.Media file = await driveApi.files.get(fileId,
            downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media;
        List<int> dataStore = [];
        final completer = Completer<File>();
        file.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () async {
          debugPrint("File downloaded.");
          final file = MemoryFileSystem().file(_fileName);
          await file.writeAsBytes(dataStore);
          completer.complete(file);
        }, onError: (error) {
          debugPrint("downloadGoogleDriveFile Error: $error");
          completer.completeError(error);
        });
        return completer.future;
      }
    }
    return null;
  }

  Future<String?> _getFolderIdIfExists(
      ga.DriveApi driveApi, String folderName) async {
    final found = await driveApi.files.list(
      q: "mimeType = '$_folderMimeType' and name = '$folderName'",
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
        q: "'$_appDataFolderId' in parents and name = '$_fileName'",
        spaces: _appDataFolderId,
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

  Future<void> _printSignInMetaData(GoogleSignInAccount account) async {
    debugPrint("isSignedIn: ${await _googleSignIn.isSignedIn()}");
    debugPrint("User: $account");
    final auth = await account.authentication;
    debugPrint("accessToken: ${auth.accessToken}");
  }

  void _printFileMetaData(ga.File file) {
    debugPrint(file.id);
    debugPrint(file.name);
    debugPrint(file.mimeType);
  }
}
