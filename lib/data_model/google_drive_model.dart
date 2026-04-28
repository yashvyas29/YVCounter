import 'package:flutter/material.dart';
import 'package:yv_counter/common/google_drive.dart';
import 'package:yv_counter/data_model/user.dart';
import 'package:yv_counter/common/logger.dart';

class GoogleDriveModel extends ChangeNotifier {
  late final GoogleDrive _drive;
  User? _currentUser;
  bool _initialized = false;

  GoogleDriveModel._();

  /// Creates the model and begins silent sign-in in the background.
  static Future<GoogleDriveModel> getInstance() async {
    final model = GoogleDriveModel._();
    model._drive = await GoogleDrive.createFromPlatform();
    // Fire-and-forget — notifies listeners when sign-in completes.
    model.initialize();
    return model;
  }

  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Exposes the underlying [GoogleDrive] for backup/restore operations.
  GoogleDrive get drive => _drive;

  /// Silently attempts sign-in and updates [currentUser]. Idempotent.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _drive.initializeGoogleSignIn();
      await _drive.signInSilently();
      _currentUser = await _drive.getUser();
      notifyListeners();
    } catch (error) {
      dLog('GoogleDriveModel.initialize: $error');
    }
  }

  Future<void> signIn() async {
    await _drive.signIn();
    _currentUser = await _drive.getUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _drive.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
