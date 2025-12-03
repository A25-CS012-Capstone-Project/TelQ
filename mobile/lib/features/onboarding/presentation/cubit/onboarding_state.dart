part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final int pageIndex;
  final String? selectedPreference;
  final List<OnboardingProduct> filteredProducts;
  final List<OnboardingProduct> bestDeals;
  final bool isLoadingFiltered;
  final bool isLoadingBestDeals;
  final String? error;

  const OnboardingState({
    this.pageIndex = 0,
    this.selectedPreference,
    this.filteredProducts = const [],
    this.bestDeals = const [],
    this.isLoadingFiltered = false,
    this.isLoadingBestDeals = false,
    this.error,
  });

  OnboardingState copyWith({
    int? pageIndex,
    String? selectedPreference,
    List<OnboardingProduct>? filteredProducts,
    List<OnboardingProduct>? bestDeals,
    bool? isLoadingFiltered,
    bool? isLoadingBestDeals,
    String? error,
  }) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      selectedPreference: selectedPreference ?? this.selectedPreference,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      bestDeals: bestDeals ?? this.bestDeals,
      isLoadingFiltered: isLoadingFiltered ?? this.isLoadingFiltered,
      isLoadingBestDeals: isLoadingBestDeals ?? this.isLoadingBestDeals,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        pageIndex,
        selectedPreference,
        filteredProducts,
        bestDeals,
        isLoadingFiltered,
        isLoadingBestDeals,
        error,
      ];
}