import 'package:payment_app/features/profile/data/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile); // exemple
}