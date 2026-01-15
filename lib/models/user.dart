class UserInfo {
  final String id;
  final String type;

  UserInfo({required this.id, required this.type});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'] as String, type: json['type'] as String);
  }
}
