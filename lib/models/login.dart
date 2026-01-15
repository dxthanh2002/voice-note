import 'user.dart';

class LoginResponse {
  final String accessToken;
  final UserInfo user;

  LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      user: UserInfo.fromJson(json['user']),
    );
  }
}
