import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthResponse {
  @JsonKey(name: 'user')
  final UserModel userModel;

  const AuthResponseModel({
    required this.userModel,
    required super.token,
  }) : super(user: userModel);

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  factory AuthResponseModel.fromEntity(AuthResponse authResponse) {
    return AuthResponseModel(
      userModel: UserModel.fromEntity(authResponse.user),
      token: authResponse.token,
    );
  }

  AuthResponse toEntity() {
    return AuthResponse(
      user: userModel.toEntity(),
      token: token,
    );
  }
}