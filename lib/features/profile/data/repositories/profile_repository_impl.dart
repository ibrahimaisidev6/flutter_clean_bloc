// features/profile/data/repositories/profile_repository_impl.dart
import 'package:payment_app/core/network/network_info.dart';
import 'package:payment_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:payment_app/features/profile/data/models/user_profile.dart';
import 'package:payment_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<UserProfile> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.getProfile();
        return profile;
      } catch (e) {
        throw Exception('Failed to fetch profile: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateProfile(profile);
      } catch (e) {
        throw Exception('Failed to update profile: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}