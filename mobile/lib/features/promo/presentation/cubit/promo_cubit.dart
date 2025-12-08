import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telQ_mobile/core/error/failure.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/usecases/get_recommendations.dart';
import '../../domain/usecases/get_best_deals.dart';
import '../../domain/usecases/submit_cold_start.dart';
import '../../domain/usecases/trigger_pipeline.dart';

part 'promo_state.dart';

class PromoCubit extends Cubit<PromoState> {
  final GetRecommendations getRecommendations;
  final GetBestDeals getBestDeals;
  final SubmitColdStart submitColdStart;
  final TriggerPipeline triggerPipeline;

  PromoCubit({
    required this.getRecommendations,
    required this.getBestDeals,
    required this.submitColdStart,
    required this.triggerPipeline,
  }) : super(const PromoState());

  /// Load both recommendations and best deals
  Future<void> loadPromoData(String customerId) async {
    emit(state.copyWith(status: PromoStatus.loading, error: null));
    try {
      // Parallel API calls for better performance using futures
      final recommendationsFuture = getRecommendations(customerId);
      final bestDealsFuture = getBestDeals();
      
      // Await both in parallel
      final recommendations = await recommendationsFuture;
      final bestDeals = await bestDealsFuture;

      if (recommendations.isEmpty) {
        // Cold start - show questionnaire
        emit(state.copyWith(
          status: PromoStatus.coldStart,
          recommendations: [],
          bestDeals: bestDeals,
        ));
      } else {
        emit(state.copyWith(
          status: PromoStatus.success,
          recommendations: recommendations,
          bestDeals: bestDeals,
        ));
      }
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: PromoStatus.failure, error: message));
    }
  }

  /// Submit preference for cold start users
  Future<void> submitPreference(String customerId, String preference) async {
    emit(state.copyWith(
      status: PromoStatus.submittingPreference,
      selectedPreference: preference,
      error: null,
    ));
    try {
      await submitColdStart(customerId: customerId, preference: preference);
      // Reload recommendations after submitting preference
      await loadPromoData(customerId);
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: PromoStatus.failure, error: message));
    }
  }

  /// Refresh recommendations by triggering pipeline
  Future<void> refreshRecommendations(String customerId) async {
    emit(state.copyWith(status: PromoStatus.refreshing, error: null));
    try {
      await triggerPipeline(customerId);
      final recommendations = await getRecommendations(customerId);
      emit(state.copyWith(
        status: PromoStatus.success,
        recommendations: recommendations,
      ));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(status: PromoStatus.failure, error: message));
    }
  }

  /// Load only best deals
  Future<void> loadBestDeals() async {
    try {
      final bestDeals = await getBestDeals();
      emit(state.copyWith(bestDeals: bestDeals));
    } catch (e) {
      // Silent failure for best deals since recommendations are primary
    }
  }
}
