// features/profile/data/datasources/profile_remote_data_source.dart
import 'package:payment_app/core/network/dio_client.dart';
import 'package:payment_app/features/profile/data/models/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<void> updateProfile(UserProfile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await dioClient.get('/profile');
      return UserProfile.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch profile from server: $e');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await dioClient.put('/profile', data: profile.toJson());
    } catch (e) {
      throw Exception('Failed to update profile on server: $e');
    }
  }
}