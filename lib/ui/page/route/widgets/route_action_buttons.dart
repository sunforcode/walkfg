import 'package:flutter/cupertino.dart';

/// 路线操作按钮组件
class RouteActionButtons extends StatelessWidget {
  /// 查看地图回调
  final VoidCallback? onViewMap;

  /// 规划行程回调
  final VoidCallback? onPlanTrip;

  /// 收藏回调
  final VoidCallback? onFavorite;

  /// 是否已收藏
  final bool isFavorite;

  /// 构造函数
  const RouteActionButtons({
    super.key,
    this.onViewMap,
    this.onPlanTrip,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 查看地图按钮
        _buildActionButton(
          icon: CupertinoIcons.map,
          label: '查看地图',
          onPressed: onViewMap,
        ),

        // 规划行程按钮
        _buildActionButton(
          icon: CupertinoIcons.calendar_badge_plus,
          label: '规划行程',
          onPressed: onPlanTrip,
          isPrimary: true,
        ),

        // 收藏按钮
        _buildActionButton(
          icon: isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          label: isFavorite ? '已收藏' : '收藏',
          onPressed: onFavorite,
          iconColor: isFavorite ? CupertinoColors.systemRed : null,
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isPrimary = false,
    Color? iconColor,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isPrimary
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey5,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: isPrimary
                    ? CupertinoColors.white
                    : iconColor ?? CupertinoColors.activeBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isPrimary
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
