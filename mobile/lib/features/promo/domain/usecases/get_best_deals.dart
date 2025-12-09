import '../../../product/domain/entities/product.dart';
import '../repositories/promo_repository.dart';

class GetBestDeals {
  final PromoRepository repository;
  GetBestDeals(this.repository);

  Future<List<Product>> call() {
    return repository.getBestDeals();
  }
}
