import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Reusable bouncing wave dots refresh badge
class CustomRefreshBadge extends StatefulWidget {
  final bool isRefreshing;
  final double percentage;
  final Color? primaryColor;
  final AnimationController? animController;

  const CustomRefreshBadge({
    super.key,
    required this.isRefreshing,
    required this.percentage,
    this.primaryColor,
    this.animController,
  });

  @override
  State<CustomRefreshBadge> createState() => _CustomRefreshBadgeState();
}

class _CustomRefreshBadgeState extends State<CustomRefreshBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;

  AnimationController get _effectiveController =>
      widget.animController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.animController == null) {
      _internalController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
      if (widget.isRefreshing) {
        _internalController!.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(CustomRefreshBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animController == null && _internalController != null) {
      if (widget.isRefreshing && !_internalController!.isAnimating) {
        _internalController!.repeat(reverse: true);
      } else if (!widget.isRefreshing && _internalController!.isAnimating) {
        _internalController!.stop();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _effectiveController,
      builder: (context, child) {
        final scale = widget.isRefreshing
            ? (0.95 + 0.1 * _effectiveController.value)
            : widget.percentage;

        return Transform.scale(
          scale: scale.clamp(0.0, 1.1),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (dotIndex) {
                final dotPhase =
                    (_effectiveController.value + (dotIndex * 0.33)) % 1.0;
                final dotOffset = widget.isRefreshing
                    ? (-4.0 * (1 - (dotPhase - 0.5).abs() * 2))
                    : 0.0;

                return Transform.translate(
                  offset: Offset(0, dotOffset),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.isRefreshing
                          ? activeColor
                          : activeColor.withValues(
                              alpha: (widget.percentage * 0.8 + 0.2)
                                  .clamp(0.2, 1.0),
                            ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

/// A drop-in CupertinoSliverRefreshControl that uses the CustomRefreshBadge
/// with 3 jumping wave dots instead of the generic circular spinner.
class CustomSliverRefreshControl extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final Color? primaryColor;

  const CustomSliverRefreshControl({
    super.key,
    required this.onRefresh,
    this.refreshTriggerPullDistance = 75.0,
    this.refreshIndicatorExtent = 60.0,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      onRefresh: onRefresh,
      builder: (
        BuildContext context,
        RefreshIndicatorMode refreshState,
        double pulledExtent,
        double refreshTriggerPullDistance,
        double refreshIndicatorExtent,
      ) {
        final double percentage =
            (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
        final bool isRefreshing =
            refreshState == RefreshIndicatorMode.refresh ||
                refreshState == RefreshIndicatorMode.armed;

        return Center(
          child: CustomRefreshBadge(
            isRefreshing: isRefreshing,
            percentage: percentage,
            primaryColor: primaryColor,
          ),
        );
      },
    );
  }
}
