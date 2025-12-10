part of 'promo_cubit.dart';

enum PromoStatus {
  idle,
  loading,
  success,
  failure,
  coldStart,
  submittingPreference,
  refreshing,
}

class PromoState extends Equatable {
  final PromoStatus status;
  final List<Recommendation> recommendations;
  final List<Product> bestDeals;
  final String? selectedPreference;
  final String? error;

  const PromoState({
    this.status = PromoStatus.idle,
    this.recommendations = const [],
    this.bestDeals = const [],
    this.selectedPreference,
    this.error,
  });

  PromoState copyWith({
    PromoStatus? status,
    List<Recommendation>? recommendations,
    List<Product>? bestDeals,
    String? selectedPreference,
    String? error,
  }) {
    return PromoState(
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      bestDeals: bestDeals ?? this.bestDeals,
      selectedPreference: selectedPreference ?? this.selectedPreference,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recommendations,
        bestDeals,
        selectedPreference,
        error,
      ];
}
