import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/auth/domain/models/cccd_data.dart';
import 'package:cook_connect_seller/features/auth/data/services/cccd_ocr_service.dart';

void main() {
  group('CccdData tests', () {
    test('Merge CccdData from front and back preserves accented name', () {
      const front = CccdData(
        citizenId: '022205009457',
        fullName: 'NGUYỄN QUANG HƯNG',
        dateOfBirth: '2005-08-05',
        gender: 'Nam',
      );

      const back = CccdData(
        fullName: 'NGUYEN QUANG HUNG', // MRZ unaccented
        issueDate: '2021-08-14',
        issuePlace: 'Cục Cảnh sát QLHC về TTXH',
      );

      final merged = front.mergeWith(back);

      expect(merged.citizenId, '022205009457');
      expect(merged.fullName, 'NGUYỄN QUANG HƯNG'); // Preserved accented!
      expect(merged.dateOfBirth, '2005-08-05');
      expect(merged.issueDate, '2021-08-14');
      expect(merged.issuePlace, 'Cục Cảnh sát QLHC về TTXH');
      expect(merged.hasAnyData, isTrue);
    });

    test('Parse Vietnamese CCCD QR code payload from IMG_0327', () {
      const qrPayload =
          '022205009457||Nguyễn Quang Hưng|05082005|Nam|Tổ 2, An Hải, Phương Nam, Uông Bí, Quảng Ninh|14082021';

      final data = CccdOcrService.instance.parseVietnameseCccdQr(qrPayload);

      expect(data, isNotNull);
      expect(data!.citizenId, '022205009457');
      expect(data.fullName, 'NGUYỄN QUANG HƯNG');
      expect(data.dateOfBirth, '2005-08-05');
      expect(data.gender, 'Nam');
      expect(data.issueDate, '2021-08-14');
      expect(data.issuePlace, 'Cục Cảnh sát QLHC về TTXH');
      expect(data.address, contains('Quảng Ninh'));
    });

    test('Parse OCR Text from Front CCCD (IMG_0327)', () {
      const frontOcrText = '''Có giá trị đến:05/08/2030
Date ol expiry
CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM
Độc lập - Tự do - Hạnh phúc
SOCIALIST REPUBLIC OF VIET NAM
Independence - Freedom - Happiness
CĂN CƯỚC CÔNG DÂN
Citizen Identity Card
Số / No.: 022205009457
Họ và tên / Full name:
NGUYỄN QUANG HƯNG
Ngày sinh / Date of birth: 05/08/2005
Giới tính / Sex: Nam Quốc tịch / Nationality: Việt Nam
Quê quận / Place of origin:
Hiệp Hòa, Thị xã Quang Yên, Quang Ninh
Nơi thường trú / Place of residence Tô 2, An Hải
Phương Nam, TP Uông Bí, Quảng Ninh''';

      final data = CccdOcrService.instance.parseTextOcr(frontOcrText);

      expect(data.citizenId, '022205009457');
      expect(data.fullName, 'NGUYỄN QUANG HƯNG');
      expect(data.dateOfBirth, '2005-08-05');
    });

    test('Parse OCR Text when labels are split into separate lines', () {
      const splitText = '''Số / No.: 022205009457
Họ và tên
Full name
NGUYỄN QUANG HƯNG
Ngày sinh / Date of birth: 05/08/2005''';

      final data = CccdOcrService.instance.parseTextOcr(splitText);

      expect(data.citizenId, '022205009457');
      expect(data.fullName, 'NGUYỄN QUANG HƯNG'); // Never 'FULL NAME'
      expect(data.dateOfBirth, '2005-08-05');
    });

    test('looksLikeVietnameseName validation rules', () {
      final ocr = CccdOcrService.instance;

      // Valid names
      expect(ocr.looksLikeVietnameseName('NGUYỄN QUANG HƯNG'), isTrue);
      expect(ocr.looksLikeVietnameseName('Trần Văn An'), isTrue);
      expect(ocr.looksLikeVietnameseName('Lê Thị Bích Ngọc'), isTrue);

      // Invalid: Stopwords / Card labels
      expect(ocr.looksLikeVietnameseName('Full name'), isFalse);
      expect(ocr.looksLikeVietnameseName('Họ và tên'), isFalse);
      expect(ocr.looksLikeVietnameseName('VIỆT NAM'), isFalse);
      expect(ocr.looksLikeVietnameseName('CĂN CƯỚC CÔNG DÂN'), isFalse);
      expect(ocr.looksLikeVietnameseName('Date of birth'), isFalse);
      expect(ocr.looksLikeVietnameseName('Nam'), isFalse); // Single word
      expect(ocr.looksLikeVietnameseName('Nữ'), isFalse); // Single word
      expect(ocr.looksLikeVietnameseName('Cục Cảnh sát'), isFalse);
      expect(ocr.looksLikeVietnameseName('123 Nguyen Van A'), isFalse);
    });

    test('Parse OCR Text from Back CCCD (IMG_0328)', () {
      const backOcrText = '''Đắc điểm nhần dạng | Personal identification:
Nối ruồi C 1cm dưới trước long
mày trải
Ngày, tháng, năm / Date, month, year: 14/08/2021
CỤC TRƯƠNG CỤC CANH SAT
QUẢN LỶ HÀNH CHÍNH VÊ TRẠT TỰ XA HỘI
DIRECTOR GENERAL OF THE POLICE DEPARTMENT
FOR AGLNSTRATIVE MANAGEMENT OF SOCIAL ORDER
·80
ĐÀNH GAT QUI
Ngón trở trái
Left index Friger
Ngon tr phai
Right index Anger
Tô Văn Huệ
IDVNM2050094578022205009457<<6
0508056M3008052VNM<<<<<<<<
<<<2
NGUYEN<<QUANG<HUNG<<''';

      final data = CccdOcrService.instance.parseTextOcr(backOcrText);

      expect(data.issueDate, '2021-08-14');
      expect(data.issuePlace, 'Cục Cảnh sát QLHC về TTXH');
    });
  });
}
