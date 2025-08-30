// features/profile/domain/usecases/update_profile_usecase.dart
import '../repositories/profile_repository.dart';
import '../../data/models/user_profile.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    return await repository.updateProfile(profile);
  }
}