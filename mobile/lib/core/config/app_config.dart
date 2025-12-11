import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
class AppConfig {
  // ============== PRODUCTION SETTINGS ==============
  // Set to TRUE for deployed API, FALSE for local Docker
  static const bool useProduction = true;
  
  // Deployed Hugging Face Space URL
  static const String _productionUrl = 'https://a25-cs012-telq-app.hf.space';
  
  // ============== LOCAL DEV SETTINGS ==============
  static const bool useEmulator = true;
  static const String _lanIP = '10.252.171.122';
  static const int _port = 5000;

  static String get apiBaseUrl {
    // Use production URL if enabled
    if (useProduction) return _productionUrl;
    
    // Local development fallback
    if (kIsWeb) return 'http://localhost:$_port';
    
    if (!useEmulator) return 'http://$_lanIP:$_port';
    
    // Emulator/Simulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port'; 
    }
    return 'http://localhost:$_port'; 
  }
}

// Global getter
String get apiBaseUrl => AppConfig.apiBaseUrl;
