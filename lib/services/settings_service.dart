import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _folderKey = 'download_folder';

  static Future<void> saveFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_folderKey, path);
  }

  static Future<String?> getFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_folderKey);
  }
}
