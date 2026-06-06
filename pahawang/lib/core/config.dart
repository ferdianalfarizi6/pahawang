import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum AppEnvironment {
  emulator,
  physicalDevice,
  localhost,
  production,
}

class AppConfig {
  // === CONFIGURATION AREA ===
  // 1. Tulis IP Local Komputer Anda (diperlukan jika menggunakan HP Fisik via WiFi)
  //    Cara cek IP di Windows cmd: ipconfig (lihat IPv4 Address)
  static const String devLocalIp = '192.168.1.13'; 

  // 2. Base URL untuk Production/Staging server (jika sudah dideploy online)
  static const String productionBaseUrl = 'https://api.pahawangtourism.com/api';
  // ==========================

  static String _resolvedHost = 'localhost';
  static bool _hasResolved = false;

  /// Dynamic API host resolver.
  /// Pings candidates (localhost, emulator gateway, local PC IP) in parallel 
  /// and caches the fastest reachable backend server host.
  static Future<void> resolveBaseUrl() async {
    if (_hasResolved) return;

    if (kIsWeb) {
      _resolvedHost = 'localhost';
      _hasResolved = true;
      debugPrint('⚡ Auto-resolved API Host for Web: $_resolvedHost');
      return;
    }

    final candidates = [
      'localhost',
      if (defaultTargetPlatform == TargetPlatform.android) '10.0.2.2',
      if (devLocalIp.isNotEmpty) devLocalIp,
    ];

    try {
      final List<Future<String>> tasks = candidates.map((host) async {
        // Ping the profile endpoint as a health check
        final response = await http.get(Uri.parse('http://$host:3000/api/auth/profile'))
            .timeout(const Duration(milliseconds: 1200));
        // Any HTTP response indicates that the server is alive and reachable
        return host;
      }).toList();

      final winningHost = await Future.any(tasks);
      _resolvedHost = winningHost;
      _hasResolved = true;
      debugPrint('⚡ Auto-resolved API Host: $_resolvedHost');
    } catch (_) {
      // Fallback defaults if no candidate responds
      if (defaultTargetPlatform == TargetPlatform.android) {
        _resolvedHost = '10.0.2.2';
      } else {
        _resolvedHost = 'localhost';
      }
      _hasResolved = true;
      debugPrint('⚠️ Auto-resolution failed, falling back to: $_resolvedHost');
    }
  }

  static String get baseUrl {
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    return 'http://$_resolvedHost:3000/api';
  }
}
