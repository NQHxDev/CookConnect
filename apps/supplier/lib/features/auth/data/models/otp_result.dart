class OtpResult {
  final bool isSuccess;
  final int statusCode;
  final String? message;
  final String? verificationToken;
  final int? cooldownSeconds;
  final int? expiresInMinutes;
  final String? error;

  OtpResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.verificationToken,
    this.cooldownSeconds,
    this.expiresInMinutes,
    this.error,
  });

  factory OtpResult.success({
    String? message,
    String? verificationToken,
    int? cooldownSeconds,
    int? expiresInMinutes,
    int statusCode = 200,
  }) {
    return OtpResult(
      isSuccess: true,
      statusCode: statusCode,
      message: message ?? 'Mã xác thực OTP đã được gửi thành công',
      verificationToken: verificationToken,
      cooldownSeconds: cooldownSeconds ?? 60,
      expiresInMinutes: expiresInMinutes ?? 5,
    );
  }

  factory OtpResult.failure({
    required String error,
    int statusCode = 400,
  }) {
    return OtpResult(
      isSuccess: false,
      statusCode: statusCode,
      error: error,
    );
  }

  factory OtpResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final token = data['verificationToken']?.toString() ??
        data['verifyToken']?.toString() ??
        data['token']?.toString() ??
        json['verificationToken']?.toString();

    final isSuccess = json['success'] as bool? ??
        (json['statusCode'] == null || (json['statusCode'] as int) < 400);

    return OtpResult(
      isSuccess: isSuccess,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? (isSuccess ? 200 : 400),
      message: data['message']?.toString() ?? json['message']?.toString(),
      verificationToken: token,
      cooldownSeconds: (data['cooldownSeconds'] as num?)?.toInt() ?? 60,
      expiresInMinutes: (data['expiresInMinutes'] as num?)?.toInt() ?? 5,
      error: isSuccess ? null : (json['error']?.toString() ?? json['message']?.toString()),
    );
  }
}
