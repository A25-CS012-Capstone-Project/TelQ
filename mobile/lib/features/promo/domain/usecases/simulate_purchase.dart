import '../repositories/promo_repository.dart';

class SimulatePurchase {
  final PromoRepository repository;

  SimulatePurchase(this.repository);

  /// Execute purchase simulation
  Future<void> call({
    required String customerId,
    required int productId,
  }) async {
    await repository.simulatePurchase(
      customerId: customerId,
      productId: productId,
    );
  }
}
