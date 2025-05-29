import 'package:flutter/cupertino.dart';
import '../../../../model/route/track_model.dart';

/// 轨迹选择器组件（弱化交互版本）
class TrackSelectorWidget extends StatelessWidget {
  /// 可用轨迹列表
  final List<TrackModel> tracks;

  /// 当前选中的轨迹索引
  final int selectedIndex;

  /// 轨迹选择回调
  final Function(int index) onTrackSelected;

  /// 构造函数
  const TrackSelectorWidget({
    super.key,
    required this.tracks,
    required this.selectedIndex,
    required this.onTrackSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前选中轨迹的信息
          _buildCurrentTrackInfo(),

          const SizedBox(height: 8),

          // 更多轨迹选择按钮
          if (tracks.length > 1) _buildMoreTracksButton(context),
        ],
      ),
    );
  }

  /// 构建当前轨迹信息
  Widget _buildCurrentTrackInfo() {
    final currentTrack = tracks[selectedIndex];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 轨迹图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              CupertinoIcons.location,
              size: 18,
              color: CupertinoColors.activeBlue,
            ),
          ),

          const SizedBox(width: 12),

          // 轨迹信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentTrack.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (currentTrack.getFeatureTag() != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getFeatureTagColor(currentTrack)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentTrack.getFeatureTag()!,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getFeatureTagColor(currentTrack),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentTrack.distance.toStringAsFixed(1)}km · ${currentTrack.getDifficultyName()} · ${currentTrack.getEstimatedTimeText()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建更多轨迹按钮
  Widget _buildMoreTracksButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showTrackSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.map,
              size: 14,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 6),
            Text(
              '更多轨迹选择 (${tracks.length})',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              size: 12,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示轨迹选择器
  void _showTrackSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择轨迹'),
        message: const Text('选择不同的轨迹来查看路线信息'),
        actions: tracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          final isSelected = index == selectedIndex;

          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onTrackSelected(index);
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
                      Row(
                        children: [
                          Text(
                            track.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (track.getFeatureTag() != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    _getFeatureTagColor(track).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                track.getFeatureTag()!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getFeatureTagColor(track),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.distance.toStringAsFixed(1)}km · ${track.getDifficultyName()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      if (track.description.isNotEmpty)
                        Text(
                          track.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  /// 获取特色标签颜色
  Color _getFeatureTagColor(TrackModel track) {
    if (track.isRecommended) return CupertinoColors.systemGreen;
    if (track.isChallenge) return CupertinoColors.systemOrange;
    if (track.isSeasonal) return CupertinoColors.systemBlue;
    return CupertinoColors.systemGrey;
  }
}
