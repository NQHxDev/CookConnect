import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditBioScreen extends StatefulWidget {
  const EditBioScreen({super.key});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late TextEditingController _bioController;
  late String _initialBio;
  bool _isLoading = false;
  final int _maxLength = 150;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _initialBio = user?.bio ?? '';
    _bioController = TextEditingController(text: _initialBio);
    _bioController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  bool get _hasChanged => _bioController.text.trim() != _initialBio.trim();

  Future<void> _saveBio() async {
    if (!_hasChanged) return;

    final bioText = _bioController.text.trim();
    setState(() => _isLoading = true);

    final token = AuthService.instance.tokens?.accessToken;
    final userId = AuthService.instance.currentUser?.id;

    if (token != null && token.isNotEmpty) {
      final apiService = ApiService();
      await apiService.updateUserProfile(
        accessToken: token,
        userId: userId,
        bio: bioText,
      );
    }

    // Update local session
    AuthService.instance.updateUser(bio: bioText);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.tick_circle5, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              bioText.isEmpty
                  ? 'Đã xoá tiểu sử cá nhân'
                  : 'Đã cập nhật tiểu sử thành công!',
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentLength = _bioController.text.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tiểu sử cá nhân',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: (_isLoading || !_hasChanged) ? null : _saveBio,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                disabledForegroundColor: Colors.grey[400],
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giới thiệu bản thân',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chia sẻ về niềm đam mê nấu nướng, các món ăn bạn thích hoặc phong cách ẩm thực đặc trưng của bạn.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _bioController,
                    maxLines: 5,
                    maxLength: _maxLength,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Tài khoản của tôi làm về chủ đề...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_bioController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _bioController.clear();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.trash,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Xoá nội dung',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        '$currentLength/$_maxLength',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: currentLength >= _maxLength
                              ? Colors.red
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quick ideas suggestions
            const Text(
              'Gợi ý phong cách',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBioSuggestion('🥗 Eat Clean & Healthy'),
                _buildBioSuggestion('🍰 Bánh ngọt & Tráng miệng'),
                _buildBioSuggestion('🇻🇳 Món ngon Việt Nam'),
                _buildBioSuggestion('⚡ Bữa ăn nhanh 15 phút'),
                _buildBioSuggestion('🍲 Bếp gia đình ấm cúng'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSuggestion(String text) {
    return InkWell(
      onTap: () {
        final current = _bioController.text.trim();
        if (current.isEmpty) {
          _bioController.text = text;
        } else if (!current.contains(text)) {
          _bioController.text = '$current | $text';
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
