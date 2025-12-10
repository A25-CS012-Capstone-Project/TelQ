import '../repositories/promo_repository.dart';

class TriggerPipeline {
  final PromoRepository repository;
  TriggerPipeline(this.repository);

  Future<void> call(String customerId) {
    return repository.triggerPipeline(customerId);
  }
}
