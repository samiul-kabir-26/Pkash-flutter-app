import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // Default fallback based on platform.
    // Note: Local Docker/Sail runs on port 80.
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2/api/v1';
    }
    return 'http://localhost/api/v1';
  }
}
