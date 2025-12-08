import '../repositories/promo_repository.dart';

class SubmitColdStart {
  final PromoRepository repository;
  SubmitColdStart(this.repository);

  Future<void> call({required String customerId, required String preference}) {
    return repository.submitColdStart(customerId: customerId, preference: preference);
  }
}
