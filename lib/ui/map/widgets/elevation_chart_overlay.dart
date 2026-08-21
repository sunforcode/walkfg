import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/widgets/elevation_chart_widget.dart';
import 'package:walk/ui/map/widgets/map_controls_overlay.dart';

/// 海拔图表覆盖层（包含切换按钮和浮动图表面板）
class ElevationChartOverlay {
  /// 构建海拔图表相关组件列表（用于 Stack children）
  static List<Widget> buildElevationChart({
    required List<TrackPointVO> trackPoints,
    required bool showElevationChart,
    required VoidCallback onToggle,
    required VoidCallback onClose,
  }) {
    return [
      Positioned(
        bottom: 16,
        right: 16,
        child: MapControlButton(
          icon: showElevationChart
              ? CupertinoIcons.chart_bar_square_fill
              : CupertinoIcons.chart_bar_square,
          isActive: showElevationChart,
          onPressed: onToggle,
        ),
      ),
      if (showElevationChart)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _FloatingElevationChart(
            trackPoints: trackPoints,
            onClose: onClose,
          ),
        ),
    ];
  }
}

/// 浮动海拔图表面板
class _FloatingElevationChart extends StatelessWidget {
  final List<TrackPointVO> trackPoints;
  final VoidCallback onClose;

  const _FloatingElevationChart({
    required this.trackPoints,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '海拔图表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: onClose,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 18,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          ElevationChartWidget(
            trackPoints: trackPoints,
            config: const ElevationChartConfig(
              height: 120.0,
              showLabels: false,
              enableInteraction: true,
            ),
          ),
        ],
      ),
    );
  }
}
