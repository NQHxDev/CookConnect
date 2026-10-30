import 'package:flutter/material.dart';

/// Hiệu ứng gói hàng rơi xuống icon "Đi chợ" ở BottomNavBar.
class FlyToCartAnimation {
  FlyToCartAnimation._();

  /// Gắn key này vào icon giỏ hàng trên BottomNavBar.
  static final GlobalKey cartIconKey = GlobalKey(debugLabel: 'cartNavIcon');

  static Offset? _centerOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  static void run(BuildContext sourceContext) {
    final start = _centerOf(sourceContext);
    final cartContext = cartIconKey.currentContext;
    final end = cartContext == null ? null : _centerOf(cartContext);
    final overlay = Overlay.maybeOf(sourceContext, rootOverlay: true);
    if (start == null || end == null || overlay == null) return;

    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 750),
    );
    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInCubic,
    );
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: curve,
        builder: (_, __) {
          final t = curve.value;
          // Bay lên nhẹ rồi rơi xuống vị trí icon.
          final lift = -70 * (1 - (2 * t - 1) * (2 * t - 1)) * (1 - t);
          final dx = start.dx + (end.dx - start.dx) * t;
          final dy = start.dy + (end.dy - start.dy) * t + lift;
          final scale = 1.0 - 0.55 * t;
          return Positioned(
            left: dx - 18,
            top: dy - 18,
            child: IgnorePointer(
              child: Opacity(
                opacity: t > 0.9 ? (1 - t) * 10 : 1,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      entry.dispose();
      curve.dispose();
      controller.dispose();
    });
  }
}
