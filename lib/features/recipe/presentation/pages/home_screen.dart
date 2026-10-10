import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/widgets/heart_animation_overlay.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/comments_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/presentation/pages/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        titleSpacing: 8,
        title: Row(
          children: [
            // Live icon (leftmost)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Iconsax.video_square,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {},
            ),
            // Scrollable tabs in center
            Expanded(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 2.0,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
                labelStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(text: 'Bạn bè'),
                  Tab(text: 'Đã follow'),
                  Tab(text: 'Đề xuất'),
                ],
              ),
            ),
            // Search icon (rightmost)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Iconsax.search_normal_1,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVideoFeed(), _buildVideoFeed(), _buildVideoFeed()],
      ),
    );
  }

  Widget _buildVideoFeed() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return _VideoItem(index: index);
      },
    );
  }
}

class _VideoItem extends StatefulWidget {
  final int index;

  const _VideoItem({required this.index});

  @override
  State<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<_VideoItem> {
  bool _isLiked = false;

  void _handleLike() {
    setState(() {
      _isLiked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeartAnimationOverlay(
      onLike: _handleLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video background (placeholder)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Iconsax.video_play,
                size: 100,
                color: Colors.white.withValues(alpha: 0.3),
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
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),
          // Right side actions
          Positioned(
            right: 12,
            bottom: 20,
            child: Column(
              children: [
                _buildAvatarWithPlus(),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: _isLiked ? Iconsax.heart5 : Iconsax.heart,
                  label: '12.5K',
                  iconColor: _isLiked ? Colors.red : Colors.white,
                  iconSize: 28,
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Iconsax.message_text,
                  label: '432',
                  iconSize: 26,
                  onTap: () {
                    showCommentsBottomSheet(context);
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Iconsax.send_2,
                  label: '89',
                  iconSize: 26,
                ),
                const SizedBox(height: 20),
                _buildActionButton(icon: Iconsax.more, label: '', iconSize: 24),
              ],
            ),
          ),
          // Bottom left info
          Positioned(
            left: 12,
            right: 80,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                const Text(
                  '@chefname',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                const Text(
                  'Delicious pasta recipe 🍝✨ Perfect for dinner!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Music/Sound
                Row(
                  children: [
                    const Icon(Iconsax.music, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Original Sound - Chef Name',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithPlus() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.orange[300],
          ),
          child: const Icon(Iconsax.user, color: Colors.white, size: 24),
        ),
        Positioned(
          bottom: -6,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
    double iconSize = 28,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
