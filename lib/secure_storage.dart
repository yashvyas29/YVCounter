import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart';

class SecureStorage {
  static const storage = FlutterSecureStorage();

  //Save Credentials
  Future<void> saveCredentials(AccessToken token, String refreshToken) async {
    await storage.write(key: "type", value: token.type);
    await storage.write(key: "data", value: token.data);
    await storage.write(key: "expiry", value: token.expiry.toString());
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  //Get Saved Credentials
  Future<Map<String, dynamic>?> getCredentials() async {
    var result = await storage.readAll();
    if (result.isEmpty) return null;
    return result;
  }

  //Save Backup File Id
  Future<void> saveBackupFileId(String fileId) async {
    await storage.write(key: "backupFileId", value: fileId);
  }

  //Get Backup File Id
  Future<String?> getBackupFileId() async {
    var result = await storage.read(key: "backupFileId");
    return result;
  }

  //Clear Saved Credentials
  Future clear() {
    return storage.deleteAll();
  }
}
