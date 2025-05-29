import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/track_model.dart';
import 'route_map_placeholder_widget.dart';

/// 悬浮地图组件
class FloatingMapWidget extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 轨迹点列表
  final List<TrackPointVO> trackPoints;

  /// 路标点列表
  final List<TrackPointVO> waypoints;

  /// 可用轨迹列表
  final List<TrackModel> availableTracks;

  /// 当前选中的轨迹索引
  final int selectedTrackIndex;

  /// 是否显示海拔剖面图
  final bool showElevationProfile;

  /// 地图点击回调
  final VoidCallback? onMapTap;

  /// 关闭悬浮地图回调
  final VoidCallback? onClose;

  /// 切换海拔剖面图回调
  final VoidCallback? onToggleElevationProfile;

  /// 轨迹选择回调
  final Function(int index)? onTrackSelection;

  /// 构造函数
  const FloatingMapWidget({
    super.key,
    required this.route,
    required this.trackPoints,
    required this.waypoints,
    required this.availableTracks,
    required this.selectedTrackIndex,
    required this.showElevationProfile,
    this.onMapTap,
    this.onClose,
    this.onToggleElevationProfile,
    this.onTrackSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 地图
            RouteMapPlaceholderWidget(
              route: route,
              trackPoints: trackPoints,
              waypoints: waypoints,
              height: 300,
              onMapTap: onMapTap,
            ),

            // 右下角功能按钮
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildMapFunctionButtons(context),
            ),

            // 关闭按钮 - 左上角
            Positioned(
              top: 16,
              left: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地图功能按钮
  Widget _buildMapFunctionButtons(BuildContext context) {
    return Column(
      children: [
        // 查看海拔图按钮
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggleElevationProfile,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.chart_bar,
              size: 20,
              color: showElevationProfile
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.white,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 切换轨迹按钮
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showTrackSelector(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoColors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.map,
              size: 20,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 显示轨迹选择器
  void _showTrackSelector(BuildContext context) {
    if (availableTracks.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择轨迹'),
        message: const Text('选择不同的轨迹来查看路线信息'),
        actions: availableTracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          final isSelected = index == selectedTrackIndex;

          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onTrackSelection?.call(index);
            },
            child: Row(
              children: [
                // 选中状态指示器
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          size: 12,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // 轨迹信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        '${track.distance.toStringAsFixed(1)}km · ${track.getDifficultyName()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }
}