import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file/memory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yv_counter/common/logger.dart';
import 'package:yv_counter/data_model/user.dart';
import 'package:yv_counter/generated/server_client_id.dart';

class GoogleDrive {
  static const _scopes = [ga.DriveApi.driveAppdataScope];
  static const _folderMimeType = "application/vnd.google-apps.folder";
  static const _appDataFolderId = "appDataFolder";
  static const malasFileName = "malas";
  static String fileName = malasFileName;

  /*
  Code: add at top-level (e.g., near app startup)
  const String kServerClientId = String.fromEnvironment('SERVER_CLIENT_ID', defaultValue: '');
  final drive = GoogleDrive(serverClientId: kServerClientId);

  Run locally:
  flutter run --dart-define=SERVER_CLIENT_ID="YOUR_CLIENT_ID"
  */
  String? serverClientId;
  late final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _account;

  GoogleDrive({this.serverClientId}) {
    if (serverClientId == null || serverClientId!.isEmpty) {
      serverClientId = kServerClientId;
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
        dLog("App data deleted successfully.");
      } else {
        const error = "App data not available.";
        return Future.error(error);
      }
    } else {
      const error = "User not logged in.";
      return Future.error(error);
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

  Future<File> downloadGoogleDriveFile() async {
    var driveApi = await _getDriveApi();
    if (driveApi == null) {
      const error = "Sign In Error";
      dLog(error);
      return Future.error(error);
    } else {
      final fileId = await _getFileId(driveApi);
      return _downloadFileFromGoogleDrive(fileId, fileName, driveApi);
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
      dLog("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      dLog(e.toString());
      return null;
    }
  }

  Future<User?> getUser() async {
    dLog("getUser");
    if (_account != null) {
      final GoogleSignInAccount user = _account!;
      await _printSignInMetaData(user);
      return User(user.displayName, user.email, user.id);
    }

    // Check if there's a stored email (local persistence)
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_signedInEmailKey);
    if (storedEmail != null) {
      final storedName = prefs.getString(_signedInNameKey) ?? '';
      dLog("Returning user from storage: $storedName, $storedEmail");
      // Return user object from stored state with both name and email
      return User(
        storedName.isEmpty ? null : storedName,
        storedEmail,
        storedEmail,
      );
    }

    return null;
  }

  Future<void> initializeGoogleSignIn() async {
    try {
      // If serverClientId is not set yet, try to fetch it from the platform
      if ((serverClientId == null || serverClientId!.isEmpty) &&
          (Platform.isAndroid || Platform.isIOS)) {
        try {
          final channel = MethodChannel('yv_counter/config');
          final id = await channel.invokeMethod<String>('getServerClientId');
          dLog('platform fetch serverClientId: $id');
          if (id != null && id.isNotEmpty) serverClientId = id;
        } catch (e) {
          dLog('platform fetch serverClientId failed: $e');
        }
      }

      await _googleSignIn.initialize(serverClientId: serverClientId);
    } catch (error) {
      dLog('initialize error: $error');
      return Future.error(error);
    }
  }

  static const _signedInEmailKey = 'gd_signed_in_email';
  static const _signedInNameKey = 'gd_signed_in_name';

  Future<void> signIn() async {
    try {
      dLog("signIn");
      if (_googleSignIn.supportsAuthenticate()) {
        _account = await _googleSignIn.authenticate(scopeHint: _scopes);
        // Store sign-in state locally for persistence
        if (_account != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_signedInEmailKey, _account!.email);
          await prefs.setString(_signedInNameKey, _account!.displayName ?? '');
          dLog("Stored signed-in: ${_account!.email}, ${_account!.displayName}");
        }
      }
    } catch (error) {
      dLog("signIn error: $error");
      return Future.error(error);
    }
  }

  Future<void> signInSilently() async {
    try {
      dLog("signInSilently");

      // First, try to restore from SharedPreferences (local persistence)
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString(_signedInEmailKey);

      if (storedEmail != null) {
        dLog("Found stored sign-in email: $storedEmail");
        // Try to get the account from plugin's cache
        _account ??= await _googleSignIn.attemptLightweightAuthentication();

        // If still null, at least mark as expected to be signed in
        // (user will be prompted to authenticate when accessing Drive)
        if (_account == null) {
          dLog("No cached account for stored email: $storedEmail");
          // We'll attempt authentication when actually needed (_getDriveApi)
        }
      } else {
        // No stored email, do normal silent sign-in attempt
        dLog("No stored sign-in state, attempting lightweight auth");
        _account ??= await _googleSignIn.attemptLightweightAuthentication();
      }
    } catch (error) {
      dLog("signInSilently error: $error");
      // Don't propagate - silent sign-in failing is expected on first launch
    }
  }

  Future<void> signOut() async {
    dLog("signOut");
    // Clear local persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signedInEmailKey);
    await prefs.remove(_signedInNameKey);

    await _googleSignIn.signOut();
    _account = null;
  }

  Future<void> uploadFileToGoogleDrive(File file) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      const error = "Sign In Error";
      dLog(error);
      return Future.error(error);
    } else {
      ga.File fileToUpload = ga.File();
      try {
        final fileId = await _getFileId(driveApi);
        dLog("Update file");
        // final uploadedFile =
        await driveApi.files.update(
          fileToUpload,
          fileId,
          uploadMedia: ga.Media(file.openRead(), await file.length()),
        );
        // _printFileMetaData(uploadedFile);
      } catch (error) {
        dLog(error.toString());
        fileToUpload.parents = [_appDataFolderId];
        fileToUpload.name = fileName;
        dLog("Create file");
        try {
          // final uploadedFile =
          await driveApi.files.create(
            fileToUpload,
            uploadMedia: ga.Media(file.openRead(), await file.length()),
          );
          // _printFileMetaData(uploadedFile);
        } catch (error) {
          dLog(error.toString());
          return Future.error(error);
        }
      }
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
          dLog("$fileName downloaded.");
          final file = MemoryFileSystem().file(fileName);
          await file.writeAsBytes(dataStore);
          completer.complete(file);
        },
        onError: (error) {
          dLog("downloadGoogleDriveFile Error: $error");
          completer.completeError(error);
        },
      );
      return completer.future;
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<ga.DriveApi?> _getDriveApi() async {
    dLog("_getDriveApi");

    // Attempt sign-in if not already signed in
    if (_account == null) {
      dLog("User not signed in, attempting sign-in");
      await signIn();
    }

    // Verify we have an account after sign-in attempt
    if (_account == null) {
      dLog("Sign in failed - account still null.");
      return null;
    }

    // Get authorization (authorizeScopes either succeeds or throws)
    final authorization = await _account!.authorizationClient.authorizeScopes(
      _scopes,
    );

    final authClient = authorization.authClient(scopes: _scopes);
    return ga.DriveApi(authClient);
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
        dLog(error);
        return Future.error(error);
      } else {
        return fileId;
      }
    } catch (error) {
      dLog("_getFileId error: $error");
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

  Future<void> _printSignInMetaData(GoogleSignInAccount account) async {
    if (!kDebugMode) return;
    dLog("supportsAuthenticate: ${_googleSignIn.supportsAuthenticate()}");
    dLog("User: $account");
    final auth = account.authentication;
    dLog("idToken: ${auth.idToken}");
  }

  /// Create a GoogleDrive instance reading `SERVER_CLIENT_ID` from the
  /// Android BuildConfig via a platform channel. Returns an instance with
  /// `serverClientId` set when available.
  static Future<GoogleDrive> createFromPlatform() async {
    // Prefer the generated constant (synchronous) to avoid platform channel race.
    if (kServerClientId.isNotEmpty) {
      dLog('createFromPlatform using generated kServerClientId');
      return GoogleDrive(serverClientId: kServerClientId);
    }
    try {
      final channel = MethodChannel('yv_counter/config');
      final id = await channel.invokeMethod<String>('getServerClientId');
      dLog('createFromPlatform got serverClientId');
      if (id == null || id.isEmpty) {
        return GoogleDrive();
      }
      return GoogleDrive(serverClientId: id);
    } catch (error) {
      dLog('createFromPlatform error: $error');
      return GoogleDrive();
    }
  }

  /*
  void _printFileMetaData(ga.File file) {
    dLog(file.id);
    dLog(file.name);
    dLog(file.mimeType);
  }
  */
}
