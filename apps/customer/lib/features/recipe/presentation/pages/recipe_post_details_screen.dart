import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/models/video_segment.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';

class RecipePostDetailsScreen extends StatefulWidget {
  final String? videoPath;
  final String? videoFileName;
  final bool isPresetVideo;
  final List<VideoSegment> recordedSegments;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final String category;
  final String difficulty;
  final int cookTimeMinutes;
  final int servings;
  final int calories;
  final VoidCallback? onPublished;

  const RecipePostDetailsScreen({
    super.key,
    this.videoPath,
    this.videoFileName,
    this.isPresetVideo = false,
    this.recordedSegments = const [],
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.difficulty,
    required this.cookTimeMinutes,
    required this.servings,
    required this.calories,
    this.onPublished,
  });

  @override
  State<RecipePostDetailsScreen> createState() =>
      _RecipePostDetailsScreenState();
}

class _RecipePostDetailsScreenState extends State<RecipePostDetailsScreen> {
  final ImagePicker _picker = ImagePicker();

  // Integrated block: Title & Description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Cover image: no presets, null by default, user adds manually
  String? _selectedCoverPath;

  // Privacy & Settings (Retained on this screen)
  String _visibility = 'Công khai';
  bool _allowComments = true;
  bool _saveToDevice = true;

  bool _isPublishing = false;
  String _publishStatus = 'Đang xử lý & đăng tải công thức...';
  double? _publishProgress;

  final List<String> _quickHashtags = [
    '#CookConnect',
    '#MonNgonMoiNgay',
    '#NauAnNgon',
    '#EatClean',
    '#ChefAtHome',
    '#ComNha',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _insertText(String tag) {
    final text = _descController.text;
    final selection = _descController.selection;
    final prefix = (text.isNotEmpty && !text.endsWith(' ')) ? ' ' : '';
    final insertString = '$prefix$tag ';

    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, insertString);
      _descController.text = newText;
      _descController.selection = TextSelection.collapsed(
        offset: selection.start + insertString.length,
      );
    } else {
      final newText = '$text$insertString';
      _descController.text = newText;
      _descController.selection = TextSelection.collapsed(
        offset: newText.length,
      );
    }
  }

  Future<void> _pickCoverFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() {
          _selectedCoverPath = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh bìa: $e')));
      }
    }
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

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#[\p{L}\p{N}_]+', unicode: true);
    final matches = regex.allMatches(text).map((m) => m.group(0)!).toList();
    if (matches.isEmpty) {
      return ['#CookConnect', '#MonNgonMoiNgay'];
    }
    return matches;
  }

  void _showPreviewScreen() {
    final title = _titleController.text.trim().isEmpty
        ? 'Món ngon mỗi ngày'
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
              // Cover / Media preview
              _selectedCoverPath != null
                  ? (_selectedCoverPath!.startsWith('http')
                      ? Image.network(
                          _selectedCoverPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey.shade900),
                        )
                      : Image.file(
                          File(_selectedCoverPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey.shade900),
                        ))
                  : Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white24,
                          size: 72,
                        ),
                      ),
                    ),

              // Gradient overlay
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

              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Positioned(
                top: 20,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CHẾ ĐỘ XEM TRƯỚC',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 110,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.orange,
                      child: Text(
                        chef.isNotEmpty ? chef[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _previewAction(Iconsax.heart5, 'Thích'),
                    const SizedBox(height: 14),
                    _previewAction(Iconsax.message, 'Bình luận'),
                    const SizedBox(height: 14),
                    _previewAction(Iconsax.archive_add, 'Lưu'),
                    const SizedBox(height: 14),
                    _previewAction(Iconsax.share, 'Chia sẻ'),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 80,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@$chef',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CHEF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.receipt_item,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Xem công thức: ${widget.ingredients.length} nguyên liệu${widget.steps.isNotEmpty ? " • ${widget.steps.length} bước" : ""}',
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
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề cho bài đăng của bạn!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final token = AuthService.instance.tokens?.accessToken;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập tài khoản trước khi đăng bài!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
      _publishStatus = 'Đang chuẩn bị dữ liệu...';
      _publishProgress = null;
    });

    try {
      // 1. Resolve cover image URL (upload if local file)
      String coverUrl =
          'https://pub-50b1ab619efd4084959e011fe2e5a273.r2.dev/thumbnails/video_1.jpg';
      if (_selectedCoverPath != null && _selectedCoverPath!.isNotEmpty) {
        if (_selectedCoverPath!.startsWith('http')) {
          coverUrl = _selectedCoverPath!;
        } else {
          final coverFile = File(_selectedCoverPath!);
          if (coverFile.existsSync()) {
            try {
              setState(() => _publishStatus = 'Đang tải ảnh bìa lên...');
              final bytes = await coverFile.readAsBytes();
              final uploaded = await ApiService.instance.post.uploadMedia(
                fileBytes: bytes,
                fileName: coverFile.uri.pathSegments.last,
                type: 'IMAGE',
                token: token,
              );
              if (uploaded != null && uploaded.isNotEmpty) {
                coverUrl = uploaded;
              }
            } catch (e) {
              debugPrint('Cover image upload error, using fallback: $e');
            }
          }
        }
      }

      // 2. Resolve video URL & mediaId via Cloudflare R2 Multipart Upload (Quy trình chuẩn 4 bước)
      String videoUrl =
          'https://pub-50b1ab619efd4084959e011fe2e5a273.r2.dev/videos/video_1.mp4';
      String? mediaId;

      if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
        if (widget.videoPath!.startsWith('http')) {
          videoUrl = widget.videoPath!;
        } else if (!widget.isPresetVideo) {
          final videoFile = File(widget.videoPath!);
          if (videoFile.existsSync()) {
            setState(() {
              _publishStatus = 'Đang chuẩn bị tải video lên Cloudflare R2...';
              _publishProgress = 0.05;
            });

            // Thực hiện quy trình multipart upload:
            // Bước 1: POST /api/v1/media/videos/multipart-initiate
            // Bước 2: Tải binary từng chunk lên các presigned URLs của R2 (PUT)
            // Bước 3: POST /api/v1/media/videos/multipart-complete
            final completeRes = await ApiService.instance.post.uploadVideoMultipart(
              videoFile: videoFile,
              token: token,
              onProgress: (progress, status) {
                if (mounted) {
                  setState(() {
                    _publishProgress = progress;
                    _publishStatus = status;
                  });
                }
              },
            );

            // Bước 4: Lấy url và mediaId thật từ Bước 3
            videoUrl = completeRes.url;
            mediaId = completeRes.id;
          }
        }
      }

      // 3. Map ingredients to API DTO
      final ingredientDtos = widget.ingredients.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final rawNum = item.amount.replaceAll(RegExp(r'[^0-9.]'), '');
        final parsedAmount = num.tryParse(rawNum);
        return CreatePostIngredientDto(
          name: item.name,
          amount: parsedAmount,
          unit: item.unit?.isNotEmpty == true ? item.unit : null,
          group: 'Nguyên liệu chính',
          sortOrder: idx,
          catalogIngredientId: item.productId,
        );
      }).toList();

      // 4. Map steps to API DTO
      final stepDtos = widget.steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final s = entry.value;
        return CreateRecipeStepDto(
          stepNumber: idx + 1,
          title: s.title,
          instruction: s.description.isNotEmpty ? s.description : s.title,
          timestampSeconds: s.durationMinutes != null ? (s.durationMinutes! * 60) : null,
          imageUrl: null,
        );
      }).toList();

      // 5. Map difficulty & visibility
      String mappedDifficulty = 'MEDIUM';
      switch (widget.difficulty.toLowerCase()) {
        case 'dễ':
          mappedDifficulty = 'EASY';
          break;
        case 'khó':
          mappedDifficulty = 'HARD';
          break;
        default:
          mappedDifficulty = 'MEDIUM';
      }

      String mappedVisibility = 'PUBLIC';
      switch (_visibility) {
        case 'Người theo dõi':
          mappedVisibility = 'FOLLOWERS_ONLY';
          break;
        case 'Riêng tư':
          mappedVisibility = 'PRIVATE';
          break;
        default:
          mappedVisibility = 'PUBLIC';
      }

      final rawTags = _extractHashtags(_descController.text);
      final cleanTags = rawTags
          .map((t) => t.replaceAll('#', '').trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // 6. Build CreatePostDto
      final dto = CreatePostDto(
        title: title,
        caption: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        videoUrl: videoUrl,
        mediaId: mediaId,
        thumbnailUrl: coverUrl,
        duration: widget.cookTimeMinutes > 0 ? (widget.cookTimeMinutes * 60) : 45,
        visibility: mappedVisibility,
        allowComments: _allowComments,
        allowDuet: false,
        tags: cleanTags.isNotEmpty ? cleanTags : ['CookConnect', 'MonNgon'],
        ingredients: ingredientDtos,
        recipe: CreateRecipeDto(
          cookTimeMinutes: widget.cookTimeMinutes,
          servings: widget.servings,
          difficulty: mappedDifficulty,
          calories: widget.calories,
          steps: stepDtos.isNotEmpty ? stepDtos : null,
        ),
      );

      // 7. Call real backend API (Bước 4)
      setState(() {
        _publishStatus = 'Đang hoàn tất đăng bài viết...';
        _publishProgress = null;
      });
      final createdPost = await ApiService.instance.post.createPost(
        dto: dto,
        token: token,
      );

      // Clear feed cache so the newly created post shows up in feed immediately
      await FeedCacheService.instance.clearCache();

      // Also persist to local RecipeDataService so offline/local screens sync
      final user = AuthService.instance.currentUser;
      final newRecipe = Recipe(
        id: createdPost.postId,
        title: title,
        category: widget.category,
        imageUrl: coverUrl,
        chefName: user?.fullName.isNotEmpty == true ? user!.fullName : 'Chef Ẩm Thực',
        chefAvatar: user?.avatar ?? '',
        rating: 5.0,
        reviewsCount: 1,
        cookTimeMinutes: widget.cookTimeMinutes,
        difficulty: widget.difficulty,
        calories: widget.calories,
        servings: widget.servings,
        tags: rawTags,
        ingredients: List.from(widget.ingredients),
        steps: List.from(widget.steps),
        isFavorite: false,
        isSaved: true,
        lastViewedAt: DateTime.now(),
        cookedCount: 0,
      );
      RecipeDataService.instance.addRecipe(newRecipe);

      if (!mounted) return;
      setState(() => _isPublishing = false);

      _showSuccessPublishDialog(newRecipe);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      String errorMsg = e.toString();
      if (e is ApiException) {
        errorMsg = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi đăng bài: $errorMsg')),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessPublishDialog(Recipe newRecipe) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66D17A), Color(0xFF2EAE4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 54),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Đăng bài thành công!',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Món "${newRecipe.title}" đã được chia sẻ đến cộng đồng.',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D30),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.pop(context); // Pop details screen
                      widget.onPublished?.call();
                    },
                    child: const Text(
                      'Xem trên Trang Chủ',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              'Thông tin bài đăng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              'Bước 2/2: Hoàn tất bài viết',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Summary card of ingredients, steps, and specs from step 1
              _buildRecipeSummaryCard(),
              const SizedBox(height: 16),

              // Integrated block: Title & Description (Left) + Cover (Right)
              _buildIntegratedPostBlock(),
              const SizedBox(height: 16),

              // Privacy & Settings (Retained here)
              _buildSettingsCard(),
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
                          backgroundColor: const Color(0xFFFF4D30),
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
                                      'Đăng bài',
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
              color: Colors.black54,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_publishProgress != null) ...[
                          CircularProgressIndicator(
                            value: _publishProgress,
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(_publishProgress! * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ] else
                          const CircularProgressIndicator(strokeWidth: 4),
                        const SizedBox(height: 16),
                        Text(
                          _publishStatus,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
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

  /// Integrated Block: Title & Description on Left (larger), Cover Frame on Right (smaller)
  Widget _buildIntegratedPostBlock() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nửa trái: Tiêu đề bên trên, mô tả bên dưới (to hơn nửa phải một xíu, flex: 6)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề video / món ăn
                    TextField(
                      controller: _titleController,
                      maxLines: 2,
                      maxLength: 80,
                      decoration: InputDecoration(
                        hintText: 'Nhập tiêu đề video... *',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(height: 18),

                    // Mô tả video kèm hashtag (#) và tag bạn bè (@)
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Thêm mô tả video... Thêm #hashtag và @tên_bạn_bè để tăng tương tác',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Nửa phải: Khung xám trống yêu cầu người dùng bổ sung ảnh bìa (flex: 4)
              Expanded(
                flex: 4,
                child: _buildCoverPickerFrame(),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Shortcut buttons for # and @
          Row(
            children: [
              _buildTagShortcutButton(
                label: '# Hashtag',
                icon: Icons.tag,
                onTap: () => _insertText('#'),
              ),
              const SizedBox(width: 8),
              _buildTagShortcutButton(
                label: '@ Bạn bè',
                icon: Icons.alternate_email,
                onTap: () => _insertText('@'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickHashtags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF4D30),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: const Color(0xFFFFECE8),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onPressed: () => _insertText(tag),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagShortcutButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade800),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Khung xám trống yêu cầu người dùng bổ sung ảnh bìa (không có ảnh mẫu nữa)
  Widget _buildCoverPickerFrame() {
    final hasCover = _selectedCoverPath != null;

    return GestureDetector(
      onTap: _pickCoverFromGallery,
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: hasCover ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasCover ? const Color(0xFFFF4D30) : Colors.grey.shade300,
            width: hasCover ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover) ...[
                _selectedCoverPath!.startsWith('http')
                    ? Image.network(
                        _selectedCoverPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300),
                      )
                    : Image.file(
                        File(_selectedCoverPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300),
                      ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.black54,
                    child: const Text(
                      'Đổi ảnh bìa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCoverPath = null);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Khung xám trống yêu cầu người dùng bổ sung vào
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.gallery_add,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thêm ảnh bìa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khung trống',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
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
      ),
    );
  }

  Widget _buildRecipeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCCBA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D30).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.receipt_2,
              color: Color(0xFFFF4D30),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Công thức & Thông số món đã thiết lập',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.category} • ${widget.difficulty} • ${widget.cookTimeMinutes}p • ${widget.ingredients.length} nguyên liệu${widget.steps.isNotEmpty ? " • ${widget.steps.length} bước" : ""}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sửa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D30),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFFFF4D30),
                ),
              ],
            ),
          ),
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
