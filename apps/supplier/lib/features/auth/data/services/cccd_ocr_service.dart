import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cook_connect_seller/features/auth/domain/models/cccd_data.dart';

/// Dịch vụ trích xuất thông tin Căn Cước Công Dân (CCCD)
/// Chạy On-Device siêu tốc (QR Code scanner + OCR Text Recognition)
class CccdOcrService {
  CccdOcrService._();
  static final CccdOcrService instance = CccdOcrService._();

  /// Phân tích ảnh và trích xuất dữ liệu CCCD
  Future<CccdData> extractFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);

      // Bước 1: Quét mã QR (Mặt trước CCCD gắn chip Việt Nam)
      final qrData = await _tryExtractFromQr(inputImage);

      // Bước 2: Nhận diện văn bản bằng Text Recognition (Mặt sau hoặc mặt trước không quét được QR)
      final ocrData = await _tryExtractFromTextOcr(inputImage);

      // Nếu có cả QR và OCR, hợp nhất dữ liệu để có thông tin đầy đủ nhất
      if (qrData != null && qrData.hasAnyData) {
        final merged = qrData.mergeWith(ocrData);
        debugPrint('[CccdOcrService] Hợp nhất QR + OCR: $merged');
        return merged;
      }

      debugPrint('[CccdOcrService] Trích xuất từ Text OCR: $ocrData');
      return ocrData;
    } catch (e, stack) {
      debugPrint('[CccdOcrService] Lỗi khi trích xuất CCCD: $e\n$stack');
      return const CccdData();
    }
  }

  /// Quét mã QR 2D trên thẻ CCCD
  Future<CccdData?> _tryExtractFromQr(InputImage inputImage) async {
    BarcodeScanner? barcodeScanner;
    try {
      barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      final barcodes = await barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue;
        if (rawValue != null && rawValue.contains('|')) {
          final parsed = parseVietnameseCccdQr(rawValue);
          if (parsed != null) return parsed;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[CccdOcrService] Quét QR thất bại: $e');
      return null;
    } finally {
      await barcodeScanner?.close();
    }
  }

  /// Parse chuỗi mã QR theo chuẩn Bộ Công An Việt Nam
  /// Cấu trúc: Số CCCD | Số CMND cũ | Họ và tên | Ngày sinh (ddMMyyyy) | Giới tính | Nơi thường trú | Ngày cấp (ddMMyyyy)
  CccdData? parseVietnameseCccdQr(String raw) {
    try {
      final parts = raw.split('|');
      if (parts.length < 5) return null;

      final citizenId = parts[0].trim();
      final oldId = parts[1].trim();
      final fullName = parts[2].trim();
      final dobRaw = parts[3].trim();
      final gender = parts[4].trim();
      final address = parts.length > 5 ? parts[5].trim() : null;
      final issueDateRaw = parts.length > 6 ? parts[6].trim() : null;

      // CCCD gắn chip đều do Cục Cảnh sát QLHC về TTXH cấp
      const defaultIssuePlace = 'Cục Cảnh sát QLHC về TTXH';

      return CccdData(
        citizenId: citizenId.isNotEmpty ? citizenId : null,
        oldCitizenId: oldId.isNotEmpty ? oldId : null,
        fullName: fullName.isNotEmpty ? fullName.toUpperCase() : null,
        dateOfBirth: formatDdMmYyyyToIso(dobRaw),
        gender: gender.isNotEmpty ? gender : null,
        address: address?.isNotEmpty == true ? address : null,
        issueDate: formatDdMmYyyyToIso(issueDateRaw),
        issuePlace: defaultIssuePlace,
        rawQr: raw,
      );
    } catch (e) {
      debugPrint('[CccdOcrService] Lỗi parse QR: $e');
      return null;
    }
  }

  /// Quét toàn bộ Text trên ảnh bằng ML Kit OCR
  Future<CccdData> _tryExtractFromTextOcr(InputImage inputImage) async {
    TextRecognizer? textRecognizer;
    try {
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return parseTextOcr(recognizedText.text);
    } catch (e) {
      debugPrint('[CccdOcrService] Quét OCR thất bại: $e');
      return const CccdData();
    } finally {
      await textRecognizer?.close();
    }
  }

  /// Bóc tách thông tin từ chuỗi văn bản OCR
  CccdData parseTextOcr(String fullText) {
    String? citizenId;
    String? fullName;
    String? dateOfBirth;
    String? issueDate;
    String? issuePlace;

    // 1. Tìm số CCCD (12 chữ số)
    final cccdMatch = RegExp(r'\b(0\d{11})\b').firstMatch(fullText);
    if (cccdMatch != null) {
      citizenId = cccdMatch.group(1);
    } else {
      // Dự phòng số 9 hoặc 12 số có khoảng trắng
      final broadCccdMatch = RegExp(
        r'(?:Số|No\.?)\s*[:.]?\s*([0-9\s]{9,15})',
        caseSensitive: false,
      ).firstMatch(fullText);
      if (broadCccdMatch != null) {
        final digits = broadCccdMatch.group(1)!.replaceAll(RegExp(r'\s+'), '');
        if (digits.length == 12 || digits.length == 9) {
          citizenId = digits;
        }
      }
    }

    // Fallback: Tìm số CCCD trong dòng MRZ (Mặt sau CCCD: IDVNM...)
    if (citizenId == null) {
      final mrzMatch = RegExp(r'IDVNM[0-9A-Z<]*(0\d{11})').firstMatch(fullText);
      if (mrzMatch != null) {
        citizenId = mrzMatch.group(1);
      }
    }

    // 2. Tìm Họ và tên (Mặt trước CCCD: Nhãn "Họ và tên / Full name:")
    final lines = fullText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(r'Họ\s*(?:và|v\.)?\s*tên|Full\s*name', caseSensitive: false)
          .hasMatch(line)) {
        // Kiểm tra xem tên có nằm ngay trên cùng dòng hay không
        String sameLineCandidate = line
            .replaceAll(
                RegExp(r'Họ\s*(?:và|v\.)?\s*tên', caseSensitive: false), '')
            .replaceAll(RegExp(r'Full\s*name', caseSensitive: false), '')
            .replaceAll(RegExp(r'[/:.-]'), '')
            .trim();

        if (looksLikeVietnameseName(sameLineCandidate)) {
          fullName = sameLineCandidate.toUpperCase();
          break;
        }

        // Nếu trên cùng dòng không có tên hợp lệ, quét các dòng kế tiếp (tối đa 3 dòng tiếp theo)
        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          final nextLine = lines[j].trim();

          // Dừng lại nếu đã chạm đến nhãn trường kế tiếp
          if (RegExp(
                  r'ngày\s*sinh|date\s*of\s*birth|giới\s*tính|sex|quê\s*quán|place\s*of\s*origin',
                  caseSensitive: false)
              .hasMatch(nextLine)) {
            break;
          }

          // Bỏ qua dòng nếu dòng đó chỉ là nhãn tiếng Anh sót lại (ví dụ "Full name")
          if (RegExp(r'^(?:Full\s*name|Họ\s*tên)[/:.-]*$', caseSensitive: false)
              .hasMatch(nextLine)) {
            continue;
          }

          String candidate =
              nextLine.replaceAll(RegExp(r'^[/:.-]+'), '').trim();
          if (looksLikeVietnameseName(candidate)) {
            fullName = candidate.toUpperCase();
            break;
          }
        }

        if (fullName != null) break;
      }
    }

    // Fallback 1: Quét tìm dòng in hoa toàn bộ (2-5 từ) nằm giữa số CCCD và Ngày sinh
    if (fullName == null) {
      int cccdLineIdx = -1;
      int dobLineIdx = -1;

      for (int i = 0; i < lines.length; i++) {
        if (citizenId != null && lines[i].contains(citizenId)) {
          cccdLineIdx = i;
        }
        if (RegExp(r'ngày\s*sinh|date\s*of\s*birth', caseSensitive: false)
            .hasMatch(lines[i])) {
          dobLineIdx = i;
          break;
        }
      }

      if (cccdLineIdx != -1 && dobLineIdx != -1 && dobLineIdx > cccdLineIdx) {
        for (int i = cccdLineIdx + 1; i < dobLineIdx; i++) {
          final candidate =
              lines[i].replaceAll(RegExp(r'^[/:.-]+'), '').trim();
          if (looksLikeVietnameseName(candidate)) {
            fullName = candidate.toUpperCase();
            break;
          }
        }
      }
    }

    // Fallback 2: Tìm họ tên từ MRZ Line 3 (NGUYEN<<QUANG<HUNG<<)
    if (fullName == null) {
      final mrzNameMatch = RegExp(r'([A-Z]+<+[A-Z<]+<<)').firstMatch(fullText);
      if (mrzNameMatch != null) {
        final rawMrzName = mrzNameMatch.group(1)!;
        final cleanName = rawMrzName
            .replaceAll('<<', ' ')
            .replaceAll('<', ' ')
            .trim();
        if (looksLikeVietnameseName(cleanName)) {
          fullName = cleanName.toUpperCase();
        }
      }
    }

    // 3. Tìm Ngày sinh (dd/MM/yyyy)
    // Hỗ trợ nhãn song ngữ: "Ngày sinh / Date of birth: 05/08/2005"
    final dobMatch = RegExp(
      r'(?:ngày\s*sinh|sinh\s*ngày|date\s*of\s*birth)[^\d\n]*([0-9]{1,2})[/-]([0-9]{1,2})[/-]([0-9]{4})',
      caseSensitive: false,
    ).firstMatch(fullText);

    if (dobMatch != null) {
      final d = dobMatch.group(1)!.padLeft(2, '0');
      final m = dobMatch.group(2)!.padLeft(2, '0');
      final y = dobMatch.group(3)!;
      dateOfBirth = '$y-$m-$d';
    } else {
      // Fallback: Tìm ngày sinh từ MRZ Line 2 (YYMMDD)
      final mrzDobMatch = RegExp(r'\n([0-9]{6})[0-9][MF]').firstMatch(fullText);
      if (mrzDobMatch != null) {
        final raw = mrzDobMatch.group(1)!;
        final yy = int.tryParse(raw.substring(0, 2)) ?? 0;
        final mm = raw.substring(2, 4);
        final dd = raw.substring(4, 6);
        final yyyy = yy > 30 ? 1900 + yy : 2000 + yy;
        dateOfBirth = '$yyyy-$mm-$dd';
      }
    }

    // 4. Tìm Ngày cấp (Mặt sau CCCD)
    // Dạng 1: "Ngày, tháng, năm / Date, month, year: 14/08/2021"
    final issueBilingualMatch = RegExp(
      r'(?:ngày[,\s]*tháng[,\s]*năm|date[,\s]*month[,\s]*year|ngày\s*cấp|cấp\s*ngày)[^\d\n]*([0-9]{1,2})[/-]([0-9]{1,2})[/-]([0-9]{4})',
      caseSensitive: false,
    ).firstMatch(fullText);

    if (issueBilingualMatch != null) {
      final d = issueBilingualMatch.group(1)!.padLeft(2, '0');
      final m = issueBilingualMatch.group(2)!.padLeft(2, '0');
      final y = issueBilingualMatch.group(3)!;
      issueDate = '$y-$m-$d';
    } else {
      // Dạng 2: "ngày 14 tháng 08 năm 2021"
      final issueDateFullMatch = RegExp(
        r'ngày\s*([0-9]{1,2})\s*tháng\s*([0-9]{1,2})\s*năm\s*([0-9]{4})',
        caseSensitive: false,
      ).firstMatch(fullText);

      if (issueDateFullMatch != null) {
        final d = issueDateFullMatch.group(1)!.padLeft(2, '0');
        final m = issueDateFullMatch.group(2)!.padLeft(2, '0');
        final y = issueDateFullMatch.group(3)!;
        issueDate = '$y-$m-$d';
      } else {
        // Dạng 3: Ngày độc lập trên mặt sau (gần các từ khóa cấp thẻ)
        final isBackSide = RegExp(r'CỤC|CANH\s*SAT|CẢNH\s*SÁT|ĐẶC\s*ĐIỂM|NHẬN\s*DẠNG', caseSensitive: false).hasMatch(fullText);
        if (isBackSide) {
          final anyDateMatch = RegExp(r'\b([0-9]{1,2})[/-]([0-9]{1,2})[/-]([0-9]{4})\b').firstMatch(fullText);
          if (anyDateMatch != null) {
            final d = anyDateMatch.group(1)!.padLeft(2, '0');
            final m = anyDateMatch.group(2)!.padLeft(2, '0');
            final y = anyDateMatch.group(3)!;
            issueDate = '$y-$m-$d';
          }
        }
      }
    }

    // 5. Tìm Nơi cấp (Mặt sau CCCD)
    final upperText = fullText.toUpperCase();
    if (upperText.contains('CỤC TRƯỞNG') ||
        upperText.contains('CỤC TRƯƠNG') ||
        upperText.contains('CẢNH SÁT QUẢN LÝ HÀNH CHÍNH') ||
        upperText.contains('CANH SAT')) {
      issuePlace = 'Cục Cảnh sát QLHC về TTXH';
    } else if (upperText.contains('BỘ CÔNG AN') || upperText.contains('BO CONG AN')) {
      issuePlace = 'Bộ Công An';
    } else if (upperText.contains('CÔNG AN TỈNH') || upperText.contains('CONG AN TINH')) {
      final caTinhMatch = RegExp(r'CÔNG AN TỈNH\s+([A-ZÀ-Ỹa-zà-ỹ\s]+)', caseSensitive: false).firstMatch(fullText);
      if (caTinhMatch != null) {
        issuePlace = 'Công an tỉnh ${caTinhMatch.group(1)!.trim()}';
      } else {
        issuePlace = 'Công an tỉnh';
      }
    } else if (upperText.contains('CÔNG AN THÀNH PHỐ') || upperText.contains('CONG AN THANH PHO')) {
      issuePlace = 'Công an thành phố';
    }

    return CccdData(
      citizenId: citizenId,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      issueDate: issueDate,
      issuePlace: issuePlace,
    );
  }

  /// Chuyển đổi chuỗi ddMMyyyy sang chuẩn YYYY-MM-DD
  String? formatDdMmYyyyToIso(String? raw) {
    if (raw == null || raw.length != 8) return null;
    try {
      final day = raw.substring(0, 2);
      final month = raw.substring(2, 4);
      final year = raw.substring(4, 8);
      return '$year-$month-$day';
    } catch (_) {
      return null;
    }
  }

  static const Set<String> _idCardStopwords = {
    'CONG HOA',
    'XA HOI',
    'CHU NGHIA',
    'VIET NAM',
    'DOC LAP',
    'TU DO',
    'HANH PHUC',
    'SOCIALIST',
    'REPUBLIC',
    'INDEPENDENCE',
    'FREEDOM',
    'HAPPINESS',
    'CAN CUOC',
    'CONG DAN',
    'CITIZEN',
    'IDENTITY',
    'CARD',
    'SO',
    'NO',
    'HO VA TEN',
    'HO TEN',
    'FULL NAME',
    'FULLNAME',
    'NGAY SINH',
    'DATE OF BIRTH',
    'DOB',
    'GIOI TINH',
    'SEX',
    'GENDER',
    'QUOC TICH',
    'NATIONALITY',
    'QUE QUAN',
    'PLACE OF ORIGIN',
    'NOI THUONG TRU',
    'NOI CU TRU',
    'PLACE OF RESIDENCE',
    'CO GIA TRI DEN',
    'DATE OF EXPIRY',
    'EXPIRY',
    'DAC DIEM',
    'NHAN DANG',
    'PERSONAL IDENTIFICATION',
    'NGAY THANG NAM',
    'DATE MONTH YEAR',
    'CUC TRUONG',
    'CANH SAT',
    'QUAN LY HANH CHINH',
    'TRAT TU XA HOI',
    'BO CONG AN',
    'CONG AN',
    'NGON TRO',
    'LEFT INDEX',
    'RIGHT INDEX',
    'FINGER',
    'NAM',
    'NU',
    'MALE',
    'FEMALE',
    'KINH',
    'TINH',
    'THANH PHO',
  };

  /// Kiểm tra chuỗi có đúng cấu trúc họ tên người Việt Nam
  bool looksLikeVietnameseName(String text) {
    final clean = text.trim();
    final words =
        clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    // Họ tên người Việt Nam luôn có từ 2 đến 5 từ (ví dụ: NGUYỄN QUANG HƯNG)
    if (words.length < 2 || words.length > 5) return false;

    // Không được chứa số hoặc ký tự đặc biệt
    if (RegExp(r'[0-9!@#\$%^&*()_+=\[\]{};:"\\|,.<>/?]').hasMatch(clean)) {
      return false;
    }

    // Chuẩn hóa loại bỏ dấu để đối chiếu với danh sách nhãn/từ dừng trên CCCD
    final normalized = _removeVietnameseAccents(clean).toUpperCase();
    for (final stopword in _idCardStopwords) {
      if (normalized == stopword || normalized.contains(stopword)) {
        return false;
      }
    }

    // Tất cả các từ phải viết hoa chữ cái đầu (trên CCCD luôn in hoa toàn bộ: NGUYỄN QUANG HƯNG)
    for (final word in words) {
      if (word.isEmpty) return false;
      final firstChar = word[0];
      if (firstChar.toLowerCase() == firstChar &&
          firstChar.toUpperCase() != firstChar) {
        return false;
      }
    }

    return true;
  }

  String _removeVietnameseAccents(String str) {
    var withAccents = str;
    withAccents = withAccents.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    withAccents = withAccents.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
    withAccents = withAccents.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    withAccents = withAccents.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
    withAccents = withAccents.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    withAccents = withAccents.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
    withAccents = withAccents.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    withAccents = withAccents.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
    withAccents = withAccents.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    withAccents = withAccents.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
    withAccents = withAccents.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    withAccents = withAccents.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
    withAccents = withAccents.replaceAll(RegExp(r'[đ]'), 'd');
    withAccents = withAccents.replaceAll(RegExp(r'[Đ]'), 'D');
    return withAccents;
  }
}
