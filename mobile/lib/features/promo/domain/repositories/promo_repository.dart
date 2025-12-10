import '../../../product/domain/entities/product.dart';
import '../entities/recommendation.dart';

abstract class PromoRepository {
  /// Get AI-powered personal recommendations for a customer
  Future<List<Recommendation>> getRecommendations(String customerId);

  /// Get best-selling products (popular deals)
  Future<List<Product>> getBestDeals();

  /// Submit cold-start preference for new users
  Future<void> submitColdStart({
    required String customerId,
    required String preference,
  });

  /// Trigger pipeline to update user profile after purchase
  Future<void> triggerPipeline(String customerId);

  /// Simulate a purchase (records to DB)
  Future<void> simulatePurchase({
    required String customerId,
    required int productId,
  });
}
