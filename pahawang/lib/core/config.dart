import 'dart:io';

class AppConfig {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        // Android Emulator loops back to development host machine on 10.0.2.2
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {
      // Fallback for platforms where Platform.isAndroid throws (e.g. web)
    }
    return 'http://localhost:3000/api';
  }
}
