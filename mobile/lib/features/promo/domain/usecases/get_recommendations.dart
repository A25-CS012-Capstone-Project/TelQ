import '../entities/recommendation.dart';
import '../repositories/promo_repository.dart';

class GetRecommendations {
  final PromoRepository repository;
  GetRecommendations(this.repository);

  Future<List<Recommendation>> call(String customerId) {
    return repository.getRecommendations(customerId);
  }
}
