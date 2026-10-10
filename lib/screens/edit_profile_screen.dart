import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'edit_name_screen.dart';
import 'edit_username_screen.dart';
import 'edit_bio_screen.dart';
import 'edit_contact_info_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool initialFocusBio;

  const EditProfileScreen({super.key, this.initialFocusBio = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);

    if (widget.initialFocusBio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateTo(const EditBioScreen());
      });
    }
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final bytes = await pickedFile.readAsBytes();
      final token = AuthService.instance.tokens?.accessToken;

      if (token != null && token.isNotEmpty && !token.startsWith('demo-')) {
        final apiService = ApiService();
        final result = await apiService.uploadAvatar(
          accessToken: token,
          fileBytes: bytes,
          filename: pickedFile.name.isNotEmpty ? pickedFile.name : 'avatar.jpg',
        );

        if (result.isSuccess && result.user?.avatar != null) {
          AuthService.instance.updateUser(avatar: result.user!.avatar);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Đã cập nhật ảnh đại diện thành công!'),
                  ],
                ),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.error ?? 'Không thể tải ảnh lên máy chủ',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      } else {
        // Offline / demo fallback
        AuthService.instance.updateUser(avatar: pickedFile.path);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        String msg = 'Không thể truy cập máy ảnh hoặc thư viện ảnh ($e).';
        if (e.code.contains('access_denied') || e.code.contains('permission')) {
          msg = 'Vui lòng cấp quyền truy cập Camera / Thư viện ảnh trong Cài đặt thiết bị.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(msg)),
              ],
            ),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  void _showAvatarPickerModal() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Thay đổi ảnh đại diện',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Iconsax.camera, color: primaryColor, size: 22),
                ),
                title: const Text(
                  'Chụp ảnh mới',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                onTap: () => _pickAndUploadAvatar(ImageSource.camera),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.gallery, color: Colors.blue, size: 22),
                ),
                title: const Text(
                  'Chọn ảnh từ thư viện',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                onTap: () => _pickAndUploadAvatar(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGender(String? gender) {
    if (gender == 'MALE') return 'Nam ♂';
    if (gender == 'FEMALE') return 'Nữ ♀';
    if (gender == 'OTHER') return 'Khác';
    return 'Chưa thiết lập';
  }

  String _formatDob(String? dob) {
    if (dob == null || dob.isEmpty) return 'Chưa thiết lập';
    try {
      final dt = DateTime.parse(dob);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final user = AuthService.instance.currentUser;

    final displayName = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName
        : 'Chưa đặt tên';

    final username = (user?.username != null && user!.username!.isNotEmpty)
        ? '@${user.username}'
        : (user?.email.isNotEmpty == true
            ? '@${user!.email.split('@').first}'
            : '@username');

    final bio = (user?.bio != null && user!.bio!.trim().isNotEmpty)
        ? user.bio!
        : 'Thêm tiểu sử giới thiệu...';

    final hasBio = user?.bio != null && user!.bio!.trim().isNotEmpty;
    final hasAvatar = user?.avatar != null && user!.avatar!.isNotEmpty;

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
          'Sửa thông tin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Avatar Header Card
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasAvatar
                              ? Image.network(
                                  user.avatar!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange[300]!,
                                          primaryColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.user,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange[300]!,
                                        primaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Iconsax.user,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // Uploading spinner overlay
                      if (_isUploadingAvatar)
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Camera action button badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploadingAvatar ? null : _showAvatarPickerModal,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(
                              Iconsax.camera5,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _isUploadingAvatar ? null : _showAvatarPickerModal,
                    icon: Icon(Iconsax.edit, size: 15, color: primaryColor),
                    label: Text(
                      'Thay đổi ảnh',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SECTION 1: THÔNG TIN CƠ BẢN (Sửa riêng từng trường)
            _buildSectionContainer(
              title: 'Thông tin cơ bản',
              children: [
                _buildRowItem(
                  title: 'Tên',
                  value: displayName,
                  isPlaceholder: user?.fullName == null || user!.fullName.isEmpty,
                  onTap: () => _navigateTo(const EditNameScreen()),
                ),
                _buildDivider(),
                _buildRowItem(
                  title: 'Tên người dùng',
                  value: username,
                  onTap: () => _navigateTo(const EditUsernameScreen()),
                ),
                _buildDivider(),
                _buildRowItem(
                  title: 'Tiểu sử',
                  value: bio,
                  isPlaceholder: !hasBio,
                  maxLines: 2,
                  onTap: () => _navigateTo(const EditBioScreen()),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 2: THÔNG TIN CHI TIẾT & LIÊN HỆ (Sửa chung cụm)
            _buildSectionContainer(
              title: 'Thông tin chi tiết & Liên hệ',
              children: [
                _buildRowItem(
                  title: 'Giới tính',
                  value: _formatGender(user?.gender),
                  onTap: () => _navigateTo(const EditContactInfoScreen()),
                ),
                _buildDivider(),
                _buildRowItem(
                  title: 'Ngày sinh',
                  value: _formatDob(user?.dateOfBirth),
                  onTap: () => _navigateTo(const EditContactInfoScreen()),
                ),
                _buildDivider(),
                _buildRowItem(
                  title: 'Email',
                  value: user?.email ?? 'Chưa thiết lập',
                  badge: 'Đã xác thực',
                  onTap: () => _navigateTo(const EditContactInfoScreen()),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 3: LIÊN KẾT MẠNG XÃ HỘI
            _buildSectionContainer(
              title: 'Mạng xã hội & Khác',
              children: [
                _buildRowItem(
                  title: 'Trang web',
                  value: 'Thêm trang web...',
                  isPlaceholder: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng liên kết trang web đang phát triển!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildRowItem({
    required String title,
    required String value,
    bool isPlaceholder = false,
    String? badge,
    int maxLines = 1,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder ? Colors.grey[400] : Colors.grey[800],
                  fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(Iconsax.arrow_right_3, size: 15, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.12),
    );
  }
}
