
// features/profile/domain/usecases/get_profile_usecase.dart
import '../repositories/profile_repository.dart';
import '../../data/models/user_profile.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserProfile> call() async {
    return await repository.getProfile();
  }
}