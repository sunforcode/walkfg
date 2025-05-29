import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';

/// 路线操作按钮组件
class RouteActionButtons extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 是否已收藏
  final bool isFavorite;

  /// 规划行程回调
  final VoidCallback? onPlanTrip;

  /// 收藏操作回调
  final VoidCallback? onToggleFavorite;

  /// 地图操作回调
  final VoidCallback? onMapAction;

  /// 构造函数
  const RouteActionButtons({
    super.key,
    required this.route,
    required this.isFavorite,
    this.onPlanTrip,
    this.onToggleFavorite,
    this.onMapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 规划行程按钮
          Expanded(
            child: CupertinoButton.filled(
              onPressed: onPlanTrip,
              child: const Text('规划行程'),
            ),
          ),

          const SizedBox(width: 12),

          // 收藏按钮
          CupertinoButton(
            color: isFavorite
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGrey,
            onPressed: onToggleFavorite,
            child: Icon(
              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            ),
          ),

          const SizedBox(width: 8),

          // 地图按钮
          CupertinoButton(
            color: CupertinoColors.systemBlue,
            onPressed: onMapAction,
            child: const Icon(CupertinoIcons.map),
          ),
        ],
      ),
    );
  }
}
