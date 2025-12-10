import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:telq_mobile/features/onboarding/model/onboarding_product.dart';

class OnboardingRepository {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    
    // Windows, macOS, Linux desktop
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://127.0.0.1:5000/api/v1';
    }
    
    // Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    
    // iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost:5000/api/v1';
    }
    
    return 'http://localhost:5000/api/v1';
  }

  /// ambil best deal products
  Future<List<OnboardingProduct>> fetchBestDeals() async {
    try {
      print('Fetching best deals from: $_baseUrl/products/best-deal');
      final response = await http.get(
        Uri.parse('$_baseUrl/products/best-deal'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => OnboardingProduct.fromJson(e)).toList();
      }
      print('Best deals response: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching best deals: $e');
      return [];
    }
  }

  /// ambil filtered products sesuai preferensi user (biar kaya web)
  Future<List<OnboardingProduct>> fetchProductsByPreference(String preference) async {
    try {
      print('Fetching filtered products from: $_baseUrl/products/filter');
      final response = await http.post(
        Uri.parse('$_baseUrl/products/filter'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'preference': preference}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> products = data is List ? data : (data['products'] ?? []);
        return products.map((e) => OnboardingProduct.fromJson(e)).toList();
      }
      print('Filter response: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching filtered products: $e');
      return [];
    }
  }
}