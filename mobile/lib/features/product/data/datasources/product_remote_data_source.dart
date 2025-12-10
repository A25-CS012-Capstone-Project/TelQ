import 'dart:convert';
import 'dart:io';

import 'package:telq_mobile/core/error/exception.dart';
import 'package:telq_mobile/core/network/api_client.dart';

import '../models/product_dto.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductDto>> getAllProducts();
  Future<List<ProductDto>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient api;
  ProductRemoteDataSourceImpl({required this.api});

  @override
  Future<List<ProductDto>> getAllProducts() async {
    try {
      final resp = await api.get('/api/v1/products');
      
      if (resp.statusCode == 200) {
        final List<dynamic> body = jsonDecode(resp.body);
        return body.map((json) => ProductDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw ServerException('Failed to load products', statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }

  @override
  Future<List<ProductDto>> getProductsByCategory(String category) async {
    try {
      final resp = await api.get('/api/v1/products?category=$category');
      
      if (resp.statusCode == 200) {
        final List<dynamic> body = jsonDecode(resp.body);
        return body.map((json) => ProductDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw ServerException('Failed to load products', statusCode: resp.statusCode);
    } on SocketException {
      throw ConnectionException();
    } on FormatException {
      throw ServerException('Invalid response format');
    }
  }
}
