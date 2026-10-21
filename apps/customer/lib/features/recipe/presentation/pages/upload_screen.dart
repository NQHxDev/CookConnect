import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';

class UploadScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onPublished;

  const UploadScreen({super.key, this.onCancel, this.onPublished});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Selected media info
  String? _videoPath;
  String? _videoFileName;
  String? _selectedCoverUrl;
  bool _isPresetVideo = false;

  // Recipe basic fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(
    text: '25',
  );
  final TextEditingController _caloriesController = TextEditingController(
    text: '450',
  );
  final TextEditingController _servingsController = TextEditingController(
    text: '2',
  );

  // Categories & metadata
  String _selectedCategory = 'Món chính';
  String _selectedDifficulty = 'Trung bình';
  String _selectedSoundtrack = 'Âm thanh gốc - Nấu nướng chill chill';
  String _visibility = 'Công khai';
  bool _allowComments = true;
  bool _saveToDevice = true;

  // Tags
  final List<String> _tags = ['#CookConnect', '#MonNgonMoiNgay'];
  final TextEditingController _tagInputController = TextEditingController();

  // Ingredients
  final List<Ingredient> _ingredients = [
    Ingredient(id: '1', name: 'Thịt bò hoặc sườn heo', amount: '300g'),
    Ingredient(id: '2', name: 'Hành tím & tỏi băm nhuyễn', amount: '2 củ'),
    Ingredient(
      id: '3',
      name: 'Gia vị: Nước mắm, tiêu, dầu hào',
      amount: 'Vừa đủ',
    ),
  ];

  // Steps
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

  final List<String> _presetThumbnails = [
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&auto=format&fit=crop&q=80',
  ];

  final List<String> _presetSounds = [
    'Âm thanh gốc - Nấu nướng chill chill',
    'Lofi Cooking Beats - ASMR kitchen sounds',
    'Acoustic Guitar - Peaceful morning breakfast',
    'Nhịp điệu phố thị - Nấu nhanh sau giờ tan tầm',
  ];

  final List<String> _suggestedTags = [
    '#NauAnNgon',
    '#BuaComGiaDinh',
    '#EatCleanVietNam',
    '#FoodReview',
    '#ChefAtHome',
    '#MonNgonDeLam',
  ];

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _selectedCoverUrl = _presetThumbnails.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _caloriesController.dispose();
    _servingsController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  double _calculateCompleteness() {
    double score = 0.0;
    if (_videoPath != null) score += 0.25;
    if (_titleController.text.trim().isNotEmpty) score += 0.2;
    if (_descController.text.trim().isNotEmpty) score += 0.15;
    if (_ingredients.isNotEmpty) score += 0.2;
    if (_steps.isNotEmpty) score += 0.2;
    return score.clamp(0.0, 1.0);
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
      _videoFileName = 'demo_chef_cooking.mp4 (Mẫu thử nghiệm)';
      _isPresetVideo = true;
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

  void _addCustomTag(String tag) {
    var formatted = tag.trim();
    if (formatted.isEmpty) return;
    if (!formatted.startsWith('#')) formatted = '#$formatted';
    if (!_tags.contains(formatted)) {
      setState(() {
        _tags.add(formatted);
        _tagInputController.clear();
      });
    }
  }

  void _showAddIngredientDialog({Ingredient? editItem, int? index}) {
    final nameCtrl = TextEditingController(text: editItem?.name ?? '');
    final amountCtrl = TextEditingController(text: editItem?.amount ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          editItem == null ? 'Thêm nguyên liệu' : 'Chỉnh sửa nguyên liệu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Tên nguyên liệu',
                hintText: 'VD: Thịt ba chỉ, Nước cốt dừa...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(
                labelText: 'Định lượng',
                hintText: 'VD: 300g, 2 muỗng canh...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
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
              ? 'Thêm bước chế biến'
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
                  labelText: 'Tiêu đề bước',
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
                  labelText: 'Chi tiết thực hiện',
                  hintText:
                      'Mô tả cụ thể cách thao tác, nhiệt độ, màu sắc món...',
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
                  labelText: 'Bí quyết đầu bếp (Tip nhỏ tuỳ chọn)',
                  hintText: 'VD: Đảo lửa to để không ra nước',
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
                  labelText: 'Thời gian ước tính (phút)',
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
              backgroundColor: Theme.of(context).colorScheme.primary,
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
                final tip = tipCtrl.text.trim().isEmpty
                    ? null
                    : tipCtrl.text.trim();
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

  void _showSoundtrackPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Iconsax.music_dashboard, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Chọn nhạc nền video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ..._presetSounds.map((sound) {
                final isSelected = sound == _selectedSoundtrack;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Colors.orange.shade100
                        : Colors.grey.shade100,
                    child: Icon(
                      Iconsax.music,
                      color: isSelected ? Colors.orange : Colors.grey.shade700,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    sound,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.orange.shade900
                          : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.orange)
                      : const Icon(Iconsax.play, size: 20, color: Colors.grey),
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

  void _showPreviewScreen() {
    final title = _titleController.text.trim().isEmpty
        ? 'Công thức nấu ăn tuyệt phẩm'
        : _titleController.text.trim();
    final desc = _descController.text.trim();
    final chef =
        AuthService.instance.currentUser?.fullName ?? 'Bếp Trưởng CookConnect';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.92,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media preview
              _selectedCoverUrl != null
                  ? Image.network(
                      _selectedCoverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey.shade900),
                    )
                  : Container(color: Colors.grey.shade900),
              // Dark gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // Top preview bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Chế độ xem trước Feed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              ),
              // Right interactions mock
              Positioned(
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: const Icon(Iconsax.user, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _previewAction(Iconsax.heart5, '0'),
                    const SizedBox(height: 18),
                    _previewAction(Iconsax.message_text, '0'),
                    const SizedBox(height: 18),
                    _previewAction(Iconsax.bookmark, 'Lưu'),
                    const SizedBox(height: 18),
                    _previewAction(Iconsax.send_2, 'Chia sẻ'),
                  ],
                ),
              ),
              // Bottom recipe details overlay
              Positioned(
                left: 16,
                right: 80,
                bottom: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@$chef',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          color: Colors.blueAccent,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _tags
                          .map(
                            (t) => Text(
                              t,
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.music,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedSoundtrack,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.book_1,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Xem công thức: ${_ingredients.length} nguyên liệu • ${_steps.length} bước',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _previewAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  Future<void> _handlePublish() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề cho món ăn của bạn!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng quay hoặc chọn video trước khi đăng tải!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    // Realistic upload pipeline simulation
    await Future.delayed(const Duration(milliseconds: 1200));

    final user = AuthService.instance.currentUser;
    final chefName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Chef Ẩm Thực';
    final chefAvatar = user?.avatar ?? '';

    final newRecipe = Recipe(
      id: 'user_rec_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      imageUrl: _selectedCoverUrl ?? _presetThumbnails.first,
      chefName: chefName,
      chefAvatar: chefAvatar,
      rating: 5.0,
      reviewsCount: 1,
      cookTimeMinutes: int.tryParse(_timeController.text.trim()) ?? 25,
      difficulty: _selectedDifficulty,
      calories: int.tryParse(_caloriesController.text.trim()) ?? 450,
      servings: int.tryParse(_servingsController.text.trim()) ?? 2,
      tags: List.from(_tags),
      ingredients: List.from(_ingredients),
      steps: List.from(_steps),
      isFavorite: false,
      isSaved: true,
      lastViewedAt: DateTime.now(),
      cookedCount: 0,
    );

    RecipeDataService.instance.addRecipe(newRecipe);

    if (!mounted) return;
    setState(() => _isPublishing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đăng tải thành công! 🎉',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Món "${newRecipe.title}" đã được chia sẻ đến cộng đồng CookConnect!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onPublished?.call();
              },
              child: const Text('Xem trên Trang Chủ'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.bookmark, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Đã lưu bài viết vào Bản Nháp thành công!')),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final completeness = _calculateCompleteness();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Đăng Video Nấu Ăn',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              )
            : null,
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text(
              'Lưu nháp',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xem trước bài đăng',
            icon: const Icon(Iconsax.eye, color: Colors.black87),
            onPressed: _showPreviewScreen,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Completeness meter
                _buildCompletenessHeader(completeness),
                const SizedBox(height: 16),

                // Video upload / pick card
                _buildVideoPickerCard(primaryColor),
                const SizedBox(height: 20),

                // Cover photo selection
                _buildCoverSelector(),
                const SizedBox(height: 20),

                // Title & Description & Hashtags
                _buildPostInfoCard(),
                const SizedBox(height: 20),

                // Audio / Sound card
                _buildAudioSelector(),
                const SizedBox(height: 20),

                // Cooking specs (Category, Time, Calories, Difficulty, Servings)
                _buildRecipeSpecsCard(),
                const SizedBox(height: 20),

                // Ingredients manager
                _buildIngredientsCard(),
                const SizedBox(height: 20),

                // Step-by-step instructions
                _buildStepsCard(),
                const SizedBox(height: 20),

                // Privacy & Settings
                _buildSettingsCard(),
                const SizedBox(height: 20),
              ],
            ),
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
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: _showPreviewScreen,
                      icon: const Icon(
                        Iconsax.eye,
                        size: 18,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        'Xem trước',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isPublishing ? null : _handlePublish,
                        child: _isPublishing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.send_1, size: 18),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Đăng Video & Công Thức',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isPublishing)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải video & xử lý công thức...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletenessHeader(double completeness) {
    final percent = (completeness * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(14),
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
                    Icon(
                      percent == 100 ? Icons.check_circle : Iconsax.magic_star,
                      color: percent == 100 ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Độ hoàn thiện công thức',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percent == 100 ? Colors.green : Colors.orange,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: completeness,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent == 100 ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            percent < 100
                ? 'Thêm video, tiêu đề, nguyên liệu và các bước để bài đăng dễ lên xu hướng hơn!'
                : 'Công thức đã hoàn thiện xuất sắc! Sẵn sàng đăng tải.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPickerCard(Color primaryColor) {
    final hasVideo = _videoPath != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: hasVideo
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          _selectedCoverUrl ?? _presetThumbnails.first,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 100,
                                color: Colors.black87,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white54,
                                ),
                              ),
                        ),
                        Container(
                          width: 80,
                          height: 100,
                          color: Colors.black26,
                        ),
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
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
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isPresetVideo ? 'VIDEO MẪU' : 'ĐÃ CHỌN',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _videoFileName ?? 'Video nấu ăn',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Định dạng: MP4 • Chuẩn Full HD',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _pickVideo(ImageSource.gallery),
                              child: Text(
                                'Đổi video',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _videoPath = null;
                                  _videoFileName = null;
                                });
                              },
                              child: Text(
                                'Gỡ video',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.video_add,
                      color: primaryColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tải lên video khoảnh khắc nấu ăn',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hỗ trợ MP4, MOV thời lượng tối đa 5 phút',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _pickVideo(ImageSource.camera),
                        icon: const Icon(Iconsax.camera, size: 16),
                        label: const Text('Quay video'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _pickVideo(ImageSource.gallery),
                        icon: const Icon(Iconsax.gallery, size: 16),
                        label: const Text('Từ thư viện'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _usePresetDemoVideo,
                    icon: const Icon(
                      Iconsax.play_circle,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    label: const Text(
                      'Dùng thử video mẫu nướng áp chảo',
                      style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCoverSelector() {
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
              const Flexible(
                child: Text(
                  'Ảnh bìa món ăn (Thumbnail)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Chọn ảnh bắt mắt nhất',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presetThumbnails.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (ctx, idx) {
                final url = _presetThumbnails[idx];
                final isSelected = url == _selectedCoverUrl;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCoverUrl = url),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfoCard() {
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
          const Text(
            'Thông tin bài đăng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            maxLength: 80,
            decoration: InputDecoration(
              labelText: 'Tiêu đề món ăn *',
              hintText: 'VD: Sườn Xào Chua Ngọt Đậm Đà Chuẩn Vị Mẹ Nấu',
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Iconsax.note_2, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descController,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            maxLength: 250,
            decoration: InputDecoration(
              labelText: 'Mô tả & Câu chuyện món ăn',
              hintText:
                  'Chia sẻ một chút về cảm hứng, hương vị hoặc kỷ niệm gắn liền...',
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Iconsax.edit_2, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hashtags & Chủ đề',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.orange.shade50,
                side: BorderSide(color: Colors.orange.shade200),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputController,
                  decoration: InputDecoration(
                    hintText: 'Nhập hashtag mới (VD: #MonNgon)',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: _addCustomTag,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () => _addCustomTag(_tagInputController.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedTags.map((st) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(st, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.grey.shade100,
                    onPressed: () => _addCustomTag(st),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.music, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhạc nền / Âm thanh video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedSoundtrack,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showSoundtrackPicker,
            child: const Text('Thay đổi'),
          ),
        ],
      ),
    );
  }

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
          const Text(
            'Thông số món ăn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
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

          // Difficulty chips
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (val) {
                    if (val) setState(() => _selectedDifficulty = diff);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Numeric fields in row
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
              Expanded(
                child: Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Nguyên liệu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_ingredients.length} mục',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showAddIngredientDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Chưa có nguyên liệu nào. Nhấn Thêm để bổ sung!',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
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
                    const Flexible(
                      child: Text(
                        'Các bước nấu chi tiết',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_steps.length} bước',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showAddStepDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm bước'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_steps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Chưa có bước thực hiện nào. Hãy hướng dẫn chi tiết nhé!',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
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
                          backgroundColor: Colors.orange,
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

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quyền riêng tư & Cài đặt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Iconsax.security_user, size: 20),
              title: const Text(
                'Ai có thể xem video này?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              trailing: DropdownButton<String>(
                value: _visibility,
                underline: const SizedBox(),
                items: ['Công khai', 'Bạn bè', 'Chỉ mình tôi']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _visibility = val);
                },
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Cho phép bình luận',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Mọi người có thể đóng góp nhận xét',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              value: _allowComments,
              onChanged: (val) => setState(() => _allowComments = val),
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Tự động lưu vào thiết bị',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Lưu bản sao chất lượng cao vào bộ sưu tập',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
              value: _saveToDevice,
              onChanged: (val) => setState(() => _saveToDevice = val),
            ),
          ],
        ),
      ),
    );
  }
}
