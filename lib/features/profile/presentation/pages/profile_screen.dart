import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/settings/presentation/pages/settings_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/login_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_email_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/edit_bio_screen.dart';
import 'package:cookconnect/core/widgets/google_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AuthService.instance.addListener(_onAuthChanged);
    if (AuthService.instance.isLoggedIn) {
      AuthService.instance.fetchUserProfile();
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    _tabController.dispose();
    super.dispose();
  }

  bool get _isLoggedIn => AuthService.instance.isLoggedIn;

  String get _userName {
    final user = AuthService.instance.currentUser;
    if (user != null && user.fullName.isNotEmpty) {
      return user.fullName;
    }
    return 'Chef Linh Đan';
  }

  String get _userHandle {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      if (user.username != null && user.username!.isNotEmpty) {
        return '@${user.username}';
      }
      final nameOrEmail = user.email.isNotEmpty
          ? user.email.split('@').first
          : user.fullName;
      final clean = nameOrEmail
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
          .toLowerCase();
      return clean.isNotEmpty ? '@$clean' : '@chef_cookconnect';
    }
    return '@linhdan_cook';
  }

  int get _videoCount => AuthService.instance.currentUser?.videoCount ?? 0;
  int get _followerCount =>
      AuthService.instance.currentUser?.followerCount ?? 0;
  int get _likeCount => AuthService.instance.currentUser?.likeCount ?? 0;

  void _showSocialUnderDevelopment([String? provider]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.info_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tính năng đang phát triển',
                style: TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    AuthService.instance.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.info_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã đăng xuất khỏi tài khoản.'),
          ],
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToEditProfileScreen({bool initialFocusBio = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfileScreen(initialFocusBio: initialFocusBio),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from right
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToEditBioScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditBioScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Slide up from bottom
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(
          isLoggedIn: _isLoggedIn,
          onLoginRequested: () => _navigateToLoginScreen(),
          onLogoutRequested: () => _logout(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from right
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _navigateToLoginScreen({bool initialSignUp = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => initialSignUp
            ? const RegisterEmailScreen()
            : const LoginScreen(initialSignUp: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Slide up from bottom
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.key, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              'Quên mật khẩu?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập Email hoặc Số điện thoại bạn đã đăng ký để nhận liên kết đặt lại mật khẩu.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetCtrl,
              decoration: InputDecoration(
                hintText: 'Email hoặc SĐT...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.sms, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
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
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hướng dẫn khôi phục mật khẩu đã được gửi đi!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  void _showAuthBottomSheet({String? message}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAuthBottomSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: _isLoggedIn
            ? IconButton(
                icon: const Icon(Iconsax.edit_2, color: Colors.black87),
                tooltip: 'Sửa thông tin',
                onPressed: () => _navigateToEditProfileScreen(),
              )
            : null,
        title: _isLoggedIn
            ? null
            : const Text(
                'Cá nhân',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2, color: Colors.black87),
            tooltip: 'Cài đặt',
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: const Icon(Iconsax.share, color: Colors.black87),
            tooltip: 'Chia sẻ',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép liên kết ứng dụng CookConnect!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoggedIn ? _buildLoggedInView() : _buildGuestView(),
    );
  }

  // ==========================================
  // UN-AUTHENTICATED (GUEST) VIEW
  // ==========================================
  Widget _buildGuestView() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. Guest Hero Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.85),
                  const Color(0xFFFF8C42),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.user,
                          size: 52,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD166),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.star1,
                        size: 16,
                        color: Color(0xFF7A4F01),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Tham gia CookConnect',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập để lưu công thức nấu ăn, theo dõi các đầu bếp yêu thích và chia sẻ những món ngon của riêng bạn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 22),
                // Main Auth Call-To-Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showAuthBottomSheet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.login, size: 20),
                        SizedBox(width: 8),
                        Text('Đăng nhập / Đăng ký ngay'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Member Benefits Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Iconsax.magic_star, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Đặc quyền khi có tài khoản',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Iconsax.bookmark_2,
                        iconColor: const Color(0xFFE76F51),
                        bgColor: const Color(0xFFFEE8E1),
                        title: 'Lưu công thức',
                        subtitle: 'Bộ sưu tập riêng không giới hạn',
                        onTap: () => _showAuthBottomSheet(
                          message: 'Đăng nhập để lưu trữ công thức món ngon!',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Iconsax.heart,
                        iconColor: const Color(0xFFE63946),
                        bgColor: const Color(0xFFFFE5E7),
                        title: 'Yêu thích & Thả tim',
                        subtitle: 'Tương tác cùng cộng đồng',
                        onTap: () => _showAuthBottomSheet(
                          message: 'Đăng nhập để bày tỏ yêu thích với món ăn!',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Iconsax.video_add,
                        iconColor: const Color(0xFF2A9D8F),
                        bgColor: const Color(0xFFE2F4F2),
                        title: 'Đăng tải video',
                        subtitle: 'Chia sẻ bí quyết nấu ăn độc quyền',
                        onTap: () => _showAuthBottomSheet(
                          message: 'Đăng nhập để đăng video công thức của bạn!',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Iconsax.people,
                        iconColor: const Color(0xFF457B9D),
                        bgColor: const Color(0xFFE3EDF4),
                        title: 'Theo dõi đầu bếp',
                        subtitle: 'Cập nhật công thức mới mỗi ngày',
                        onTap: () => _showAuthBottomSheet(
                          message:
                              'Đăng nhập để theo dõi các đầu bếp yêu thích!',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. User Activity Section (Requires Login)
          _buildMenuSection(
            title: 'Tài khoản & Hoạt động',
            children: [
              _buildModernMenuItem(
                icon: Iconsax.bookmark,
                title: 'Món ăn đã lưu',
                badgeText: 'Cần đăng nhập',
                trailingIcon: Iconsax.lock,
                onTap: () => _showAuthBottomSheet(
                  message: 'Đăng nhập để xem danh sách món đã lưu',
                ),
              ),
              _buildModernMenuItem(
                icon: Iconsax.heart,
                title: 'Video đã thích',
                badgeText: 'Cần đăng nhập',
                trailingIcon: Iconsax.lock,
                onTap: () => _showAuthBottomSheet(
                  message: 'Đăng nhập để xem các video bạn đã thích',
                ),
              ),
              _buildModernMenuItem(
                icon: Iconsax.clock,
                title: 'Lịch sử xem gần đây',
                subtitle: 'Xem lại các công thức đã lướt qua',
                onTap: () => _showAuthBottomSheet(
                  message: 'Đăng nhập để đồng bộ lịch sử xem trên các thiết bị',
                ),
              ),
              _buildModernMenuItem(
                icon: Iconsax.setting_2,
                title: 'Cài đặt & Quyền riêng tư',
                subtitle: 'Ngôn ngữ, thông báo, FAQ, bộ nhớ đệm',
                onTap: _navigateToSettings,
              ),
            ],
          ),

          const SizedBox(height: 32),
          // Footer watermark
          Center(
            child: Column(
              children: [
                Text(
                  'CookConnect - Nền tảng chia sẻ đam mê ẩm thực',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phiên bản 1.0.0 (Build 100)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================
  // AUTHENTICATED VIEW (LOGGED IN)
  // ==========================================
  Widget _buildLoggedInView() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final user = AuthService.instance.currentUser;
    final userBio = user?.bio;
    final hasBio = userBio != null && userBio.trim().isNotEmpty;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        await AuthService.instance.fetchUserProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
        children: [
          // Header User Profile Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: [Name + Handle on the Left] and [Avatar on the Right]
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Tên người dùng to ra + @username + Gender badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _userHandle,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (user?.gender != null &&
                                  user!.gender!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user.gender == 'MALE'
                                        ? 'Nam ♂'
                                        : (user.gender == 'FEMALE'
                                              ? 'Nữ ♀'
                                              : 'Khác'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Social stats directly below Username (no box, no following)
                          Row(
                            children: [
                              _buildInlineStatItem('$_videoCount', 'Món ăn'),
                              const SizedBox(width: 22),
                              _buildInlineStatItem(
                                _followerCount >= 1000
                                    ? '${(_followerCount / 1000).toStringAsFixed(1)}K'
                                    : '$_followerCount',
                                'Follower',
                              ),
                              const SizedBox(width: 22),
                              _buildInlineStatItem(
                                _likeCount >= 1000
                                    ? '${(_likeCount / 1000).toStringAsFixed(1)}K'
                                    : '$_likeCount',
                                'Thích',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 22),
                    // Right Side: Avatar with verified badge
                    Stack(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (user?.avatar != null && user!.avatar!.isNotEmpty)
                                ? Image.network(
                                    user.avatar!,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.orange[300]!, primaryColor],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Iconsax.user,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.orange[300]!, primaryColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.user,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Iconsax.verify5,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),



                const SizedBox(height: 14),

                // Bio Section: Custom "+ Thêm tiểu sử" button if empty, otherwise display text
                if (!hasBio)
                  InkWell(
                    onTap: _navigateToEditBioScreen,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.add, size: 13, color: primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Thêm tiểu sử',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _navigateToEditBioScreen,
                    child: Text(
                      userBio,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tabs for Created, Liked, Saved
          Container(
            color: Colors.white,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                enableFeedback: false,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey[500],
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(icon: Icon(Iconsax.video_play, size: 16)),
                Tab(icon: Icon(Iconsax.heart, size: 16)),
                Tab(icon: Icon(Iconsax.bookmark, size: 16)),
              ],
            ),
            ),
          ),

          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoGridTab(),
                _buildLikedGridTab(),
                _buildSavedGridTab(),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInlineStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGridTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange[(index + 1) * 100 % 400 + 200]!,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Center(
                  child: Icon(
                    Iconsax.video_play,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Row(
                    children: [
                      const Icon(Iconsax.play, size: 12, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        '${(index + 1) * 320}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
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

  Widget _buildLikedGridTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.heart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Các video đã thích',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chỉ bạn mới có thể nhìn thấy mục này',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedGridTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.bookmark, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Chưa có công thức nào được lưu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn biểu tượng lưu trên video để xem lại tại đây',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildBenefitCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? valueText,
    String? badgeText,
    IconData trailingIcon = Iconsax.arrow_right_3,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (valueText != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (trailingWidget != null)
              trailingWidget
            else
              Icon(trailingIcon, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // AUTH MODAL BOTTOM SHEET
  // ==========================================
  Widget _buildAuthBottomSheet({String? message}) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Logo / Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.profile_circle5, size: 36, color: primaryColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đăng nhập vào CookConnect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ??
                'Tham gia cộng đồng để chia sẻ niềm đam mê nấu ăn và lưu giữ những món ngon mỗi ngày.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // SĐT / Email / Username Option (Primary)
          _buildAuthOptionButton(
            leading: Icon(
              Icons.phone_android_rounded,
              size: 22,
              color: primaryColor,
            ),
            title: 'Sử dụng SĐT / Email / Username',
            onTap: () {
              Navigator.pop(context);
              _navigateToLoginScreen();
            },
          ),
          const SizedBox(height: 10),

          // Google Login Button with authentic 4-color Google logo
          _buildAuthOptionButton(
            leading: const GoogleLogoWidget(size: 22),
            title: 'Tiếp tục với Google',
            onTap: () {
              Navigator.pop(context);
              _showSocialUnderDevelopment('Google');
            },
          ),
          const SizedBox(height: 10),

          // Apple Login Button
          _buildAuthOptionButton(
            leading: const Icon(
              FlutterRemix.apple_fill,
              size: 22,
              color: Colors.black,
            ),
            title: 'Tiếp tục với Apple',
            onTap: () {
              Navigator.pop(context);
              _showSocialUnderDevelopment('Apple');
            },
          ),

          const SizedBox(height: 16),

          // Row for "Quên mật khẩu?" (left) and "Đăng ký tài khoản" (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showForgotPasswordDialog();
                },
                icon: Icon(Iconsax.key, size: 16, color: Colors.grey[600]),
                label: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToLoginScreen(initialSignUp: true);
                },
                icon: Icon(Iconsax.user_add, size: 16, color: primaryColor),
                label: Text(
                  'Đăng ký tài khoản',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Bằng việc tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách quyền riêng tư của CookConnect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOptionButton({
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
