// profile_event.dart
import '../../data/models/user_profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserProfile profile;
  
  UpdateProfile(this.profile);
}