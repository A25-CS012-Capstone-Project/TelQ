part of 'profile_cubit.dart';

enum ProfileStatus { idle, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final List<PurchaseHistory> filteredHistory;
  final String? selectedCategory;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.idle,
    this.profile,
    this.filteredHistory = const [],
    this.selectedCategory,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<PurchaseHistory>? filteredHistory,
    String? selectedCategory,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      selectedCategory: selectedCategory,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, profile, filteredHistory, selectedCategory, error];
}
