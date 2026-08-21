import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 段 13：操作按钮 (PRD §3.3.13)
///
/// "规划行程"主按钮（flex:2，渐变背景）+ 收藏按钮 + 地图按钮
class RouteActionButtons extends StatefulWidget {
  final RouteModel route;
  final bool isFavorite;
  final VoidCallback? onPlanTrip;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onMapAction;

  const RouteActionButtons({
    super.key,
    required this.route,
    required this.isFavorite,
    this.onPlanTrip,
    this.onToggleFavorite,
    this.onMapAction,
  });

  @override
  State<RouteActionButtons> createState() => _RouteActionButtonsState();
}

class _RouteActionButtonsState extends State<RouteActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // "规划行程"主按钮 (PRD: flex:2, 渐变背景, 圆角12px, padding 14px)
        Expanded(
          flex: 2,
          child: _PlanTripButton(onTap: widget.onPlanTrip),
        ),

        const SizedBox(width: 10),

        // 收藏按钮 (PRD: 48x48, 圆角12px, 1px浅边框, 心形, 200ms缩放动画)
        _FavoriteButton(
          isFavorite: widget.isFavorite,
          onTap: widget.onToggleFavorite,
        ),

        const SizedBox(width: 10),

        // 地图按钮 (PRD: 同收藏样式, 🗺图标)
        _MapButton(onTap: widget.onMapAction),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  "规划行程"主按钮
// ---------------------------------------------------------------------------

class _PlanTripButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _PlanTripButton({this.onTap});

  @override
  State<_PlanTripButton> createState() => _PlanTripButtonState();
}

class _PlanTripButtonState extends State<_PlanTripButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.gradientCta,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '规划行程',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  收藏按钮 (PRD: 48x48, 圆角12px, 1px浅边框, 心形, 200ms缩放动画)
// ---------------------------------------------------------------------------

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  double _scale = 1.0;

  void _handleTap() {
    // PRD: 200ms 缩放动画 scale 0.9→1.0
    setState(() => _scale = 0.9);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.sheetBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.iconBtnBorder, width: 1),
          ),
          child: Center(
            child: Icon(
              widget.isFavorite
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart,
              color: widget.isFavorite
                  ? const Color(0xFFEF4444)
                  : AppColors.sheetTextSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  地图按钮 (PRD: 同收藏样式, 🗺图标 → 抽屉收至 min)
// ---------------------------------------------------------------------------

class _MapButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _MapButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.sheetBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.iconBtnBorder, width: 1),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.map,
            color: AppColors.sheetTextSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
