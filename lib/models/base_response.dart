class BaseResponse {
  BaseResponse({
    this.error,
    this.msg,
    this.threadId,
    this.code,
    this.index,
    this.version,
  });

  final bool? error;
  final String? msg;
  final String? threadId;
  final int? code;
  final int? index;
  final String? version;

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      error: json['error'] as bool?,
      msg: json['msg'] as String?,
      threadId: json['thread_id'] as String?,
      code: json['code'] as int?,
      index: json['index'] as int?,
      version: json['version'] as String?,
    );
  }
}
