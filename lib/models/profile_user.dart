import 'base_response.dart';

class ProfileUserInfo {
  ProfileUserInfo({
    this.token,
    this.id,
    this.name,
    this.remainingDays,
    this.describe,
    this.idcode,
    this.phone,
    this.email,
    this.type,
    this.deviceId,
    this.username,
    this.company,
    this.address,
    this.avatar,
    this.ggid,
    this.avatarStorage,
    this.role,
    this.countBot,
    this.code,
    this.begin,
  });

  final String? token;
  final String? id;
  final String? name;
  final int? remainingDays;
  final String? describe;
  final String? idcode;
  final String? phone;
  final String? email;
  final String? type;
  final String? deviceId;
  final String? username;
  final String? company;
  final String? address;
  final String? avatar;
  final String? ggid;
  final String? avatarStorage;
  final String? role;
  final String? countBot;
  final String? code;
  final bool? begin;

  factory ProfileUserInfo.fromJson(Map<String, dynamic> json) {
    return ProfileUserInfo(
      token: json['token']?.toString(),
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      remainingDays: json['remaining_days'] as int?,
      describe: json['describe']?.toString(),
      idcode: json['idcode']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      type: json['type']?.toString(),
      deviceId: json['device_id']?.toString(),
      username: json['username']?.toString(),
      company: json['company']?.toString(),
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      ggid: json['ggid']?.toString(),
      avatarStorage: json['avatar_storage']?.toString(),
      role: json['role']?.toString(),
      countBot: json['count_bot']?.toString(),
      code: json['code']?.toString(),
      begin: json['begin'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'name': name,
      'remaining_days': remainingDays,
      'describe': describe,
      'idcode': idcode,
      'phone': phone,
      'email': email,
      'type': type,
      'device_id': deviceId,
      'username': username,
      'company': company,
      'address': address,
      'avatar': avatar,
      'ggid': ggid,
      'avatar_storage': avatarStorage,
      'role': role,
      'count_bot': countBot,
      'code': code,
      'begin': begin,
    };
  }

  ProfileUserInfo copyWith({
    String? name,
    String? describe,
    String? avatar,
    String? avatarStorage,
  }) {
    return ProfileUserInfo(
      token: token,
      id: id,
      name: name ?? this.name,
      remainingDays: remainingDays,
      describe: describe ?? this.describe,
      idcode: idcode,
      phone: phone,
      email: email,
      type: type,
      deviceId: deviceId,
      username: username,
      company: company,
      address: address,
      avatar: avatar ?? this.avatar,
      ggid: ggid,
      avatarStorage: avatarStorage ?? this.avatarStorage,
      role: role,
      countBot: countBot,
      code: code,
      begin: begin,
    );
  }
}

class ProfileUser extends BaseResponse {
  ProfileUser({
    super.error,
    super.msg,
    super.threadId,
    super.code,
    super.index,
    super.version,
    required this.data,
    this.token,
    this.accessToken,
  });

  final ProfileUserInfo data;
  final String? token;
  final String? accessToken;

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      error: json['error'] as bool?,
      msg: json['msg'] as String?,
      threadId: json['thread_id'] as String?,
      code: json['code'] as int?,
      index: json['index'] as int?,
      version: json['version'] as String?,
      data: ProfileUserInfo.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      token: json['token']?.toString(),
      accessToken: json['access_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'msg': msg,
      'thread_id': threadId,
      'code': code,
      'index': index,
      'version': version,
      'data': data.toJson(),
      'token': token,
      'access_token': accessToken,
    };
  }

  ProfileUser copyWith({ProfileUserInfo? data}) {
    return ProfileUser(
      error: error,
      msg: msg,
      threadId: threadId,
      code: code,
      index: index,
      version: version,
      data: data ?? this.data,
      token: token,
      accessToken: accessToken,
    );
  }
}
