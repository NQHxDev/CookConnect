import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:cookconnect/features/recipe/data/models/video_segment.dart';
import 'package:cookconnect/features/recipe/presentation/pages/upload_screen.dart';

class CookingCameraScreen extends StatefulWidget {
  final List<VideoSegment>? existingSegments;
  final String? initialSoundtrack;

  const CookingCameraScreen({
    super.key,
    this.existingSegments,
    this.initialSoundtrack,
  });

  @override
  State<CookingCameraScreen> createState() => _CookingCameraScreenState();
}

class _CookingCameraScreenState extends State<CookingCameraScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  // Mode durations
  final List<int> _durations = [15, 60, 180];
  int _selectedDurationIndex = 1; // Mặc định 60s
  int get _maxSeconds => _durations[_selectedDurationIndex];

  // Trạng thái quay & danh sách phân đoạn
  final List<VideoSegment> _segments = [];
  bool _isRecording = false;
  Timer? _recordTimer;
  int _currentSegmentMillis = 0;
  bool _showMinDurationWarning = false;
  Timer? _minDurationWarningTimer;

  // Nhạc nền / Âm thanh nấu ăn
  String _selectedSoundtrack = 'Âm thanh gốc - Nấu nướng ASMR';
  final List<String> _soundTracks = [
    'Âm thanh gốc - Nấu nướng ASMR',
    'Lofi Kitchen Beats - Nấu ăn chill',
    'Acoustic Guitar - Bữa sáng yên bình',
    'Xèo xèo bếp lửa - Tiếng áp chảo giòn rụm',
    'Nhịp điệu phố thị - Nấu nhanh 15 phút',
  ];

  // Thiết lập camera phần cứng & tuỳ chỉnh
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraInitializing = false;
  String? _cameraErrorMessage;

  bool _isFrontCamera = false;
  bool _isFlipping = false;
  double _currentSpeed = 1.0;
  bool _showSpeedBar = false;
  bool _showGrid = false;
  bool _isFlashOn = false;
  bool _isAsmrMicOn = true;

  // Bộ lọc màu ẩm thực
  String _selectedFilter = 'Tự nhiên';
  final Map<String, Color> _foodFilters = {
    'Tự nhiên': Colors.transparent,
    'Ấm nồng (Nướng)': const Color(0x26FFA726),
    'Tươi xanh (Salad)': const Color(0x2066BB6A),
    'Vàng giòn (Chiên)': const Color(0x2BFFA000),
    'Điện ảnh ASMR': const Color(0x303F51B5),
  };

  // Hẹn giờ đếm ngược trước khi quay (0: Tắt, 3: 3s, 10: 10s)
  int _countdownSeconds = 0;
  int _selectedCountdownOption = 0;
  Timer? _countdownTimer;

  // Chạm lấy nét (Touch to focus)
  Offset? _focusPoint;
  Timer? _focusResetTimer;

  // Animation Controllers
  late AnimationController _shutterPulseController;
  late AnimationController _musicSpinController;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.existingSegments != null) {
      _segments.addAll(widget.existingSegments!);
    }
    if (widget.initialSoundtrack != null) {
      _selectedSoundtrack = widget.initialSoundtrack!;
    }

    _shutterPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _musicSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _countdownTimer?.cancel();
    _focusResetTimer?.cancel();
    _minDurationWarningTimer?.cancel();
    _shutterPulseController.dispose();
    _musicSpinController.dispose();
    _flipController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera({CameraDescription? description}) async {
    if (!mounted) return;
    setState(() {
      _isCameraInitializing = true;
      _cameraErrorMessage = null;
    });

    try {
      if (_availableCameras.isEmpty) {
        _availableCameras = await availableCameras();
      }

      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraInitializing = false;
            _cameraErrorMessage = 'Không tìm thấy camera trên thiết bị.';
          });
        }
        return;
      }

      final selectedCamera = description ??
          _availableCameras.firstWhere(
            (c) =>
                c.lensDirection ==
                (_isFrontCamera
                    ? CameraLensDirection.front
                    : CameraLensDirection.back),
            orElse: () => _availableCameras.first,
          );

      final prevController = _cameraController;
      _cameraController = null;
      await prevController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: _isAsmrMicOn,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (_isFlashOn &&
          selectedCamera.lensDirection == CameraLensDirection.back) {
        try {
          await controller.setFlashMode(FlashMode.torch);
        } catch (_) {}
      } else {
        try {
          await controller.setFlashMode(FlashMode.off);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isCameraInitializing = false;
          _isFrontCamera =
              selectedCamera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
          _isCameraInitialized = false;
          _cameraErrorMessage = 'Không thể khởi động máy ảnh: $e';
        });
      }
    }
  }

  int get _totalRecordedMillis {
    final recorded = _segments.fold<int>(
      0,
      (sum, item) => sum + item.duration.inMilliseconds,
    );
    return recorded + (_isRecording ? _currentSegmentMillis : 0);
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    final maxMillis = _maxSeconds * 1000;
    if (_totalRecordedMillis >= maxMillis) {
      HapticFeedback.heavyImpact();
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể bắt đầu quay: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _currentSegmentMillis = 0;
    });

    const interval = 50; // Chu kỳ 50ms để thanh tiến trình mượt mà
    _recordTimer = Timer.periodic(const Duration(milliseconds: interval), (t) {
      final effectiveSpeed = _currentSpeed <= 0 ? 1.0 : _currentSpeed;
      final addedMillis = (interval * effectiveSpeed).toInt();

      if (!mounted) {
        t.cancel();
        return;
      }

      setState(() {
        _currentSegmentMillis += addedMillis;
        if (_totalRecordedMillis >= maxMillis) {
          _stopRecording();
        }
      });
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    HapticFeedback.mediumImpact();
    _recordTimer?.cancel();

    XFile? recordedFile;
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo) {
      try {
        recordedFile = await _cameraController!.stopVideoRecording();
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
      }
    }

    final segDuration = Duration(milliseconds: _currentSegmentMillis);
    if (segDuration.inMilliseconds >= 400 && recordedFile != null) {
      final stepIndex = _segments.length + 1;
      final newSegment = VideoSegment(
        id: 'seg_${DateTime.now().millisecondsSinceEpoch}_$stepIndex',
        path: recordedFile.path,
        duration: segDuration,
        speed: _currentSpeed,
        filterName: _selectedFilter,
        soundTrack: _selectedSoundtrack,
        label: 'Phân đoạn $stepIndex',
      );
      _segments.add(newSegment);
    }

    setState(() {
      _isRecording = false;
      _currentSegmentMillis = 0;
    });
  }

  void _triggerRecordingWithCountdown() {
    if (_isRecording) {
      _stopRecording();
      return;
    }

    if (_selectedCountdownOption > 0) {
      setState(() => _countdownSeconds = _selectedCountdownOption);
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        HapticFeedback.selectionClick();
        if (_countdownSeconds <= 1) {
          timer.cancel();
          setState(() => _countdownSeconds = 0);
          _startRecording();
        } else {
          setState(() => _countdownSeconds -= 1);
        }
      });
    } else {
      _startRecording();
    }
  }

  void _handleDeleteLastSegment() {
    if (_segments.isEmpty) return;
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF262626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Text(
                  'Xóa bỏ clip gần nhất?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.6, color: Colors.white24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 0.6,
                    height: 44,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          if (_segments.isNotEmpty) {
                            _segments.removeLast();
                          }
                        });
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                            color: Color(0xFFFF4D30),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2 || _isFlipping || _isCameraInitializing) {
      return;
    }
    _isFlipping = true;

    try {
      HapticFeedback.lightImpact();
      _flipController.forward(from: 0.0);

      final targetDirection = _isFrontCamera
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      // Tìm camera của hướng đối diện
      final nextCamera = _availableCameras.firstWhere(
        (c) => c.lensDirection == targetDirection,
        orElse: () => _availableCameras.firstWhere(
          (c) => c != _cameraController?.description,
          orElse: () => _availableCameras.first,
        ),
      );

      // Chuyển camera nhanh và mượt mà qua setDescription
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.setDescription(nextCamera);
      } else {
        await _initCamera(description: nextCamera);
      }

      if (_isFlashOn && nextCamera.lensDirection == CameraLensDirection.back) {
        try {
          await _cameraController?.setFlashMode(FlashMode.torch);
        } catch (_) {}
      } else {
        try {
          await _cameraController?.setFlashMode(FlashMode.off);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isFrontCamera =
              nextCamera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      debugPrint('Error flipping camera with setDescription: $e');
      // Fallback nếu máy không hỗ trợ đổi camera động
      try {
        final targetDirection = _isFrontCamera
            ? CameraLensDirection.back
            : CameraLensDirection.front;
        final nextCamera = _availableCameras.firstWhere(
          (c) => c.lensDirection == targetDirection,
          orElse: () => _availableCameras.first,
        );
        await _initCamera(description: nextCamera);
      } catch (err) {
        debugPrint('Fallback flip camera error: $err');
      }
    } finally {
      _isFlipping = false;
    }
  }

  Future<void> _toggleFlash() async {
    final nextFlash = !_isFlashOn;
    setState(() => _isFlashOn = nextFlash);
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setFlashMode(
          nextFlash ? FlashMode.torch : FlashMode.off,
        );
      } catch (_) {}
    }
  }

  void _toggleMic() {
    HapticFeedback.selectionClick();
    setState(() {
      _isAsmrMicOn = !_isAsmrMicOn;
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null && mounted) {
        _navigateToEditor(
          videoPath: picked.path,
          videoFileName: picked.name,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn video: $e')));
      }
    }
  }

  void _showMinDurationAlert() {
    HapticFeedback.lightImpact();
    _minDurationWarningTimer?.cancel();
    setState(() => _showMinDurationWarning = true);
    _minDurationWarningTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _showMinDurationWarning = false);
      }
    });
  }

  @visibleForTesting
  Future<void> navigateToEditorForTesting({String? videoPath, String? videoFileName}) {
    return _navigateToEditor(videoPath: videoPath, videoFileName: videoFileName);
  }

  Future<void> _navigateToEditor({String? videoPath, String? videoFileName}) async {
    if (videoPath == null && _totalRecordedMillis < 3000) {
      _showMinDurationAlert();
      return;
    }
    final finalVideoPath =
        videoPath ??
        (_segments.isNotEmpty
            ? _segments.first.path
            : 'cooking_merged_clip.mp4');
    final finalFileName =
        videoFileName ??
        'CookConnect_Clip_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      _cameraController?.pausePreview().catchError((_) {});
    } catch (_) {}

    final nav = Navigator.of(context);
    final published = await nav.push<bool>(
      MaterialPageRoute(
        builder: (editorContext) => UploadScreen(
          initialVideoPath: finalVideoPath,
          initialVideoFileName: finalFileName,
          initialSegments: List.from(_segments),
          initialSoundtrack: _selectedSoundtrack,
          onCancel: () {
            if (editorContext.mounted) {
              Navigator.of(editorContext).pop(false);
            }
          },
          onPublished: () {
            if (editorContext.mounted) {
              Navigator.of(editorContext).pop(true);
            }
          },
        ),
      ),
    );

    if (published == true && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      try {
        _cameraController?.resumePreview().catchError((_) {});
      } catch (_) {}
    }
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Iconsax.music, color: Color(0xFFFF4D30)),
                    SizedBox(width: 8),
                    Text(
                      'Kho âm thanh nấu nướng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ..._soundTracks.map((sound) {
                final isSelected = sound == _selectedSoundtrack;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xFFFF4D30)
                        : Colors.white12,
                    child: Icon(
                      Iconsax.music_dashboard,
                      color: isSelected ? Colors.white : Colors.white70,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    sound,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFFFF4D30) : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFFF4D30))
                      : const Icon(Iconsax.play, color: Colors.white38, size: 20),
                  onTap: () {
                    setState(() => _selectedSoundtrack = sound);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bộ lọc màu Món Ăn bắt mắt',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _foodFilters.keys.map((filterName) {
                    final isSelected = filterName == _selectedFilter;
                    final color = _foodFilters[filterName]!;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filterName);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color == Colors.transparent
                                    ? Colors.grey.shade800
                                    : color.withValues(alpha: 0.9),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF4D30)
                                      : Colors.white24,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Iconsax.magicpen,
                                  color: isSelected
                                      ? const Color(0xFFFF4D30)
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filterName,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF4D30)
                                    : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimerCountdownPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hẹn giờ tự động bấm máy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tự động đếm ngược để bạn rảnh tay chuẩn bị đứng vào bếp!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCountdownOption(0, 'Tắt', setModalState),
                    const SizedBox(width: 14),
                    _buildCountdownOption(3, '3 giây', setModalState),
                    const SizedBox(width: 14),
                    _buildCountdownOption(10, '10 giây', setModalState),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D30),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Xác nhận hẹn giờ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOption(
      int seconds, String label, StateSetter setModalState) {
    final isSelected = _selectedCountdownOption == seconds;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedCountdownOption = seconds;
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4D30) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _onTapViewfinder(
      TapDownDetails details, BoxConstraints constraints) async {
    final mediaQuery = MediaQuery.of(context);
    final topBoundary = mediaQuery.padding.top + 70.0;
    final bottomBoundary = constraints.maxHeight -
        mediaQuery.padding.bottom -
        (_showSpeedBar ? 220.0 : 185.0);
    final rightBoundary = constraints.maxWidth - 75.0;
    const leftBoundary = 10.0;

    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // Chỉ cho phép lấy nét trong phạm vi ô quay:
    // Không nhận chạm ở header, cột option bên phải hoặc từ nút quay trở xuống
    if (tapX < leftBoundary ||
        tapX > rightBoundary ||
        tapY < topBoundary ||
        tapY > bottomBoundary) {
      return;
    }

    const boxHalf = 30.0;
    final clampedX =
        tapX.clamp(leftBoundary + boxHalf, rightBoundary - boxHalf);
    final clampedY =
        tapY.clamp(topBoundary + boxHalf, bottomBoundary - boxHalf);

    setState(() {
      _focusPoint = Offset(clampedX, clampedY);
    });
    _focusResetTimer?.cancel();
    _focusResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _focusPoint = null);
    });

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final offset = Offset(
          (clampedX / constraints.maxWidth).clamp(0.0, 1.0),
          (clampedY / constraints.maxHeight).clamp(0.0, 1.0),
        );
        await _cameraController!.setFocusPoint(offset);
        await _cameraController!.setExposurePoint(offset);
      } catch (_) {}
    }
  }

  void _handleClose() {
    if (_segments.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF222222),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Hủy bỏ các đoạn video?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Nếu thoát bây giờ, các phân đoạn nấu ăn bạn vừa quay sẽ không được lưu.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tiếp tục quay',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D30),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pop();
              },
              child: const Text('Bỏ và Thoát'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Viewport máy quay chân thực từ cảm biến camera
              GestureDetector(
                onTapDown: (details) => _onTapViewfinder(details, constraints),
                child: _buildCameraViewport(),
              ),

              // Chỉ báo điểm lấy nét khi chạm (giới hạn trong ô quay)
              if (_focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx - 30,
                  top: _focusPoint!.dy - 30,
                  child: IgnorePointer(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Lưới bố cục 3x3 căn góc đĩa thức ăn
              if (_showGrid) _buildGridOverlay(),

              // Đếm ngược 3... 2... 1... to giữa màn hình khi hẹn giờ
              if (_countdownSeconds > 0) _buildCountdownOverlay(),

              // Thanh công cụ trên cùng (Đóng, Chọn nhạc, Thanh tiến trình ngắt đoạn)
              _buildTopOverlay(),

              // Cột công cụ bên phải (Lật, Tốc độ, Hẹn giờ, Flash, Bộ lọc, Lưới, Mic ASMR)
              _buildRightSidebar(),

              // Khu vực điều khiển dưới đáy (Nút quay đỏ, Xoá đoạn, Tải lên, Tiếp tục)
              _buildBottomControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraViewport() {
    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        final angle = _flipController.value * math.pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Luồng Camera thật hoặc Fallback
              if (_isCameraInitialized && _cameraController != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize?.height ?? 1,
                      height: _cameraController!.value.previewSize?.width ?? 1,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              else if (_isCameraInitializing)
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFFF4D30),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang khởi động máy ảnh...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_off_outlined,
                            color: Colors.white.withValues(alpha: 0.35),
                            size: 52,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _cameraErrorMessage ?? 'Chưa kết nối được máy ảnh',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4D30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _initCamera(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Gradient mờ trên dưới cho các icon điều khiển dễ nhìn
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.18, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Lớp màu bộ lọc ẩm thực
              if (_foodFilters[_selectedFilter] != Colors.transparent)
                Container(color: _foodFilters[_selectedFilter]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridOverlay() {
    return IgnorePointer(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white24)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white24)),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_countdownSeconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 100,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chuẩn bị quay video công thức...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh tiến trình phân đoạn
          _buildSegmentedProgressBar(),

          const SizedBox(height: 10),

          // Hàng hành động trên đỉnh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Đóng [X]
                IconButton(
                  onPressed: _handleClose,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                  ),
                ),

                // Pill chọn nhạc nền
                GestureDetector(
                  onTap: _showSoundPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotationTransition(
                          turns: _musicSpinController,
                          child: const Icon(
                            Iconsax.music,
                            color: Color(0xFFFF4D30),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            _selectedSoundtrack,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Giữ cân đối với nút đóng [X] bên trái
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Thông báo "Quay ít nhất 3 giây" xuất hiện bên dưới chỗ âm thanh
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _showMinDurationWarning
                ? Container(
                    key: const ValueKey('min_duration_warning'),
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Quay ít nhất 3 giây',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar() {
    final maxMillis = _maxSeconds * 1000;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;

          return Stack(
            children: [
              // Các đoạn đã quay xong
              Row(
                children: _segments.asMap().entries.map((entry) {
                  final seg = entry.value;
                  final segWidth =
                      (seg.duration.inMilliseconds / maxMillis) * totalWidth;
                  const color = Color(0xFFFF4D30); // Đỏ cam đặc trưng

                  return Row(
                    children: [
                      Container(
                        width: segWidth,
                        height: 5,
                        color: color,
                      ),
                      // Vạch chia trắng giữa các đoạn
                      Container(
                        width: 2,
                        height: 5,
                        color: Colors.white,
                      ),
                    ],
                  );
                }).toList(),
              ),

              // Đoạn hiện đang quay chạy theo thời gian thực
              if (_isRecording)
                Positioned(
                  left: (_segments.fold<int>(
                            0,
                            (sum, item) => sum + item.duration.inMilliseconds,
                          ) /
                          maxMillis) *
                      totalWidth,
                  child: Container(
                    width: (_currentSegmentMillis / maxMillis) * totalWidth,
                    height: 5,
                    color: const Color(0xFFFF4D30),
                  ),
                ),

              // Mốc thời lượng tối thiểu 3 giây
              Positioned(
                left: (3000 / maxMillis) * totalWidth,
                child: Container(
                  width: 1.5,
                  height: 5,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Positioned(
      right: 12,
      top: 100,
      child: SafeArea(
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSidebarItem(
                icon: Iconsax.camera,
                label: 'Lật',
                onTap: _flipCamera,
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: Iconsax.flash_1,
                label: 'Tốc độ',
                isActive: _showSpeedBar,
                onTap: () => setState(() => _showSpeedBar = !_showSpeedBar),
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: Iconsax.timer_1,
                label: _selectedCountdownOption > 0
                    ? '${_selectedCountdownOption}s'
                    : 'Hẹn giờ',
                isActive: _selectedCountdownOption > 0,
                onTap: _showTimerCountdownPicker,
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: _isFlashOn ? Iconsax.lamp_on : Iconsax.lamp_charge,
                label: 'Flash',
                isActive: _isFlashOn,
                onTap: _toggleFlash,
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: Iconsax.magicpen,
                label: 'Bộ lọc',
                isActive: _selectedFilter != 'Tự nhiên',
                onTap: _showFilterPicker,
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: Iconsax.grid_1,
                label: 'Lưới',
                isActive: _showGrid,
                onTap: () => setState(() => _showGrid = !_showGrid),
              ),
              const SizedBox(height: 14),
              _buildSidebarItem(
                icon: _isAsmrMicOn ? Iconsax.microphone : Iconsax.microphone_slash,
                label: 'ASMR',
                isActive: _isAsmrMicOn,
                onTap: _toggleMic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF4D30).withValues(alpha: 0.25)
                    : Colors.black26,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? const Color(0xFFFF4D30) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFFFF4D30) : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: isActive ? const Color(0xFFFF4D30) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final recordedSeconds = (_totalRecordedMillis / 1000.0).toStringAsFixed(1);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh chọn tốc độ
            if (_showSpeedBar) _buildSpeedSelector(),

            // Huy hiệu hiển thị thời gian đã quay
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$recordedSeconds s / $_maxSeconds s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hàng nút thao tác (Xoá đoạn, Nút quay Shutter, Thư viện / Tiếp tục)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Nút xoá đoạn gần nhất
                  SizedBox(
                    width: 60,
                    child: _segments.isNotEmpty && !_isRecording
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _handleDeleteLastSegment,
                                icon: const Icon(
                                  Icons.backspace_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              const Text(
                                'Xoá đoạn',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),

                  // Nút Quay chính giữa
                  GestureDetector(
                    onTap: _triggerRecordingWithCountdown,
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: _buildShutterButton(),
                  ),

                  // Bên phải: Tải lên thư viện hoặc Nút Dấu tích Tiếp tục
                  SizedBox(
                    width: 60,
                    child: _segments.isNotEmpty && !_isRecording
                        ? Builder(
                            builder: (context) {
                              final canProceed = _totalRecordedMillis >= 3000;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (!canProceed) {
                                        _showMinDurationAlert();
                                        return;
                                      }
                                      _navigateToEditor();
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      color: canProceed ? Colors.white : Colors.white38,
                                      size: 28,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: canProceed
                                          ? const Color(0xFFFF4D30)
                                          : Colors.white12,
                                    ),
                                  ),
                                  Text(
                                    'Tiếp tục',
                                    style: TextStyle(
                                      color: canProceed ? Colors.white : Colors.white38,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _pickFromGallery,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white12,
                                  ),
                                  child: const Icon(
                                    Iconsax.gallery,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tải lên',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chế độ thời lượng quay: 15s | 60s | 3m
            if (!_isRecording) _buildDurationCarousel(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return AnimatedBuilder(
      animation: _shutterPulseController,
      builder: (context, child) {
        final scale = _isRecording
            ? 1.0 + (_shutterPulseController.value * 0.08)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vòng tròn tiến trình TikTok với các vạch ngắt đoạn
                CustomPaint(
                  size: const Size(84, 84),
                  painter: _TikTokShutterRingPainter(
                    segments: _segments,
                    maxMillis: _maxSeconds * 1000,
                    currentSegmentMillis: _currentSegmentMillis,
                    isRecording: _isRecording,
                  ),
                ),
                // Nút đỏ trung tâm (thu nhỏ thành hình vuông bo góc khi quay)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 36 : 64,
                  height: _isRecording ? 36 : 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D30),
                    borderRadius: BorderRadius.circular(_isRecording ? 8 : 32),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedSelector() {
    final speeds = [0.3, 0.5, 1.0, 2.0, 3.0];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: speeds.map((speed) {
          final isSelected = speed == _currentSpeed;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentSpeed = speed);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${speed}x',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationCarousel() {
    final labels = ['15s', '60s', '3m'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: labels.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        final isSelected = idx == _selectedDurationIndex;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedDurationIndex = idx);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Painter vẽ vòng tròn tiến trình phong cách TikTok trên nút quay:
/// - Vòng nền xám biểu thị tổng thời lượng (15s, 60s, 3m).
/// - Tiến trình các đoạn quay chạy từ từ (màu đỏ cam đặc trưng).
/// - Điểm ngắt giữa các đoạn có vạch vàng nhỏ báo hiệu điểm dừng chờ quay tiếp.
/// - Phân đoạn cuối cùng chuyển sang màu vàng khi người dùng nhấn nút xoá đoạn.
class _TikTokShutterRingPainter extends CustomPainter {
  final List<VideoSegment> segments;
  final int maxMillis;
  final int currentSegmentMillis;
  final bool isRecording;

  _TikTokShutterRingPainter({
    required this.segments,
    required this.maxMillis,
    required this.currentSegmentMillis,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // 1. Vòng tròn nền ban đầu màu xám mờ
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (maxMillis <= 0) return;

    // Bắt đầu từ đỉnh 12h (-pi / 2) theo chiều kim đồng hồ
    double currentAngle = -math.pi / 2;
    const totalAngle = 2 * math.pi;

    // 2. Vẽ các phân đoạn đã quay
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      double sweepAngle = (seg.duration.inMilliseconds / maxMillis) * totalAngle;
      if (currentAngle + sweepAngle > (-math.pi / 2 + totalAngle)) {
        sweepAngle = (-math.pi / 2 + totalAngle) - currentAngle;
      }
      if (sweepAngle <= 0) break;

      final segPaint = Paint()
        ..color = const Color(0xFFFF4D30) // Màu đỏ cam quay
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        false,
        segPaint,
      );

      currentAngle += sweepAngle;

      // Vạch vàng nhỏ tại điểm ngắt phân đoạn
      final tickInnerR = radius - (strokeWidth / 2) - 2.0;
      final tickOuterR = radius + (strokeWidth / 2) + 2.0;
      final tickPaint = Paint()
        ..color = const Color(0xFFFFB800)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final p1 = Offset(
        center.dx + tickInnerR * math.cos(currentAngle),
        center.dy + tickInnerR * math.sin(currentAngle),
      );
      final p2 = Offset(
        center.dx + tickOuterR * math.cos(currentAngle),
        center.dy + tickOuterR * math.sin(currentAngle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Vẽ đoạn hiện đang quay chạy từ từ theo thời gian thực
    if (isRecording && currentSegmentMillis > 0) {
      double activeSweep = (currentSegmentMillis / maxMillis) * totalAngle;
      if (currentAngle + activeSweep > (-math.pi / 2 + totalAngle)) {
        activeSweep = (-math.pi / 2 + totalAngle) - currentAngle;
      }
      if (activeSweep > 0) {
        final activePaint = Paint()
          ..color = const Color(0xFFFF4D30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          activeSweep,
          false,
          activePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TikTokShutterRingPainter oldDelegate) {
    return oldDelegate.segments.length != segments.length ||
        oldDelegate.currentSegmentMillis != currentSegmentMillis ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.maxMillis != maxMillis;
  }
}
