import 'package:flutter/cupertino.dart';
import '../../../../theme/theme/app_color_palette.dart';

/// 操作按钮组件
class RouteActionButtonsSection extends StatelessWidget {
  final VoidCallback onViewMap;
  final VoidCallback onPlanTrip;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const RouteActionButtonsSection({
    super.key,
    required this.onViewMap,
    required this.onPlanTrip,
    required this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            CupertinoIcons.map,
            '查看地图',
            AppColorPalette.blueColors[0],
            onViewMap,
          ),
          _buildActionButton(
            CupertinoIcons.calendar_badge_plus,
            '规划行程',
            AppColorPalette.blueColors[2],
            onPlanTrip,
          ),
          _buildActionButton(
            isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            isFavorite ? '已收藏' : '收藏',
            isFavorite
                ? CupertinoColors.systemRed
                : AppColorPalette.blueColors[4],
            onFavorite,
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
