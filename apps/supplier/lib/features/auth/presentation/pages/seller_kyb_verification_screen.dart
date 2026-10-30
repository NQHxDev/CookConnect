import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/domain/models/cccd_data.dart';
import 'package:cook_connect_seller/features/auth/data/services/cccd_ocr_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/cccd_camera_capture_screen.dart';

/// Màn hình nộp hồ sơ pháp lý & thông tin tài khoản ngân hàng (KYB - Step 2/3)
/// Dành cho nhà bán hàng để được duyệt mở bán sản phẩm trên CookConnect
class SellerKybVerificationScreen extends StatefulWidget {
  const SellerKybVerificationScreen({super.key});

  @override
  State<SellerKybVerificationScreen> createState() =>
      _SellerKybVerificationScreenState();
}

class _SellerKybVerificationScreenState
    extends State<SellerKybVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Merchant type: 'INDIVIDUAL' or 'ENTERPRISE'
  String _merchantType = 'INDIVIDUAL';

  // Controllers for Individual
  late final TextEditingController _fullNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _citizenIdController;
  late final TextEditingController _idIssuedDateController;
  late final TextEditingController _idIssuePlaceController;

  // Controllers for Enterprise
  late final TextEditingController _businessNameController;
  late final TextEditingController _taxCodeController;

  // Controllers for Banking / Settlement (Both)
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccountNumberController;
  late final TextEditingController _bankAccountHolderController;

  // Ảnh 2 mặt CCCD
  File? _frontCardFile;
  File? _backCardFile;

  // Buffer trích xuất ngầm từ 2 mặt CCCD
  CccdData _extractedCccdBuffer = const CccdData();

  bool _isLoading = false;
  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();

  static const List<String> _popularBanks = [
    'Vietcombank (Ngân hàng Ngoại thương)',
    'Techcombank (Ngân hàng Kỹ thương)',
    'MB Bank (Ngân hàng Quân đội)',
    'VietinBank (Ngân hàng Công thương)',
    'BIDV (Ngân hàng Đầu tư & Phát triển)',
    'ACB (Ngân hàng Á Châu)',
    'VPBank (Ngân hàng Việt Nam Thịnh vượng)',
    'TPBank (Ngân hàng Tiên Phong)',
    'Sacombank (Ngân hàng Sài Gòn Thương tín)',
    'Khác (Nhập tên ngân hàng)',
  ];

  @override
  void initState() {
    super.initState();
    final profile = SellerAuthService.instance.supplierProfile;

    _merchantType = profile?.merchantType ?? 'INDIVIDUAL';

    _fullNameController = TextEditingController(text: profile?.bankAccountHolder ?? '');
    _dateOfBirthController = TextEditingController();
    _citizenIdController = TextEditingController(text: profile?.citizenId ?? '');
    _idIssuedDateController = TextEditingController(
      text: profile?.citizenIdIssuedDate?.split('T').first ?? '',
    );
    _idIssuePlaceController = TextEditingController();

    _businessNameController =
        TextEditingController(text: profile?.businessName ?? '');
    _taxCodeController = TextEditingController(text: profile?.taxCode ?? '');

    _bankNameController = TextEditingController(text: profile?.bankName ?? '');
    _bankAccountNumberController =
        TextEditingController(text: profile?.bankAccountNumber ?? '');
    _bankAccountHolderController =
        TextEditingController(text: profile?.bankAccountHolder ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _citizenIdController.dispose();
    _idIssuedDateController.dispose();
    _idIssuePlaceController.dispose();
    _businessNameController.dispose();
    _taxCodeController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountHolderController.dispose();
    super.dispose();
  }

  /// Chọn ngày trực quan cho trường ngày sinh hoặc ngày cấp
  Future<void> _pickDateForController(TextEditingController controller,
      {required bool isDob}) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    DateTime initialDate;
    try {
      if (controller.text.trim().isNotEmpty) {
        initialDate = DateTime.parse(controller.text.trim());
      } else {
        initialDate = isDob ? DateTime(2000, 1, 1) : now;
      }
    } catch (_) {
      initialDate = isDob ? DateTime(2000, 1, 1) : now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isDob ? DateTime(1940) : DateTime(1990),
      lastDate: isDob ? now : now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$y-$m-$d';
      });
    }
  }

  /// Xử lý trích xuất ngầm dữ liệu thẻ CCCD (Không hiển thị dialog/loader chặn màn hình)
  void _processSilentCard(File file, {required bool isFront}) async {
    try {
      // Bóc tách siêu tốc (quét mã QR ưu tiên, tiếp đến là Text OCR)
      final result = await CccdOcrService.instance.extractFromImage(file);

      // Gộp vào bộ nhớ đệm
      _extractedCccdBuffer = _extractedCccdBuffer.mergeWith(result);

      if (!mounted) return;
      setState(() {
        // Tự động nạp số CCCD nếu trích xuất được
        if (_extractedCccdBuffer.citizenId != null &&
            _extractedCccdBuffer.citizenId!.isNotEmpty) {
          _citizenIdController.text = _extractedCccdBuffer.citizenId!;
        }

        // Tự động nạp Họ và Tên (chỉ ghi đè nếu là mặt trước hoặc ô đang trống)
        if (_extractedCccdBuffer.fullName != null &&
            _extractedCccdBuffer.fullName!.isNotEmpty) {
          if (isFront || _fullNameController.text.trim().isEmpty) {
            _fullNameController.text = _extractedCccdBuffer.fullName!.toUpperCase();
            // Đồng bộ với Tên chủ tài khoản ngân hàng thụ hưởng nếu đang trống
            if (_bankAccountHolderController.text.trim().isEmpty) {
              _bankAccountHolderController.text =
                  _extractedCccdBuffer.fullName!.toUpperCase();
            }
          }
        }

        // Tự động nạp Ngày sinh
        if (_extractedCccdBuffer.dateOfBirth != null &&
            _extractedCccdBuffer.dateOfBirth!.isNotEmpty) {
          _dateOfBirthController.text = _extractedCccdBuffer.dateOfBirth!;
        }

        // Tự động nạp Ngày cấp
        if (_extractedCccdBuffer.issueDate != null &&
            _extractedCccdBuffer.issueDate!.isNotEmpty) {
          _idIssuedDateController.text = _extractedCccdBuffer.issueDate!;
        }

        // Tự động nạp Nơi cấp
        if (_extractedCccdBuffer.issuePlace != null &&
            _extractedCccdBuffer.issuePlace!.isNotEmpty) {
          _idIssuePlaceController.text = _extractedCccdBuffer.issuePlace!;
        }
      });

      // Rung nhẹ phản hồi xúc giác báo hoàn tất
      HapticFeedback.lightImpact();
    } catch (e) {
      // Âm thầm xử lý ngoại lệ để không gây gián đoạn cho người dùng
      debugPrint('[KybVerification] Lỗi xử lý ngầm: $e');
    }
  }

  /// Mở màn hình Chụp ảnh CCCD chuẩn ngân hàng hoặc Chọn từ thư viện
  Future<void> _handleCaptureCccd({required bool isFront}) async {
    FocusScope.of(context).unfocus();
    final sideTitle = isFront ? 'Mặt trước' : 'Mặt sau';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Tải ảnh $sideTitle CCCD',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn chụp ảnh bằng camera có khung căn chỉnh hoặc tải từ thư viện ảnh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                if ((isFront ? _frontCardFile : _backCardFile) != null) ...[
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.eye, color: Color(0xFF2E7D32)),
                    ),
                    title: Text('Xem chi tiết ảnh $sideTitle'),
                    subtitle: const Text('Phóng to kiểm tra độ sắc nét thẻ'),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showZoomableImagePreview(
                        file: isFront ? _frontCardFile! : _backCardFile!,
                        title: '$sideTitle CCCD',
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.camera, color: AppColors.primary),
                  ),
                  title: Text((isFront ? _frontCardFile : _backCardFile) == null
                      ? 'Mở máy ảnh căn chỉnh $sideTitle'
                      : 'Chụp lại bằng máy ảnh căn chỉnh'),
                  subtitle: const Text('Tự động zoom 1.6x & chạm lấy nét rõ nét'),
                  trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final File? captured = await Navigator.push<File?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CccdCameraCaptureScreen(
                          sideTitle: sideTitle,
                          hintText: isFront
                              ? 'Căn chỉnh mặt trước CCCD vào khung hình'
                              : 'Căn chỉnh mặt sau CCCD vào khung hình',
                        ),
                      ),
                    );

                    if (captured != null && mounted) {
                      setState(() {
                        if (isFront) {
                          _frontCardFile = captured;
                        } else {
                          _backCardFile = captured;
                        }
                      });
                      // Xử lý ngầm trích xuất dữ liệu
                      _processSilentCard(captured, isFront: isFront);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.gallery, color: Colors.blue),
                  ),
                  title: const Text('Chọn ảnh từ Thư viện'),
                  subtitle: const Text('Tải ảnh CCCD gốc đã chụp sẵn trong máy'),
                  trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final XFile? picked = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1920,
                      imageQuality: 85,
                    );
                    if (picked != null && mounted) {
                      final file = File(picked.path);
                      setState(() {
                        if (isFront) {
                          _frontCardFile = file;
                        } else {
                          _backCardFile = file;
                        }
                      });
                      // Xử lý ngầm trích xuất dữ liệu
                      _processSilentCard(file, isFront: isFront);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xem chi tiết ảnh CCCD gốc với khả năng Zoom đa điểm
  void _showZoomableImagePreview({required File file, required String title}) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '🔍 Dùng 2 ngón tay phóng to để kiểm tra chi tiết ảnh gốc',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankPicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.bank,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn Ngân hàng thụ hưởng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dùng để nhận tiền thanh toán đơn hàng',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle,
                          color: AppColors.textHint, size: 22),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _popularBanks.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final bank = _popularBanks[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        title: Text(
                          bank,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        onTap: () {
                          setState(() {
                            _bankNameController.text = bank.split(' (').first;
                          });
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitKyb() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_merchantType == 'INDIVIDUAL') {
      if (_frontCardFile == null || _backCardFile == null) {
        setState(() {
          _errorMessage =
              'Vui lòng chụp hoặc tải lên đầy đủ ảnh 2 mặt Căn cước công dân.';
        });
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final success = await SellerAuthService.instance.submitKyb(
        merchantType: _merchantType,
        citizenId: _merchantType == 'INDIVIDUAL'
            ? _citizenIdController.text.trim()
            : null,
        citizenIdIssuedDate: _merchantType == 'INDIVIDUAL' &&
                _idIssuedDateController.text.trim().isNotEmpty
            ? '${_idIssuedDateController.text.trim()}T00:00:00.000Z'
            : null,
        idCardFrontUrl: _frontCardFile?.path,
        idCardBackUrl: _backCardFile?.path,
        businessName: _merchantType == 'ENTERPRISE'
            ? _businessNameController.text.trim()
            : null,
        taxCode: _merchantType == 'ENTERPRISE'
            ? _taxCodeController.text.trim()
            : null,
        bankName: _bankNameController.text.trim(),
        bankAccountNumber: _bankAccountNumberController.text.trim(),
        bankAccountHolder: _bankAccountHolderController.text.trim().isNotEmpty
            ? _bankAccountHolderController.text.trim().toUpperCase()
            : _fullNameController.text.trim().toUpperCase(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage =
              'Không thể gửi hồ sơ xác minh. Vui lòng kiểm tra lại thông tin kết nối.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ApiException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác minh gian hàng',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                _buildInfoBanner(),

                const SizedBox(height: 20),

                // Step 1: Business Entity Selector
                const Text(
                  '1. Loại hình kinh doanh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMerchantTypeSelector(),

                const SizedBox(height: 24),

                // Step 2: Identification Details
                Text(
                  _merchantType == 'INDIVIDUAL'
                      ? '2. Thông tin CCCD / Hộ chiếu cá nhân'
                      : '2. Thông tin pháp lý Doanh nghiệp / Hộ KD',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (_merchantType == 'INDIVIDUAL')
                  _buildIndividualForm()
                else
                  _buildEnterpriseForm(),

                const SizedBox(height: 24),

                // Step 3: Bank Settlement Details
                const Text(
                  '3. Tài khoản ngân hàng nhận doanh thu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mọi khoản thanh toán từ khách hàng sẽ được đối soát tự động về tài khoản này.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBankingForm(),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.warning_2,
                            color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmitKyb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Gửi hồ sơ thẩm định ngay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'CookConnect cam kết bảo mật 100% dữ liệu hồ sơ theo quy định pháp luật.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.shield_tick,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yêu cầu xác minh danh tính',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF795548),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Để bảo vệ quyền lợi người tiêu dùng và mở khóa tính năng đăng bán sản phẩm, bạn cần cung cấp thông tin đối soát hợp lệ.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5D4037),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _merchantType = 'INDIVIDUAL'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: _merchantType == 'INDIVIDUAL'
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _merchantType == 'INDIVIDUAL'
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: _merchantType == 'INDIVIDUAL' ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _merchantType == 'INDIVIDUAL'
                        ? Iconsax.tick_circle
                        : Iconsax.user,
                    color: _merchantType == 'INDIVIDUAL'
                        ? AppColors.primary
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cá nhân / Hộ nhỏ',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: _merchantType == 'INDIVIDUAL'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Dùng CCCD / Hộ chiếu',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _merchantType = 'ENTERPRISE'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: _merchantType == 'ENTERPRISE'
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _merchantType == 'ENTERPRISE'
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: _merchantType == 'ENTERPRISE' ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _merchantType == 'ENTERPRISE'
                        ? Iconsax.tick_circle
                        : Iconsax.buildings,
                    color: _merchantType == 'ENTERPRISE'
                        ? AppColors.primary
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doanh nghiệp / Cty',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: _merchantType == 'ENTERPRISE'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Mã số thuế & ĐKKD',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khu vực chụp/tải ảnh 2 mặt CCCD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ảnh chụp Căn cước công dân (2 mặt)',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              if (_frontCardFile != null && _backCardFile != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.tick_circle, size: 13, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'Đã đủ 2 mặt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Hệ thống sẽ tự động quét thông tin từ ảnh để điền vào các ô bên dưới.',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          // 2 Card Upload Box (Mặt trước & Mặt sau)
          Row(
            children: [
              Expanded(
                child: _buildCccdCardBox(
                  title: 'Mặt trước CCCD',
                  file: _frontCardFile,
                  isFront: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCccdCardBox(
                  title: 'Mặt sau CCCD',
                  file: _backCardFile,
                  isFront: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 1. Trường Họ và tên
          const Text(
            'Họ và tên chủ sở hữu / Người đại diện',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Ví dụ: NGUYỄN QUANG HƯNG',
              prefixIcon: const Icon(Iconsax.user, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (val) {
              // Tự động đồng bộ với tên chủ thẻ ngân hàng nếu đang trống
              if (_bankAccountHolderController.text.trim().isEmpty) {
                _bankAccountHolderController.text = val.toUpperCase();
              }
            },
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Vui lòng nhập họ và tên đầy đủ';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // 2. Trường Ngày sinh
          const Text(
            'Ngày sinh (YYYY-MM-DD)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _dateOfBirthController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 2005-08-05',
              prefixIcon: const Icon(Iconsax.calendar_1, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.calendar, size: 20, color: AppColors.primary),
                onPressed: () => _pickDateForController(_dateOfBirthController, isDob: true),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 8) {
                return 'Vui lòng nhập ngày sinh hợp lệ (YYYY-MM-DD)';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // 3. Trường số CCCD (Cho phép sửa linh hoạt)
          const Text(
            'Số CMND / Căn cước công dân (12 số)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _citizenIdController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: 'Nhập hoặc để hệ thống tự điền từ ảnh',
              counterText: '',
              prefixIcon: const Icon(Iconsax.card, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 9) {
                return 'Vui lòng nhập số CMND/CCCD hợp lệ (9 - 12 số)';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // 4. Trường ngày cấp
          const Text(
            'Ngày cấp (YYYY-MM-DD)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _idIssuedDateController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 2021-08-14',
              prefixIcon: const Icon(Iconsax.calendar, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.calendar, size: 20, color: AppColors.primary),
                onPressed: () => _pickDateForController(_idIssuedDateController, isDob: false),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 8) {
                return 'Vui lòng nhập ngày cấp (YYYY-MM-DD)';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // 5. Trường nơi cấp
          const Text(
            'Nơi cấp CCCD',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _idIssuePlaceController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Cục Cảnh sát QLHC về TTXH hoặc Bộ Công An',
              prefixIcon: const Icon(Iconsax.location, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập nơi cấp CCCD';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Khung hiển thị và chọn ảnh CCCD từng mặt
  Widget _buildCccdCardBox({
    required String title,
    required File? file,
    required bool isFront,
  }) {
    final hasImage = file != null;

    return InkWell(
      onTap: () => _handleCaptureCccd(isFront: isFront),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: hasImage ? Colors.black : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AppColors.primary : Colors.grey.shade300,
            width: hasImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.file(file, fit: BoxFit.cover)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.camera,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chạm để chụp',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

            // Badge & Nút đổi ảnh khi đã chụp
            if (hasImage) ...[
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.refresh, size: 11, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'Chụp lại',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 10, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnterpriseForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tên pháp nhân công ty / Hộ kinh doanh',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: CÔNG TY TNHH THỰC PHẨM SẠCH MIỀN NAM',
              prefixIcon: const Icon(Iconsax.buildings, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên công ty pháp nhân';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Mã số thuế doanh nghiệp (MST)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _taxCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 0312345678',
              prefixIcon: const Icon(Iconsax.document_text, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 10) {
                return 'Vui lòng nhập Mã số thuế hợp lệ (10 - 13 số)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ngân hàng thụ hưởng',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _showBankPicker,
            child: IgnorePointer(
              child: TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  hintText: 'Chạm để chọn ngân hàng',
                  prefixIcon: const Icon(Iconsax.bank, size: 20),
                  suffixIcon: const Icon(Iconsax.arrow_down_1, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng chọn ngân hàng thụ hưởng';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Số tài khoản ngân hàng',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bankAccountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Nhập số tài khoản',
              prefixIcon: const Icon(Iconsax.card_tick, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'Vui lòng nhập số tài khoản hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Tên chủ tài khoản (Viết hoa không dấu)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bankAccountHolderController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Ví dụ: NGUYEN VAN A',
              prefixIcon: const Icon(Iconsax.user, size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên chủ tài khoản';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
