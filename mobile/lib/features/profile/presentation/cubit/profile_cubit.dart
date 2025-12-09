import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(const ProfileState());

  Future<void> loadProfile(String customerId) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final profile = await repository.getProfile(customerId);
      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        filteredHistory: profile.historyList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void filterHistory(String? category) {
    if (state.profile == null) return;

    final allHistory = state.profile!.historyList;
    
    if (category == null || category == 'All') {
      emit(state.copyWith(
        filteredHistory: allHistory,
        selectedCategory: null,
      ));
    } else {
      final filtered = allHistory.where((h) => 
        h.category.toLowerCase().contains(category.toLowerCase())
      ).toList();
      emit(state.copyWith(
        filteredHistory: filtered,
        selectedCategory: category,
      ));
    }
  }
}
