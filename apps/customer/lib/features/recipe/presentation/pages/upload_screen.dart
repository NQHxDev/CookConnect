import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/models/video_segment.dart';
import 'package:cookconnect/features/recipe/presentation/pages/cooking_camera_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/recipe_post_details_screen.dart';

class UploadScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onPublished;
  final String? initialVideoPath;
  final String? initialVideoFileName;
  final List<VideoSegment>? initialSegments;
  final String? initialSoundtrack;

  const UploadScreen({
    super.key,
    this.onCancel,
    this.onPublished,
    this.initialVideoPath,
    this.initialVideoFileName,
    this.initialSegments,
    this.initialSoundtrack,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();

  // Selected media info
  String? _videoPath;
  String? _videoFileName;
  bool _isPresetVideo = false;
  final List<VideoSegment> _recordedSegments = [];

  // Specs (Placed directly above Ingredients)
  final TextEditingController _timeController = TextEditingController(text: '25');
  final TextEditingController _caloriesController = TextEditingController(text: '450');
  final TextEditingController _servingsController = TextEditingController(text: '2');
  String _selectedCategory = 'Món chính';
  String _selectedDifficulty = 'Trung bình';

  final List<String> _categories = [
    'Món chính',
    'Món nước',
    'Eat Clean',
    'Bánh ngọt',
    'Đồ uống',
    'Món chay',
    'Ăn vặt',
    'Món nhanh (<15p)',
  ];

  final List<String> _difficulties = ['Dễ', 'Trung bình', 'Khó'];

  // Ingredients (Required)
  final List<Ingredient> _ingredients = [
    Ingredient(id: '1', name: 'Thịt bò hoặc sườn heo', amount: '300g'),
    Ingredient(id: '2', name: 'Hành tím & tỏi băm nhuyễn', amount: '2 củ'),
    Ingredient(
      id: '3',
      name: 'Gia vị: Nước mắm, tiêu, dầu hào',
      amount: 'Vừa đủ',
    ),
  ];

  // Steps (Optional)
  final List<CookingStep> _steps = [
    const CookingStep(
      stepNumber: 1,
      title: 'Sơ chế nguyên liệu',
      description:
          'Rửa sạch nguyên liệu với nước muối loãng, cắt miếng vừa ăn và để ráo nước.',
      tip: 'Nên dùng khăn sạch thấm khô để khi áp chảo thịt không bị bắn dầu.',
      durationMinutes: 5,
    ),
    const CookingStep(
      stepNumber: 2,
      title: 'Ướp và nấu lửa vừa',
      description:
          'Ướp đều gia vị trong 10-15 phút rồi đảo đều trên chảo nóng thơm lừng.',
      tip: 'Đảo nhanh tay để nguyên liệu giữ trọn vị ngọt tự nhiên.',
      durationMinutes: 10,
    ),
  ];

  // Quick suggestions for ingredients
  final List<String> _quickIngredients = [
    'Thịt bò',
    'Thịt heo',
    'Ức gà',
    'Tôm tươi',
    'Trứng gà',
    'Hành tím',
    'Tỏi băm',
    'Hành lá',
    'Nước mắm',
    'Dầu ăn',
    'Tiêu xay',
    'Hạt nêm',
    'Ớt tươi',
    'Gừng tươi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoPath != null) {
      _videoPath = widget.initialVideoPath;
      _videoFileName = widget.initialVideoFileName ?? 'Video nấu ăn đã quay';
      _isPresetVideo = false;
    }
    if (widget.initialSegments != null) {
      _recordedSegments.addAll(widget.initialSegments!);
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _caloriesController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _openCookingCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CookingCameraScreen(
          existingSegments: List.from(_recordedSegments),
        ),
      ),
    );
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null) {
        setState(() {
          _videoPath = picked.path;
          _videoFileName = picked.name;
          _isPresetVideo = false;
          _recordedSegments.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn video: $e')));
      }
    }
  }

  void _usePresetDemoVideo() {
    setState(() {
      _videoPath = 'preset_demo_cooking_video.mp4';
      _videoFileName = 'demo_chef_cooking.mp4 (Mẫu nướng áp chảo)';
      _isPresetVideo = true;
      _recordedSegments.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã chọn video mẫu nướng áp chảo để trải nghiệm đăng bài!',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddIngredientDialog({Ingredient? editItem, int? index, String? prefillName}) {
    final nameCtrl = TextEditingController(text: editItem?.name ?? prefillName ?? '');
    final amountCtrl = TextEditingController(text: editItem?.amount ?? '');

    final quickUnits = ['300g', '500g', '1kg', '2 quả', '2 củ', '1 muỗng canh', '1 thìa cafe', 'Vừa đủ'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              editItem == null ? 'Thêm nguyên liệu' : 'Chỉnh sửa nguyên liệu',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: editItem == null && prefillName == null,
                    decoration: InputDecoration(
                      labelText: 'Tên nguyên liệu *',
                      hintText: 'VD: Thịt ba chỉ, Cà chua...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountCtrl,
                    autofocus: prefillName != null,
                    decoration: InputDecoration(
                      labelText: 'Định lượng',
                      hintText: 'VD: 300g, 2 muỗng canh, Vừa đủ...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gợi ý định lượng nhanh:',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickUnits.map((u) {
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            amountCtrl.text = u;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            u,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D30),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final amount = amountCtrl.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      if (editItem != null && index != null) {
                        _ingredients[index] = editItem.copyWith(
                          name: name,
                          amount: amount.isEmpty ? 'Vừa đủ' : amount,
                        );
                      } else {
                        _ingredients.add(
                          Ingredient(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            amount: amount.isEmpty ? 'Vừa đủ' : amount,
                          ),
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddStepDialog({CookingStep? editItem, int? index}) {
    final titleCtrl = TextEditingController(text: editItem?.title ?? '');
    final descCtrl = TextEditingController(text: editItem?.description ?? '');
    final tipCtrl = TextEditingController(text: editItem?.tip ?? '');
    final durationCtrl = TextEditingController(
      text: editItem?.durationMinutes?.toString() ?? '5',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          editItem == null
              ? 'Thêm bước thực hiện (Tùy chọn)'
              : 'Chỉnh sửa bước ${editItem.stepNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề bước *',
                  hintText: 'VD: Phi thơm hành tỏi',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Chi tiết thao tác *',
                  hintText: 'Mô tả cụ thể cách thao tác, nhiệt độ, độ chín...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tipCtrl,
                decoration: InputDecoration(
                  labelText: 'Mẹo / Bí quyết đầu bếp (Tùy chọn)',
                  hintText: 'VD: Đảo lửa lớn để không ra nước',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Thời gian ước tính (phút, tùy chọn)',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D30),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (title.isNotEmpty && desc.isNotEmpty) {
                final dur = int.tryParse(durationCtrl.text.trim()) ?? 5;
                final tip = tipCtrl.text.trim().isEmpty ? null : tipCtrl.text.trim();
                setState(() {
                  if (editItem != null && index != null) {
                    _steps[index] = CookingStep(
                      stepNumber: editItem.stepNumber,
                      title: title,
                      description: desc,
                      tip: tip,
                      durationMinutes: dur,
                    );
                  } else {
                    _steps.add(
                      CookingStep(
                        stepNumber: _steps.length + 1,
                        title: title,
                        description: desc,
                        tip: tip,
                        durationMinutes: dur,
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _onNextStep() {
    // 1. Validate video
    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng quay video hoặc chọn video từ thư viện trước khi tiếp tục!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Validate ingredients
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất 1 nguyên liệu cho món ăn của bạn!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Cooking steps are OPTIONAL, so no error if steps is empty.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipePostDetailsScreen(
          videoPath: _videoPath,
          videoFileName: _videoFileName,
          isPresetVideo: _isPresetVideo,
          recordedSegments: List.from(_recordedSegments),
          ingredients: List.from(_ingredients),
          steps: List.from(_steps),
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          cookTimeMinutes: int.tryParse(_timeController.text.trim()) ?? 25,
          servings: int.tryParse(_servingsController.text.trim()) ?? 2,
          calories: int.tryParse(_caloriesController.text.trim()) ?? 450,
          onPublished: () {
            if (widget.onPublished != null) {
              widget.onPublished!();
            } else if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Nguyên liệu & Cách làm',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              'Bước 1/2: Nhập công thức',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        actions: [
          TextButton(
            onPressed: _onNextStep,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tiếp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFFF4D30),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFFF4D30)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Video status header card
              _buildVideoStatusCard(),
              const SizedBox(height: 16),

              // Thông số món ăn (Chuyển sang đây và đặt TRÊN mục Nguyên liệu)
              _buildRecipeSpecsCard(),
              const SizedBox(height: 16),

              // Section 1: Ingredients
              _buildIngredientsCard(),
              const SizedBox(height: 16),

              // Section 2: Steps (Optional)
              _buildStepsCard(),
              const SizedBox(height: 20),
            ],
          ),

          // Bottom sticky action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_ingredients.length} nguyên liệu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _steps.isEmpty
                                ? 'Chưa có bước nấu (Tùy chọn)'
                                : '${_steps.length} bước nấu chi tiết',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onNextStep,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tiếp theo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thông số món ăn: Chuyên mục, Độ khó, Thời gian, Khẩu phần, Calo
  Widget _buildRecipeSpecsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.slider_horizontal, size: 18, color: Color(0xFFFF4D30)),
              const SizedBox(width: 8),
              const Text(
                'Thông số món ăn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown chuyên mục
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Chuyên mục món',
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Iconsax.category, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 12),

          // Chips độ khó
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text(
                'Độ khó: ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              ..._difficulties.map((diff) {
                final isSelected = diff == _selectedDifficulty;
                return ChoiceChip(
                  label: Text(
                    diff,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFECE8),
                  onSelected: (val) {
                    if (val) setState(() => _selectedDifficulty = diff);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Hàng thời gian, khẩu phần, calo
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Thời gian',
                    suffixText: 'phút',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Khẩu phần',
                    suffixText: 'người',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Calo',
                    suffixText: 'kcal',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStatusCard() {
    final hasVideo = _videoPath != null;

    if (!hasVideo) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFFECE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.video_play,
                color: Color(0xFFFF4D30),
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chưa có video nấu ăn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy quay clip nấu ăn hoặc chọn video từ điện thoại của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _openCookingCamera,
                    icon: const Icon(Iconsax.video_circle, size: 18),
                    label: const Text('Quay video'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Iconsax.gallery, size: 18),
                    label: const Text('Thư viện'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _usePresetDemoVideo,
              child: const Text(
                'Dùng thử video mẫu nướng áp chảo',
                style: TextStyle(fontSize: 12, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.videocam, color: Colors.white54, size: 28),
                  Container(color: Colors.black26),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _recordedSegments.isNotEmpty
                            ? const Color(0xFFFFECE8)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _recordedSegments.isNotEmpty
                            ? '${_recordedSegments.length} PHÂN ĐOẠN ĐÃ QUAY'
                            : (_isPresetVideo ? 'VIDEO MẪU' : 'VIDEO ĐÃ CHỌN'),
                        style: TextStyle(
                          color: _recordedSegments.isNotEmpty
                              ? const Color(0xFFFF4D30)
                              : Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _videoFileName ?? 'Video nấu ăn đã sẵn sàng',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã gắn kèm bài đăng',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (val) {
              if (val == 'camera') {
                _openCookingCamera();
              } else if (val == 'gallery') {
                _pickVideo(ImageSource.gallery);
              } else if (val == 'remove') {
                setState(() {
                  _videoPath = null;
                  _videoFileName = null;
                  _recordedSegments.clear();
                });
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Iconsax.video, size: 18),
                    SizedBox(width: 8),
                    Text('Quay lại / Sửa clip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'gallery',
                child: Row(
                  children: [
                    Icon(Iconsax.gallery, size: 18),
                    SizedBox(width: 8),
                    Text('Đổi video khác'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Gỡ video', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Nguyên liệu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_ingredients.length} mục',
                      style: const TextStyle(
                        color: Color(0xFFFF4D30),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddIngredientDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D30),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm nguyên liệu', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick ingredient chips
          const Text(
            'Chọn nhanh nguyên liệu phổ biến:',
            style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickIngredients.map((item) {
                final isAdded = _ingredients.any((i) => i.name.toLowerCase().contains(item.toLowerCase()));
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(
                      isAdded ? Icons.check : Icons.add,
                      size: 14,
                      color: isAdded ? const Color(0xFFFF4D30) : Colors.black87,
                    ),
                    label: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAdded ? const Color(0xFFFF4D30) : Colors.black87,
                        fontWeight: isAdded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isAdded ? const Color(0xFFFFECE8) : Colors.grey.shade100,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: () {
                      _showAddIngredientDialog(prefillName: item);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Iconsax.receipt_edit, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có nguyên liệu nào',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhấn "+ Thêm nguyên liệu" hoặc chọn gợi ý bên trên để bổ sung',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _ingredients.removeAt(oldIndex);
                  _ingredients.insert(newIndex, item);
                });
              },
              itemBuilder: (ctx, idx) {
                final item = _ingredients[idx];
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          item.amount,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () => _showAddIngredientDialog(
                          editItem: item,
                          index: idx,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() => _ingredients.removeAt(idx));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Các bước nấu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tùy chọn',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddStepDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4D30),
                  side: const BorderSide(color: Color(0xFFFF4D30)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm bước', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bạn có thể bỏ qua phần này nếu video đã hướng dẫn đầy đủ, hoặc thêm từng bước để người xem dễ thực hiện.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 14),

          if (_steps.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.note_favorite, size: 30, color: Colors.grey.shade400),
                  const SizedBox(height: 6),
                  Text(
                    'Chưa có bước thực hiện nào (Không bắt buộc)',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có thể ấn "Tiếp theo" để hoàn tất bài đăng ngay',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_steps.length, (idx) {
              final step = _steps[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFFFF4D30),
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (step.durationMinutes != null)
                          Text(
                            '~${step.durationMinutes}p',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              _showAddStepDialog(editItem: step, index: idx),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => _steps.removeAt(idx));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    if (step.tip != null && step.tip!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Tip: ${step.tip}',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
