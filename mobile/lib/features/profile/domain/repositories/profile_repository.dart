import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String customerId);
}
