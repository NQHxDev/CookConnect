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
}
