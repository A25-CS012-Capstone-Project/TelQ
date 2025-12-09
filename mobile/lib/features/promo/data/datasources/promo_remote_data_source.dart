import 'dart:convert';
import 'dart:io';

import 'package:telQ_mobile/core/error/exception.dart';
import 'package:telQ_mobile/core/network/api_client.dart';

import '../../../product/data/models/product_dto.dart';
import '../models/recommendation_dto.dart';

abstract class PromoRemoteDataSource {
  /// ini biar kita bisa ngefetch AI buat rekomendasi
  Future<List<RecommendationDto>> getRecommendations(String customerId);

  /// ini biar kita bisa ngefetch produk terlaris
  Future<List<ProductDto>> getBestDeals();

  /// yang ini buat cold start ya guys ya
  Future<void> submitColdStart({
    required String customerId,
    required String preference,
  });

  /// pipeline update (aku cuman ngikutin BE)
  Future<void> triggerPipeline(String customerId);
}

class PromoRemoteDataSourceImpl implements PromoRemoteDataSource {
  final ApiClient api;
  PromoRemoteDataSourceImpl({required this.api});

  @override
  Future<List<RecommendationDto>> getRecommendations(String customerId) async {
    try {
      final resp = await api.post(
        '/api/v1/recommend',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'customer_id': customerId}),
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final status = body['status'] as String?;

        // Handle COLD status 
        if (status == 'COLD') {
          return [];
        }

        // Parse items array for WARM/FALLBACK status
        final items = body['items'] as List<dynamic>? ?? [];
        return items
            .map((json) => RecommendationDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException('Failed to load recommendations', statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }

  @override
  Future<List<ProductDto>> getBestDeals() async {
    try {
      final resp = await api.get('/api/v1/products/best-deal');

      if (resp.statusCode == 200) {
        final List<dynamic> body = jsonDecode(resp.body);
        return body.map((json) => ProductDto.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw ServerException('Failed to load best deals', statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }

  @override
  Future<void> submitColdStart({
    required String customerId,
    required String preference,
  }) async {
    try {
      final resp = await api.post(
        '/api/v1/cold-start',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'preference': preference,
        }),
      );

      if (resp.statusCode != 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>?;
        final message = body?['error']?.toString() ?? 'Failed to submit preference';
        throw ServerException(message, statusCode: resp.statusCode);
      }
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }

  @override
  Future<void> triggerPipeline(String customerId) async {
    try {
      final resp = await api.post(
        '/api/v1/trigger-pipeline',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'customer_id': customerId}),
      );

      if (resp.statusCode != 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>?;
        final message = body?['error']?.toString() ?? 'Pipeline failed';
        throw ServerException(message, statusCode: resp.statusCode);
      }
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }
}
