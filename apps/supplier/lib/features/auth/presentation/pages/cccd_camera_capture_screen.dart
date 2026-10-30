import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

/// Màn hình chụp thẻ CCCD chuyên dụng với khung căn chỉnh chuẩn ngân hàng,
/// độ phân giải tối đa (Max/VeryHigh) và hỗ trợ chạm để lấy nét (Tap to focus).
class CccdCameraCaptureScreen extends StatefulWidget {
  final String sideTitle; // "Mặt trước" hoặc "Mặt sau"
  final String hintText;

  const CccdCameraCaptureScreen({
    super.key,
    required this.sideTitle,
    this.hintText = 'Căn chỉnh giấy tờ nằm trọn trong khung hình, tránh bóng lóa đèn',
  });

  @override
  State<CccdCameraCaptureScreen> createState() =>
      _CccdCameraCaptureScreenState();
}

class _CccdCameraCaptureScreenState extends State<CccdCameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isTakingPhoto = false;
  bool _isFlashOn = false;
  String? _errorMessage;

  // Điểm chạm lấy nét (Tap to focus)
  Offset? _focusPointScreen;
  bool _showFocusIndicator = false;
  Timer? _focusIndicatorTimer;

  // Zoom control (Thu phóng để tránh mờ tiêu cự cận cảnh / Macro blur)
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  // File ảnh sau khi chụp để xem trước (preview)
  File? _capturedFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusIndicatorTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage =
              'Không tìm thấy máy ảnh trên thiết bị. Bạn có thể chọn ảnh từ thư viện.';
        });
        return;
      }

      // Ưu tiên camera sau
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // Khởi tạo camera với độ phân giải veryHigh (Full HD 1080p sắc nét, tối ưu dung lượng cho OCR & upload)
      // Nếu thiết bị không hỗ trợ thì fallback về high
      CameraController controller;
      try {
        controller = CameraController(
          backCamera,
          ResolutionPreset.veryHigh,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await controller.initialize();
      } catch (_) {
        controller = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await controller.initialize();
      }

      // Thiết lập chế độ lấy nét tự động và đo sáng tối ưu cho tài liệu
      try {
        await controller.setFocusMode(FocusMode.auto);
      } catch (_) {}

      try {
        await controller.setExposureMode(ExposureMode.auto);
      } catch (_) {}

      // Lấy nét mặc định vào trung tâm thẻ (tọa độ chuẩn hóa ~ 0.5, 0.45)
      try {
        await controller.setFocusPoint(const Offset(0.5, 0.45));
        await controller.setExposurePoint(const Offset(0.5, 0.45));
      } catch (_) {}

      // Khởi tạo mức zoom được hỗ trợ trên thiết bị
      double minZoom = 1.0;
      double maxZoom = 1.0;
      try {
        minZoom = await controller.getMinZoomLevel();
        maxZoom = await controller.getMaxZoomLevel();
      } catch (_) {}

      // Tự động kích hoạt mức Zoom 1.6x ngay từ đầu.
      // Điều này giúp người dùng cầm điện thoại ở cự ly thoải mái 20-25cm,
      // thẻ CCCD vẫn khớp khung mà không bao giờ bị rơi vào vùng mờ cận cảnh (Macro blur).
      double defaultZoom = 1.6;
      if (defaultZoom > maxZoom) defaultZoom = maxZoom;
      if (defaultZoom < minZoom) defaultZoom = minZoom;
      try {
        await controller.setZoomLevel(defaultZoom);
      } catch (_) {}

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isCameraReady = true;
        _errorMessage = null;
        _minZoomLevel = minZoom;
        _maxZoomLevel = maxZoom;
        _currentZoomLevel = defaultZoom;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Không thể khởi động máy ảnh: $e\nBạn có thể tải ảnh từ thư viện.';
        });
      }
    }
  }

  /// Chạm để lấy nét và đo sáng tại điểm người dùng chạm
  Future<void> _handleTapToFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final tapPos = details.localPosition;
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    if (screenWidth <= 0 || screenHeight <= 0) return;

    final normalizedPoint = Offset(
      (tapPos.dx / screenWidth).clamp(0.0, 1.0),
      (tapPos.dy / screenHeight).clamp(0.0, 1.0),
    );

    setState(() {
      _focusPointScreen = tapPos;
      _showFocusIndicator = true;
    });

    _focusIndicatorTimer?.cancel();
    _focusIndicatorTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showFocusIndicator = false);
      }
    });

    HapticFeedback.selectionClick();

    try {
      await controller.setFocusPoint(normalizedPoint);
    } catch (_) {}

    try {
      await controller.setExposurePoint(normalizedPoint);
    } catch (_) {}
  }

  Future<void> _setZoomLevel(double zoom) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final target = zoom.clamp(_minZoomLevel, _maxZoomLevel);
    try {
      await controller.setZoomLevel(target);
      setState(() => _currentZoomLevel = target);
    } catch (_) {}
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null || _pointers < 2) return;
    final newZoom = (_baseScale * details.scale).clamp(_minZoomLevel, _maxZoomLevel);
    await _setZoomLevel(newZoom);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    try {
      setState(() => _isTakingPhoto = true);
      HapticFeedback.mediumImpact();

      // Chụp ảnh trực tiếp với độ nét tối đa (không khóa tiêu cự đột ngột)
      final XFile xFile = await controller.takePicture();
      final file = File(xFile.path);

      if (mounted) {
        setState(() {
          _capturedFile = file;
          _isTakingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chụp ảnh: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Giữ 100% chất lượng gốc không nén ảnh khi chọn từ thư viện
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (xFile != null && mounted) {
        setState(() {
          _capturedFile = File(xFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  /// Mở ứng dụng Camera gốc của điện thoại (hỗ trợ chuyển đổi ống kính & Macro của hệ điều hành)
  Future<void> _pickFromNativeCamera() async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (xFile != null && mounted) {
        Navigator.of(context).pop(File(xFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở máy ảnh gốc: $e')),
        );
      }
    }
  }

  void _confirmPhoto() {
    if (_capturedFile != null) {
      Navigator.of(context).pop(_capturedFile);
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _capturedFile != null
            ? _buildPreviewScreen()
            : _buildCameraCaptureScreen(),
      ),
    );
  }

  /// Màn hình Camera chụp với Khung căn chỉnh ID Card
  Widget _buildCameraCaptureScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers = (_pointers - 1).clamp(0, 10),
          onPointerCancel: (_) => _pointers = (_pointers - 1).clamp(0, 10),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (details) {
              if (_pointers <= 1) {
                _handleTapToFocus(details, constraints);
              }
            },
            child: Stack(
            fit: StackFit.expand,
            children: [
              // Camera Viewfinder
              if (_isCameraReady && _controller != null)
                Center(
                  child: CameraPreview(_controller!),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.camera_slash,
                            size: 54, color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Iconsax.gallery),
                          label: const Text('Chọn ảnh từ Thư viện'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),

              // Lớp phủ khung căn chỉnh (Card Overlay Mask)
              _buildCardOverlay(context, constraints),

              // Hiệu ứng vòng tròn lấy nét khi chạm (Focus Ring Indicator)
              if (_showFocusIndicator && _focusPointScreen != null)
                Positioned(
                  left: _focusPointScreen!.dx - 32,
                  top: _focusPointScreen!.dy - 32,
                  child: _buildFocusRing(),
                ),

              // Thanh điều hướng trên cùng (Top Bar)
              Positioned(
                top: 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        'Chụp ${widget.sideTitle} CCCD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                      ),
                      icon: Icon(
                        _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _isFlashOn ? Colors.amber : Colors.white,
                        size: 22,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),

              // Dòng hướng dẫn người dùng
              Positioned(
                bottom: 155,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.hintText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '💡 Cầm máy cách thẻ 20 - 25cm (không đưa sát thẻ). Thẻ nằm trong khung là quét được!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Phím chuyển nhanh mức thu phóng (Zoom Selector)
              Positioned(
                bottom: 110,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildZoomControl(),
                ),
              ),

              // Thanh điều khiển chụp ảnh bên dưới (Bottom Controls)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút Chọn ảnh từ Gallery
                    InkWell(
                      onTap: _pickFromGallery,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.gallery,
                            color: Colors.white, size: 24),
                      ),
                    ),

                    // Nút Chụp chính (Shutter Button)
                    GestureDetector(
                      onTap: _isTakingPhoto ? null : _takePicture,
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                _isTakingPhoto ? Colors.white60 : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: _isTakingPhoto
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Nút Mở máy ảnh gốc hệ thống (dành cho người muốn chụp trực tiếp từ Apple Camera)
                    InkWell(
                      onTap: _pickFromNativeCamera,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.camera5,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  /// Nút chuyển nhanh mức Zoom (1x, 1.5x, 2x)
  Widget _buildZoomControl() {
    final options = [1.0, 1.5, 2.0];
    final availableOptions = options
        .where((z) => z <= _maxZoomLevel && z >= _minZoomLevel)
        .toList();
    if (availableOptions.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableOptions.map((zoom) {
          final isSelected = (_currentZoomLevel - zoom).abs() < 0.15;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _setZoomLevel(zoom);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${zoom.toStringAsFixed(zoom.truncateToDouble() == zoom ? 0 : 1)}x',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Vòng tròn chỉ thị lấy nét mô phỏng máy ảnh chuyên nghiệp
  Widget _buildFocusRing() {
    return IgnorePointer(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 14,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  /// Màn hình xem lại ảnh vừa chụp (Hỗ trợ Pinch-to-Zoom để soi rõ từng chi tiết)
  Widget _buildPreviewScreen() {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: _retakePhoto,
              ),
              Text(
                'Kiểm tra ${widget.sideTitle}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),

        // Ảnh Preview với hỗ trợ Pinch-to-Zoom
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.file(
                  _capturedFile!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // Dòng nhắc kiểm tra độ rõ nét
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              Text(
                'Hãy chắc chắn rằng số CCCD và toàn bộ thông tin trên thẻ đều nhìn rõ, không bị mờ nhòe hay che khuất.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                '🔍 Dùng 2 ngón tay phóng to để kiểm tra độ sắc nét',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Chụp lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmPhoto,
                  icon: const Icon(Iconsax.tick_circle, size: 18),
                  label: const Text('Dùng ảnh này'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget vẽ Lớp phủ tạo Khung căn chỉnh ID Card chuẩn ngân hàng
Widget _buildCardOverlay(BuildContext context, BoxConstraints constraints) {
  return CustomPaint(
    size: Size(constraints.maxWidth, constraints.maxHeight),
    painter: _CardOverlayPainter(),
  );
}

class _CardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tỉ lệ thẻ CCCD tiêu chuẩn ISO/IEC 7810 ID-1: 85.60 mm × 53.98 mm (~ 1.586 : 1)
    const cardRatio = 1.586;

    // Chiều rộng khung thẻ 78% màn hình giúp người dùng giữ khoảng cách tự nhiên (20-25cm),
    // kết hợp với mức Zoom mặc định 1.6x giúp loại bỏ triệt để hiện tượng mờ tiêu cự cận cảnh (Macro blur).
    final cardWidth = size.width * 0.78;
    final cardHeight = cardWidth / cardRatio;

    final cardLeft = (size.width - cardWidth) / 2;
    // Đặt khung hơi dịch lên trên một chút để chừa chỗ cho cụm zoom và nút chụp
    final cardTop = (size.height - cardHeight) / 2 - 45;

    final cardRect = Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);
    final cardRRect =
        RRect.fromRectAndRadius(cardRect, const Radius.circular(16));

    // 1. Vẽ nền đen mờ bao quanh (Mask)
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cardRRect);
    final maskPath =
        Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, maskPaint);

    // 2. Vẽ viền nét đứt mỏng cho khung thẻ
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(cardRRect, borderPaint);

    // 3. Vẽ 4 góc định vị (Corner Brackets) nổi bật chuẩn ngân hàng
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;
    const radius = 16.0;

    // Góc trên bên trái
    canvas.drawPath(
      Path()
        ..moveTo(cardLeft, cardTop + cornerLength)
        ..lineTo(cardLeft, cardTop + radius)
        ..arcToPoint(Offset(cardLeft + radius, cardTop),
            radius: const Radius.circular(radius))
        ..lineTo(cardLeft + cornerLength, cardTop),
      cornerPaint,
    );

    // Góc trên bên phải
    canvas.drawPath(
      Path()
        ..moveTo(cardLeft + cardWidth - cornerLength, cardTop)
        ..lineTo(cardLeft + cardWidth - radius, cardTop)
        ..arcToPoint(Offset(cardLeft + cardWidth, cardTop + radius),
            radius: const Radius.circular(radius))
        ..lineTo(cardLeft + cardWidth, cardTop + cornerLength),
      cornerPaint,
    );

    // Góc dưới bên trái
    canvas.drawPath(
      Path()
        ..moveTo(cardLeft, cardTop + cardHeight - cornerLength)
        ..lineTo(cardLeft, cardTop + cardHeight - radius)
        ..arcToPoint(Offset(cardLeft + radius, cardTop + cardHeight),
            radius: const Radius.circular(radius))
        ..lineTo(cardLeft + cornerLength, cardTop + cardHeight),
      cornerPaint,
    );

    // Góc dưới bên phải
    canvas.drawPath(
      Path()
        ..moveTo(cardLeft + cardWidth - cornerLength, cardTop + cardHeight)
        ..lineTo(cardLeft + cardWidth - radius, cardTop + cardHeight)
        ..arcToPoint(
            Offset(cardLeft + cardWidth, cardTop + cardHeight - radius),
            radius: const Radius.circular(radius))
        ..lineTo(cardLeft + cardWidth, cardTop + cardHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
