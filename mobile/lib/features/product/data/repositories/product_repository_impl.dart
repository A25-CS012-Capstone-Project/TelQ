import 'package:telQ_mobile/core/error/exception.dart';
import 'package:telQ_mobile/core/error/failure.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl(this.remote);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final dtos = await remote.getAllProducts();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final dtos = await remote.getProductsByCategory(category);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }
}
