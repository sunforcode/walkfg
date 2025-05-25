import 'package:flutter/cupertino.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 轨迹渲染模式选择器
class TrackRenderModeSelector extends StatelessWidget {
  /// 轨迹渲染模式
  final TrackRenderMode trackRenderMode;

  /// 轨迹渲染模式变更回调
  final ValueChanged<TrackRenderMode>? onTrackRenderModeChanged;

  /// 构造函数
  const TrackRenderModeSelector({
    super.key,
    required this.trackRenderMode,
    this.onTrackRenderModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '轨迹渲染模式',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _buildTrackRenderModeOption(TrackRenderMode.normal, '普通'),
            _buildTrackRenderModeOption(TrackRenderMode.speed, '速度'),
            _buildTrackRenderModeOption(TrackRenderMode.elevation, '海拔'),
            _buildTrackRenderModeOption(TrackRenderMode.gradient, '坡度'),
          ],
        ),
      ),
    );
  }

  /// 构建轨迹渲染模式选项
  Widget _buildTrackRenderModeOption(TrackRenderMode mode, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trackRenderMode == mode
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: trackRenderMode == mode
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: trackRenderMode == mode
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (onTrackRenderModeChanged != null) {
          onTrackRenderModeChanged!(mode);
        }
      },
    );
  }
}
