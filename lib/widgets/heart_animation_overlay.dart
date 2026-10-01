import 'dart:math';
import 'package:flutter/material.dart';

class HeartAnimationOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLike;

  const HeartAnimationOverlay({super.key, required this.child, this.onLike});

  @override
  State<HeartAnimationOverlay> createState() => _HeartAnimationOverlayState();
}

class _HeartAnimationOverlayState extends State<HeartAnimationOverlay>
    with TickerProviderStateMixin {
  final List<_HeartAnimationData> _heartAnimations = [];
  final Random _random = Random();
  DateTime? _lastTapTime;

  @override
  void dispose() {
    for (var animation in _heartAnimations) {
      animation.controller.dispose();
    }
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    widget.onLike?.call();

    final now = DateTime.now();
    final isMultipleTap =
        _lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500;
    _lastTapTime = now;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Single tap: straight up, Multiple taps: random rotation
    final rotation = isMultipleTap ? (_random.nextDouble() - 0.5) * 60 : 0.0;

    // Random horizontal curve direction
    final curveDirection = (_random.nextDouble() - 0.5) * 80;

    final heartAnimation = _HeartAnimationData(
      position: details.localPosition,
      rotation: rotation,
      curveDirection: curveDirection,
      controller: controller,
    );

    setState(() {
      _heartAnimations.add(heartAnimation);
    });

    controller.forward().then((_) {
      setState(() {
        _heartAnimations.remove(heartAnimation);
      });
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ..._heartAnimations.map((heartAnim) {
            return AnimatedBuilder(
              animation: heartAnim.controller,
              builder: (context, child) {
                // Scale: grow quickly then maintain
                final scale = Tween<double>(begin: 0.0, end: 1.2)
                    .animate(
                      CurvedAnimation(
                        parent: heartAnim.controller,
                        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
                      ),
                    )
                    .value;

                // Stay in place for ~0.3s (30% of 1s), then move
                final moveProgress = Tween<double>(begin: 0.0, end: 1.0)
                    .animate(
                      CurvedAnimation(
                        parent: heartAnim.controller,
                        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                    )
                    .value;

                // Vertical movement (upward)
                final moveUp = -100.0 * moveProgress;

                // Horizontal curve movement (arc)
                final curveX =
                    heartAnim.curveDirection * sin(moveProgress * pi / 2);

                // Opacity: visible during stay, fade out during movement
                final opacity = Tween<double>(begin: 1.0, end: 0.0)
                    .animate(
                      CurvedAnimation(
                        parent: heartAnim.controller,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                      ),
                    )
                    .value;

                return Positioned(
                  left: heartAnim.position.dx - 50 + curveX,
                  top: heartAnim.position.dy - 50 + moveUp,
                  child: Transform.rotate(
                    angle: heartAnim.rotation * pi / 180,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.favorite,
                          size: 100,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _HeartAnimationData {
  final Offset position;
  final double rotation;
  final double curveDirection;
  final AnimationController controller;

  _HeartAnimationData({
    required this.position,
    required this.rotation,
    required this.curveDirection,
    required this.controller,
  });
}
