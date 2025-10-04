import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yv_counter/data_model/user.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file/memory.dart';

class GoogleDrive {
  static const _scopes = [ga.DriveApi.driveAppdataScope];
  static const _folderMimeType = "application/vnd.google-apps.folder";
  static const _appDataFolderId = "appDataFolder";
  static const malasFileName = "malas";
  static String fileName = malasFileName;

  final _googleSignIn = GoogleSignIn.instance; // standard(scopes: _scopes);
  GoogleSignInAccount? _account;

  Future<void> initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (error) {
      debugPrint('initialize error: $error');
      Future.error(error);
    }
  }

  Future<void> signIn() async {
    try {
      debugPrint("signIn");
      await _googleSignIn.initialize();
      if (_googleSignIn.supportsAuthenticate()) {
        _account =
            await _googleSignIn.attemptLightweightAuthentication() ??
            await _googleSignIn.authenticate(scopeHint: _scopes);
      } else {
        /*
        // For web, you can use the renderButton method to display a sign-in button.
        if (kIsWeb)
          web.renderButton()
         */
      }
    } catch (error) {
      debugPrint("signIn error: $error");
      Future.error(error);
    }
  }

  Future<void> signInSilently() async {
    try {
      debugPrint("signInSilently");
      _account ??= await _googleSignIn.attemptLightweightAuthentication();
    } catch (error) {
      debugPrint("signInSilently error: $error");
      Future.error(error);
    }
  }

  Future<void> signOut() async {
    debugPrint("signOut");
    // await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    _account = null;
  }

  Future<User?> getUser() async {
    debugPrint("getUser");
    if (_account != null) {
      final GoogleSignInAccount user = _account!;
      await _printSignInMetaData(user);
      return User(user.displayName, user.email, user.id);
    } else {
      return null;
    }
  }

  // Get Drive Api
  Future<ga.DriveApi?> _getDriveApi() async {
    debugPrint("_getDriveApi");
    if (_account == null) {
      debugPrint("User not signed in.");
      await signIn();
    }
    final authorization = await _account?.authorizationClient.authorizeScopes(
      _scopes,
    );
    final authClient = authorization?.authClient(scopes: _scopes);
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

  Future<List<File>> downloadAppDataFolderFiles() async {
    ga.DriveApi? driveApi = await _getDriveApi();
    if (driveApi != null) {
      final filesList = await driveApi.files.list(spaces: _appDataFolderId);
      final files = filesList.files;
      final List<File> downloadedFiles = [];
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          // _printFileMetaData(file);
          final fileId = file.id;
          final fileName = file.name;
          if (fileId != null && fileName != null) {
            final downloadedFile = await _downloadFileFromGoogleDrive(
              fileId,
              fileName,
              driveApi,
            );
            downloadedFiles.add(downloadedFile);
          }
        }
        return downloadedFiles;
      } else {
        const error = "No files available.";
        return Future.error(error);
      }
    } else {
      const error = "User not logged in.";
      return Future.error(error);
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
        const error = "App data not available.";
        return Future.error(error);
      }
    } else {
      const error = "User not logged in.";
      return Future.error(error);
    }
  }

  Future<void> uploadFileToGoogleDrive(File file) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      const error = "Sign In Error";
      debugPrint(error);
      return Future.error(error);
    } else {
      ga.File fileToUpload = ga.File();
      try {
        final fileId = await _getFileId(driveApi);
        debugPrint("Update file");
        // final uploadedFile =
        await driveApi.files.update(
          fileToUpload,
          fileId,
          uploadMedia: ga.Media(file.openRead(), await file.length()),
        );
        // _printFileMetaData(uploadedFile);
      } catch (error) {
        debugPrint(error.toString());
        fileToUpload.parents = [_appDataFolderId];
        fileToUpload.name = fileName;
        debugPrint("Create file");
        try {
          // final uploadedFile =
          await driveApi.files.create(
            fileToUpload,
            uploadMedia: ga.Media(file.openRead(), await file.length()),
          );
          // _printFileMetaData(uploadedFile);
        } catch (error) {
          debugPrint(error.toString());
          return Future.error(error);
        }
      }
    }
  }

  Future<File> downloadGoogleDriveFile() async {
    var driveApi = await _getDriveApi();
    if (driveApi == null) {
      const error = "Sign In Error";
      debugPrint(error);
      return Future.error(error);
    } else {
      final fileId = await _getFileId(driveApi);
      return _downloadFileFromGoogleDrive(fileId, fileName, driveApi);
    }
  }

  Future<File> _downloadFileFromGoogleDrive(
    String fileId,
    String fileName,
    ga.DriveApi driveApi,
  ) async {
    try {
      ga.Media file =
          await driveApi.files.get(
                fileId,
                downloadOptions: ga.DownloadOptions.fullMedia,
              )
              as ga.Media;
      List<int> dataStore = [];
      final completer = Completer<File>();
      file.stream.listen(
        (data) {
          dataStore.insertAll(dataStore.length, data);
        },
        onDone: () async {
          debugPrint("$fileName downloaded.");
          final file = MemoryFileSystem().file(fileName);
          await file.writeAsBytes(dataStore);
          completer.complete(file);
        },
        onError: (error) {
          debugPrint("downloadGoogleDriveFile Error: $error");
          completer.completeError(error);
        },
      );
      return completer.future;
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<String?> _getFolderIdIfExists(
    ga.DriveApi driveApi,
    String folderName,
  ) async {
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

  Future<String> _getFileId(ga.DriveApi driveApi) async {
    try {
      final found = await driveApi.files.list(
        q: "'$_appDataFolderId' in parents and name = '$fileName'",
        spaces: _appDataFolderId,
        $fields: "files(id)",
      );
      final fileId = found.files?.first.id;
      if (fileId == null || fileId.isEmpty) {
        const error = "File not found";
        debugPrint(error);
        return Future.error(error);
      } else {
        return fileId;
      }
    } catch (error) {
      debugPrint("_getFileId error: $error");
      return Future.error(error);
    }
  }

  Future<void> _printSignInMetaData(GoogleSignInAccount account) async {
    debugPrint("supportsAuthenticate: ${_googleSignIn.supportsAuthenticate()}");
    debugPrint("User: $account");
    final auth = account.authentication;
    debugPrint("idToken: ${auth.idToken}");
  }

  /*
  void _printFileMetaData(ga.File file) {
    debugPrint(file.id);
    debugPrint(file.name);
    debugPrint(file.mimeType);
  }
  */
}
