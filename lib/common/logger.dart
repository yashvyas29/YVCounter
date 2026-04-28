import 'package:flutter/foundation.dart';

/// Prints [message] to the console only in debug builds.
/// kDebugMode is a compile-time constant, so release builds
/// tree-shake this call entirely.
void dLog(String message) {
  if (kDebugMode) debugPrint(message);
}
