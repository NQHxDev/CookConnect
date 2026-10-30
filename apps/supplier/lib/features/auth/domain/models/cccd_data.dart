/// Model lưu thông tin bóc tách từ thẻ Căn Cước Công Dân (CCCD / Căn Cước)
class CccdData {
  final String? citizenId;
  final String? oldCitizenId;
  final String? fullName;
  final String? dateOfBirth; // Định dạng chuẩn YYYY-MM-DD
  final String? gender;
  final String? address;
  final String? issueDate; // Định dạng chuẩn YYYY-MM-DD
  final String? issuePlace;
  final String? rawQr;

  const CccdData({
    this.citizenId,
    this.oldCitizenId,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.issueDate,
    this.issuePlace,
    this.rawQr,
  });

  /// Gộp dữ liệu từ 2 mặt (Mặt trước + Mặt sau)
  CccdData mergeWith(CccdData other) {
    // Ưu tiên giữ lại tên tiếng Việt có dấu thay vì bị ghi đè bởi tên không dấu (từ MRZ)
    String? resolvedFullName =
        other.fullName?.isNotEmpty == true ? other.fullName : fullName;
    if (fullName != null &&
        fullName!.isNotEmpty &&
        other.fullName != null &&
        other.fullName!.isNotEmpty) {
      final vietnameseAccentRegex = RegExp(
        r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
        caseSensitive: false,
      );
      final hasAccents = vietnameseAccentRegex.hasMatch(fullName!);
      final otherHasAccents = vietnameseAccentRegex.hasMatch(other.fullName!);
      if (hasAccents && !otherHasAccents) {
        resolvedFullName = fullName;
      }
    }

    return CccdData(
      citizenId: other.citizenId?.isNotEmpty == true ? other.citizenId : citizenId,
      oldCitizenId: other.oldCitizenId?.isNotEmpty == true ? other.oldCitizenId : oldCitizenId,
      fullName: resolvedFullName,
      dateOfBirth: other.dateOfBirth?.isNotEmpty == true ? other.dateOfBirth : dateOfBirth,
      gender: other.gender?.isNotEmpty == true ? other.gender : gender,
      address: other.address?.isNotEmpty == true ? other.address : address,
      issueDate: other.issueDate?.isNotEmpty == true ? other.issueDate : issueDate,
      issuePlace: other.issuePlace?.isNotEmpty == true ? other.issuePlace : issuePlace,
      rawQr: other.rawQr?.isNotEmpty == true ? other.rawQr : rawQr,
    );
  }

  bool get hasAnyData =>
      (citizenId != null && citizenId!.isNotEmpty) ||
      (fullName != null && fullName!.isNotEmpty) ||
      (dateOfBirth != null && dateOfBirth!.isNotEmpty) ||
      (issueDate != null && issueDate!.isNotEmpty) ||
      (issuePlace != null && issuePlace!.isNotEmpty);

  @override
  String toString() {
    return 'CccdData(citizenId: $citizenId, fullName: $fullName, dob: $dateOfBirth, issueDate: $issueDate, issuePlace: $issuePlace)';
  }
}
