import 'package:telQ_mobile/core/error/exception.dart';
import 'package:telQ_mobile/core/error/failure.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/promo_repository.dart';
import '../datasources/promo_remote_data_source.dart';

class PromoRepositoryImpl implements PromoRepository {
  final PromoRemoteDataSource remote;
  PromoRepositoryImpl(this.remote);

  @override
  Future<List<Recommendation>> getRecommendations(String customerId) async {
    try {
      final dtos = await remote.getRecommendations(customerId);
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
  Future<List<Product>> getBestDeals() async {
    try {
      final dtos = await remote.getBestDeals();
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
  Future<void> submitColdStart({
    required String customerId,
    required String preference,
  }) async {
    try {
      await remote.submitColdStart(customerId: customerId, preference: preference);
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> triggerPipeline(String customerId) async {
    try {
      await remote.triggerPipeline(customerId);
    } on ConnectionException catch (e) {
      throw ConnectionFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }
}
