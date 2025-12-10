import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telq_mobile/features/onboarding/domain/onboarding_repository.dart';
import 'package:telq_mobile/features/onboarding/model/onboarding_product.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingCubit({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepository(),
        super(const OnboardingState());

  void pageChanged(int index) {
    emit(state.copyWith(pageIndex: index));
    

    if (index == 2 && state.bestDeals.isEmpty && !state.isLoadingBestDeals) {
      fetchBestDeals();
    }
  }


  Future<void> selectPreference(String preference) async {
    emit(state.copyWith(
      selectedPreference: preference,
      isLoadingFiltered: true,
      error: null,
    ));

    try {
      final products = await _repository.fetchProductsByPreference(preference);
      emit(state.copyWith(
        filteredProducts: products,
        isLoadingFiltered: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingFiltered: false,
        error: 'Failed to load products',
      ));
    }
  }


  Future<void> fetchBestDeals() async {
    emit(state.copyWith(isLoadingBestDeals: true, error: null));

    try {
      final products = await _repository.fetchBestDeals();
      emit(state.copyWith(
        bestDeals: products,
        isLoadingBestDeals: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingBestDeals: false,
        error: 'Failed to load best deals',
      ));
    }
  }

  Future<void> initialize() async {
    await selectPreference('Streaming');
  }
}