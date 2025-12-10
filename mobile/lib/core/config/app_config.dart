import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
class AppConfig {

  static const bool useEmulator = true;
  
  static const String _lanIP = '10.252.171.122';
  static const int _port = 5000;

  static String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:$_port';
    
    if (!useEmulator) return 'http://$_lanIP:$_port';
    
    // Emulator/Simulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port'; 
    }
    return 'http://localhost:$_port'; 
  }
}
//getter
String get apiBaseUrl => AppConfig.apiBaseUrl;
