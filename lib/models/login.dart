class UserInfo {
  final String id;
  final String type;

  UserInfo({required this.id, required this.type});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'] as String, type: json['type'] as String);
  }
}

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
