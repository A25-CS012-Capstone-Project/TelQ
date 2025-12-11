import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:telq_mobile/core/config/app_config.dart';
import 'package:telq_mobile/features/onboarding/model/onboarding_product.dart';

class OnboardingRepository {
  // Use centralized config - single source of truth!
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/api/v1';

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