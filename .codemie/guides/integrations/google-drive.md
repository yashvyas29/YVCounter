# Google Drive Integration Guide

**Project**: YVCounter
**Integration**: Google Sign-In + Google Drive API (appDataFolder)
**Purpose**: Cloud backup and restore of mala/jap data
**Main File**: `lib/common/google_drive.dart`

---

## Overview

The app uses Google Sign-In for OAuth and the Drive API to backup/restore JSON data files to the user's private `appDataFolder` (not visible in Drive UI).

**Packages used:**
- `google_sign_in: ^7.2.0`
- `googleapis: ^16.0.0` (Drive API)
- `extension_google_sign_in_as_googleapis_auth: ^3.0.0`

---

## Setup & Configuration

### Server Client ID

The OAuth server client ID is stored in a generated file:

```dart
// lib/generated/server_client_id.dart
const String kServerClientId = '...'; // populated at build time
```

Passed to `GoogleDrive` at construction and to `GoogleSignIn.initialize()`.

**To run locally with a real client ID:**
```bash
flutter run --dart-define=SERVER_CLIENT_ID="YOUR_CLIENT_ID"
```

### Scopes

```dart
// Source: lib/common/google_drive.dart:14
static const _scopes = [ga.DriveApi.driveAppdataScope];
```

Only `appdata` scope is requested — data is sandboxed to the app.

---

## Authentication Flow

```dart
// Source: lib/common/google_drive.dart:160-178
Future<void> signIn() async {
  await _googleSignIn.initialize(serverClientId: serverClientId);
  if (_googleSignIn.supportsAuthenticate()) {
    _account =
        await _googleSignIn.attemptLightweightAuthentication() ??
        await _googleSignIn.authenticate(scopeHint: _scopes);
  }
}
```

**Flow**:
1. `signIn()` — full interactive sign-in (used on first sign-in or after sign-out)
2. `signInSilently()` — attempts lightweight re-auth without UI
3. `signOut()` — clears `_account`, calls `GoogleSignIn.signOut()`

**Getting Drive API client:**
```dart
// Source: lib/common/google_drive.dart:272-291
Future<ga.DriveApi?> _getDriveApi() async {
  if (_account == null) await signIn();
  if (_account == null) return null;
  final authorization = await _account!.authorizationClient.authorizeScopes(_scopes);
  final authClient = authorization.authClient(scopes: _scopes);
  return ga.DriveApi(authClient);
}
```

---

## File Operations

All files are stored in the Drive `appDataFolder` — invisible to users in Drive UI but accessible by the app.

### Upload (Backup)

```dart
// Source: lib/common/google_drive.dart:198-233
Future<void> uploadFileToGoogleDrive(File file) async {
  final driveApi = await _getDriveApi();
  // Try update first (file exists), fallback to create
  try {
    final fileId = await _getFileId(driveApi!);
    await driveApi.files.update(fileToUpload, fileId,
        uploadMedia: ga.Media(file.openRead(), await file.length()));
  } catch (error) {
    fileToUpload.parents = [_appDataFolderId];
    fileToUpload.name = fileName;
    await driveApi!.files.create(fileToUpload,
        uploadMedia: ga.Media(file.openRead(), await file.length()));
  }
}
```

**Pattern**: Update if file exists, create if not — idempotent backup.

### Download (Restore)

```dart
// Source: lib/common/google_drive.dart:61-89
Future<List<File>> downloadAppDataFolderFiles() async {
  final driveApi = await _getDriveApi();
  final filesList = await driveApi!.files.list(spaces: _appDataFolderId);
  // Downloads all files in appDataFolder to in-memory MemoryFileSystem
}
```

Files are downloaded to `MemoryFileSystem` (in-memory), then parsed by the caller.

### Delete

```dart
Future<void> deleteAppDataFolderFiles() async {
  // Lists and deletes all files in appDataFolder
}
```

---

## File Naming

```dart
// Source: lib/common/google_drive.dart:17-18
static const malasFileName = "malas";
static String fileName = malasFileName; // can be overridden
```

Change `GoogleDrive.fileName` before operations to target a different file.

---

## Error Handling

Service methods use `Future.error(message)` for failures:

```dart
if (_account == null) return Future.error("User not logged in.");
if (files == null || files.isEmpty) return Future.error("No files available.");
```

Callers should use try/catch and display errors via `SnackbarDialog`.

---

## Usage in App

The `GoogleDrive` instance is created via `GoogleDrive.createFromPlatform()` which reads the server client ID from the generated constant or platform channel.

Sign-in state (the `_account`) is held in memory — not persisted. `signInSilently()` is called on app startup to restore session without prompting the user.

---

## Adding New Backup Files

1. Set `GoogleDrive.fileName = 'your_file_name'` before calling upload/download
2. Or subclass / extend `GoogleDrive` with a typed method
3. Restore the filename afterward if sharing an instance

---

## Conventions Summary

| DO | DON'T |
|----|-------|
| Use `createFromPlatform()` to get an instance | Hardcode the server client ID in code |
| Catch `Future.error` from drive methods in UI | Let drive errors propagate uncaught to user |
| Use `appDataFolder` scope only | Request broader Drive scopes |
| Test sign-in on both Android and iOS (different behavior) | Assume identical auth behavior across platforms |

---

## Quick Reference

| Need | Location |
|------|----------|
| Main integration class | `lib/common/google_drive.dart` |
| Server client ID constant | `lib/generated/server_client_id.dart` |
| User data model | `lib/data_model/user.dart` |
| Sign-in call site | `lib/mala_japs/mala_jap_counter_page_state.dart` |
